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

## Dependencies

Install `libpng-dev` and `libjpeg-dev` ONLY IF if you are using the PNG or JPEG
functions.

(libJPEG is NOT easy to understand, nor from experience -easy to get working)

