import processing.sound.*;

PShader shader;

InputAnalyzer hang;
InputAnalyzer bodhran;
InputAnalyzer kalimba;

float hangOffset = 0.0;
float kalimbaOffset = 0.0;
float bodhranOffset = 0.0;

float rOffset = 10.0;
float gOffset = 120.0;
float bOffset = 240.0;
float shiftOffset = -300.0;

float hangAmplitude = 0.0;
float kalimbaAmplitude = 0.0;
float bodhranAmplitude = 0.0;

// Wall dimensions for projection: 361" x 144" - projector location? distance back?

void setup(){
  //fullScreen(P2D);
  size(1280, 720, P2D);
  noiseDetail(7, 0.5);
  noStroke();
  
  // Load and compile shader
  shader = loadShader("shader.frag");
  // We only have to set this once
  shader.set("u_resolution", float(width), float(height));
  
  try {
    Sound s = new Sound(this);
    String device = "Scarlett 18i8 USB";
    s.inputDevice(device);
  } catch(Exception e){
    print("While initializing Sound Object: " + e);
    exit();
  }

  bodhran = new InputAnalyzer(this, 0, 2048, 1024);  
  hang = new InputAnalyzer(this, 1, 2048, 1024);
  kalimba = new InputAnalyzer(this, 2, 2048, 1024);
}

void draw(){
  //read analyzers
  hangAmplitude = hang.getAmplitude();
  hangOffset += hangAmplitude;
  
  bodhranAmplitude = bodhran.getAmplitude();
  bodhranOffset += bodhranAmplitude;
  
  kalimbaAmplitude = kalimba.getAmplitude();
  kalimbaOffset += kalimbaAmplitude;
  
  // Set uniforms
  shader.set("u_mouse", mouseX/float(width), mouseY/float(height));
  shader.set("u_time", millis() / 1000.0);
  shader.set("u_offset", kalimbaOffset);
  
  shader(shader);
  rect(0, 0, width, height);
  
  pixelsort();
}

void pixelsort(){
  loadPixels();

  int[] column = new int[height];
  int amount;
  
  for(int x = 0; x < width; x++){
    for(int y = 0; y < height; y++){
      column[y] = pixels[y * width + x];
    }
    column = sort(column);
    amount = round(50 * hangAmplitude * column.length * (noise(
      0.1 * x,
      0.125 * height * hangOffset)-0.5
    ));
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
