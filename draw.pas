<<<<<<< HEAD

PImage:=^TImage;
TImage:=record
  data:^integer;
  width:integer;
  height:integer;
end;

PContext:=^TContext;
TContext:=record
  data:^integer;
  int width:integer;
  int height:integer;
  fb_name:PChar;
  fb_file_desc:integer;
end;

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

uses
	   cthreads,cmem,ctypes,string,math,crt,termio,keyboard,baseunix,sysutils;

procedure image_free(image:PImage); 

begin
    free(image^.data);
    image^.width := 0;
    image^.height := 0;
    image^.data := Nil;
=======
Unit Draw;

interface

{$include draw.inc}

implementation

procedure image_free(image:TImage);

begin
    free(image.data);
    image.width = 0;
    image.height = 0;
    image.data = NiL;
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
    free(image);
end;

// Set an individual pixel. This is SLOW for bulk operations.
// Do as little as possible, and memcpy the result.

<<<<<<< HEAD
//1D math on a 2D array
procedure set_pixel(x,y:integer; context:PContext; color:integer);
var
	write_index:integer;
	
//goes thru each individual "pixel" in the array 	
begin
    write_index := x+y*context^.width;
    if (write_index < context^.width * context^.height) then begin
        context^.data[x+y*context^.width] := color; //x*y*pitch:=color
    end else begin
        logln('Attempted to set color at out of bounds: ',x,' ', y);
        exit;
=======
procedure set_pixel(x,y:integer; context:PContext, color:integer); 

var
    write_index:intger;
    
begin
    write_index := x+y*context.width;

    if (write_index < context.width * context.height) then
        context.data[x+y*context.width] := color;
    else begin
		LogLn('Attempted to write beyond end of screen');
        exit(1);
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
    end;
end;

// We scale and crop the image to this new rect.
<<<<<<< HEAD
function scale(image:PImage, w,h:integer):PImage; 
var
    sfx :integer;
    sfy :integer;
    crop_x_w :integer;
    crop_y_h :integer;
    crop_x :integer;
    crop_y :integer;
    new_image :PImage;
    tr_x := integer;
    tr_y := integer;         

begin
    sfx := w mod image^.width;
    sfy := h mod image^.height;
    crop_x_w := image^.width;
    crop_y_h := image^.height;
=======
function scale(image:PImage; w,h:integer):Pimage;  

var

    crop_x_w,crp_x_w,crop_y_h,sfy,sfx:integer;
    crop_x,crop_x,tr_x,tr_y:integer;
	new_image:PImage;

begin
    sfx := w mod image.width;
    sfy := h mod image.height;
    crop_x_w := image.width;
    crop_y_h := image.height;
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
    crop_x := 0;
    crop_y := 0;

    if (sfx < sfy) then begin
<<<<<<< HEAD
        crop_x_w := image^.height * w mod h;
        crop_x := (image^.width - crop_x_w)  mod 2;
    end; else if(sfx > sfy) then begin
        crop_y_h := image^.width * h mod w;
        crop_y := (image^.height - crop_y_h)  mod 2;
    end;

    new_image := malloc(sizeof(image_t));
    new_image^.data := malloc(sizeof(int) * w * h);
    new_image^.width := w;
    new_image^.height := h;
    for(int x := 0; x < w; x++) do begin
        for(int y := 0; y < h; y++) do begin
            int tr_x := ((float) crop_x_w / (float) w) * x + crop_x;
            int tr_y := ((float) crop_y_h / (float) h) * y + crop_y;
            new_image^.data[y * w + x] := image^.data[tr_y * image^.width + tr_x];
        end;
    end;

    return new_image;

