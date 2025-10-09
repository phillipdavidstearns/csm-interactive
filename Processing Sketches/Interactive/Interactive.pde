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

float rOffset = 10.0;
float gOffset = 120.0;
float bOffset = 240.0;
float shiftOffset = -300.0;

float hangAmplitude = 0.0;
float kalimbaAmplitude = 0.0;
float bodhranAmplitude = 0.0;

// Wall dimensions: 361" x 144" - projector location? distance back?
// Projector Aspect Ratio: 16:9
// Distance between projection wall and rear wall: 17' 5" (209")
// Max Projection Dimensions (16:9): 256" x 144" (~294" diagonal)

ArrayList<Palette> palettes;
Palette activePalette;

void setup() {
  pixelDensity(1);
  //fullScreen(P2D);
  size(1280, 720, P2D);
  noiseDetail(7, 0.5);
  noStroke();

  loadPalettes();
  activePalette = palettes.get(int(random(palettes.size())));

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

  bodhranAmplitude = 4.0 * bodhran.getAmplitude();
  bodhranOffset += bodhranAmplitude;

  hangAmplitude = 4.0 * hang.getAmplitude();
  hangOffset += hangAmplitude;

  kalimbaAmplitude = 4.0 * kalimba.getAmplitude();
  kalimbaOffset += kalimbaAmplitude;

  float zoomFactor = 2 * noise(0.1, sin(2 * PI * frameCount / 12000.0));

  // Set uniforms
  shader.set("u_texture", pg);
  //shader.set("u_mouse", mouseX/float(width), mouseY/float(height));
  shader.set("u_time", millis() * 0.0001);
  shader.set("u_offset", kalimbaOffset);
  shader.set("u_zoom", zoomFactor);
  shader.set("u_gain1", 4 * noise(0.2, sin(2 * PI * frameCount / 13000.0)));
  shader.set("u_gain2", 4 * noise(0.3, sin(2 * PI * frameCount / 14000.0)));
  shader.set("u_gain3", 4 * noise(0.4, sin(2 * PI * frameCount / 15000.0)));
  shader.set("u_gain4", 4.0);
  shader.set("u_pedistal1", -1.0);
  shader.set("u_pedistal2", -1.0);
  shader.set("u_pedistal3", -1.0);
  shader.set("u_pedistal4", -2.0);

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

  // draw white crosshairs
  //stroke(255);
  //line(0, height/2.0, width, height/2.0);
  //line(width/2.0, 0, width/2.0, height);
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
  shader.set("u_background", activePalette.background[0], activePalette.background[1], activePalette.background[2], 1.0);
  shader.set("u_palette", activePalette.getFlattenedPalette(), 4);
  shader.set("u_paletteLength", activePalette.pastels.length);
}
