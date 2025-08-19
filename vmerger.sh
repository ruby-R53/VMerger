#!/bin/bash

# - VMerger v1.0a -
# a tool for labeling and merging videos
# together using FFmpeg.
# Written by ruby R53 on August 2025.

#set -x # for debugging
set -u # increase safety by aborting on unset variable access

# make ffmpeg a lil' quiet so that we don't
# pollute our screen with so much info
LOGLVL="warning"
# amount of threads to use on every render
THREADS="$(nproc)"
# text parameters, change this for your
# labels
TEXT_PARAMS=("drawtext='fontfile=Noto Sans\\:style=Bold':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=h-th-10")
# miscellaneous render arguments
RENDER_ARGS=(-c:v libx264 -c:a copy -crf 0 -qp 0 -preset ultrafast -color_range 1 -colorspace bt709 -color_trc bt709 -color_primaries bt709 -movflags faststart)
# this is where our actual text parameters
# will be placed, in case we wanna use
# another video filter option
VIDEO_FLTRS=(scale=out_color_matrix=bt709,"${TEXT_PARAMS[@]}")

# get how many files we have to work on
ENTRIES=("$(sed '$ d' $1 | awk -F"=" '{ print $1 }' | tr '\n' ' ')")
# and our output file name
OUTFILE=$(awk 'END { print }' $1)

# check if any captions are present and apply them
#for (( i = 1; i <= ${ENTRIES}; i++ )); do
for FILE in ${ENTRIES[@]}; do
	# get label for current video
	LABEL="$(grep "$FILE" $1 | awk -F"=" '{ print $2 }')"

	# skip this file if there's no label for it
	[[ -z ${LABEL} ]] && continue

	# create a separate directory for those
	[[ ! -d "$(pwd)/vmerger" ]] && mkdir "$(pwd)/vmerger"

	# skip entry if it already exists
	[[ -r "vmerger/"${FILE}"" ]] && continue

	# then, actually apply the label to the current video
	ffmpeg -v "${LOGLVL}" -threads "${THREADS}" -i "${FILE}"\
		"${RENDER_ARGS[@]}" -vf "${VIDEO_FLTRS[@]}":text="${LABEL}" \
		vmerger/"${FILE}"

	# exit on failure and delete that directory if it's
	# empty
	[[ $? != '0' ]] && rmdir "vmerger/" && exit 1
done

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

# now that we're prepared, actually fire it up
# and make it merge all the videos we've got
ffmpeg -v "${LOGLVL}" -threads "${THREADS}" "${FILES[@]}" \
	-crf 0 -qp 0 -preset ultrafast -c:a pcm_f32le \
	-filter_complex "${STREAMS}"concat=n="${NSTREAMS}":v=1:a=1 \
	"${OUTFILE}"
	# and finally use last file entry as our output file name
