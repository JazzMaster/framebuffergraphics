<<<<<<< HEAD

PGlyph:=^TGlyph;
TGlyph:=record

=======
Unit Font;

interface
{$include draw.inc}

uses 
	strings;

const
	FONT_SIZE=8


type 
PGlyph:^TGlyph;
TGlyph=record
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
  data:^Integer;
  width:integer;
  height:integer;
  baseline_offset:integer;
  centerline_offset:integer;
end;

<<<<<<< HEAD
PFontMap:=^TFontMap;
TFontMap:=Record
=======
PFontMap:^TFontMap;
TFontMap=record
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
  map:PGlyph;
  size:integer;
  max_height:integer;
  max_width:integer;
end;

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

procedure fontmap_dispose(fontmap:PFontMap);
function fontmap_default:PFontMap;
procedure draw_string(x, y:integer; strint:PChar; fontmap:PFontMap; context:PContext);

procedure image_dispose(image:Pimage);
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
	strings;

const
	FONT_SIZE:=8
	ALPHA_COUNT:=26
	NUMBERS_COUNT:=10
	ASCIISYMB1_COUNT:=16
	ASCIISYMB2_COUNT:=7

type
	Alpha:=Array [0..7,0..25] of DWord;
	Numbers:=Array [0..7,0..9] of DWord;
	ASCIISYMB1:=Array [0..7,0..15] of DWord;
	ASCIISYMB2:=Array [0..7,0..6] of DWord;



procedure fontmap_dispose(fontmap_t* fontmap:PFontMap); 

begin
  dispose(fontmap^.map);
  dispose(fontmap);
end;

fontmap_t * fontmap_default() 
var
	i:integer;
	result :PFontMap;
	map :PGlyph;
  
begin
  result := malloc(sizeof(Tfontmap));
  map := malloc(128 * sizeof(Tglyph));
  result^.size := 128;
  result^.map := map;

  
  for(i := 0; i < 128; i++) begin
=======
var

	//bitmapped font- FF or 00
	charblock:array [0..7,0..7] of byte;

	Alpha:array[0..26] of charblock;
	Numbers:array[0..9] of charblock;
	ASCIISYMB1:array[0..15] of charblock;
	ASCIISYMB2:array[0..6] of charblock;

	LBRACKET:Charblock;
	RBRACKET:Charblock;
	BACKSLASH:Charblock;
	CARET:Charblock;
	UNDERSCORE:Charblock;
	BACKTICK:Charblock;
	LCURLYB:Charblock;
	RCURLYB:Charblock;
	VLINE:Charblock;
	TILDE:Charblock;
	NIL_CHAR:Charblock;


procedure fontmap_free(fontmap:PFontMap);
function fontmap_default:Pfontmap;
procedure draw_string(x,y:integer; strint:PChar; fontmap:PFontMap; context:PContext);

implementation

procedure fontmap_free(fontmap:PFontMap); 
begin
  free(fontmap.map);
  free(fontmap);
end;

function fontmap_default:PFontMap;

var
  resultFont:PFontMap;
  map:PGlyphMap;
  i:integer;

begin
  resultFont = malloc(sizeof(Tfontmap));
  map = malloc(128 * sizeof(Tglyph));

  result.size := 128;
  result.map := map;
  i:=0;

  while (i < 128) do begin
>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
    map[i].width := FONT_SIZE;
    map[i].height := FONT_SIZE;
    map[i].baseline_offset := 0;
    map[i].centerline_offset := 0;
<<<<<<< HEAD
    map[i].data :=  &NIL_CHAR;
  end;

  // Uppercase
  for(i := 0; i < ALPHA_COUNT; i++) begin
    map[65 + i].data := &ALPHA[i];
  end;

  // Lowercase
  for(i := 0; i < ALPHA_COUNT; i++) begin
    map[97 + i].data := &ALPHA[i];
  end;

  // Numbers
  for(i := 0; i < NUMBERS_COUNT; i++) begin
    map[48 + i].data := &NUMBERS[i];
  end;
  
  // Symbols:

  for(i := 0; i < ASCIISYMB1_COUNT; i++) begin
    map[32 + i].data := &ASCIISYMB1[i];
  end;

  for(i := 0; i < ASCIISYMB2_COUNT; i++) begin
    map[58 + i].data := &ASCIISYMB2[i];
  end;

  map[91].data := &LBRACKET;
  map[92].data := &BACKSLASH;
  map[93].data :=  &RBRACKET;
  map[94].data :=  &CARET;
  map[95].data :=  &UNDERSCORE;
  map[96].data :=  &BACKTICK;
  map[123].data := &LCURLYB;
  map[124].data := &VLINE;
  map[125].data := &RCURLYB;
  map[126].data := &TILDE;

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


