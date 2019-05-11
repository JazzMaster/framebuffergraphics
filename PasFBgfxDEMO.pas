Program PasFBgfx;

//We need to open the TTY(POSIX: everything is a file, remember??)
//and write certain commands to it to flip to - and from graphics modes.

//This is explained in further detail- (where Im getting the conversion hints from)
// http://betteros.org/tut/graphics1.php

uses
{$IFDEF unix}
	cthreads,cmem,baseunix,sysutils,
{$ENDIF}
    ctypes,strings,math,crt,keyboard,readjpg,readpng;    

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
  width:integer;
  height:integer;
  fb_name:PChar;
  fb_file_desc:integer;
end;

IntPtr=array of Integer;

//FontMaps....and Glyphs are oldschool methods...
//TTF fonts need to be used instead.


//procedure fontmap_free(fontmap:PFontMap);
//function fontmap_default:PFontMap;
//procedure draw_string(x, y:integer; strint:PChar; fontmap:PFontMap; context:PContext);

//procedure image_free(image:Pimage);
//procedure set_pixel(x,y:integer; context:PContext; color:integer);
//function scale(image:Pimage; w, h:integer):Pimage;
//procedure draw_array(x, y, w,h:integer; IntArray:IntPtr; context:Pcontext);

//procedure draw_image(x, y:integer; image:PImage; context:PContext);
//procedure draw_rect(x, y, w, h:integer; context:PContext; color:integer);
//procedure clear_context_color(context:Pcontext; color:integer);
//procedure clear_context(context:Pcontext);

//procedure test_pattern(context:PContext);

//procedure context_release(context:PContext);
//function context_create:PContext;

{$ifdef ImgSupport}
    function read_png_file (filename:PChar):PImage;
    function read_jpeg_file (filename:PChar):Pimage;
{$endif}


var
    ttyfd:text;
    runflag:integer;
    jpegImage,scaledBackgroundImage:PImage;
    fontmap:PfontMap;
   pctx:PContext;

// Intercept SIGINT
procedure sig_handler(signo:integer);


begin
    if (signo = SIGINT) then begin //may just want to wait for the task scheduler in the kernel...
        writeln('Interrupted...');
        runflag := 0;
    end;

    // If we segfault in graphics mode, we can't get out. So catch it.
    if (signo = SIGSEGV) then begin
        if (not ttyfd ) then 
            writeln('Error: could not open the tty.')
        else 
            FpIOCtl(ttyfd, KDSETMODE, KD_TEXT);
        
        writeln('Segmentation Fault. (Bad memory access)');
        
    end;

end;


//main()
begin
    
    runflag:= 1;

    // Intercept SIGINT so we can shut down graphics loops.
    if (fpsignal(sig_handler(SIGINT)) = SIG_ERR) then
         writeln('cant catch INTERRUPTS');
    
    if (fpsignal(sig_handler(SIGSEV)) = SIG_ERR) then
        writeln('cant catch INVALID memory accesses');
    

    Pctx := context_create;
    fontmap := fontmap_default;
    writeln('Graphics Context: $ ', string(@Pctx));

    
    // Attempt to open the TTY:

    Assign(ttyfd,'/dev/tty1');
    ReWrite(ttyfd);

    if (ttyfd = Nil) then begin
      writeln('Error: could not open the tty');
      exit;
    end
    else 
      // This line enables graphics mode on the tty.
      FpIOCtl(ttyfd, KDSETMODE, KD_GRAPHICS);
         
    if(pctx <> NiL) then begin
//Load image
//        jpegImage := read_jpeg_file('./nyc.jpg');
//        scaledBackgroundImage := scale(jpegImage, pctx^.width, pctx^.height);

//do graphics ops        
        clear_context(pctx);
        draw_image(0, 0, scaledBackgroundImage, pctx);
        
        draw_rect(-100, -100, 200, 200, Pctx, $FF0000);
        draw_rect(context^.width - 100, Pctx^.height - 100, 200, 200, Pctx, $FFFF00);
        draw_rect(context^.width - 100, -100, 200, 200, pctx, $00FF00);
        draw_rect(-100, pctx^.height - 100, 200, 200, pctx, $0000FF);
        draw_rect(pctx^.width mod 2 - 200, Pctx^.height mod 2 - 200, 400, 400, Pctx, $00FFFF);
        draw_string(200, 200, 'Hello, World!', fontmap, pctx);      

//main event input loop
        //no-its not "event driven"..then again...do we care?
        if keypressed then runflag:=0;

        repeat
            sleep(1);
        until runflag=0;

//        image_free(jpegImage);
//        image_free(scaledBackgroundImage);

        fontmap_free(fontmap);
        context_release(context);
    end;
    
    FpIOCtl(ttyfd, KDSETMODE, KD_TEXT);
    close(ttyfd);  
    writeln('Shutdown successful.');
end.
