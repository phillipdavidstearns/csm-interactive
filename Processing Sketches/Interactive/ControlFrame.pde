//================================================================
// Import ControlP5 library

import controlP5.*;

//----------------------------------------------------------------
int margin_x = 10;
int margin_y = 10;
int unit_w = 20;
int unit_h = 20;
int buffer_w = 10;
int buffer_h = 10;

int grid_x(int steps) {
  return margin_x + steps * (unit_w + buffer_w);
}

int grid_y(int steps) {
  return margin_y + steps * (unit_w + buffer_w);
}

int size_w(int units) {
  units = max(units, 1);
  return (unit_w * units) + (buffer_w * (units - 1));
};

int size_h(int units) {
  units = max(units, 1);
  return (unit_h * units) + (buffer_h * (units - 1));
};

//----------------------------------------------------------------

RadioButton sortModeRadio;

Numberbox sort_min;
Numberbox sort_max;

controlP5.Label label;

//================================================================
// ControlFrame for controls in separate window.
// Connection between gui elements and variables in the parent applet are
// made via the plugTo(<parent>, <name>) method.

class ControlFrame extends PApplet {
  int w, h;
  String name;
  PApplet parent;
  ControlP5 cp5;

  public ControlFrame(PApplet _parent, int _w, int _h) {
    super();
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(this.w, this.h, P2D);
  }

  public void setup() {
    pixelDensity(1);
    frameRate(30);
    surface.setLocation(0, 0);
    cp5 = new ControlP5(this);
    setupControls(this.parent, this.cp5);
  }

  void draw() {
    background(0);
  }
}

