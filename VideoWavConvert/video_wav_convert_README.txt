video_wav_convert.sh README
Ryan Himmelwright
Last Revised: 08/06/2013
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
To use, first copy script into a directory containing the video files that the 
audio will be extracted from. 
	**Please note: the script will extract the audio from ALL the files with 
	the specified video file extension. If you have files you DO NOT wish 
	to extract audio from (to save time) that have the same file extension, 
	simply remove them from the directory) 

******************************************************
Copying files and script to a remote machine using SCP
******************************************************
If the files are being converted on a remote machine, both the files and script
will have be transferred to and from the machine. One simple way to do this is
using SCP. To copy the files, follow these steps:
	
Mac/Linux Users:
1. Open up a terminal window. 
2. Enter the command:
   "scp -r /PATH/OF/FILES/ user@host.edu:/Path/On/Remote/Machine"

Ex on arrayzilla computer:
scp –r Documents/file_with_vids arrayzilla@arrayzilla.neuro.brown.edu:/path/

3. Enter password when prompted to start file copy. ("Eptesicus" for arrayzilla)
---
4. After the script is finished, to pull the package from the remote machine to
   your machine, use scp in the other direction from your computer.
Ex:
scp arrayzilla@arrayzulla.neuro.brown.edu:/packageLocaion/videoAudioPackage_PACKAGEDATE.tar.gz /Home/Documents/file/

5. To unzip the package in Mac/Linux, locate it in ther terminal and enter the
   following command: "tar -zxf packageNAME.tar.gz"

Windows Users:
- Windows users will have to install a program such as WinSCP
(found at http://winscp.net/eng/download.php ) to connect use scp.

1. Open WinSCP or an scp program.
2. Connect to the remote computer.
	To connect to the arrayzilla computer:
	- Enter “arrayzilla.neuro.brown.edu” for the Host name.
	- Enter “arrayzilla” for the user name field, and “Eptesicus” for the 
	  password field.
	- Keep “Port Number” set to “22”, “File protocol” to “SFTP” and check 
	  “Allow SCP fallback”.
	- Hit the 'Login' Button.
   * To connect to another remote server, replace these fields the the login
   information of that computer.
3. Once connected, simply drag and drop the video files into a folder on the
   remote machine.
---
4. When the script is done running, to pull the package from the remote to your 
   computer, just drag the newly generated tar.gz package to a location on your
   computer in WinSCP.
5. Unzip the package using a program like WinRAR.


When running the script on a remote machine, you will have to connect to the 
machine through ssh to run the script after transferring the files over. This is
very similar to scp. Mac/Linux Users just have to type the following command
into the terminal window. (Windows users will have to get an SSH application. 
I suggest using PuTTY: http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)

1. To connect to arrayzilla through ssh, enter:
   "ssh arrayzilla@arrayzilla.neuro.brown.edu"

2. Enter the password when prompted (again, "Eptesicus" for arrayzilla)

- You should  now be logged into a terminal window just as if you were sitting 
  in front of the remote machine with a terminal window open.

- Next, change the directory to the location of videos and script. This can be 
  done using the "cd" command. 
  Example: "cd /path/to/file/"

Some helpful hints:
- Typing "pwd" will show the current directory you are in.
- Typing "ls" will display all the files and sub-directories within the current
  directory.
- Hitting TAB will auto complete a command (if unique) and double tapping TAB
  will display possible options (if not unique).
- To change the directory, type "cd directory/path/"
	- To move back a directory, use the path ".." Ex: "cd .."
- To copy file, use the "cp" command. Ex: "cp filename.txt /pather/toMove/"

*At this point, remote users can continue with the process of running the script
as normal.
*****************************************************

Running the Script
-------------------
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


