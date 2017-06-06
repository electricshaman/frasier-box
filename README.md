Frasier Box
======
Elixir application intended for Raspberry Pi that plays a configurable number (`:video_count`) of random videos in a queue.

The queue will exclude any videos which have been played in a configurable number of previous days (`:blacklist_num_days`).  Playback can be started and stopped via UDP commands.  The queue is populated from videos in a single folder and played using omxplayer.

It can be used as a kiosk video player, sleep timer on steroids, etc.

I built this project for my wife, who likes to watch Frasier at night.  This version is a port of the original that I built in 2005 which ran on XBMC.
