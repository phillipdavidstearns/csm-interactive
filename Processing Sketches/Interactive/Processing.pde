//================================================================
// Pixel Sorting Related Functions

void updateThresholds() {
  thMin = 255 * constrain(thCenter - 0.5 * thWidth, 0.0, 1.0);
  thMax = 255 * constrain(thCenter + 0.5 * thWidth, 0.0, 1.0);
  //thMin = round(255 * thCenter * (1 - thWidth));
  //thMax = round(255 * (thCenter * (1 - thWidth) + thWidth));
}

//----------------------------------------------------------------

void process(PGraphics _pg) {
  if (sortShader ==false &&
    shiftShader == false &&
    sortFeedback == false &&
    reverseSort == false ) return;

  _pg.beginDraw();
  _pg.loadPixels();
  processPixels(_pg.pixels, _pg.height, _pg.width, kalimbaSum, 0.1 * kalimbaOffset);
  _pg.updatePixels();
  _pg.endDraw();
}

//----------------------------------------------------------------

void process() {
  loadPixels();
  processPixels(pixels, height, width, kalimbaSum, 0.1 * kalimbaOffset);
  updatePixels();
}

//----------------------------------------------------------------

void processPixels(int[] _pixels, int _height, int _width, float _shiftAmount, float _noiseOffset) {
  int[] column = new int[_height];

  for (int x = 0; x < _width; x++) {
    for (int y = 0; y < _height; y++) {
      column[y] = _pixels[y * _width + x];
    }

    if (sortShader) column = thresholdSort(column, sortMode);

    if (shiftShader) {
      int amount = round( _shiftAmount * column.length * (
        map(noise( 0.05 * x, _noiseOffset ), 0.25, 0.75, -1.0, 1.0)
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
    return _flag ? _value >= 255 * thCenter : _value < 255 * thCenter;
  case 1: // start capture pixels below min, stop above max
    return _flag ? _value >= thMax : _value < thMin;
  case 2: // pixel values above min
    return _flag ? _value <= 255 * thCenter: _value > 255 * thCenter;
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
