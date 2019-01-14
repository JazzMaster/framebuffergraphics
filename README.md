# Framebuffer Graphics for Linux vTerm 

(Not fully ported from C yet)

At it's heart, this project aims to allow programs running on a "small device" 
(such as a raspberry pi) -or "not running X11" -to be able to draw graphics using a simple API

Provides:

PutPixel
Init
Close
clearscreen (w _bgcolor)

Color ops are math- as are arc/ellipse/circle methods

Colors are limited to using integer. 
Int32 has a 4G-"4 billions" (4*1024) limit. It also wraps-which is wrong.

Anything put on the "screen" is suboptimal unless it uses memcopy ops to "pageflip" the data
from a buffer(array [0..MaxSize] of color ints) into the video buffer(vRam).

(This is minimal SDL v1-ish behaviour.)

The X11 interface code- 
is with the sdlBGI/Lazarus Graphics project Im hosting.

It may at some point link into this if X11 isnt available.

## Dependencies

Install `libpng-dev` and `libjpeg-dev` ONLY IF if you are using the PNG or JPEG
functions.

