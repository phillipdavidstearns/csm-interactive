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
  text("frameCount: " + frameCount, 100, 140);
  text("blendStart: " + blendStart, 100, 170);
  text("blendDuration: " + blendDuration, 100, 200);
  text("blend: " + blend, 100, 230);
  text("noiseZoomFactor: " + noiseZoomFactor, 100, 260);
  text("ampSum: " + ampSum, 100, 290);

  //Column 2
  text("bodhranOffset: " + bodhranOffset, 250, 50);
  text("hangOffset: " + hangOffset, 250, 80);
  text("kalimbaOffset: " + kalimbaOffset, 250, 110);

  text("minThreshold: " + thMin, 250, 140);
  text("maxThreshold: " + thMax, 250, 170);

  text("wind.x: " + origin_wind.x, 250, 200);
  text("wind.y: " + origin_wind.y, 250, 230);
  text("wind.z: " + origin_wind.z, 250, 260);


  // Column 3
  text("origin.loc.x: " + origin.loc.x, 400, 50);
  text("origin.loc.y: " + origin.loc.y, 400, 80);
  text("origin.loc.z: " + origin.loc.z, 400, 110);

  text("mass.loc.x: " + mass.loc.x, 400, 140);
  text("mass.loc.y: " + mass.loc.y, 400, 170);
  text("mass.loc.z: " + mass.loc.z, 400, 200);

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
  line(
    mouseX,
    mouseY,
    250*mouse_wind.mag()*mouse_wind.x + mouseX,
    250*mouse_wind.mag()*mouse_wind.y + mouseY
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
        map(wind.wind(x/float(width), y/float(width)).heading(), -PI, PI, 0, 2*PI),
        wind.wind(x/float(width), y/float(width)).mag(),
        wind.wind(x/float(width), y/float(width)).mag()
        ));
      square(x, y, pixelSize);
    }
  }
  colorMode(RGB, 255, 255, 255);
}