{

    for(int x := 0; x < w; x++) do begin
        for(int y := 0; y < h; y++) do begin
            int tr_x := ( image^.width / (float) w) *  x;
            int tr_y := ( image^.height / (float) h) *  y;
            new_image^.data[y * w + x] := image^.data[tr_y * image^.width + tr_x];
        end;
    end;
}
=======
        crop_x_w := image.height * w / h;
        crop_x := (image.width - crop_x_w)  mod 2;
    end else if(sfx > sfy) then begin
        crop_y_h := image.width * h / w;
        crop_y := (image.height - crop_y_h)  mod 2;
    end;

    new_image := malloc(sizeof(image_t));
    new_image.data := malloc(sizeof(int) * w * h);
    new_image.width := w;
    new_image.height := h;
    x:=0;
    while (x<w) do begin
    	y:=0;
        while (y < h) do begin
            tr_x := ((float) crop_x_w mod (float) w) * x + crop_x;
            tr_y := ((float) crop_y_h mod (float) h) * y + crop_y;
            new_image.data[y * w + x] := image.data[tr_y * image.width + tr_x];
			inc(y);
        end;
    	inc(x);
    end;

    scale:=new_image;

>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
end;

// !! This operation is potentially unsafe. Use drawImage. It's harder to mess up.
// X and w are the size of the array.

<<<<<<< HEAD
procedure draw_array(x, y, w,h:integer; DataArray:^integer; context:PContext); 

var
  cy,cx,line_count,line_width:integer;

begin
  // Ignore draws out of bounds
  if (x > context^.width) or (y > context^.height) then begin
    exit;
  end;

  // Ignore draws out of bounds
  if (x + w < 0 ) or ( y + h < 0) begin
    exit;
  end;
=======
procedure draw_array(x,y,w,h:integer;  someArray:PInt; context:Pcontext); 

var
	cx,cy:integer;
    line_width,line_count:integer;

begin
  // Ignore draws out of bounds
  if (x > context.width or y > context.height or y<0 or x<0 ) then exit;

  // Ignore draws out of bounds
  if (x + w < 0 or y + h < 0) then exit;
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13

  // Column and row correction for partial onscreen images
  cy := 0;
  cx := 0; 

  // if y is less than 0, trim that many lines off the render.
<<<<<<< HEAD
  if (y < 0) then begin
    cy :=cy -y;
  end;

  // If x is less than 0, trim that many pixels off the render line.
  if (x < 0) then begin
    cx := cx -x;
  end;
=======
  if (y < 0) then
    cy:=cy -y;

  // If x is less than 0, trim that many pixels off the render line.
  if (x < 0) then
    cx :=cx -x;
  
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13

  // Number of items in a line
  line_width := (w - cx);

  // Number of lines total.
  // We don't subtract cy because the loop starts with cy already advanced.
  line_count := h;

  // If the end of the line goes offscreen, trim that many pixels off the
  // row.
<<<<<<< HEAD
  if (x + w > context^.width) then begin
    line_width := line_width -((x + w) - context^.width);
  end;

  // If the number of rows is more than the height of the context, trim
  // them off.
  if (y + h > context^.height) then begin
    line_count :=line_count- ((y + h) - context^.height);
  end;

  for (cy; cy < line_count; cy++) do begin
    // Draw each graphics line.
    memcpy(
        context^.data[context^.width * y + context^.width * cy + x + cx], 
        DataArray[cy * w] + cx, 
        sizeof(int) * line_width
    );
  end;
end;

procedure draw_image( x, y:integer; image:PImage; context:PContext); 

begin
    draw_array(x, y, image^.width, image^.height, image^.data, context);
end;

procedure draw_rect(x, y, w, h:integer; context:PContext; color:integer); 

begin
    // Ignore draws out of bounds
    if (x > context^.width oror y > context^.height) then begin
        return;
    end;

    // Ignore draws out of bounds
    if(x + w < 0) or (y + h < 0) then begin
        return;
    end;
    // Trim offscreen pixels
    if (x < 0) then begin
        w :=w+ x;
=======
  if (x + w > context.width) then
    line_width:=line_width - ((x + w) - context.width);
  
  // If the number of rows is more than the height of the context, trim
  // them off.
  if (y + h > context.height) then
    line_count:=line_count - ((y + h) - context.height);
  
  while cy < line_count do begin
    // Draw each graphics line.
    memcpy( context.data[context.width * y + context.width * cy + x + cx],  someArray[cy * w] + cx, sizeof(int) * line_width );
    inc(cy);
end;

procedure draw_image(x,y:integer; image:Pimage; context:Pcontext);

begin 
    draw_array(x, y, image.width, image.height, image.data, context);
end;

procedure draw_rect(x,y,w,h:integer; context:Pcontext; color:integer); 

