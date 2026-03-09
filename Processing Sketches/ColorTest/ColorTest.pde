PGraphics bufferR;
PGraphics bufferG;
PGraphics bufferB;

void setup(){
  size(800, 600);
  bufferR = createGraphics(800, 600);
  bufferG = createGraphics(800, 600);
  bufferB = createGraphics(800, 600);
  noiseDetail(9, 0.5);
}

void draw(){
  background(125,125,125);
  drawNoise(bufferR, color(0xFF, 0x00, 0x00), 2.25 + frameCount * 0.01);
  image(bufferR, 0, 0);
  drawNoise(bufferG, color(0x00, 0xFF, 0x00), 4.5 + frameCount * 0.01);
  image(bufferG, 0, 0);
  drawNoise(bufferB, color(0x00, 0x00, 0xFF), 4.125 + frameCount * 0.01);
  image(bufferB, 0, 0);
  text(frameRate, width/2.0, height/2.0);
}


void drawNoise(PGraphics buffer, color c , float z){
  buffer.beginDraw();
  buffer.loadPixels();
  for(int y = 0 ; y < height; y++){
    for(int x = 0 ; x < width; x++){
      buffer.pixels[y * width + x] = color( c, round(255 *
        constrainedNoise(
          x * 0.01,
          y * 0.01,
          z,
          -0.5,
          5.0
        )
      ));
    } 
  }
  buffer.updatePixels();
  buffer.endDraw();
}

float constrainedNoise(float x, float y, float z, float offset, float gain){
  return gain * ( noise(x, y, z) + offset);
}
