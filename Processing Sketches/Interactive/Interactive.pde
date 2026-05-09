//================================================================

import processing.sound.*;

//================================================================

int qtyInstruments = 3;

//----------------------------------------------------------------

PShader noiseLayer;
PShader feedbackLayer;
PGraphics pg;

//----------------------------------------------------------------
// switches for processing
boolean sortShader = false;
boolean shiftShader = false;
boolean shiftSort = false;
boolean sortFeedback = false;
boolean reverseSort= false;
boolean devMode = false;
boolean preProcess = false;
boolean postProcess = false;

//----------------------------------------------------------------
// value for pixelsorting

int sortMode = 0;

// GLOBALS functions like updateThresholds, thresholdSort and evalPixel
int thMin = 0;
int thMax = 0;
float thCenter = 0.0;
float thWidth = 0.0;

//----------------------------------------------------------------

InputAnalyzer hang;
InputAnalyzer bodhran;
InputAnalyzer kalimba;

float hangOffset = 0.0;
float kalimbaOffset = 0.0;
float bodhranOffset = 0.0;

float hangAmplitude = 0.0;
float kalimbaAmplitude = 0.0;
float bodhranAmplitude = 0.0;

//----------------------------------------------------------------
// Color controls

float blend = 0.0;
float rate = 0.001;
int blendStart = 0;
int blendDuration = 1200;

//----------------------------------------------------------------

float[] gain = new float[qtyInstruments];
PVector[] offset = new PVector[qtyInstruments];
float noiseZoomFactor;
float feedbackZoomFactor;
float alphaCenter = 0.0;
float alphaWidth = 0.0;

float feedbackAlpha = 0.0;
float darkenAmount = 0.0;
float brightenAmount = 0.0;
float fbmWarp = 0.0;

// Wall dimensions: 361" x 144" - projector location? distance back?
// Projector Aspect Ratio: 16:9
// Distance between projection wall and rear wall: 17' 5" (209")
// Max Projection Dimensions (16:9): 256" x 144" (~294" diagonal)

//----------------------------------------------------------------

ArrayList<Palette> palettes;

Palette activePaletteA;
Palette activePaletteB;
Palette mixedPalette;

//----------------------------------------------------------------

ControlFrame cf;

//----------------------------------------------------------------

Mass mass = new Mass(
  new PVector(0.5, 0.5, 1.0),
  2500,
  0.00125,
  0.0025,
  25,
  false,
  true,
  color(255)
  );

Mass origin = new Mass(
  new PVector(0.5, 0.5, 1.0),
  100,
  0.01,
  0.001,
  25,
  true,
  false,
  color(255)
  );

float ampSum = 0.0;
float ampSumFalloff = 0.05; // could cycle throughout the day

PVector wind;

//================================================================

void setup() {
  pixelDensity(1);
  fullScreen(P2D, 2);
  frameRate(30);
  noiseDetail(7, 0.5);
  noStroke();

  // instantiate the ControlFrame
  cf = new ControlFrame(this, 400, 800);

  palettes = loadPalettes();
  activePaletteA = palettes.get(int(random(palettes.size())));
  activePaletteA.randomizePastels();
  activePaletteB = palettes.get(int(random(palettes.size())));
  activePaletteB.randomizePastels();

  // Load and compile noise shader
  noiseLayer = loadShader("noise.frag");
  // We only have to set resolution once
  noiseLayer.set("u_resolution", float(width), float(height));

  feedbackLayer = loadShader("feedback.frag");
  //feedbackLayer.set("u_resolution", float(width), float(height));

  // Create an off-screen rendering context
  pg = createGraphics(width, height, P2D);

  // Initialize the sound device
  try {
    //Sound s = new Sound(this);
    String device = "Scarlett 18i8 USB";
    processing.sound.Sound.inputDevice(device);
  }
  catch(Exception e) {
    print("While initializing Sound Object: " + e);
  }

  // create analyzers for each of the instruments
  bodhran = new InputAnalyzer(this, 0, 2048, 1024);
  hang = new InputAnalyzer(this, 1, 2048, 1024);
  kalimba = new InputAnalyzer(this, 2, 2048, 1024);

  //used to create unique starting conditions for the pastel noise layers
  offset[0] = new PVector(
    random(-2, 2),
    random(-2, 2),
    bodhranOffset
    );
  offset[1] = new PVector(
    random(-2, 2),
    random(-2, 2),
    hangOffset
    );
  offset[2] = new PVector(
    random(-2, 2),
    random(-2, 2),
    kalimbaOffset
    );

  blendStart = frameCount;
}

