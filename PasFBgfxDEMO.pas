Program PasFBgfx;

//We need to open the TTY(POSIX: everything is a file, remember??)
//and write certain commands to it to flip to - and from graphics modes.

//This is explained in further detail- (where Im getting the conversion hints from)
// http://betteros.org/tut/graphics1.php

{$mode objfpc}{$H+}

uses
{$IFDEF unix}
	cthreads,cmem,baseunix,sysutils,
{$ENDIF}
    ctypes,termio,strings,math,crt,keyboard

{$ifdef ImgSupport}
,readjpg,readpng    
{$endif}
;

//framebuffer and tty code at this level is undocumented- you have to parse the sources.
//fb.h (pascal undocumented) is the source of most of this- headers and routines.
//termio is the other.

type

//sdl_color, basically- but I dont think youre gonna get 32bpp in a console.
//but you might get 16bpp.

//dont point to one pixel- point to the array of pixel data.
Tpixel=record
  red:byte;
  green:byte;
  blue:byte;
  alpha:byte;
end;

PPixel=^PixelArray;
PixelArray= array of Tpixel;


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
  data:PixelArray;
  width:integer;
  height:integer;
end;

Pctx=^Tcontext;
Tcontext=record
  data:PixelArray;
  width:integer;
  height:integer;
  fb_name:PChar;
  fb_file_desc:integer;
end;

IntPtr=array of Integer;


//FontMaps....and Glyphs are oldschool methods...
//TTF fonts need to be used instead.

var
    ttyfd,Fbfd:text;
    runflag:integer;
    jpegImage,scaledBackgroundImage:PImage;
    fontmap:PfontMap;
	devPath : string = '/dev/tty1';
    handle : Cint;

//    tios : Termios;
    gfx:longword =$01;
    txt:longword =$00;
	KDSETMODE:longword =$4B3A; //see reddit python demo for how I got this.    

//remember VESA assembler??
	FBIOGET_VSCREENINFO:longword =$4600;
	FBIOPUT_VSCREENINFO:longword= $4601;
	FBIOGET_FSCREENINFO:longword= $4602;

procedure image_free(image:PImage); 

begin
    free(image);
end;

// Set an individual pixel. This is SLOW for bulk operations.
// Do as little as possible, and memcpy the result.

//1D math on a 2D array

procedure set_pixel(x,y:integer; context:pctx; color:TPixel);
var
	write_index:integer;
	
//goes thru each individual "pixel" in the array 	
begin
    write_index := x+y*context^.width;
    if (write_index < context^.width * context^.height) then begin
        context^.data[x+y*context^.width] := color; //x*y*pitch:=color
    end else begin
        writeln('Attempted to set color at out of bounds: ',x,' ', y);
        exit;
    end;
end;

// We scale and crop the image to this new rect.
function scale(image:PImage; w,h:integer):PImage; 
var
    sfx :integer;
    sfy :integer;
    crop_x_w :integer;
    crop_y_h :integer;
    crop_x :integer;
    crop_y :integer;
    new_image :PImage;
    tr_x,x : integer;
    tr_y,y : integer;         

begin
    sfx := w mod image^.width;
    sfy := h mod image^.height;
    crop_x_w := image^.width;
    crop_y_h := image^.height;
    crop_x := 0;
    crop_y := 0;

    if (sfx < sfy) then begin
        crop_x_w := image^.height * w mod h;
        crop_x := (image^.width - crop_x_w)  mod 2;
    end 
	else if(sfx > sfy) then begin
        crop_y_h := image^.width * h mod w;
        crop_y := (image^.height - crop_y_h)  mod 2;
    end;

    new_image := malloc(sizeof(Timage));
    new_image^.data := malloc((sizeof(integer) * w * h));
    new_image^.width := w;
    new_image^.height := h;
    x:=0;
    repeat
        y:=0;
        repeat
            tr_x := ( crop_x_w mod  w) * x + crop_x;
            tr_y := ( crop_y_h mod  h) * y + crop_y;
            new_image^.data[y * w + x] := image^.data[tr_y * image^.width + tr_x];
            inc(y);
        until (y > h);
        inc(x);
    until (x > w);

    scale:=new_image;

