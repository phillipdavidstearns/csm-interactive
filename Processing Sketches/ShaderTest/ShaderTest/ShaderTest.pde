// Copyright 2015 Patricio Gonzalez Vivo (http://patriciogonzalezvivo.com)

PShader shader;

void setup() {
  size(1280, 720, P2D);
  noStroke();
  
  // Load and compile shader
  shader = loadShader("shader.frag");
  // We only have to set this once
  shader.set("u_resolution", float(width), float(height));
}

void draw() {
  // Set uniforms
  shader.set("u_mouse", mouseX/float(width), mouseY/float(height));
  shader.set("u_time", millis() / 1000.0);

  // Replace the default pipeline programs with our shader
  
  shader(shader);
  rect(0, 0, width, height);
  loadPixels();
  int[] col = new int[height];
  for(int x=0; x < width; x++){
    for(int y=0; y < height; y++){
      col[y] = pixels[y * width + x];
    }
    col=sort(col);
    for(int y=0; y < height; y++){
      pixels[y * width + x] = col[y];
    }
  }
  updatePixels();
  text(frameRate, width/2.0, height/2.0);
}

void keyPressed(){
  // Reload shader everytime a key is press
  shader = loadShader("shader.frag");
}
