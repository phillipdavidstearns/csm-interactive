import processing.sound.*;
InputAnalyzer hang;
InputAnalyzer bohdrain;
InputAnalyzer kalimba;

float hangOffset = 0.0;
float kalimbaOffset = 0.0;
float bohdranOffset = 0.0;

float rOffset = 10.0;
float gOffset = 120.0;
float bOffset = 240.0;
float shiftOffset = -300.0;

// Wall dimensions for projection: 361" x 144" - projector location? distance back?

void setup(){
  size(1280, 720);
  try {
    Sound s = new Sound(this);
    String device = "Scarlett 18i8 USB";
    s.inputDevice(device);
  } catch(Exception e){
    print("While initializing Sound Object: " + e);
    exit();
  }
  
  hang = new InputAnalyzer(this, 0, 2048, 1024);
  kalimba = new InputAnalyzer(this, 2, 2048, 1024);
  colorMode(HSB, 255);
}

void draw(){
  strokeWeight(2);
  noFill();
  stroke(255);
  
  draw2DNoise();

}

void draw2DNoise(){

  float hangAmplitude = hang.getAmplitude();
  hangOffset += hangAmplitude;
  
  float kalimbaAmplitude = kalimba.getAmplitude();
  kalimbaOffset += kalimbaAmplitude;
  
  noiseDetail(7, 0.5);
  loadPixels();
  
  //3D Perlin Noise => 2D RGB colorfield
  for(int y = 0; y < height; y++){
    for(int x = 0; x < width; x++){
      pixels[y * width + x] = color(
        colorChannelNoise3D(x, y, kalimbaOffset, rOffset),
        colorChannelNoise3D(x, y, kalimbaOffset, gOffset),
        colorChannelNoise3D(x, y, kalimbaOffset, bOffset)
      );
    }
  }
  
  int[] column = new int[height];
  int amount;
  
  for(int x = 0; x < width; x++){
    for(int y = 0; y < height; y++){
      column[y] = pixels[y * width + x];
    }
    column = sort(column);
    amount = round(10 * hangAmplitude * column.length * (noise(shiftOffset + 0.25 * x, 0.5 * height * hangOffset)-0.5));
    column = shift(column, amount);
    for(int y = 0; y < height; y++){
      pixels[y * width + x] = column[y];
    }
  }

  updatePixels();
}

int[] shift(int[] array, int amount){
  int[] shifted = new int[array.length];
  int j = 0;
  for(int i = 0; i < shifted.length; i++){
    j = (i + amount) % array.length;
    shifted[i] = array[j < 0 ? j + array.length : j];
  }
  return shifted;
}

int colorChannelNoise3D(float x, float y, float z, float offset){
  return round( 255 * noise(
    offset + ( y / float(height)),
    offset + ( x / float(width)),
    offset + z
  ));
}