void setupControls(PApplet parent, ControlP5 cp5) {

  //----------------------------------------------------------------
  // Numberboxes for min and max threshold values...
  // Set by adjusting the center and width controls of the sorting threshold

  // Displays the minimum threshold value for pixel sorting
  sort_min = cp5.addNumberbox("sort_min")
    .setPosition(grid_x(8), grid_y(0))
    .setSize(size_w(3), size_h(1))
    .setDecimalPrecision(0)
    ;
  cp5.getController("sort_min").getCaptionLabel()
    .align(RIGHT, CENTER)
    .setPaddingX(5)
    ;

  sort_max = cp5.addNumberbox("sort_max")
    .setPosition(grid_x(8), grid_y(1))
    .setSize(size_w(3), size_h(1))
    .setDecimalPrecision(0)
    ;
  cp5.getController("sort_max").getCaptionLabel()
    .align(RIGHT, CENTER)
    .setPaddingX(5)
    ;

  //----------------------------------------------------------------

  cp5.addSlider("sort_c")
    .plugTo(parent, "sort_c")
    .setPosition(grid_x(0), grid_y(0))
    .setSize(size_w(8), size_h(1))
    .setRange(0, 1.0)
    .setValue(random(1.0))
    ;
  cp5.getController("sort_c").getCaptionLabel()
    .align(ControlP5.RIGHT, CENTER)
    ;

  cp5.addSlider("sort_w")
    .plugTo(parent, "sort_w")
    .setPosition(grid_x(0), grid_y(1))
    .setSize(size_w(8), size_h(1))
    .setRange(0, 1.0)
    .setValue(random(1.0))
    ;
  cp5.getController("sort_w").getCaptionLabel()
    .align(ControlP5.RIGHT, CENTER)
    ;

  //----------------------------------------------------------------
  // switches for processing chain

  // enable spixelsorting
  cp5.addToggle("sort")
    .plugTo(parent, "sortShader")
    .setValue(sortShader)
    .setSize(size_w(1), size_h(1))
    .setPosition(grid_x(0), grid_y(2))
    ;
  cp5.getController("sort").getCaptionLabel()
    .set("SRT")
    .align(CENTER, CENTER)
    .setPaddingX(5)
    ;

  //enable pixelshifting
  cp5.addToggle("shift")
    .plugTo(parent, "shiftShader")
    .setValue(shiftShader)
    .setSize(size_w(1), size_h(1))
    .setPosition(grid_x(1), grid_y(2))
    ;
  cp5.getController("shift").getCaptionLabel()
    .set("SHF")
    .align(CENTER, CENTER)
    .setPaddingX(5)
    ;

  //reverse the sort order
  cp5.addToggle("reverse")
    .plugTo(parent, "reverseSort")
    .setValue(reverseSort)
    .setSize(size_w(1), size_h(1))
    .setPosition(grid_x(2), grid_y(2))
    ;
  cp5.getController("reverse").getCaptionLabel()
    .set("REV")
    .align(CENTER, CENTER)
    .setPaddingX(5)
    ;

  //perform sorting and shifting before rendering of new layer on top
  cp5.addToggle("pre")
    .plugTo(parent, "preProcess")
    .setValue(preProcess)
    .setSize(size_w(1), size_h(1))
    .setPosition(grid_x(3), grid_y(2))
    ;
  cp5.getController("pre").getCaptionLabel()
    .set("PRE")
    .align(CENTER, CENTER)
    .setPaddingX(5)
    ;

  //perform sorting and shifting after rendering of new layer on top
  cp5.addToggle("post")
    .plugTo(parent, "postProcess")
    .setValue(postProcess)
    .setSize(size_w(1), size_h(1))
    .setPosition(grid_x(4), grid_y(2))
    ;
  cp5.getController("post").getCaptionLabel()
    .set("PST")
    .align(CENTER, CENTER)
    .setPaddingX(5)
    ;

  //----------------------------------------------------------------
  // selects the evaluation mode for calculating the mask used for pixel sorting

  sortModeRadio = cp5.addRadioButton("sort_mode")
    .plugTo(parent, "sort_mode")
    .setPosition(grid_x(0), grid_y(3))
    .setSize(size_w(1), size_h(1))
    .setItemsPerRow(8)
    .setSpacingColumn(buffer_h)
    .setLabelPadding(int(-0.5*(unit_w+buffer_w)), int(-0.5*(unit_h)))
    .addItem(">", 0)
    .addItem(">>", 1)
    .addItem("<", 2)
    .addItem("<<", 3)
    .addItem("<>", 4)
    .addItem("><", 5)
    ;

  //----------------------------------------------------------------

  cp5.addSlider("alpha_center")
    .plugTo(parent, "alphaCenter")
    .setPosition(grid_x(0), grid_y(5))
    .setSize(size_w(8), size_h(1))
    .setRange(0, 1.0)
    .setValue(0.05)
    ;
  cp5.getController("alpha_center").getCaptionLabel()
    .align(ControlP5.RIGHT, CENTER)
    ;

  cp5.addSlider("alpha_width")
    .plugTo(parent, "alphaWidth")
    .setPosition(grid_x(0), grid_y(6))
    .setSize(size_w(8), size_h(1))
    .setRange(0, 1.0)
    .setValue(0.10)
    ;
  cp5.getController("alpha_width").getCaptionLabel()
    .align(ControlP5.RIGHT, CENTER)
    ;

  //----------------------------------------------------------------

  cp5.addSlider("noise_zoom")
    .plugTo(parent, "noiseZoomFactor")
    .setPosition(grid_x(0), grid_y(7))
    .setSize(size_w(8), size_h(1))
    .setRange(-5.0, 5.0)
    .setValue(5.0)
    ;
  cp5.getController("noise_zoom").getCaptionLabel()
    .align(ControlP5.RIGHT, CENTER)
    ;

  //----------------------------------------------------------------

  cp5.addSlider("feedback_zoom")
    .plugTo(parent, "feedbackZoomFactor")
    .setPosition(grid_x(0), grid_y(8))
    .setSize(size_w(8), size_h(1))
    .setRange(0.75, 1.25)
    .setValue(1.025)
    ;
  cp5.getController("feedback_zoom").getCaptionLabel()
    .align(ControlP5.RIGHT, CENTER)
    ;

  cp5.addSlider("feedback_alpha")
    .plugTo(parent, "feedbackAlpha")
    .setPosition(grid_x(0), grid_y(9))
    .setSize(size_w(8), size_h(1))
    .setRange(0.0, 1.0)
    .setValue(0.5)
    ;
  cp5.getController("feedback_alpha").getCaptionLabel()
    .align(ControlP5.RIGHT, CENTER)
    ;
}

void sort_c(float value) {
  thCenter = value;
  updateThresholds();
  sort_min.setValue(thMin);
  sort_max.setValue(thMax);
  //println("thCenter: " + thCenter + ", thWidth: " + thWidth + ", thMin: " + thMin + ", thMax: " + thMax);
}

void sort_w(float value) {
  thWidth = value;
  updateThresholds();
  sort_min.setValue(thMin);
  sort_max.setValue(thMax);
  //println("thCenter: " + thCenter + ", thWidth: " + thWidth + ", thMin: " + thMin + ", thMax: " + thMax);
}

void sort_mode(int mode) {
  sortMode = mode;
  sortShader = sortMode >= 0;
  //println("sortMode: " + sortMode);
}