//================================================================

void draw() {

  //read analyzers

  bodhranAmplitude = bodhran.getAmplitude();
  bodhranOffset += bodhranAmplitude;
  if (bodhran.isBeat()) {
    mass.addForce(new PVector(0.0, 0.0, -bodhranAmplitude * 1000));
  }
  hangAmplitude = hang.getAmplitude();
  hangOffset += hangAmplitude;
  if (hang.isBeat()) {
    mass.addForce(new PVector(0.0, -hangAmplitude * 1000, 0.0));
  }

  kalimbaAmplitude = kalimba.getAmplitude();
  kalimbaOffset += kalimbaAmplitude;
  if (kalimba.isBeat()) {
    mass.addForce(new PVector(kalimbaAmplitude * 1000, 0.0, 0.0));
  }

  ampSum *= 1 - ampSumFalloff;
  ampSum += (bodhranAmplitude + hangAmplitude + kalimbaAmplitude);
  //feedbackZoomFactor = 1.0 - noise(1, (bodhranAmplitude+hangAmplitude+kalimbaAmplitude)/3);
  //noiseZoomFactor = 5;

  gain[0] = 2.0 * bodhranAmplitude;
  gain[1] = 2.0 * hangAmplitude;
  gain[2] = 2.0 * kalimbaAmplitude;

  offset[0].z = bodhranOffset;
  offset[1].z = hangOffset;
  offset[2].z = kalimbaOffset;

  // Set uniforms

  if (pg != null) {

    pg.beginDraw();
    pg.noStroke();

    background(getBGColor());

    feedbackLayer.set("u_alpha", ampSum);
    feedbackLayer.set("u_feedbackZoom", mass.loc.z);
    feedbackLayer.set("u_centerX", mass.loc.x);
    feedbackLayer.set("u_centerY", mass.loc.y);
    pg.shader(feedbackLayer);
    pg.image(pg, 0, 0);

    for (int i = 0; i < qtyInstruments; i++) {
      setShaderParams(i);
      pg.shader(noiseLayer);
      pg.rect(0, 0, pg.width, pg.height);
      pg.resetShader(); // necessary to maintain layer independence
    }

    pg.endDraw();

    if (preProcess) process(pg);

    image(pg, 0, 0);
  }

  if (postProcess) process();
  
  //loadPixels();
  //for(int x = 0; x < width; x++){
  //  for(int y = 0; y < height; y++ ){
  //    pixels[y*width+x] = color(
  //      int(255 * getWind(
  //        x/float(width), y/float(height), 5, 1, 3.5 - millis() * 0.0001, -1.2 + millis() * 0.0001
  //      ).mag()));
  //  }
  //}
  //updatePixels();

  if (devMode) showInfo();

  updateBlend();

  mass.update();

  //PVector test = wind(mouseX/float(width), mouseY/float(height),2, 0.01, 3.5, -1.2);
  
  wind = getWind(mass.loc.x, mass.loc.y, 5, 0.05, 3.5 - millis() * 0.0001, -1.2 + millis() * 0.0001);

  accumulateWind(wind);
  origin.addForce(wind);
  origin.update();
  mass.setOrigin(origin.loc);
  mass.update();
}

//================================================================

