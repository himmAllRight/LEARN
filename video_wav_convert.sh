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
		# (Comment out 'sox' command if you wish to keep both channels)
		sox "${f%%.$filetype}_VidAudio_bothChan.wav" "${f%%.$filetype}_VidAudio.wav" remix $channel
		rm "${f%%.$filetype}_VidAudio_bothChan.wav" # remove stereo file
		done
	echo  'Conversion Complete.'  

	# Ask to make package of wav files.
	read -r -p "Would you like to make a package of audio files? [Y/n]: " response
	# Yes
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
		then
		read -r -p "Do you want to also include the $filetype files? [Y/n]: " response
		if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
			then
			echo "Starting to create package with both .wav and $filetype files... "
			mkdir videoAudioPackage			# Make package folder
			echo 'adding wav files...'
			mv *_VidAudio.wav videoAudioPackage	# Move wav files to package folder
			echo "adding $filetype files..."
			cp *.$filetype videoAudioPackage	# Copy video files to package folder
			echo 'creating package...'
			tar -czvf "videoAudioPackage"_`date +"%Y%m%d%H%M"`.tar.gz videoAudioPackage
			rm videoAudioPackage/*.$filetype
			echo -e 'Package created. \n'
		else
			echo -e 'Starting to create package with just .wav files...' # put files in package
	 		mkdir videoAudioPackage
			echo 'adding wav files...'
			mv *_VidAudio.wav videoAudioPackage
			echo 'creating package...'
			tar -czvf "videoAudioPackage"_`date +"%Y%m%d%H%M"`.tar.gz videoAudioPackage
			echo -e 'Package created. \n'
		fi
	# If no (for package make)
	else
		echo -e 'No package created. \n'
	fi

	# Asks user if they want to delete wav files.
	read -r -p "Do you want to delete the wav files stripped from the video? (files will still exist in package, if it was created) [Y/n]: " response
	# Yes, delete converted wav files.
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
		echo -e 'Removing wav files'
		rm -r videoAudioPackage/*	# remove wav files
		rm -r videoAudioPackage		# remove directory
		echo -e 'wav files delete. \n'

	# No, move wav files into main Directory and remove package folder.
	else
		mv videoAudioPackage/* .
		rm -r videoAudioPackage
		echo -e 'wav files left in directory. \n'
	fi

#	# Asks the user if they want to delete the video files.
read -r -p "Do you want to delete the $filetype files as well? [Y/n]: " response
	
#	# Yes, delete the video files,
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
		then
		echo 'Removing Video Files...'
		rm -r *.$filetype
		echo "The $filetype files were deleted."
		echo 'Exiting Script.' 
	else
		echo " $filetype files have been left in the directory. Exiting Script."
	fi

# If user selects 'n' (for convert)
else
	echo -e 'Exiting Script. \n'
fi
