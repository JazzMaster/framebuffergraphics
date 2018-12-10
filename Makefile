CC=fpc
BINFILE=PasFBdemo

all: fbdemo

%.o: %.pas
	$(CC)  -o $(BINFILE)

fbdemo: main.pas draw.pas font.pas img-png.pas img-jpeg.pas
	$(CC) -o $(BINFILE)

clean: 
	rm -rf *.o *.ppu $(BINFILE)
