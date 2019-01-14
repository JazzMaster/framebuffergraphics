Program FBGraphDemo;
//the header must match the filename

//We need to open the TTY(POSIX: everything is a file, remember??)
//and write certain commands to it- 
//init and close graph (similar to: int 10 mode 2fa)
//graphics and text mode are triggered by writing certain bits to the tty file.

//This is explained in further detail- 
// http://betteros.org/tut/graphics1.php


//this unit has "whacky signal handling" on windows.

uses
    cthreads,cmem,ctypes,strings,math,crt,keyboard,draw,signals,BaseUnix,sysutils;

{$include "font.inc"}


{$ifdef ImgSupport}
    {$include "img-png.inc"}
    {$include "img-jpeg.inc"}
{$endif}

var
    oa,na : PSigActionRec;
    runflag,ttyfd:integer;
    jpegImage,scaledBackgroundImage:PTImage;
    fontmap:Pfontmap;

Procedure DoSig(sig : cint);cdecl;

begin

    if (sig = SIGINT) then begin
        writeln('Interrupted...');
        runflag := 0;
		exit;
    end;

    // If we segfault in graphics mode, we can't get out.
    if (sig = SIGSEGV) then begin
        if (ttyfd = -1) then 
            writeln('Error: could not open the tty.');
        else 
            Fpioctl(ttyfd, KDSETMODE, KD_TEXT);
        
        writeln('Segmentation Fault. (Bad memory access)');
        halt(1);
    end;

end;

//main()
begin
    
    runflag:= 1;

//Need to install TWO Interrupt signal handlers.

   new(na);
   new(oa);
   na^.sa_Handler:=SigActionHandler(@DoSig);

   fillchar(na^.Sa_Mask,sizeof(na^.sa_mask),#0);
   na^.Sa_Flags:=0;

   {$ifdef Linux}               // Linux specific
     na^.Sa_Restorer:=Nil;
   {$endif}

//if we cant assign a signal handler for "signal" then....

//SIGINT
   if fpSigAction(295,na,oa)<>0 then
     begin
		 writeln('Signal Handler not installed.');
	     writeln('Error: ',fpgeterrno,'.');
	     halt(1);
     end; 

//SIGSEV
   if fpSigAction(291,na,oa)<>0 then
     begin
		 writeln('Signal Handler not installed.');
	     writeln('Error: ',fpgeterrno,'.');
	     halt(1);
     end; 


    context := context_create;
    fontmap := fontmap_default;
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
      fpioctl(ttyfd, KDSETMODE, KD_GRAPHICS);
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
        draw_rect(context^.width mod 2 - 200, context^.height mod 2 - 200, 400, 400, context, $00FFFF);
        draw_string(200, 200, 'Hello, World!', fontmap, context);      

        //no-its not "event driven"..then again...do we care?
        if keypressed then runflag:=0;

        repeat
            sleep(1);
        until runflag=0;

        image_free(jpegImage);
        image_free(scaledBackgroundImage);
        fontmap_free(fontmap);
        context_release(context);
    end;
    
    if (ttyfd = -1) then
      writeln('Error: could not open the tty')
    else
 
      fpioctl(ttyfd, KDSETMODE, KD_TEXT);

    close(ttyfd);    
    writeln('Shutdown successful.');

end.