begin


//[ALPHA_COUNT][FONT_SIZE][FONT_SIZE]
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


=======
    map[i].data = @NIL_CHAR;
    inc(i); 
  end;

  // Uppercase
  i:=0;
  while (i < ALPHA_COUNT) do begin
    map[65 + i].data = @ALPHA[i];
    inc(i);
  end;

  // Lowercase
  i:=0;
  while (i < ALPHA_COUNT) do begin
    map[65 + i].data = @ALPHA[i];
    inc(i);
  end;

  // Numbers
  i:=0;
  while (i < NUMBERS_COUNT) do begin
    map[48 + i].data =  @NUMBERS[i];
    inc(i);
  end;

  // Symbols:

  i:=0;
  while (i < ASCIISYMB1_COUNT) do begin
    map[32 + i].data =  @ASCIISYMB1[i];
    inc(i);
  end;

  i:=0;
  while (i < ASCIISYMB2_COUNT) do begin
    map[58 + i].data =  @ASCIISYMB2[i];
    inc(i);
  end;

  map[91].data = @LBRACKET;
  map[92].data = @BACKSLASH;
  map[93].data = @RBRACKET;
  map[94].data = @CARET;
  map[95].data = @UNDERSCORE;
  map[96].data = @BACKTICK;
  map[123].data = @LCURLYB;
  map[124].data = @VLINE;
  map[125].data = @RCURLYB;
  map[126].data = @TILDE;

  fontmap_default:=resultFont;
end;


procedure draw_glyph($FF,y:integer; glyph:PGlyph; conte$FFt:PConte$FFt); 

begin
  draw_array($FF, y, glyph.width, glyph.height, glyph.data, conte$FFt);
end;

procedure draw_string($FF, y:integer; string:PChar; fontmap:PFontMap; conte$FFt:Pconte$FFt);

var
	length,i:integer;
    charPtr:PGlyph;

begin
  length: = strlen(string);
  draw_rect(0, 0, length * fontmap.ma$FF_width + 2, fontmap.ma$FF_height + 4, conte$FFt, $0);
  i:=0;
  while ( i < length) do begin
    charPtr: = @fontmap.map[string[i]];
    if(charPtr = NiL) then continue;
    draw_glyph($FF + 9 * i, y + 1, charPtr, conte$FFt);
	inc(i);
  end;
end;


begin


