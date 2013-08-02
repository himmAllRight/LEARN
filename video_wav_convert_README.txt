video_wav_convert.sh README
Ryan Himmelwright
08/01/2013
--------------------------------------------------------------------------------
This script is written to simplify stripping the audio from video files for 
analysis. Additionally, it can compress all the files into a .tar.gz package 
that is named with a time stamp. This it makes easier to transfer all the files 
through scp to another machine. 


Dependencies:
-------------
In order to use this script, the host machine must have:
	- ffmpeg
	- sox

To Use:
-------
To use, copy script into a directory containing the video files that the audio 
will be extracted from. 
	**Please note: the script will extract the audio from ALL the files with 
	the specified video file extension. If you have files you DO NOT wish 
	to extract audio from (to save time) that have the same file extension, 
	simply remove them from the directory) 

Once the script is in the desired directory, run it by entering the following
command:

			./video_wav_convert.sh FILETYPE

		 	(ex: ./video_wav_convert.sh MP4 )

The script will then find all the files to convert, display them, and ask if you
want to proceed. If everything appears correct, enter 'y', otherwise enter 'n'.
The script will proceed to pull the audio from all the video files and save them
as .wav audio files.

After generating the audio files, you will be asked if you want to make a 
package of the audio files. This will place all the files in a time-stamped tar
package for easy transfer. If you want to package the files, enter 'y', 
otherwise, enter 'n' and the script will close. The generated wav files can be
found in the directory named 'videoAudioPackage'.

If you choose to create a package, you will be asked if you also want to include
the original video files that the audio was pulled from. If you want to include 
these, enter 'y', otherwise enter 'n' to just package the .wav files.

** Please note, if you decided to include the video files, realize that it will
take much longer. The video files have to be moved and packaged which will add a
considerable amount of time compared to just packaging the wav files. It is 
advised to only do this if you need to/ want a package with everything together.

After the package is generated, you will be prompted if you want to delete the
generated wav files. Remember, the wav files in the package won't be deleted,
just the ones left in the directory. If you generated a package to transfer the
files to another machine, it is recommended you delete the wav files in order to
save space. Enter 'y' to delete the files and leave the script, or 'n' to just
exit the script.

Lastly, you will be asked if you want to delete the video files from the 
directory. Again, if you are just using the script to convert the files, package
the wav files, and transfer the files to another machine, it is advised to
delete these files to save space and keep the directory clean. To delete the
video files, enter 'y', otherwise enter 'n' to leave them.



Changing the sampling rate:
----------------------------
When the script pulls the audio and saves it as a .wav file, it saves it at a
specified sampling rate. To change the rate this is being saved at (should be
what the audio sampling rate of the video is), change the number after the 
variable 'sampleRate' in the beginning of the script.

	ex: sampleRate=44100   for a 44.1 kHz sampling rate.



Changing the audio channel:
---------------------------
Because the audio of the GoPro camera is taken in stereo, the audio from it
contains two channels of audio, the right and left. At the time this script was
written, only one of the channels was needed for analysis and one of the
the channels happened to contain a lot of noise and unwanted. So, after the 
audio is extracted into a wav file, only one audio channel is saved to the file.
To change which channel is saved, change the value in the variable 'channel'.

	ex: channel=1       to save the right channel,  or,
	ex: channel=2       to save the left channel

If you want both channels to be saved in the .wav file, comment out the line
that starts with 'sox' ( Read the comments, the point out where it is ).

The line to be commented out:

sox "${f%%.$filetype}_VidAudio_bothChan.wav" "${f%%.$filetype}_VidAudio.wav" remix $channel


