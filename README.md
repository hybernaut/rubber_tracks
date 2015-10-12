
## RUBBER TRACKER

Hacking project for the Converse Rubber Tracks Sample Library / Indaba Hackathon
2015-10-10 Boston, MA

### Project Description:

TLDR: project unsuccessful, but created a Ruby downloading utility

This project's goal is a script for downloading a set of samples from the
Converse Rubber Tracks Sample Library into a 64-pad
Ableton Live Drum Rack in the style of the [Infinite Drum Rack](http://producerdj.com/product/infinite-drum-rack-live-9/) from [ill.Gates](http://producerdj.com/). This layout for finger drumming standardizes the locations of various parts (kicks, snares, etc.) and allows for easy cycling of samples so you can dial in a tight kit from a large range of samples.

Since Ableton Live 9.2 exposes all 64 pads on the Push controller in a drum rack, it's possible to access a large number of samples in a routine.

Progress:

I started out building a ruby utility for parsing API messages and downloading files to build drum racks. This project is here:

http://github.com/hybernaut/rubber_tracks

Not many people know this, but the Ableton ADG file format used for drum racks and other saved presets is gzip xml, quite readable, and incredibly comprehensive. It should be easy to generate a file describing a drum rack which Ableton Live would accept, with links to the downloaded samples properly laid out on the grid.

Unfortunately the ADG format uses a block of binary data in the <FileRef> element which I could not decipher, so I was unable to build an ADG file with a completed drum rack. Perhaps the way forward is to download all the samples, drag them all into a drum rack, then process the saved ADG file.

Brian Del Vecchio <bdv@hybernaut.com>
