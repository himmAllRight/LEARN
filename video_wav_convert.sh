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
sampleRate=44100 # Change number to change sampling rate
channel=2        # select which stereo channel to pull (1 for right, 2 for left)

echo -e '\n \n Stripping audio for following files:\n --------------------------------------'

# Prints out the names of all the files to convert.
for f in *.$filetype;
do
echo $f
done

echo -e '\n' # Space

read -r -p "Would you like to continue? [Y/n] " response
# If user selects 'y'
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	# for each file in directory of specified file type..
	for f in *.$filetype;
	do
	# Converts files using ffmpeg
	ffmpeg -i "$f" -f wav -vn -ar $sampleRate  "${f%%.$filetype}_VidAudio_bothChan.wav"
	# Strips out one channel for stereo and saves as wav.
	sox "${f%%.$filetype}_VidAudio_bothChan.wav" "${f%%.$filetype}_VidAudio.wav" remix $channel
	rm "${f%%.$filetype}_VidAudio_bothChan.wav" # remove stereo file
	done
echo -e '\n Conversion Complete. \n'  # End of script

# If user selects 'n'
else
echo -e '\n Exiting Script.'

fi