void setShaderParams(int i) {
  float[] pastel = getPaletteColor(i);
  noiseLayer.set("u_color", pastel[0], pastel[1], pastel[2]);
  noiseLayer.set("u_time", millis() * 0.0001);
  noiseLayer.set("u_offset", offset[i]);
  noiseLayer.set("u_zoom", noiseZoomFactor);
  noiseLayer.set("u_center", alphaCenter);
  noiseLayer.set("u_width", alphaWidth);
  noiseLayer.set("u_darken", darkenAmount);
  noiseLayer.set("u_brighten", brightenAmount);
  noiseLayer.set("u_warp", fbmWarp);
  noiseLayer.set("u_wind", accumulatedWind);
}

//================================================================
// Diagnostics Display

void showInfo() {
  fill(255);
  text("bodhran: " + gain[0], 100, 50);
  text("hang pan: " + gain[1], 100, 80);
  text("kalimba: " + gain[2], 100, 110);
  text("frameCount: " + frameCount, 100, 140);
  text("blendStart: " + blendStart, 100, 170);
  text("blendDuration: " + blendDuration, 100, 200);
  text("blend: " + blend, 100, 230);
  text("noiseZoomFactor: " + noiseZoomFactor, 100, 260);
  text("ampSum: " + ampSum, 100, 290);

  text("bodhranOffset: " + bodhranOffset, 250, 50);
  text("hangOffset: " + hangOffset, 250, 80);
  text("kalimbaOffset: " + kalimbaOffset, 250, 110);

  text("minThreshold: " + thMin, 250, 140);
  text("maxThreshold: " + thMax, 250, 170);

  text("wind.x: " + wind.x, 250, 200);
  text("wind.y: " + wind.y, 250, 230);
  text("wind.z: " + wind.z, 250, 250);

  noStroke();

  fill(getBGColor());
  square(20, 50, 30);
  for (int i = 0; i < qtyInstruments; i++) {
    float[] pastel = getPaletteColor(i);
    fill(
      round(pastel[0]*255),
      round(pastel[1]*255),
      round(pastel[2]*255)
      );
    square(20, 80+(i*30), 30);
  }
  origin.render();
  mass.render();
}

//================================================================
// Pixel Sorting Related Functions

void updateThresholds() {
  thMin = round(255 * thCenter * (1 - thWidth));
  thMax = round(255 * (thCenter * (1 - thWidth) + thWidth));
}

//----------------------------------------------------------------

void process(PGraphics _pg) {
  if (sortShader ==false &&
    shiftShader == false &&
    sortFeedback == false &&
    reverseSort == false ) return;

  _pg.beginDraw();
  _pg.loadPixels();
  processPixels(_pg.pixels, _pg.height, _pg.width);
  _pg.updatePixels();
  _pg.endDraw();
}

//----------------------------------------------------------------

void process() {
  loadPixels();
  processPixels(pixels, height, width);
  updatePixels();
}

//----------------------------------------------------------------

void processPixels(int[] _pixels, int _height, int _width) {
  int[] column = new int[_height];

  for (int x = 0; x < _width; x++) {
    for (int y = 0; y < _height; y++) {
      column[y] = _pixels[y * _width + x];
    }

    if (sortShader) column = thresholdSort(column, sortMode);

    if (shiftShader) {
      int amount = round(((bodhranAmplitude+hangAmplitude+kalimbaAmplitude)/3.0) * column.length * (noise(
        0.01 * x,
        _height * frameCount * 0.0001)-0.5
        ));
      column = shift(column, amount);
    }

    for (int y = 0; y < _height; y++) {
      _pixels[y * _width + x] = column[y];
    }
  }
}

//----------------------------------------------------------------

