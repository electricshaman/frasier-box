Frasier Box
======
Elixir application for Raspberry Pi that plays X (:video_count) number of random videos in a queue after receiving start command via UDP.
The queue will exclude any videos which have been played in the previous Y (:blacklist_num_days) number of days.
Playback can be stopped via UDP command.
The videos are played using omxplayer.

I built this project for my wife, who likes to watch Frasier at night.  This version is a port of the original that I built in 2005 which ran on XBMC.
