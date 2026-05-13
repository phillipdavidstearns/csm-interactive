//================================================================
// Diagnostics Display

void showInfo() {

  PVector origin_wind = wind.wind(origin.loc.x, origin.loc.y);

  if (devWind) visualizeWind();
  fill(255);

  //Column 1
  text("bodhran: " + gain[0], 100, 50);
  text("hang pan: " + gain[1], 100, 80);
  text("kalimba: " + gain[2], 100, 110);

  text("ctl.beatBlend: " + ctl.beatBlend, 100, 140);
  text("ctl.blendFlag: " + ctl.blendFlag, 100, 170);
  text("ctl.frame: " + ctl.frame, 100, 200);
  text("ctl.blendAmount: " + ctl.blendAmount, 100, 230);

  text("sortMode: " + sortMode, 100, 290);
  text("sortShader: " + sortShader, 100, 320);

  //Column 2
  text("bodhranOffset: " + bodhranOffset, 250, 50);
  text("hangOffset: " + hangOffset, 250, 80);
  text("kalimbaOffset: " + kalimbaOffset, 250, 110);

  text("minThreshold: " + thMin, 250, 140);
  text("maxThreshold: " + thMax, 250, 170);

  text("wind.x: " + origin_wind.x, 250, 200);
  text("wind.y: " + origin_wind.y, 250, 230);
  text("wind.z: " + origin_wind.z, 250, 260);
  text("windHeading: " + windHeading, 250, 290);

  // Column 3

  text("bodhran avg: " + bodhran.getRollingAvg(), 400, 50);
  text("hang avg: " + hang.getRollingAvg(), 400, 80);
  text("kalimba avg: " + kalimba.getRollingAvg(), 400, 110);
  text("bodhranSum: " + bodhranSum, 400, 140);

  //text("origin.loc.x: " + origin.loc.x, 400, 50);
  //text("origin.loc.y: " + origin.loc.y, 400, 80);
  //text("origin.loc.z: " + origin.loc.z, 400, 110);

  //text("mass.loc.x: " + mass.loc.x, 400, 140);
  //text("mass.loc.y: " + mass.loc.y, 400, 170);
  //text("mass.loc.z: " + mass.loc.z, 400, 200);

  // Column 4

  text("bodhran peak: " + bodhran.getPeak(), 550, 50);
  text("hang peak: " + hang.getPeak(), 550, 80);
  text("kalimba peak: " + kalimba.getPeak(), 550, 110);

  //Palette Swatches
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

  mass.render();
  origin.render();
  text("origin.loc.x: " + origin.loc.x, origin.loc.x * width, origin.loc.y * height);
  text("origin.loc.y: " + origin.loc.y, origin.loc.x * width, origin.loc.y * height + 20);


  origin_wind.setMag(250*origin_wind.mag());
  stroke(255);
  line(
    origin.loc.x*width,
    origin.loc.y*height,
    origin_wind.x + (origin.loc.x*width),
    origin_wind.y + (origin.loc.y*height)
    );

  PVector mouse_wind = wind.wind(mouseX/float(width), mouseY/float(height));
  mouse_wind.setMag(250*mouse_wind.mag());
  line(
    mouseX,
    mouseY,
    mouse_wind.x + mouseX,
    mouse_wind.y + mouseY
    );
  text("mouseX: " + mouseX/float(width), mouseX, mouseY);
  text("mouseY: " + mouseY/float(width), mouseX, mouseY+20);
  text("heading: "+mouse_wind.heading(), mouseX, mouseY+40 );
  text("mag: "+mouse_wind.mag(), mouseX, mouseY+60);
}


//================================================================

void visualizeWind() {
  int pixelSize=10;
  colorMode(HSB, 2*PI, 1, 1);
  for (int x = 0; x < width; x+=pixelSize) {
    for (int y = 0; y < height; y+=pixelSize ) {
      noStroke();
      fill(color(
        map(wind.wind(x/float(width), y/float(height)).heading(), -PI, PI, 0, 2*PI),
        wind.wind(x/float(width), y/float(height)).mag(),
        wind.wind(x/float(width), y/float(height)).mag()
        ));
      square(x, y, pixelSize);
    }
  }
  colorMode(RGB, 255, 255, 255);
}