// different ways in which the threshold for max and min can be used to mask pixels to be sorted
boolean evalPixel(float _value, int _mode, boolean _flag) {
  switch(_mode) {
  case 0: // pixel values below center
    return _flag ? _value >= round(255 * thCenter) : _value < round(255 * thCenter);
  case 1: // start capture pixels below min, stop above max
    return _flag ? _value >= thMax : _value < thMin;
  case 2: // pixel values above min
    return _flag ? _value <= round(255 * thCenter): _value > round(255 * thCenter);
  case 3: // start capture pixels above max, stop below min
    return _flag ? _value <= thMin : _value > thMax;
  case 4: // start capture pixels below max, stop capture below min
    return _flag ? _value <= thMin  || _value >= thMax : _value < thMax && _value > thMin;
  case 5:  // start capture pixels below max, stop capture below min
    return _flag ? _value >= thMin  && _value <= thMax : _value > thMax || _value < thMin;
  }
  return false;
}

//----------------------------------------------------------------

// pixelsorting on the main rendering chain
int[] thresholdSort(int[] pixelArray, int mode) {
  boolean segmentFlag = false;
  int start = 0;
  int end = 0;
  float value;
  for (int i = 0; i < pixelArray.length; i++) {
    value = brightness(pixelArray[i]);

    if (!segmentFlag && evalPixel(value, mode, segmentFlag)) {
      start = i;
      segmentFlag = true;
    } else if (segmentFlag && (evalPixel(value, mode, segmentFlag) || i == pixelArray.length - 1)) {
      end = i;
      segmentFlag = false;
      int[] chunk = new int[end-start];
      for (int j = 0; j < end-start; j++) {
        chunk[j] = pixelArray[start+j];
      }
      chunk = sort(chunk);
      if (reverseSort) chunk = reverse(chunk);
      if (shiftSort) {
        int amount = round(chunk.length * noise(
          0.1 * i,
          frameCount * 0.0001));
        chunk = shift(chunk, amount);
      }
      for (int j = 0; j < end-start; j++) {
        pixelArray[start+j] = chunk[j];
      }
    }
  }

  return pixelArray;
}

//----------------------------------------------------------------

int[] shift(int[] array, int amount) {
  int[] shifted = new int[array.length];
  int j = 0;
  for (int i = 0; i < shifted.length; i++) {
    j = (i + amount) % array.length;
    shifted[i] = array[j < 0 ? j + array.length : j];
  }
  return shifted;
}

//================================================================
// Shaper functions

float doubleExponentialSigmoid (float x, float a) {

  float epsilon = 0.00001;
  float min_param_a = 0.0 + epsilon;
  float max_param_a = 1.0 - epsilon;
  a = constrain(a, min_param_a, max_param_a);
  a = 1.0 - a; // for sensible results

  float y = 0.0;

  if (x <= 0.5) {
    y = (pow(2.0 * x, 1.0 / a)) / 2.0;
  } else {
    y = 1.0 - (pow(2.0 * (1.0 - x), 1.0 / a)) / 2.0;
  }
  return y;
}

//================================================================
// Color Management Functions

void updateBlend() {
  if (frameCount - blendStart >= blendDuration) {
    activePaletteA = activePaletteB.copy();
    activePaletteB = palettes.get(int(random(palettes.size())));
    activePaletteB.randomizePastels();
    blendStart = frameCount;
  }

  blend = doubleExponentialSigmoid(
    (frameCount - blendStart) / float(blendDuration),
    0.9);
}

//----------------------------------------------------------------

color getBGColor() {
  return color(
    round(255*lerp(activePaletteA.background[0], activePaletteB.background[0], blend)),
    round(255*lerp(activePaletteA.background[1], activePaletteB.background[1], blend)),
    round(255*lerp(activePaletteA.background[2], activePaletteB.background[2], blend))
    );
}

//----------------------------------------------------------------

float[] getPaletteColor(int index) {
  return new float[]{
    lerp(activePaletteA.pastels[index][0], activePaletteB.pastels[index][0], blend),
    lerp(activePaletteA.pastels[index][1], activePaletteB.pastels[index][1], blend),
    lerp(activePaletteA.pastels[index][2], activePaletteB.pastels[index][2], blend)
  };
}