end;

// !! This operation is potentially unsafe. Use drawImage. It's harder to mess up.
// X and w are the size of the array.

procedure draw_array(x, y, w,h:integer; DataArray:PixelArray; context:pctx); 

var
  cy,cx,line_count,line_width:integer;

begin
  // Ignore draws out of bounds
  if (x > context^.width) or (y > context^.height) then begin
    exit;
  end;

  // Ignore draws out of bounds
  if (x + w < 0 ) or ( y + h < 0) then begin
    exit;
  end;

  // Column and row correction for partial onscreen images
  cy := 0;
  cx := 0; 

  // if y is less than 0, trim that many lines off the render.
  if (y < 0) then begin
    cy :=cy -y;
  end;

  // If x is less than 0, trim that many pixels off the render line.
  if (x < 0) then begin
    cx := cx -x;
  end;

  // Number of items in a line
  line_width := (w - cx);

  // Number of lines total.
  // We don't subtract cy because the loop starts with cy already advanced.
  line_count := h;

  // If the end of the line goes offscreen, trim that many pixels off the
  // row.
  if (x + w > context^.width) then begin
    line_width := line_width -((x + w) - context^.width);
  end;

  // If the number of rows is more than the height of the context, trim
  // them off.
  if (y + h > context^.height) then begin
    line_count :=line_count- ((y + h) - context^.height);
  end;

  repeat
    // Draw each graphics line- this is slow.
//c: memcpy , Pascal: move
    move( context^.data[context^.width * y + context^.width * cy + x + cx],  DataArray[cy * w +cx], (sizeof(integer) * line_width) );
    inc(cy);
  until (cy > line_count);
end;

procedure draw_image( x, y:integer; image:PImage; context:pctx); 

begin
    draw_array(x, y, image^.width, image^.height, image^.data, context);
end;

procedure draw_rect(x, y, w, h:integer; context:pctx; color:TPixel); 

var
	rx,ry:integer;

begin
    // Ignore draws out of bounds
    if ((x > context^.width) or (y > context^.height)) then begin
        exit;
    end;

    // Ignore draws out of bounds
    if(x + w < 0) or (y + h < 0) then begin
        exit;
    end;
    // Trim offscreen pixels
    if (x < 0) then begin
        w :=w+ x;
        x := 0;
    end;

    // Trim offscreen lines
    if (y < 0) then begin
        h :=h+ y;
        y := 0;
    end;

    // Trim offscreen pixels
    if (x + w > context^.width) then begin
        w :=w- ((x + w) - context^.width);
    end;

    // Trim offscreen lines.
    if (y + h > context^.height) then begin
       h:=h- ((y + h) - context^.height);
    end;

    // Set the first line.
	rx:=x;
    repeat
        set_pixel(rx, y, context, color);
		inc(rx);
    until (rx > x+w);

    // Repeat the first line.
    ry:=1;
    repeat 
        move(
            context^.data[context^.width * y + context^.width * ry + x], 
            context^.data[context^.width * y + x], 
            (w*sizeof(integer))
        );
        inc(ry);
    until (ry > h);
end;

procedure clear_context_color(context:pctx; color:tpixel);

begin
    draw_rect(0, 0, context^.width, context^.height, context, color);
end;

procedure clear_context(context:pctx);

begin
    fillword(context^.data, 0, (context^.width * context^.height * sizeof(integer)));  
end;


procedure context_release(context:pctx);

begin
    fillchar(context^.data,0, (context^.width * context^.height));
    fpclose(context^.fb_file_desc);
    context^.data := Nil;
    context^.fb_file_desc := 0;
    free(context);
end;

type

