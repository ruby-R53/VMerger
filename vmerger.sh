#!/bin/bash

# - VMerger v1.0a -
# a tool for labeling and merging videos
# together using FFmpeg.
# Written by ruby R53 on August 2025.

error() {
	tput setaf 1; tput bold
	echo -n "ERROR"
	tput setaf 7
	echo -n ": "
	tput sgr0
	echo $1

	exit 1
}

[[ -z $1 ]] &&
	error "a file must be supplied!"

# make ffmpeg a lil' quiet so that we don't
# pollute our screen with so much info
LOGLVL="warning"
# amount of threads to use on every render,
# let's just use all of them by default :)
THREADS="$(nproc)"
# default text parameters:
# Noto Sans Bold as font, white, size 48 px,
# located at the bottom center of the screen
# change this to your liking
TEXT_PARAMS=("drawtext='fontfile=Noto Sans\\:style=Bold':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=h-th-10")
# miscellaneous render arguments
RENDER_ARGS=(-c:v libx264 -c:a copy -crf 0 -qp 0 \
	-preset ultrafast -color_range 1 -colorspace bt709 \
	-color_trc bt709 -color_primaries bt709 -movflags faststart)
# this is where our actual text parameters
# will be placed, in case we wanna use
# another video filter option
VIDEO_FLTRS=(scale=out_color_matrix=bt709,"${TEXT_PARAMS[@]}")

# check if any captions are present and apply them
# get how many files we have to work on
ENTRIES=("$(sed '$ d' $1 | awk -F"=" '{ print $1 }' | tr '\n' ' ')")
# and our output file name
OUTFILE=$(awk -e 'END { print }' -F"=" -e '{ print $1 }' $1)

for FILE in ${ENTRIES[@]}; do
	# get label for current video
	LABEL="$(grep "${FILE}" $1 | awk -F"=" '{ print $2 }')"

	# skip this file if there's no label for it
	[[ -z "${LABEL}" ]] && continue

	# create a separate directory for those
	[[ ! -d "$(pwd)/vmerger" ]] && mkdir "$(pwd)/vmerger"

	# skip entry if it already exists
	[[ -r "vmerger/"${FILE}"" ]] && continue

	# show the user which file we're at, in case ffmpeg doesn't
	# already do that
	if [[ ${LOGLVL} = "warning" ]] || [[ ${LOGLVL} = "quiet" ]]; then
		tput bold
		echo "Labeling ${FILE}..."
		tput sgr0
	fi

	# then, actually apply the label to the current video
	ffmpeg -v "${LOGLVL}" -threads "${THREADS}" -i "${FILE}"\
		"${RENDER_ARGS[@]}" -vf "${VIDEO_FLTRS[@]}":text="${LABEL}" \
		vmerger/"${FILE}"

	# exit on failure and delete that directory if it's
	# empty
	[[ $? != '0' ]] && rmdir "vmerger/" && exit 1
done

MERGETYPE="$(awk -e 'END { print }' -F"=" -e '{ print $2 }' $1)"
case $MERGETYPE in
	"filter" | "f")
		# feed files to ffmpeg's input
		for FILE in ${ENTRIES[@]}; do
			# check if the user wants to merge labeled
			# or unlabeled videos
			if [[ -d "$(pwd)/vmerger" ]] &&
				# also make sure we're pointing to a
				# labeled video file
				[[ ! -z "$(grep "$FILE" $1 | awk -F"=" '{ print $2 }')" ]]
			then
				FILES+=(-i "vmerger/"${FILE}"")
			else
				FILES+=(-i "${FILE}")
			fi
		done

		# tell ffmpeg about the streams we have
		NSTREAMS=$(sed '$ d' $1 | wc -l)
		for (( i = 0; i <= $(( NSTREAMS - 1 )); i++ )); do
			STREAMS+="[${i}:v][${i}:a]"
		done

		MERGEOPTS=(-crf 0 -qp 0 -preset ultrafast -c:a pcm_f32le \
			-filter_complex "${STREAMS}"concat=n="${NSTREAMS}":v=1:a=1)
		;;
	
	"muxer" | "m")
		if [[ ! -r "/tmp/$1.vmr" ]]; then
			# generate a text file to feed to FFmpeg's concat demuxer,
			# kinda translating the original file to a format it
			# understands
			for FILE in ${ENTRIES[@]}; do
				# if we got a captioned video file, add the prefix
				if [[ ! -z "$(grep "$FILE" $1 | awk -F"=" '{ print $2 }')" ]]
				then
					echo "file "$(pwd)"/vmerger/"${FILE}"" >> /tmp/$1.vmr
				else
					echo "file "${FILE}"" >> /tmp/$1.vmr
				fi
			done
		fi

		MERGEOPTS=(-f concat -i /tmp/$1.vmr -c copy)
		;;

	*)
		error "invalid concatenation method! \
			\nValid ones are: (f)ilter, (m)uxer."
		;;
esac

# now that we're prepared, actually fire it up
# and make it merge all the videos we've got
ffmpeg -v "${LOGLVL}" -threads "${THREADS}" \
	"${FILES[@]}" "${MERGEOPTS[@]}" "${OUTFILE}"
	# and finally use last file entry as our output file name