//re define this before compile
const int ALPHA[ALPHA_COUNT][FONT_SIZE][FONT_SIZE] = {
  { 
    {0,0,0,$FF,$FF,0,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,$FF,$FF,0,0,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF} 
  }, {
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0} 
  }, {
    {0,0,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,$FF,$FF,$FF,$FF,$FF,$FF} 
  }, { 
    {$FF,$FF,$FF,$FF,$FF,$FF,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,0,0},
    {$FF,$FF,0,0,0,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,0,0}
  }, {
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF}
  }, {
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0}
  }, {
    {0,0,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,$FF,$FF,$FF,$FF,0,0}
  },{
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF}
  },{
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF}
  },{
    {0,0,0,0,0,0,$FF,$FF},
    {0,0,0,0,0,0,$FF,$FF},
    {0,0,0,0,0,0,$FF,$FF},
    {0,0,0,0,0,0,$FF,$FF},
    {0,0,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,0,0,0,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,$FF,$FF,$FF,$FF,$FF,0}
  },{
    {$FF,$FF,0,0,0,$FF,$FF,$FF},
    {$FF,$FF,0,0,$FF,$FF,0,0},
    {$FF,$FF,0,$FF,$FF,0,0,0},
    {$FF,$FF,$FF,$FF,0,0,0,0},
    {$FF,$FF,$FF,$FF,0,0,0,0},
    {$FF,$FF,0,$FF,$FF,0,0,0},
    {$FF,$FF,0,0,$FF,$FF,0,0},
    {$FF,$FF,0,0,0,$FF,$FF,$FF}
  },{
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF}
  },{
    {$FF,0,0,0,0,0,0,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,0,0,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,$FF,$FF,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF}
  },{
    {$FF,0,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,0,0,$FF,$FF},
    {$FF,$FF,0,$FF,$FF,0,$FF,$FF},
    {$FF,$FF,0,0,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF}
  },{
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,$FF,$FF,$FF,$FF,0,0}
  }, {
    {$FF,$FF,$FF,$FF,$FF,$FF,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,0,0},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0}
  }, {
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,$FF,0,$FF,$FF},
    {$FF,$FF,0,0,0,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,$FF,$FF,$FF,$FF,0,$FF}
  }, {
    {$FF,$FF,$FF,$FF,$FF,$FF,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,0,0,0,0},
    {$FF,$FF,0,$FF,$FF,$FF,0,0},
    {$FF,$FF,0,0,$FF,$FF,$FF,$FF}
  }, {
    {0,0,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,0,0,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,0,0,0,0,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0}
  }, {
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0}
  }, {
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,0,0,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,0,$FF,$FF,0,0,0}
  }, {
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {0,$FF,$FF,0,0,$FF,$FF,0},
    {0,$FF,$FF,0,0,$FF,$FF,0},
    {0,9,$FF,$FF,$FF,$FF,0,0},
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,0,0,$FF,$FF,0,0,0}
  }, {
    {$FF,0,0,0,0,0,0,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,$FF,$FF,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,0,0,$FF,$FF,$FF},
    {0,$FF,0,0,0,0,$FF,0}
  }, {
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,0,0,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,0,0,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF}
  }, {
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,0,0,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0}
  }, {
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,0,0,0,$FF,$FF,$FF},
    {0,0,0,$FF,$FF,$FF,0,0},
    {0,$FF,$FF,$FF,0,0,0,0},
    {$FF,$FF,$FF,0,0,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF}
  }
};

const int NUMBERS[NUMBERS_COUNT][FONT_SIZE][FONT_SIZE] = {
  {
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,$FF,$FF,0,$FF,$FF},
    {$FF,$FF,0,$FF,$FF,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0}
  }, {
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,$FF,$FF,$FF,0,0,0},
    {0,$FF,$FF,$FF,$FF,0,0,0},
    {$FF,$FF,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0}
  }, {
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,$FF,$FF,0,0,$FF,$FF,0},
    {0,0,0,0,$FF,$FF,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,$FF,$FF,0,0,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF}
  }, {
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,0,0,$FF,$FF,$FF},
    {0,0,0,0,$FF,$FF,0,0},
    {0,0,0,0,$FF,$FF,0,0},
    {$FF,$FF,$FF,0,0,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,$FF,$FF,$FF,$FF,0,0}
  }, {
    {$FF,$FF,0,0,0,$FF,$FF,0},
    {$FF,$FF,0,0,0,$FF,$FF,0},
    {$FF,$FF,0,0,0,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,0,0,0,$FF,$FF,0},
    {0,0,0,0,0,$FF,$FF,0},
    {0,0,0,0,0,$FF,$FF,0}
  }, {
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,0,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,0,0,0,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,0,0,0}
  }, {
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,0,0,0,0,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0}
  }, {
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,0,0,0,$FF,$FF,0},
    {0,0,0,0,$FF,$FF,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,$FF,$FF,0,0,0,0},
    {0,$FF,$FF,0,0,0,0,0},
    {$FF,$FF,0,0,0,0,0,0}
  }, {
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0}
  }, {
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,0,0,0,0,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,0,0,0,0,$FF,$FF},
    {0,0,0,0,0,0,$FF,$FF},
    {0,0,0,0,0,0,$FF,$FF}
  }
};

