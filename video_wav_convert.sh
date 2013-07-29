#!/bin/bash
# Uses ffmpeg to convert video files in a list into .wav files.
# To run, simply run script with the file extension of the video files as the first
# argument.
#
# ex: ./video_wav_convert.sh m4v 
#
# To convert all the .m4v video files in the directory to .wav audio files.

filetype=$1

echo -e '\n \n Stripping audio for following files:\n --------------------------------------'

# Prints out the names of all the files to convert.
for f in *.$filetype;
do
echo $f
done

echo -e '\n \n' # Space

# Strips the audio of each file and makes a wav file using ffmpeg.
for f in *.$filetype;
do
ffmpeg -i "$f" -f wav -vn "${f%%.$filetype}_VidAudio.wav" # the convert command
done

echo -e '\n Conversion Complete. \n'  # End of script