fb_fix_screeninfo=^fb_fix_screeninfoRec;
fb_fix_screeninfoRec=record
 	id:array [0..16] of char;
 	smem_start:Longword;
 	smem_len:Longword;
 	type_:Longword;
 	type_aux:Longword;
 	visual:Longword;
 	xpanstep:Word;
 	ypanstep:Word;
 	ywrapstep:Word;
	line_length:LongWord; 
 	mmio_start:Longword;
 	mmio_len:LongWord;
	accel:Longword; 
 	reserved: ARRAY [0..3] of word;
end;

fb_bitfield=record
	offset:LongWord;
	length:LongWord;
	msb_right:Longword;
end;

fb_var_screeninfo=^fb_var_screeninfoRec;
fb_var_screeninfoRec=record

 	xres:longword;
 	yres:longword;
 	xres_virtual:longword;
 	yres_virtual:longword;
 	xoffset:longword;
 	yoffset:longword;
 	bits_per_pixel:longword;
 	grayscale:longword;

    red:^fb_bitfield;
    green:^fb_bitfield;
    blue:^fb_bitfield;
    transp:^fb_bitfield;

 	nonstd:longword;
 	activate:longword;
 	height:longword;
 	width:longword;

 	accel_flags:longword;
 	pixclock:longword;
 	left_margin:longword;
 	right_margin:longword;
 	upper_margin:longword;
 	lower_margin:longword;
 	hsync_len:longword;
 	vsync_len:longword;
 	sync:longword;
 	vmode:longword;
 	rotate:longword;
 	reserved:array  [0..5] of longword;

end;

function context_create:pctx;
var
  FB_NAME:PChar;
  mapped_ptr:pointer;
  fb_fixinfo:fb_fix_screeninfo;
  fb_varinfo:fb_var_screeninfo;
  fb_file_desc,fb_size:integer;
  PointedContext:Pctx;

begin
    FB_NAME := '/dev/fb0';
    mapped_ptr := Nil;
    fb_size := 0;

    // Open the framebuffer device in read write
    fb_file_desc := fpopen(FB_NAME, O_RDWR);
    if (fb_file_desc < 0) then begin
        writeln('Unable to open: ', FB_NAME);
        context_create:=NIL;
	    exit;
    end;
    //Do Ioctl. Retrieve fixed screen info.
    if (fpioctl(fb_file_desc, FBIOGET_FSCREENINFO, fb_fixinfo) < 0) then begin
        writeln('get fixed screen info failed: ', errno);
        fpclose(fb_file_desc);
        context_create:=NIL;
	    exit;
    end;
    // Do Ioctl. Get the variable screen info.
    if (fpioctl(fb_file_desc, FBIOGET_VSCREENINFO, fb_varinfo) < 0) then begin
        writeln('Unable to retrieve variable screen info: ', errno);
        fpclose(fb_file_desc);
        context_create:=NIL;
	    exit;
    end;
   {
     this code is funky C. 
     If we have the file handle we can read/write to/from it-in this case the screens framebuffer.
     We need to alloc an array with a 1:1 mapping as a "PageFile" Stream. The Pascal code is overcomplicated(nuked).

     We need to zeroFill the buffer.
     We need to copy the "screen contents" into a char buffer
		We work on data in the buffer- but not live updating the screen
	 We live-copy it back to the "screens framebuffer" (as double buffered IO)
   }

    fb_size := (fb_fixinfo^.line_length * fb_varinfo^.yres);     
    FillWord(fb_file_desc,0,sizeof(fb_size));

    move(fb_file_desc,mapped_ptr,sizeof(fb_size)); //linear copy, doesnt blit

    //hMap:=CreateFileMapping(fb_file_desc,nil,PAGE_READWRITE,0,fb_size,FB_NAME); 
    //mapped_ptr:=OpenFileMapping(FILE_MAP_ALL_ACCESS,false,fb_file_desc); 
{
    if (mapped_ptr = Nil) then begin
        writeln('mmap failed: ');
        fpclose(fb_file_desc);
        return NIL;
    end;}

    PointedContext := malloc(sizeof(Tcontext));
    PointedContext^.data :=  mapped_ptr;
    PointedContext^.width := (fb_fixinfo^.line_length mod 4);
    PointedContext^.height := fb_varinfo^.yres;
    PointedContext^.fb_file_desc := fb_file_desc;
    PointedContext^.fb_name := FB_NAME;
    context_create:=PointedContext;