const int ASCIISYMB1[ASCIISYMB1_COUNT][8][8] = {
  {  
    {0,0,0,0,0,0,0,0},  // SPACE
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0}
  },{
    {0,0,0,$FF,$FF,0,0,0},  // E$FFCLAIMATION
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0}
  }, {  
    {0,0,$FF,0,$FF,0,0,0},  // DBL QUOTE
    {0,0,$FF,0,$FF,0,0,0},
    {0,0,$FF,0,$FF,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0}
  }, {  
    {0,0,$FF,0,0,0,$FF,0},  // SHARP
    {0,0,$FF,0,0,0,$FF,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,0,0,0,$FF,0,0},
    {0,$FF,0,0,0,$FF,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,0,0,0,$FF,0,0},
    {0,$FF,0,0,0,$FF,0,0}
  }, {
    {0,0,0,0,$FF,0,0,0},  // DOLLAR
    {0,0,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,$FF,$FF,0,$FF,0,0,0},
    {0,$FF,$FF,0,$FF,0,0,0},
    {0,0,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,0,0,$FF,0,$FF,$FF},
    {0,$FF,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,0,0,$FF,0,0,0}
  },
  {  
    {0,0,0,0,0,0,0,0},  // PERCENT
    {0,$FF,$FF,0,0,0,$FF,0},
    {0,$FF,$FF,0,0,$FF,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,$FF,0,0,$FF,$FF,0},
    {0,$FF,0,0,0,$FF,$FF,0},
    {0,0,0,0,0,0,0,0}
  },
  {  
    {0,0,$FF,$FF,0,0,0,0},  // AMP
    {0,$FF,0,0,$FF,0,0,0},
    {0,$FF,0,0,$FF,0,0,0},
    {0,0,$FF,$FF,0,0,0,$FF},
    {0,0,$FF,$FF,$FF,0,$FF,0},
    {0,$FF,0,0,0,$FF,0,0},
    {0,$FF,$FF,0,$FF,0,$FF,0},
    {0,0,$FF,$FF,0,0,0,$FF}
  }, {  
    {0,0,0,$FF,0,0,0,0},  // QUOT
    {0,0,0,$FF,0,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0}
  }, {  
    {0,0,0,0,0,$FF,0,0},  // LPAREN
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,0,0,$FF,0,0}
  }, {  
    {0,0,$FF,0,0,0,0,0},  // RPAREN
    {0,0,0,$FF,0,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,$FF,0,0,0,0,0}
  }, {
    {$FF,0,0,$FF,$FF,0,0,$FF},
    {0,$FF,0,$FF,$FF,0,$FF,0},
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF},
    {0,0,$FF,$FF,$FF,$FF,0,0},
    {0,$FF,0,$FF,$FF,0,$FF,0},
    {$FF,0,0,$FF,$FF,0,0,$FF}
  }, {  
    {0,0,0,0,0,0,0,0},  // PLUS
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,0,0,0,0,0}
  },
  {
    {0,0,0,0,0,0,0,0}, // COMMA
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,$FF,$FF,0,0,0,0}
  }, 
  {  
    {0,0,0,0,0,0,0,0},  // MINUS
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0}
  }, {
    {0,0,0,0,0,0,0,0}, // PERIOD
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0}
  },
  {  
    {0,0,0,0,0,0,0,0},  // FSLASH
    {0,0,0,0,0,0,$FF,0},
    {0,0,0,0,0,$FF,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,$FF,0,0,0,0,0},
    {0,$FF,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0}
  }  
};

