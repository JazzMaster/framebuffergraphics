# Framebuffer Graphics

## Expect bugs.

A TON of code from yesteryears (like 20 years ago) is starting to catch up with modern day programmers.
As a result- we have a LOT of work to do.

Personally- this X1 handshaking server/client BULLSHIT is a bit much.
(You should see the KMS handshaking code- even in C- it looks like ass)

Reminds me of the Novell Netware 5 print server setup routine...
(A->b->c->d->f->n  back to A, then C....then H - just to print.)

At it's heart, this project aims to allow programs running on a "small device" 
(such as a raspberry pi) -or "not running X11" -to be able to draw graphics using a simple API
-SANS X11.

## Dependencies
Install `libpng-dev` and `libjpeg-dev` if you are using the PNG or JPEG
functions.
FPC DOES have hooks somewhere in the package tree- (just download FPC off GH and then look for it)