end;


const
	FONT_SIZE=8;
	ALPHA_COUNT=26;
	NUMBERS_COUNT=10;
	ASCIISYMB1_COUNT=16;
	ASCIISYMB2_COUNT=7;

type
	Alpha=Array [0..7,0..25] of DWord;
	Numbers=Array [0..7,0..9] of DWord;
	ASCIISYMB1=Array [0..7,0..15] of DWord;
	ASCIISYMB2=Array [0..7,0..6] of DWord;


procedure fontmap_dispose(fontmap:PFontMap); 

begin
  dispose(fontmap^.map);
  dispose(fontmap);
end;

function fontmap_default:PFontmap;

var
	i:integer;
	result :PFontMap;
	map :PGlyph;
  
begin
  result := malloc(sizeof(Tfontmap));
  map := malloc(128 * sizeof(Tglyph));
  result^.size := 128;
  result^.map := map;

  i:=0;
  repeat  
    map[i].width := FONT_SIZE;
    map[i].height := FONT_SIZE;
    map[i].baseline_offset := 0;
    map[i].centerline_offset := 0;
    map[i].data :=  NIL_CHAR;
    inc(i);
  until i > 128);

  // Uppercase
  for(i := 0; i < ALPHA_COUNT; i++) begin
    map[65 + i].data := ALPHA[i];
  end;

  // Lowercase
  for(i := 0; i < ALPHA_COUNT; i++) begin
    map[97 + i].data := ALPHA[i];
  end;

  // Numbers
  for(i := 0; i < NUMBERS_COUNT; i++) begin
    map[48 + i].data := NUMBERS[i];
  end;
  
  // Symbols:

  for(i := 0; i < ASCIISYMB1_COUNT; i++) begin
    map[32 + i].data := ASCIISYMB1[i];
  end;

  for(i := 0; i < ASCIISYMB2_COUNT; i++) begin
    map[58 + i].data := ASCIISYMB2[i];
  end;

  map[91].data := LBRACKET;
  map[92].data := BACKSLASH;
  map[93].data :=  RBRACKET;
  map[94].data :=  CARET;
  map[95].data :=  UNDERSCORE;
  map[96].data :=  BACKTICK;
  map[123].data := LCURLYB;
  map[124].data := VLINE;
  map[125].data := RCURLYB;
  map[126].data := TILDE;

  return result;
end;

procedure draw_glyph(int x, int y, glyph_t * glyph, context_t * context) 

begin
  draw_array(x, y, glyph^.width, glyph^.height, glyph^.data, context);
end;

procedure draw_string(x, y:integer; stringdata:PChar; fontmap:PFontMap; context:PContext); 

var
	length:integer;
	charPtr:PGlyph;
	i:integer;

begin
  length := strlen(stringdata);
  draw_rect(0, 0, length * fontmap^.max_width + 2, fontmap^.max_height + 4, context, 0);
  for(int i := 0; i < length; i++) do begin
    charPtr := fontmap^.map[stringdata[i]];
    if(charPtr = Nil) then 
		continue;
    draw_glyph(x + 9 * i, y + 1, charPtr, context);
  end;
end;

// Intercept SIGnals
procedure DoSig(signo:cint); cdecl;

begin
	writeln('Signal caught: ',signo);
end;

begin
//setup font first


ALPHA := (
  ( 
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF) 
  ), (
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0) 
  ), (
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF) 
  ), ( 
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0)
  ), (
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF)
  ), (
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0)
  ), (
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0)
  ),(
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF)
  ),(
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF)
  ),(
    (0,0,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0)
  ),(
    ($FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF)
  ),(
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF)
  ),(
    ($FFFFFF,0,0,0,0,0,0,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF)
  ),(
    ($FFFFFF,0,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF)
  ),(
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0)
  ), (
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0)
  ), (
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,$FFFFFF,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,$FFFFFF)
  ), (
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF)
  ), (
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0)
  ), (
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0)
  ), (
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0)
  ), (
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,0),
    (0,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,0),
    (0,9,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0)
  ), (
    ($FFFFFF,0,0,0,0,0,0,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,0,0,0,0,$FFFFFF,0)
  ), (
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF)
  ), (
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0)
  ), (
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,0,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF)
  )
);



