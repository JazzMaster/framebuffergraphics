<<<<<<< HEAD
## Framebuffer Graphics

Framebuffer Graphics routines for Freepascal. 

**Lazarus cant use this because X11 will never be active while using this code**

(This is ported from C-more as proof of concept than anything.)
The port is WIP- mostly there.


BMP -> usually available no matter what
libPNG -> use png unit in uses clause

libJPEG (PasJPEG):
(20 year old code -w shitty documentation)

	use imjdmaster.pas or imjpeglib.pas
	(basic bare-minimal decoding is in the files with this project)
	
---


This code may or may not work with a KMS Kernel.

-If it doesnt-

Then we need to upgrade code to support KMS.

---

Personally- this X11 handshaking server/client BULLSHIT is a bit much.
(Glad I dont have to write it..)

### What does this accomplish?

Its a fallback for other code- use it if you like(and can get it working)

At it's heart, this project aims to allow programs running on a "small device" 
(such as a raspberry pi) -or "not running X11" -to be able to draw graphics using a simple API.
=======
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
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13

It may at some point link into this if X11 isnt available.

## Dependencies

Install `libpng-dev` and `libjpeg-dev` ONLY IF if you are using the PNG or JPEG
functions.

<<<<<<< HEAD
(libJPEG is NOT easy to understand, nor from experience -easy to get working)

=======
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
