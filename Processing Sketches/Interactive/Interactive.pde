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
boolean shiftShader = true;
boolean shiftSort = false;
boolean sortFeedback = false;
boolean reverseSort= false;
boolean devMode = false;
boolean devWind = false;
boolean preProcess = false;
boolean postProcess = true;

//----------------------------------------------------------------
// value for pixelsorting

int sortMode = 0;

// GLOBALS functions like updateThresholds, thresholdSort and evalPixel
float thMin = 0.5;
float thMax = 0.5;
float thCenter = 0.5;
float thWidth = 0.5;

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
int blendDuration = 27000;
boolean blending = false;
float bri = 0.95;
float sat = 1.05;
float con = 0.95;
//----------------------------------------------------------------

float[] gain = new float[qtyInstruments];
PVector[] offset = new PVector[qtyInstruments];
float noiseZoomFactor = 6;

float alphaCenter = 0.05;
float alphaWidth = 0.15;

float feedbackAlpha = 0.0;
float feedbackRotation = 0.0;
float feedbackZoom = 0.0;

float darkenAmount = 0.05;
float brightenAmount = 0.1;
float fbmWarp = 3.0;

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
  5000, //mass
  0.001, // drag
  0.0001, // k (return to origin force)
  10, // drawn radius
  false, //stroke
  true, //fill
  color(255)
  );

Mass origin = new Mass(
  new PVector(0.5, 0.5, 1.0),
  2500,
  0.0075,
  0.0001,
  10,
  true,
  false,
  color(255)
  );

float bodhranSum = 0.0;
float bodhranSumGain = 0.25;
float bodhranSumFalloff = 0.025; // could cycle throughout the day

float kalimbaSum = 0.0;
float kalimbaSumGain = 0.075;
float kalimbaSumFalloff = 0.0625;

Wind wind = new Wind(7);
PVector forceWind = new PVector();
float windHeading;

float bonkForceGain = 15.0;

Control ctl = new Control(27000, 300, 256, 64);

//================================================================

void setup() {
  pixelDensity(1);
  fullScreen(P2D, 2);
  noCursor();
  frameRate(30);
  noiseDetail(7, 0.5);
  noStroke();
  background(0);

  // instantiate the ControlFrame
  // disabled for exhibition
  // cf = new ControlFrame(this, 400, 800);

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
    random(-3, 3),
    random(-3, 3),
    bodhranOffset
    );
  offset[1] = new PVector(
    random(-3, 3),
    random(-3, 3),
    hangOffset
    );
  offset[2] = new PVector(
    random(-3, 3),
    random(-3, 3),
    kalimbaOffset
    );

  blendStart = frameCount;
  randomizeSort();
}

//================================================================

void draw() {

  // read audio from instruments and update global values
  updateAudio();

  if (pg != null) {

    pg.beginDraw();
    pg.noStroke();

    background(getBGColor());

    setFeedbackShaderParams();
    pg.shader(feedbackLayer);
    pg.image(pg, 0, 0);

    for (int i = 0; i < qtyInstruments; i++) {
      setNoiseShaderParams(i);
      pg.shader(noiseLayer);
      pg.rect(0, 0, pg.width, pg.height);
      pg.resetShader(); // necessary to maintain layer independence
    }

    pg.endDraw();

    if (preProcess) process(pg);

    image(pg, 0, 0);
  }

  //----------------------------------------------------------------

  if (postProcess) process();

  if (devMode) showInfo();

  //----------------------------------------------------------------

  mass.update();
  forceWind = wind.wind(origin.loc.x, origin.loc.y).mult(0.0625);
  accumulateWind(forceWind);
  origin.addForce(forceWind);
  origin.update();
  mass.setOrigin(origin.loc);
  mass.update();
  wind.stepOffsets(0.05 * forceWind.x, 0.05 * forceWind.y);
  windHeading = wind.wind(origin.loc.x, origin.loc.y).mag() + PI;

  //----------------------------------------------------------------

  if (sortCenter != null && sortWidth != null) {
    sortCenter.setValue(mass.loc.x);
    sortWidth.setValue(mass.loc.y);
  } else {
    sort_c(mass.loc.x);
    sort_w(mass.loc.y);
  }

  //----------------------------------------------------------------

  ctl.update();

  if (!ctl.blendFlag && ctl.frame == 0 && ctl.blendAmount == 0.0) {
    activePaletteA = activePaletteB.copy();
    activePaletteB = palettes.get(int(random(palettes.size())));
    activePaletteB.randomizePastels();
  }
}

//================================================================

void randomizeSort() {
  int mode = sortMode;
  while (mode == sortMode) {
    mode = floor(random(-1, 6));
    //mode = floor(random(-1, sortModeRadio.getItems().size()));
  }

  if (mode < 0) {
    //sortModeRadio.deactivateAll();
    sortShader = false;
  } else {
    sortShader = true;
    //sortModeRadio.activate(mode);
    sort_mode(mode);
    reverseSort = random(1.0) < 0.25;
    //reverseSortToggle.setValue(random(1.0) < 0.25);
  }
}


//================================================================
// Set parameters for the feedback shader 

void setFeedbackShaderParams() {
  feedbackLayer.set("u_alpha", bodhranSum);
  feedbackLayer.set("u_feedbackZoom", mass.loc.z);
  feedbackLayer.set("u_c_fb", mass.loc.x, mass.loc.y);
  feedbackLayer.set("u_c_rot", origin.loc.x, origin.loc.y);
  feedbackLayer.set("u_rotation", map(windHeading, 0.0, 2*PI, -0.1, 0.1));
}

//----------------------------------------------------------------
// Set the parameters for the noise/cloud shader

void setNoiseShaderParams(int i) {
  float[] pastel = getPaletteColor(i);
  noiseLayer.set("u_color", pastel[0], pastel[1], pastel[2]);
  noiseLayer.set("u_time", millis() * 0.0001);
  noiseLayer.set("u_offset", offset[i]);
  noiseLayer.set("u_zoom", noiseZoomFactor);
  noiseLayer.set("u_center", alphaCenter);
  noiseLayer.set("u_width", alphaWidth);
  noiseLayer.set("u_darken", darkenAmount);
  noiseLayer.set("u_brighten", brightenAmount);
  noiseLayer.set("u_brightness", bri);
  noiseLayer.set("u_contrast", con);
  noiseLayer.set("u_saturation", sat);
  noiseLayer.set("u_warp", fbmWarp);
  noiseLayer.set("u_wind", PVector.mult(accumulatedWind, 0.0125));
  noiseLayer.set("u_amp", gain[i]);
}

//================================================================
// Shaper function

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

color getBGColor() {
  return color(
    round(255*lerp(activePaletteA.background[0], activePaletteB.background[0], ctl.blendAmount)),
    round(255*lerp(activePaletteA.background[1], activePaletteB.background[1], ctl.blendAmount)),
    round(255*lerp(activePaletteA.background[2], activePaletteB.background[2], ctl.blendAmount))
    );
}

//----------------------------------------------------------------

float[] getPaletteColor(int index) {
  return new float[]{
    lerp(activePaletteA.pastels[index][0], activePaletteB.pastels[index][0], ctl.blendAmount),
    lerp(activePaletteA.pastels[index][1], activePaletteB.pastels[index][1], ctl.blendAmount),
    lerp(activePaletteA.pastels[index][2], activePaletteB.pastels[index][2], ctl.blendAmount)
  };
}