//[NUMBERS_COUNT][FONT_SIZE][FONT_SIZE]
NUMBERS := (
  (
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0)
  ), (
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0),
    ($FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0)
  ), (
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,$FFFFFF,$FFFFFF,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,0,0,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF)
  ), (
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,0,0,$FFFFFF,$FFFFFF,0,0),
    (0,0,0,0,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0)
  ), (
    ($FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,0,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,0,$FFFFFF,$FFFFFF,0)
  ), (
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0)
  ), (
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0)
  ), (
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,$FFFFFF,$FFFFFF,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,0,0,0,0),
    (0,$FFFFFF,$FFFFFF,0,0,0,0,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,0,0)
  ), (
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0)
  ), (
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,0,0,0,0,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,0,$FFFFFF,$FFFFFF),
    (0,0,0,0,0,0,$FFFFFF,$FFFFFF)
  )
);



//[ASCIISYMB1_COUNT][8][8] 
ASCIISYMB1:= (
  (  
    (0,0,0,0,0,0,0,0),  // SPACE
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0)
  ),(
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),  // E$FFFFFFCLAIMATION
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0)
  ), (  
    (0,0,$FFFFFF,0,$FFFFFF,0,0,0),  // DBL QUOTE
    (0,0,$FFFFFF,0,$FFFFFF,0,0,0),
    (0,0,$FFFFFF,0,$FFFFFF,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0)
  ), (  
    (0,0,$FFFFFF,0,0,0,$FFFFFF,0),  // SHARP
    (0,0,$FFFFFF,0,0,0,$FFFFFF,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,0,0,0,$FFFFFF,0,0),
    (0,$FFFFFF,0,0,0,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,0,0,0,$FFFFFF,0,0),
    (0,$FFFFFF,0,0,0,$FFFFFF,0,0)
  ), (
    (0,0,0,0,$FFFFFF,0,0,0),  // DOLLAR
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,0,$FFFFFF,0,0,0),
    (0,$FFFFFF,$FFFFFF,0,$FFFFFF,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,$FFFFFF,0,$FFFFFF,$FFFFFF),
    (0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,$FFFFFF,0,0,0)
  ),
  (  
    (0,0,0,0,0,0,0,0),  // PERCENT
    (0,$FFFFFF,$FFFFFF,0,0,0,$FFFFFF,0),
    (0,$FFFFFF,$FFFFFF,0,0,$FFFFFF,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,$FFFFFF,0,0,$FFFFFF,$FFFFFF,0),
    (0,$FFFFFF,0,0,0,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,0,0,0,0)
  ),
  (  
    (0,0,$FFFFFF,$FFFFFF,0,0,0,0),  // AMP
    (0,$FFFFFF,0,0,$FFFFFF,0,0,0),
    (0,$FFFFFF,0,0,$FFFFFF,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,0,0,0,$FFFFFF),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,0,$FFFFFF,0),
    (0,$FFFFFF,0,0,0,$FFFFFF,0,0),
    (0,$FFFFFF,$FFFFFF,0,$FFFFFF,0,$FFFFFF,0),
    (0,0,$FFFFFF,$FFFFFF,0,0,0,$FFFFFF)
  ), (  
    (0,0,0,$FFFFFF,0,0,0,0),  // QUOT
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0)
  ), (  
    (0,0,0,0,0,$FFFFFF,0,0),  // LPAREN
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,0,0,$FFFFFF,0,0)
  ), (  
    (0,0,$FFFFFF,0,0,0,0,0),  // RPAREN
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,$FFFFFF,0,0,0,0,0)
  ), (
    ($FFFFFF,0,0,$FFFFFF,$FFFFFF,0,0,$FFFFFF),
    (0,$FFFFFF,0,$FFFFFF,$FFFFFF,0,$FFFFFF,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,0,$FFFFFF,$FFFFFF,0,$FFFFFF,0),
    ($FFFFFF,0,0,$FFFFFF,$FFFFFF,0,0,$FFFFFF)
  ), (  
    (0,0,0,0,0,0,0,0),  // PLUS
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,0,0,0,0,0)
  ),
  (
    (0,0,0,0,0,0,0,0), // COMMA
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,0,0,0,0)
  ), 
  (  
    (0,0,0,0,0,0,0,0),  // MINUS
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0)
  ), (
    (0,0,0,0,0,0,0,0), // PERIOD
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0)
  ),
  (  
    (0,0,0,0,0,0,0,0),  // FSLASH
    (0,0,0,0,0,0,$FFFFFF,0),
    (0,0,0,0,0,$FFFFFF,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,$FFFFFF,0,0,0,0,0),
    (0,$FFFFFF,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0)
  )  
);



