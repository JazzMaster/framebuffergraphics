TImage=record
  data:^Integer;
  width,height:integer;
end;

Tcontext=record
  data:PInt;
  width,height:integer;
  fb_name:PChar;
  fb_file_desc:integer;
end;

var
	PContext:^Tcontext;
	PImage:^TImage;

procedure image_free(image:PImage);
procedure set_pixel(x,y:integer; context:Pcontext; color:integer);
function  scale(image:PImage, w,h:integer):Pimage;
procedure draw_array(x,y,w,h:integer; someArray:PInt; context:Pcontext);
procedure draw_image(x,y:integer; image:PImage, context:Pcontext);
procedure draw_rect(x,y,w,h:integer; context:PContext,color:integer);
procedure clear_context_color(context:PContext; color:integer);
procedure clear_context(context:PContext;);
procedure test_pattern(context:PContext;);
procedure context_release(context:Pcontext);
function context_create:Pcontext;


uses
	cthreads,strings,math,crt,ctypes,signals,BaseUnix,sysutils;
