Unit Font;

interface
{$include draw.inc}

uses 
	strings;

const
	FONT_SIZE=8

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
    map[i].width := FONT_SIZE;
    map[i].height := FONT_SIZE;
    map[i].baseline_offset := 0;
    map[i].centerline_offset := 0;
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

end.