//[ASCIISYMB2_COUNT]*[8]*[8]
ASCIISYMB2 := (
  (
    (0,0,0,0,0,0,0,0),  // COLON
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,0,0,0,0,0)
  ),(
    (0,0,0,0,0,0,0,0),  // SEMI
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,0,0,0,0)
  ), (  
    (0,0,0,0,0,0,0,0),  // LESS THAN
    (0,0,0,0,0,$FFFFFF,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,$FFFFFF,0,0,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,0,0,$FFFFFF,0,0)
  ), (  
    (0,0,0,0,0,0,0,0),  // EQUALS
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,0,0,0,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0)
  ), (  
    (0,0,0,0,0,0,0,0),  // GREATER THAN
    (0,0,$FFFFFF,0,0,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,0,0,$FFFFFF,0,0),
    (0,0,0,0,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,0,0,0,0),
    (0,0,$FFFFFF,0,0,0,0,0)
  ), (
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0), // QUESTION
    (0,$FFFFFF,$FFFFFF,0,0,$FFFFFF,$FFFFFF,0),
    (0,$FFFFFF,0,0,0,0,$FFFFFF,0),
    (0,0,0,0,0,$FFFFFF,$FFFFFF,0),
    (0,0,0,0,$FFFFFF,$FFFFFF,0,0),
    (0,0,0,0,0,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
    (0,0,0,$FFFFFF,$FFFFFF,0,0,0)
  ), (
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0),  // AT
    (0,$FFFFFF,0,0,0,0,$FFFFFF,0),
    ($FFFFFF,0,0,$FFFFFF,$FFFFFF,0,0,$FFFFFF),
    ($FFFFFF,0,$FFFFFF,0,0,$FFFFFF,0,$FFFFFF),
    ($FFFFFF,0,$FFFFFF,0,0,$FFFFFF,$FFFFFF,0),
    ($FFFFFF,0,0,$FFFFFF,$FFFFFF,$FFFFFF,0,0),
    (0,$FFFFFF,0,0,0,0,$FFFFFF,0),
    (0,0,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,0)
  )
);



//8x8 seperate glyphs
LBRACKET := (  
  (0,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,$FFFFFF,$FFFFFF,$FFFFFF,0)
);

RBRACKET := (  
  (0,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,$FFFFFF,$FFFFFF,$FFFFFF,0,0,0,0)
);

BACKSLASH := (  
  (0,0,0,0,0,0,0,0),
  (0,$FFFFFF,0,0,0,0,0,0),
  (0,0,$FFFFFF,0,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,0,$FFFFFF,0,0),
  (0,0,0,0,0,0,$FFFFFF,0),
  (0,0,0,0,0,0,0,0)
);

CARET := (  
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,$FFFFFF,0,$FFFFFF,0,0,0),
  (0,$FFFFFF,0,0,0,$FFFFFF,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0)
);

UNDERSCORE := (  
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  ($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF)
);

BACKTICK := (  
  (0,0,$FFFFFF,0,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0)
);

