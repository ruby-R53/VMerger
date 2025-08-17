# VMerger
This is a tool for labeling videos and merging them into one with FFmpeg,
written in Bash.

## "How's that work?"
You supply a text file containing each video you want to work with, plus the
file name of the resulting video. Here is an example:
```
[funnycompilation.txt]
intro.mp4
01_cat_falling.mp4
transition.mp4
02_sneeze.mp4
transition.mp4
03_workaccident.mp4
outro.mp4
WeeklyFunnyVideosCompilation.mp4
```
The script then feeds that to FFmpeg, which will then merge all these videos
into one, producing a file named `WeeklyFunnyVideosCompilation.mp4`.

Now, to add labels to your videos, you can just append `=` to each entry and
add the text for it:
```
intro.mp4
01_cat_falling.mp4='Jumpscare'
transition.mp4
02_sneeze.mp4='Who Sneezes Like That??'
transition.mp4
03_workaccident.mp4='Uh Oh···'
outro.mp4
WeeklyFunnyVideosCompilation.mp4
```
Yes, the script also automatically skips the entries not marked with that
symbol, leaving them to be worked on only during the merge part.

So in both cases, to render such video, the command for that would be:
```
$ vmerger.sh funnycompilation.txt
```
That's it! Really simple stuff :)
This can be useful for things like video game soundtrack videos and compilation
ones, because of how fast it is.

## Current Caveats
- File names with spaces are currently unsupported. This breaks the script as
it's unable to handle such information properly.
- Since this runs solely on the command line, there's no timeline view, which
makes it hard to find out what the timestamp for each video is.
- You might require a TON of RAM for FFmpeg to merge your videos, depending on
their quality and size. Make sure you at least have big enough swap space for
it!

## Contributing
Feel free to open issues and pull requests! I'm open to suggestions, although
I'm still not very skilled at Bash scripting :)
