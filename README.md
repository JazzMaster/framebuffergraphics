# Framebuffer Graphics
I dont even think this is lib(s)vga...its "vTerm graphics".

## Expect bugs
(This code is work in progress-at best)

A TON of code from yesteryears (like 20 years ago) is starting to catch up with modern day programmers.
As a result- we have a LOT of work to do.

Personally- this X11 handshaking server/client BULLSHIT is a bit much.
(You should see the KMS handshaking code- even in C- it looks like ass)

Reminds me of the Novell Netware 5 print server setup routine...
(A->b->c->d->f->n  back to A, then C....then H - just to print.)




At it's heart, this project aims to allow programs running on a "small device" 
(such as a raspberry pi) -or "not running X11" -to be able to draw graphics using a simple API
-SANS X11.

The X11 interface code- and I do mean that- (because someone has some other hooks if it looks like running the BGI instead)
is with the sdlBGI/Lazarus Graphics project Im hosting.

## Dependencies

Install `libpng-dev` and `libjpeg-dev` ONLY IF if you are using the PNG or JPEG
functions.


FPC DOES have hooks somewhere in the package tree- (just download FPC off GH and then look for it)
(libJPEG is NOT easy to understand, nor from experience -easy to get working)