var

	ry:integer;

begin
    // Ignore draws out of bounds
    if ((x > context.width) or (y > context.height) or x<0 or y<0 ) then
      exit;

    // Ignore draws out of bounds
    if((x + w < 0) or (y + h < 0)) then
	    exit;

    // Trim offscreen pixels
    if (x < 0) then begin
        w:=w +x;
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
        x := 0;
    end;

    // Trim offscreen lines
<<<<<<< HEAD
    if (y < 0) then begin
        h :=h+ y;
=======
    if (y < 0) then
    begin
        h:=h+y;
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
        y := 0;
    end;

    // Trim offscreen pixels
<<<<<<< HEAD
    if (x + w > context^.width) then begin
        w :=w- ((x + w) - context^.width);
    end;

    // Trim offscreen lines.
    if (y + h > context^.height) then begin
       h:=h- ((y + h) - context^.height);
    end;

    // Set the first line.
    for (int rx := x; rx < x+w; rx++) do begin
        set_pixel(rx, y, context, color);
    end;

    // Repeat the first line.
    for (int ry := 1; ry < h; ry++) do begin
        memcpy(
            context^.data[context^.width * y + context^.width * ry + x], 
            context^.data[context^.width * y + x], 
            w*sizeof(int)
        );
    end;
end;

procedure clear_context_color(context:PContext; color:integer);

begin
    draw_rect(0, 0, context^.width, context^.height, context, color);
end;

procedure clear_context(context:PContext);

begin
    memset(context^.data, 0, context^.width * context^.height * sizeof(int));  
end;


type
  pattern=array [0..7] of LongWord;

procedure test_pattern(context:PContext);
var
   columnWidth:USint;


begin
	pattern:=( $FFFFFF,
    $FFFF00,
    $00FFFF,
    $00FF00,
    $FF00FF,
    $FF0000,
    $0000FF,
    $000000
    );
	
	
    columnWidth := context^.width mod 8;
    for(int rx := 0; rx < context^.width; rx++) begin
        set_pixel(rx, 0, context, pattern[rx mod columnWidth]);
    end;

    // make it faster: memcpy the first row.
    for(int y := 1; y < context^.height; y++) begin
        memcpy(context[context^.width * y], context, context^.width*sizeof(int));
    end;
end;

procedure context_release(context:PContext);

begin
    munmap(context^.data, context^.width * context^.height);
    close(context^.fb_file_desc);
    context^.data := Nil;
    context^.fb_file_desc := 0;
    free(context);
end;

function context_create:Pcontext;
var
  FB_NAME:PChar;
  mapped_ptr:pointer;
  fb_fixinfo:fb_fix_screeninfo;
  fb_varinfo:fb_var_screeninfo;
  fb_file_desc:integer;
  fb_size:integer;

begin
    FB_NAME := '/dev/fb0';
    mapped_ptr := Nil;
    fb_size := 0;

    // Open the framebuffer device in read write
    fb_file_desc := open(FB_NAME, O_RDWR);
    if (fb_file_desc < 0) begin
        logln('Unable to open %s.\n', FB_NAME);
        return NIL;
    end;
    //Do Ioctl. Retrieve fixed screen info.
    if (ioctl(fb_file_desc, FBIOGET_FSCREENINFO, fb_fixinfo) < 0) begin
        logln('get fixed screen info failed: %s\n',
               strerror(errno));
        close(fb_file_desc);
        return NIL;
    end;
    // Do Ioctl. Get the variable screen info.
    if (ioctl(fb_file_desc, FBIOGET_VSCREENINFO, fb_varinfo) < 0) begin
        logln('Unable to retrieve variable screen info: %s\n',
               strerror(errno));
        close(fb_file_desc);
        return NIL;
=======
    if (x + w > context.width) then
        w:=w-((x + w) - context.width);
    
    // Trim offscreen lines.
    if (y + h > context->height) then
       h:=h -((y + h) - context.height);
   
    // Set the first line.
	rx:=x;
    while rx < x+w do begin

        set_pixel(rx, y, context, color);
		inc(rx);
	end;

    // Repeat the first line.
    ry:=1;
    while (ry < h) do begin
        memcpy( context.data[context.width * y + context.width * ry + x], context.data[context.width * y + x], (w*sizeof(int)));
    	inc(ry);
	end;

