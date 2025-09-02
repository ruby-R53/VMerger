# VMerger
This is a tool for labeling videos and merging them into one with FFmpeg,
written in Bash.

## "How's that work?"
You supply a text file containing each video you want to work with, plus the
file name of the resulting video, which you then have to append a `=` to
specify whether you want the videos to be merged with the (m)uxer method or
the (f)ilter one:
```
[funnycompilation.txt]
intro.mp4
01_cat_falling.mp4
transition.mp4
02_sneeze.mp4
transition.mp4
03_workaccident.mp4
outro.mp4
WeeklyFunnyVideosCompilation.mp4=f
```
The script then feeds that to FFmpeg, which will then merge all these videos
into one, producing a file named `WeeklyFunnyVideosCompilation.mp4`.

Now, to add labels to your videos, you can just append `=` to each entry and
add the text for it, always remembering to surround them with single-quotes:
```
intro.mp4
01_cat_falling.mp4='Jumpscare'
transition.mp4
02_sneeze.mp4='Who Sneezes Like That??'
transition.mp4
03_workaccident.mp4='Uh Oh···'
outro.mp4
WeeklyFunnyVideosCompilation.mp4=f
```
Yes, the script also automatically skips the entries not marked with that
symbol, leaving them to be worked on only during the merge part.

So in both cases, to render such video, the command for that would be:
```
$ vmerger.sh funnycompilation.txt
```
That's it! Dead-simple stuff :)

### Differences Between the concat Muxer and Filter
- muxer: it won't eat all of your RAM and there won't be a need to re-encode
  the video and audio streams. However, _all_ the videos _must_ be in the
  exact same resolution, framerate, and codec.
- filter: requires a ton of RAM depending on how many videos you have and
  their quality and the final video must be re-encoded, however, here you can
  merge videos with different resolutions, refresh rates and even codecs.

**Choose what fits your use-case the best.**

This can be useful for things like video game soundtrack videos and compilation
ones, because of how fast it is. No dependencies whatsoever, other than Bash,
awk and FFmpeg. All of which should already come preinstalled in most distros.

## Current Caveats
- File names with spaces are currently unsupported. This breaks the script as
  it's unable to handle such information properly.
- Since this runs solely on the command line, there's no timeline view, which
  makes it hard to find out what the timestamp for each video is.
- While it does work, it's pretty much still in experimental phase. There's
  stuff I wanna add to it to make it a little more sophisticated and more
  usable overall.

## Contributing
Feel free to open issues and pull requests! I'm open to suggestions, although
I'm still not very skilled at Bash scripting :)
