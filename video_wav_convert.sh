#!/bin/bash
# 7/30/2013
#
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

echo -e '\n' # Space

read -r -p "Would you like to continue? [Y/n] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	# for each file in directory of specified file type..
	for f in *.$filetype;
	do
	# Converts files using ffmpeg
	ffmpeg -i "$f" -f wav -vn -ar 44100 "${f%%.$filetype}_VidAudio.wav" 
	done
echo -e '\n Conversion Complete. \n'  # End of script

else

echo -e '\n Exiting Script.'

fi
