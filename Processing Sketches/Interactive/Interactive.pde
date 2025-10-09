import processing.sound.*;

PShader shader;
PGraphics pg;

boolean sortShader = false;
boolean sortFeedback = false;
boolean reverseShaderSort = false;
boolean reverseFeedbackSort = false;

InputAnalyzer hang;
InputAnalyzer bodhran;
InputAnalyzer kalimba;

float hangOffset = 0.0;
float kalimbaOffset = 0.0;
float bodhranOffset = 0.0;

float hangAmplitude = 0.0;
float kalimbaAmplitude = 0.0;
float bodhranAmplitude = 0.0;

float blend = 0.0;
float rate = 0.001;

// Wall dimensions: 361" x 144" - projector location? distance back?
// Projector Aspect Ratio: 16:9
// Distance between projection wall and rear wall: 17' 5" (209")
// Max Projection Dimensions (16:9): 256" x 144" (~294" diagonal)

ArrayList<Palette> palettes;

Palette activePaletteA;
Palette activePaletteB;
Palette mixedPalette;

void setup() {
  pixelDensity(1);
  fullScreen(P2D, 2);
  size(1280, 720, P2D);
  noiseDetail(7, 0.5);
  noStroke();

  loadPalettes();
  activePaletteA = palettes.get(int(random(palettes.size())));
  activePaletteA.randomizePastels();
  activePaletteB = palettes.get(int(random(palettes.size())));
  activePaletteB.randomizePastels();


  // Load and compile shader
  shader = loadShader("shader.frag");
  // We only have to set resolution once
  shader.set("u_resolution", float(width), float(height));
  pg = createGraphics(width, height, P2D);
  shader.set("u_texture", pg);

  try {
    Sound s = new Sound(this);
    String device = "Scarlett 18i8 USB";
    s.inputDevice(device);
  }
  catch(Exception e) {
    print("While initializing Sound Object: " + e);
    //exit();
  }

  bodhran = new InputAnalyzer(this, 0, 2048, 1024);
  hang = new InputAnalyzer(this, 1, 2048, 1024);
  kalimba = new InputAnalyzer(this, 2, 2048, 1024);
}

void draw() {
  //read analyzers

  bodhranAmplitude = bodhran.getAmplitude();
  bodhranOffset += bodhranAmplitude;

  hangAmplitude = hang.getAmplitude();
  hangOffset += hangAmplitude;

  kalimbaAmplitude = kalimba.getAmplitude();
  kalimbaOffset += kalimbaAmplitude;

  float zoomFactor = noise(0.1, sin(2 * PI * frameCount / 12000.0));
  float noiseZoomFactor = 2.5 * noise(0.1, sin(2 * PI * frameCount / 11000.0)) + 2.5;

  float gain1 = 10.0 * bodhranAmplitude + 0.75;
  float gain2 = 10.0 * hangAmplitude + 0.75;
  float gain3 = 10.0 * kalimbaAmplitude + 0.75;

  //float gain1 = 1.0;
  //float gain2 = 1.0;
  //float gain3 = 1.0;

  // Set uniforms
  shader.set("u_texture", pg);
  shader.set("u_time", millis() * 0.00001);
  shader.set("u_offset1", bodhranOffset);
  shader.set("u_offset2", hangOffset);
  shader.set("u_offset3", kalimbaOffset);
  shader.set("u_feedbackZoom", zoomFactor);
  shader.set("u_noiseZoom", noiseZoomFactor);
  shader.set("u_gain1", gain1);
  shader.set("u_gain2", gain2);
  shader.set("u_gain3", gain3);
  //shader.set("u_gain1", 5 * bodhranAmplitude * noise(0.2, sin(2 * PI * frameCount / 13000.0)));
  //shader.set("u_gain2", 5 * hangAmplitude * noise(0.3, sin(2 * PI * frameCount / 14000.0)));
  //shader.set("u_gain3", 5 * kalimbaAmplitude * noise(0.4, sin(2 * PI * frameCount / 15000.0)));
  shader.set("u_gain4", 1.0);
  shader.set("u_pedistal1", 0.0);
  shader.set("u_pedistal2", 0.0);
  shader.set("u_pedistal3", 0.0);
  shader.set("u_pedistal4", 0.0);

  setShaderColors();

  if (sortFeedback) pixelsort(pg, reverseFeedbackSort);
  pg.beginDraw();
  pg.shader(shader);
  pg.rect(0, 0, width, height);
  //pg.textAlign(CENTER);
  //pg.textSize(72);
  //pg.text(zoomFactor, width/2.0, height/2.0);
  pg.endDraw();
  if (sortShader) pixelsort(pg, reverseShaderSort);

  image(pg, 0, 0);
  fill(255);
  text("bodhran: " + gain1, 100, 50);
  text("hang pan: " + gain2, 100, 80);
  text("kalimba: " + gain3, 100, 110);

  noStroke();
  fill(
    round(mixedPalette.background[0]*255),
    round(mixedPalette.background[1]*255),
    round(mixedPalette.background[2]*255)
    );
  square(20, 50, 30);
  for (int i = 0; i < mixedPalette.pastels.length; i++) {
    fill(
      round(mixedPalette.pastels[i][0]*255),
      round(mixedPalette.pastels[i][1]*255),
      round(mixedPalette.pastels[i][2]*255)
      );
    square(20, 80+(i*30), 30);
  }

  // draw white crosshairs
  //stroke(255);
  //line(0, height/2.0, width, height/2.0);
  //line(width/2.0, 0, width/2.0, height);
  blend=sin(2*PI*frameCount*rate)*sin(2*PI*frameCount*rate);
}

