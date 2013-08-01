#!/bin/bash
# 8/01/2013
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

echo -e '\n Stripping audio for following files:\n --------------------------------------'

# Prints out the names of all the files to convert.
for f in *.$filetype;
do
	echo $f
done

echo -e '' # Space

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
echo -e 'Conversion Complete. \n'  # End of script

# Ask to make package of wav files.
read -r -p "Would you like to make a package of audio files? [Y/n]: " response
# Yes
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	read -r -p "Do you also want to include the $filetype files? [Y/n]: "
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		echo -e "Starting to create package with .wav and $filetype files... \n"
		mkdir videoAudioPackage			# Make package folder
		echo 'adding wave files...'
		mv *_VidAudio.wav videoAudioPackage	# Move wav files to package folder
		echo "adding $filetype files..."
		cp *.$filetype videoAudioPackage	# Copy video files to package folder
		echo 'creating package...'
		tar -czvf "videoAudioPackage"_`date +"%Y%m%d%H%M"`.tar.gz videoAudioPackage
		echo -e 'Package created. \n'
	else
		echo -e 'Starting to create package with just .wav files...\n' # put files in package
		mkdir videoAudioPackage
		mv *_VidAudio.wav videoAudioPackage
		tar -czvf "videoAudioPackage"_`date +"%Y%m%d%H%M"`.tar.gz videoAudioPackage
		echo -e 'Package created. \n'
	fi
# If no (for package make)
else
	echo -e 'Exiting Script.'
fi

# Asks user if they want to delete wav files.
read -r -p "Do you want to delete the wav files stripped from the video? (files still exist in package) [Y/n]: " response
# Yes, delete converted wav files.
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
then
	echo -e 'Removing files'
	rm -r videoAudioPackage/*	# remove wav files
	rm -r videoAudioPackage		# remove directory
	echo 'Exiting Script.'
# No, move wav files into main Directory and remove package folder.
else
	echo 'Leaving wav files in directory'
	mv videoAudioPackage/* .
	rm -r videoAudioPackage
	echo 'Exiting Script.'
fi
# If user selects 'n' (for convert)
else
	echo -e 'Exiting Script. \n'
fi
