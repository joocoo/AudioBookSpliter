# Audio Book Splitter
A simple audio book splitting tool written in Powershell that takes in an audio book file, an output directory, and a CSV file of the following format.

| startTime | endTime | chapterName |

Prereqs to run is installing ffmpeg which includes ffmprobe. 

This code works on all platforms provided that the ffmpeg bin folder is in your PATH environment variable.
