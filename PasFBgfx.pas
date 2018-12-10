Program PasFBgfx;
//the header must match the filename

//We need to open the TTY(POSIX: everything is a file, remember??)
//and write certain commands to it to flip to - and from graphics modes.

//This is explained in further detail- (where Im getting the conversion hints from)
// http://betteros.org/tut/graphics1.php

uses

    cthreads,cmem,ctypes,string,math,crt,keyboard;
    //signals,fb,vt??

{$include "font.inc"}
{$include "draw.inc"}


//wait- this isnt a unit...(YES, theres still a way to trip this....)
//some people like things without 3rd party "units" or libraries.
//the easiest way is to abstract this further into a unit- and then call THIS code.

{$ifdef ImgSupport}
    {$include "img-png.inc"}
    {$include "img-jpeg.inc"}
{$endif}

var

    runflag,ttyfd:integer;
    jpegImage,scaledBackgroundImage:PTImage;


// Intercept SIGINT
procedure sig_handler(int signo:integer);


begin
    if (signo = SIGINT) then begin
        writeln('Interrupted...');
        runflag := 0;
    end;

    // If we segfault in graphics mode, we can't get out.
    if (signo = SIGSEGV) then begin
        if (ttyfd = -1) then 
            writeln('Error: could not open the tty.');
        else 
            ioctl(ttyfd, KDSETMODE, KD_TEXT);
        
        writeln('Segmentation Fault. (Bad memory access)');

        exit(1);
    end;
end;

//main()
begin
    
    runflag:= 1;

    // Intercept SIGINT so we can shut down graphics loops.
    if (signal(SIGINT, sig_handler) = SIG_ERR) then
         writeln('cant catch INTERRUPTS');
    
    if (signal(SIGSEGV, sig_handler) = SIG_ERR) then
        writeln('cant catch INVALID memory accesses');
    

    context := context_create;
    // fontmap_t * fontmap = fontmap_default();
    writeln('Graphics Context: $ ', context);

    
    // Attempt to open the TTY:

    Assign(filename,'/dev/tty1');
    ReWrite(filename);

    //try..except IOError..finally
    //makes a lot more sense


    if (ttyfd = -1) then
      writeln('Error: could not open the tty');
    else begin
      // This line enables graphics mode on the tty.
      ioctl(ttyfd, KDSETMODE, KD_GRAPHICS);
    end;

  
   
    if(context <> NiL) then begin
        jpegImage := read_jpeg_file('./nyc.jpg');
        scaledBackgroundImage := scale(jpegImage, context^.width, context^.height);
        
        clear_context(context);
        draw_image(0, 0, scaledBackgroundImage, context);
        draw_rect(-100, -100, 200, 200, context, $FF0000);
        draw_rect(context^.width - 100, context^.height - 100, 200, 200, context, $FFFF00);
        draw_rect(context^.width - 100, -100, 200, 200, context, $00FF00);
        draw_rect(-100, context^.height - 100, 200, 200, context, $0000FF);
        draw_rect(context^.width / 2 - 200, context^.height / 2 - 200, 400, 400, context, $00FFFF);
        // draw_string(200, 200, "Hello, World!", fontmap, context);      

        //no-its not "event driven"..then again...do we care?
        //if keypressed then runflag:=0;

        repeat
            sleep(1);
        until runflag=0;

        image_free(jpegImage);
        image_free(scaledBackgroundImage);
        // fontmap_free(fontmap);
        context_release(context);
    end;
    
    if (ttyfd = -1) then
      writeln('Error: could not open the tty')
    else
 
      ioctl(ttyfd, KDSETMODE, KD_TEXT);

    close(ttyfd);
    
    writeln('Shutdown successful.');


end.


---

#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <linux/fb.h>
#include <linux/vt.h>
#include <sys/stat.h>
#include <sys/mman.h>

#include <sys/ioctl.h>



 