// pixelsorting for off-screen rendering contexts
void pixelsort(PGraphics _pg, boolean reverse) {
  _pg.beginDraw();
  _pg.loadPixels();

  int[] column = new int[_pg.height];
  int amount;

  for (int x = 0; x < _pg.width; x++) {
    for (int y = 0; y < _pg.height; y++) {
      column[y] = _pg.pixels[y * _pg.width + x];
    }
    column = sort(column);
    if (reverse) column = reverse(column);
    amount = round(50 * hangAmplitude * column.length * (noise(
      0.1 * x,
      0.125 * _pg.height * hangOffset)-0.5
      ));
    column = shift(column, amount);
    for (int y = 0; y < _pg.height; y++) {
      _pg.pixels[y * _pg.width + x] = column[y];
    }
  }

  _pg.updatePixels();
  _pg.endDraw();
}

// pixelsorting on the main rendering chain
void pixelsort(boolean reverse) {
  loadPixels();

  int[] column = new int[height];
  int amount;

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      column[y] = pixels[y * width + x];
    }
    column = sort(column);
    if (reverse) column = reverse(column);
    amount = round(50 * hangAmplitude * column.length * (noise(
      0.1 * x,
      0.125 * height * hangOffset)-0.5
      ));
    column = shift(column, amount);
    for (int y = 0; y < height; y++) {
      pixels[y * width + x] = column[y];
    }
  }

  updatePixels();
}

int[] shift(int[] array, int amount) {
  int[] shifted = new int[array.length];
  int j = 0;
  for (int i = 0; i < shifted.length; i++) {
    j = (i + amount) % array.length;
    shifted[i] = array[j < 0 ? j + array.length : j];
  }
  return shifted;
}

void setShaderColors() {

  float[] mixedBackground = {
    lerp(activePaletteA.background[0], activePaletteB.background[0], blend),
    lerp(activePaletteA.background[1], activePaletteB.background[1], blend),
    lerp(activePaletteA.background[2], activePaletteB.background[2], blend)
  };

  float[][] mixedPastels = new float[3][3];

  for (int p = 0; p < 3; p++) {
    for (int c = 0; c < 3; c++) {
      mixedPastels[p][c]=lerp(activePaletteA.pastels[p][c], activePaletteB.pastels[p][c], blend);
    }
  }

  mixedPalette = new Palette("mixed", mixedBackground, mixedPastels);

  shader.set("u_background", mixedPalette.background[0], mixedPalette.background[1], mixedPalette.background[2], 1.0);
  shader.set("u_palette", mixedPalette.getFlattenedPalette(), 4);
  shader.set("u_paletteLength", mixedPalette.pastels.length);
}