LCURLYB := (  
  (0,0,0,0,0,$FFFFFF,$FFFFFF,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,$FFFFFF,$FFFFFF,0,0,0,0),
  (0,0,$FFFFFF,$FFFFFF,0,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,$FFFFFF,0,0,0),
  (0,0,0,0,0,$FFFFFF,$FFFFFF,0)
);

RCURLYB := (  
  (0,$FFFFFF,$FFFFFF,0,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,0,$FFFFFF,$FFFFFF,0,0),
  (0,0,0,0,$FFFFFF,$FFFFFF,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,0,0,$FFFFFF,0,0,0,0),
  (0,$FFFFFF,$FFFFFF,0,0,0,0,0)
);

VLINE:= (  
  (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
  (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
  (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
  (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
  (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
  (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
  (0,0,0,$FFFFFF,$FFFFFF,0,0,0),
  (0,0,0,$FFFFFF,$FFFFFF,0,0,0)
);

TILDE:= (  
  (0,0,0,0,0,0,0,0),
  (0,$FFFFFF,$FFFFFF,0,0,0,0,0),
  ($FFFFFF,0,0,$FFFFFF,0,0,$FFFFFF,0),
  (0,0,0,0,$FFFFFF,$FFFFFF,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0),
  (0,0,0,0,0,0,0,0)
);

NIL_CHAR:=
(($FFFFFF,0,0,$FFFFFF,0,$FFFFFF,0,$FFFFFF),
($FFFFFF,$FFFFFF,0,$FFFFFF,0,$FFFFFF,0,$FFFFFF),
($FFFFFF,0,$FFFFFF,$FFFFFF,0,$FFFFFF,0,$FFFFFF),
($FFFFFF,0,0,$FFFFFF,0,0,$FFFFFF,0),
(0,0,0,0,0,0,0,0),
($FFFFFF,0,0,0,0,$FFFFFF,0,0),
($FFFFFF,0,0,0,0,$FFFFFF,0,0),
($FFFFFF,$FFFFFF,$FFFFFF,$FFFFFF,0,$FFFFFF,$FFFFFF,$FFFFFF));

//code
    
    runflag:= 1;

    // Intercept SIGINT so we can shut down graphics loops.
    if (fpsignal(SIGINT,signalhandler(@doSig)) = signalhandler(SIGINT)) then begin
         writeln('Interrupted...');
         runflag := 0;
         halt;
    end;
    if (fpsignal(Sig_ERR,signalhandler(@doSig)) = signalhandler(SIG_ERR)) then begin
        //stuck in gfx mode if not careful!!
        fpIOCtl(handle,KDSETMODE, pointer(txt));        
        fpclose(handle);
        writeln('Segmentation Fault. (Bad memory access)');
        halt;
    end;
    // Attempt to open the TTY:
    fpopen(devPath,O_RDWR);

try
    handle := fpopen(devPath,O_RDWR);
    fpIOCtl(handle,KDSETMODE, pointer(gfx));
except
    writeln('Error: could not open the tty');
    halt;
end;

    Pctx := context_create;
    fontmap := fontmap_default;
//    writeln('Graphics pctx: $ ', string(@Pctx));

         
    if(pctx <> NiL) then begin
//Load image
//        jpegImage := read_jpeg_file('./nyc.jpg');
//        scaledBackgroundImage := scale(jpegImage, pctx^.width, pctx^.height);

//do graphics ops        
        clear_context(pctx);
        draw_image(0, 0, scaledBackgroundImage, pctx);
        
        draw_rect(-100, -100, 200, 200, Pctx, $FF0000);
        draw_rect(pctx^.width - 100, Pctx^.height - 100, 200, 200, Pctx, $FFFF00);
        draw_rect(pctx^.width - 100, -100, 200, 200, pctx, $00FF00);
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
        context_release(pctx);
    end;
try
    fpIOCtl(handle,KDSETMODE, pointer(txt));
except
    writeln('Error: could not close the tty');
    halt;
end;
    fpclose(handle);
    writeln('Shutdown successful.');
end.