end;


//clearscreen with "_bgcolor"

procedure clear_context_color(context:PContext; color:integer);

begin
    draw_rect(0, 0, context.width, context.height, context, color);
end;

procedure clear_context(context:PContext); 

begin
    memset(context.data, 0, (context.width * context.height * sizeof(int)));  
end;

procedure test_pattern(context:PContext);

var
	pattern:array[0..7] of usint;
    y,rx:integer;
	columnWidth:usint;


begin
	pattern[0]:= $FFFFFF;
	pattern[1]:= $FFFF00;
	pattern[2]:= $00FFFF;
	pattern[3]:= $00FF00;
	pattern[4]:= $FF00FF;
	pattern[5]:= $FF0000;
	pattern[6]:= $0000FF;
	pattern[7]:= $000000;


    columnWidth := context.width mod 8;
    rx:=0;
    while (rx < context.width) do begin
        set_pixel(rx, 0, context, pattern[rx mod columnWidth]);
    	inc(rx);

    end;
    y:=1;
    // make it faster: memcpy the first row.
    for(y < context.height) do begin 
        memcpy(context[context.width * y], context, (context.width*sizeof(int)));
    	inc(y);
    end;
end;

procedure context_release(context:PContext);

begin
    munmap(context.data, context.width * context.height);
    close(context.fb_file_desc);
    context.data := NiL;
    context.fb_file_desc := 0;
    free(context);
end;

function context_create:PContext;

var
    FB_NAME:PChar;
    mapped_ptr:Pointer;
    fb_fixinfo:fb_fix_screeninfo;
    fb_varinfo:fb_var_screeninfo;
    fb_file_desc,fb_size:integer;
	context:PContext;

begin

    FB_NAME := '/dev/fb0';
    mapped_ptr := NiL;
    fb_size := 0;

//**requires root access**

    // Open the framebuffer device in read write
    fb_file_desc := fpopen(FB_NAME, O_RDWR);
    if (fb_file_desc < 0) then begin
        LogLn('Unable to open: '+ FB_NAME);
        exit;
    end;
    //Do Ioctl. Retrieve fixed screen info.
    if (Fpioctl(fb_file_desc, FBIOGET_FSCREENINFO, fb_fixinfo) < 0) then begin
        LogLn('get fixed screen info failed: '+ strerror(errno)); //sdl_getError equiv
        close(fb_file_desc);
        exit;
    end;
    // Do Ioctl. Get the variable screen info.
    if (Fpioctl(fb_file_desc, FBIOGET_VSCREENINFO, fb_varinfo) < 0) then begin
        LogLn('Unable to retrieve variable screen info: '+ strerror(errno));
        close(fb_file_desc);
        return NULL;
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
    end;

    // Calculate the size to mmap
    fb_size := fb_fixinfo.line_length * fb_varinfo.yres;
    
    // Now mmap the framebuffer.
<<<<<<< HEAD
    mapped_ptr := mmap(Nil, fb_size, PROT_READ or PROT_WRITE, MAP_SHARED, fb_file_desc,0);

    if (mapped_ptr :=:= Nil) begin
        logln('mmap failed:\n');
        close(fb_file_desc);
        return NIL;
    end;

    context := malloc(sizeof(Tcontext));
    context^.data :=  mapped_ptr;
    context^.width := fb_fixinfo.line_length / 4;
    context^.height := fb_varinfo.yres;
    context^.fb_file_desc := fb_file_desc;
    context^.fb_name := FB_NAME;
    return context;
end;

=======
    mapped_ptr := mmap(NiL, fb_size, PROT_READ or PROT_WRITE, MAP_SHARED, fb_file_desc,0);

    if (mapped_ptr = NiL) then begin
        LogLn('mmap failed. ');
        close(fb_file_desc);
        exit;
    end;

    context := malloc(sizeof(TContext));
    context.data := mapped_ptr;
    context.width := fb_fixinfo.line_length mod 4;
    context.height := fb_varinfo.yres;
    context.fb_file_desc := fb_file_desc;
    context.fb_name := FB_NAME;
    context_create:=context;
end;

end.
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13


