Program FBGraphDemo;
//the header must match the filename

//We need to open the TTY(POSIX: everything is a file, remember??)
//and write certain commands to it- 
//init and close graph (similar to: int 10 mode 2fa)
//graphics and text mode are triggered by writing certain bits to the tty file.

//This is explained in further detail- 
// http://betteros.org/tut/graphics1.php


<<<<<<< HEAD:PasFBgfx.pas
    cthreads,cmem,ctypes,string,math,crt,termio,keyboard,baseunix,sysutils;
    //signals,fb,vt??

type

PGlyph=^TGlyph;
TGlyph=record

  data:^Integer;
  width:integer;
  height:integer;
  baseline_offset:integer;
  centerline_offset:integer;
end;

PFontMap=^TFontMap;
TFontMap=Record
  map:PGlyph;
  size:integer;
  max_height:integer;
  max_width:integer;
end;

PImage=^TImage;
TImage=record
  data:^integer;
  width:integer;
  height:integer;
end;

PContext=^TContext;
TContext=record
  data:^integer;
  int width:integer;
  int height:integer;
  fb_name:PChar;
  fb_file_desc:integer;
end;


//FontMaps....and Glyphs are oldschool methods...
//TTF fonts need to be used instead.


procedure fontmap_free(fontmap:PFontMap);
function fontmap_default:PFontMap;
procedure draw_string(x, y:integer; strint:PChar; fontmap:PFontMap; context:PContext);

procedure image_free(image:Pimage);
procedure set_pixel(x,y:integer; context:PContext; color:integer);
function scale(image:Pimage; w, h:integer):Pimage;
procedure draw_array(x, y, w,h:integer; IntArray:^Integer; context:Pcontext);
procedure draw_image(x, y:integer; image:PImage; context:PContext);
procedure draw_rect(x, y, w, h:integer; context:PContext, color:integer);
procedure clear_context_color(context:Pcontext; color:integer);
procedure clear_context(context:Pcontext);

procedure test_pattern(context:PContext);

procedure context_release(context:PContext);
function context_create:PContext;
=======
//this unit has "whacky signal handling" on windows.

uses
    cthreads,cmem,ctypes,strings,math,crt,keyboard,draw,signals,BaseUnix,sysutils;

{$include "font.inc"}

>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13:FBGraphDemo.pas

{$ifdef ImgSupport}
	function read_png_file (filename:PChar):PImage;
    function read_jpeg_file (filename:PChar):Pimage;
{$endif}

var
    oa,na : PSigActionRec;
    runflag,ttyfd:integer;
    jpegImage,scaledBackgroundImage:PTImage;
<<<<<<< HEAD:PasFBgfx.pas
    fontmap:PfontMap;

// Intercept SIGINT
procedure sig_handler(int signo:integer);


begin
    if (signo = SIGINT) then begin //may just want to wait for the task scheduler in the kernel...
=======
    fontmap:Pfontmap;

Procedure DoSig(sig : cint);cdecl;

begin

    if (sig = SIGINT) then begin
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13:FBGraphDemo.pas
        writeln('Interrupted...');
        runflag := 0;
		exit;
    end;

<<<<<<< HEAD:PasFBgfx.pas
    // If we segfault in graphics mode, we can't get out. So catch it.
    if (signo = SIGSEGV) then begin
        if (ttyfd = -1) then 
            writeln('Error: could not open the tty.');
        else 
            FpIOCtl(ttyfd, KDSETMODE, KD_TEXT);
=======
    // If we segfault in graphics mode, we can't get out.
    if (sig = SIGSEGV) then begin
        if (ttyfd = -1) then 
            writeln('Error: could not open the tty.');
        else 
            Fpioctl(ttyfd, KDSETMODE, KD_TEXT);
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13:FBGraphDemo.pas
        
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
<<<<<<< HEAD:PasFBgfx.pas
      FpIOCtl(ttyfd, KDSETMODE, KD_GRAPHICS);
=======
      fpioctl(ttyfd, KDSETMODE, KD_GRAPHICS);
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13:FBGraphDemo.pas
    end;
  
   
    if(context <> NiL) then begin
//Load image
        jpegImage := read_jpeg_file('./nyc.jpg');
        scaledBackgroundImage := scale(jpegImage, context^.width, context^.height);

//do graphics ops        
        clear_context(context);
        draw_image(0, 0, scaledBackgroundImage, context);
        
        draw_rect(-100, -100, 200, 200, context, $FF0000);
        draw_rect(context^.width - 100, context^.height - 100, 200, 200, context, $FFFF00);
        draw_rect(context^.width - 100, -100, 200, 200, context, $00FF00);
        draw_rect(-100, context^.height - 100, 200, 200, context, $0000FF);
<<<<<<< HEAD:PasFBgfx.pas
        draw_rect(context^.width / 2 - 200, context^.height / 2 - 200, 400, 400, context, $00FFFF);
        draw_string(200, 200, "Hello, World!", fontmap, context);      
=======
        draw_rect(context^.width mod 2 - 200, context^.height mod 2 - 200, 400, 400, context, $00FFFF);
        draw_string(200, 200, 'Hello, World!', fontmap, context);      
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13:FBGraphDemo.pas

//main event input loop
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
    
<<<<<<< HEAD:PasFBgfx.pas
    FpIOCtl(ttyfd, KDSETMODE, KD_TEXT);
    close(ttyfd);
  
    writeln('Shutdown successful.');

end.

=======
    if (ttyfd = -1) then
      writeln('Error: could not open the tty')
    else
 
      fpioctl(ttyfd, KDSETMODE, KD_TEXT);

    close(ttyfd);    
    writeln('Shutdown successful.');

end.
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13:FBGraphDemo.pas