const int ASCIISYMB2[ASCIISYMB2_COUNT][8][8] = {
  {
    {0,0,0,0,0,0,0,0},  // COLON
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,0,0,0,0,0}
  },{
    {0,0,0,0,0,0,0,0},  // SEMI
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,$FF,$FF,0,0,0,0}
  }, {  
    {0,0,0,0,0,0,0,0},  // LESS THAN
    {0,0,0,0,0,$FF,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,$FF,0,0,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,0,0,$FF,0,0}
  }, {  
    {0,0,0,0,0,0,0,0},  // EQUALS
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,0,0,0,0,0,0},
    {0,0,$FF,$FF,$FF,$FF,$FF,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0}
  }, {  
    {0,0,0,0,0,0,0,0},  // GREATER THAN
    {0,0,$FF,0,0,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,0,0,$FF,0,0},
    {0,0,0,0,$FF,0,0,0},
    {0,0,0,$FF,0,0,0,0},
    {0,0,$FF,0,0,0,0,0}
  }, {
    {0,0,$FF,$FF,$FF,$FF,0,0}, // QUESTION
    {0,$FF,$FF,0,0,$FF,$FF,0},
    {0,$FF,0,0,0,0,$FF,0},
    {0,0,0,0,0,$FF,$FF,0},
    {0,0,0,0,$FF,$FF,0,0},
    {0,0,0,0,0,0,0,0},
    {0,0,0,$FF,$FF,0,0,0},
    {0,0,0,$FF,$FF,0,0,0}
  }, {
    {0,0,$FF,$FF,$FF,$FF,0,0},  // AT
    {0,$FF,0,0,0,0,$FF,0},
    {$FF,0,0,$FF,$FF,0,0,$FF},
    {$FF,0,$FF,0,0,$FF,0,$FF},
    {$FF,0,$FF,0,0,$FF,$FF,0},
    {$FF,0,0,$FF,$FF,$FF,0,0},
    {0,$FF,0,0,0,0,$FF,0},
    {0,0,$FF,$FF,$FF,$FF,0,0}
  }
};


const int LBRACKET[8][8] = {  
  {0,0,0,0,$FF,$FF,$FF,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,$FF,$FF,$FF,0}
};

const int RBRACKET[8][8] = {  
  {0,$FF,$FF,$FF,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,$FF,$FF,$FF,0,0,0,0}
};

const int BACKSLASH[8][8] = {  
  {0,0,0,0,0,0,0,0},
  {0,$FF,0,0,0,0,0,0},
  {0,0,$FF,0,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,0,$FF,0,0},
  {0,0,0,0,0,0,$FF,0},
  {0,0,0,0,0,0,0,0}
};

const int CARET[8][8] = {  
  {0,0,0,$FF,0,0,0,0},
  {0,0,$FF,0,$FF,0,0,0},
  {0,$FF,0,0,0,$FF,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0}
};

const int UNDERSCORE[8][8] = {  
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF}
};

const int BACKTICK[8][8] = {  
  {0,0,$FF,0,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0}
};

const int LCURLYB[8][8] = {  
  {0,0,0,0,0,$FF,$FF,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,$FF,$FF,0,0,0,0},
  {0,0,$FF,$FF,0,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,$FF,0,0,0},
  {0,0,0,0,0,$FF,$FF,0}
};

const int RCURLYB[8][8] = {  
  {0,$FF,$FF,0,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,0,$FF,$FF,0,0},
  {0,0,0,0,$FF,$FF,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,0,0,$FF,0,0,0,0},
  {0,$FF,$FF,0,0,0,0,0}
};

const int VLINE[8][8] = {  
  {0,0,0,$FF,$FF,0,0,0},
  {0,0,0,$FF,$FF,0,0,0},
  {0,0,0,$FF,$FF,0,0,0},
  {0,0,0,$FF,$FF,0,0,0},
  {0,0,0,$FF,$FF,0,0,0},
  {0,0,0,$FF,$FF,0,0,0},
  {0,0,0,$FF,$FF,0,0,0},
  {0,0,0,$FF,$FF,0,0,0}
};

const int TILDE[8][8] = {  
  {0,0,0,0,0,0,0,0},
  {0,$FF,$FF,0,0,0,0,0},
  {$FF,0,0,$FF,0,0,$FF,0},
  {0,0,0,0,$FF,$FF,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0}
};

const int NIL_CHAR[8][8] ={{$FF,0,0,$FF,0,$FF,0,$FF},
                          {$FF,$FF,0,$FF,0,$FF,0,$FF},
                          {$FF,0,$FF,$FF,0,$FF,0,$FF},
                          {$FF,0,0,$FF,0,0,$FF,0},
                          {0,0,0,0,0,0,0,0},
                          {$FF,0,0,0,0,$FF,0,0},
                          {$FF,0,0,0,0,$FF,0,0},
                          {$FF,$FF,$FF,$FF,0,$FF,$FF,$FF}};

>>>>>>> 618b678e8e7c35c034a4299db3396431c60d0b13
end.
