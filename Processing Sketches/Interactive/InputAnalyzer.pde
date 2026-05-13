//========================================================

void updateAudio() {

  //read analyzers

  //----------------------------------------------------------------

  bodhranAmplitude = bodhran.getAmplitude();

  bodhranOffset += 0.5 * bodhranAmplitude;

  if (bodhran.isBeat()) {
    ctl.bonk();
    origin.addForce(new PVector(
      0.0,
      0.0,
      (origin.vel.z < 0 ? -1 : 1) * bodhranAmplitude * bonkForceGain)
      );
  }

  //----------------------------------------------------------------

  hangAmplitude = hang.getAmplitude();

  hangOffset += 0.5 * hangAmplitude;

  if (hang.isBeat()) {
    ctl.bonk();
    mass.addForce(
      PVector.random2D().setMag(bonkForceGain * hangAmplitude)
      );
  }

  //----------------------------------------------------------------

  kalimbaAmplitude = kalimba.getAmplitude();

  kalimbaOffset += 0.5 * kalimbaAmplitude;

  if (kalimba.isBeat()) {
    ctl.bonk();
    origin.addForce(
      PVector.random2D().setMag(bonkForceGain * kalimbaAmplitude)
      );
  }

  //----------------------------------------------------------------

  bodhranSum *= 1 - bodhranSumFalloff;
  bodhranSum += bodhranSumGain * bodhranAmplitude;
  bodhranSum = constrain(bodhranSum, 0, 1);

  kalimbaSum *= 1 - kalimbaSumFalloff;
  kalimbaSum += kalimbaSumGain * kalimbaAmplitude;
  kalimbaSum = constrain(kalimbaSum, 0, 1);

  //adds a little "bounce" to the clouds when instruments are played
  gain[0] = 0.125 * bodhranAmplitude;
  gain[1] = 0.125 * hangAmplitude;
  gain[2] = 0.125 * kalimbaAmplitude;

  offset[0].z = bodhranOffset;
  offset[1].z = hangOffset;
  offset[2].z = kalimbaOffset;
}

//========================================================

class InputAnalyzer {
  AudioIn input;

  Amplitude amplitude;
  PitchDetector pitch;
  Waveform waveform;
  BeatDetector beat;
  FFT fft;

  int avg_samples = 30;
  int channel;
  int blockSize;
  int bands;
  float[] spectrum;

  float peak_fallOff = 0.1 / 30; // 10% every 30 frames
  float peak = 0;
  float[] rolling = new float[avg_samples];
  int rolling_index = 0;
  float lastReadAmplitude = 0;


  //--------------------------------------------------------

  InputAnalyzer(PApplet parent, int channel, int blockSize, int bands) {
    this.channel = channel;
    this.blockSize = blockSize;
    this.bands = bands;
    this.spectrum = new float[bands];

    try {
      this.input = new AudioIn(parent, this.channel);
      this.input.start();
    }
    catch(Exception e) {
      println("While initializing AudioIn: " + e);
      exit();
    }

    this.amplitude = new Amplitude(parent);
    this.amplitude.input(this.input);

    this.pitch = new PitchDetector(parent);
    this.pitch.input(this.input);

    this.waveform = new Waveform(parent, this.blockSize);
    this.waveform.input(this.input);

    this.beat = new BeatDetector(parent);
    this.beat.input(this.input);

    this.fft = new FFT(parent);
    this.fft.input(this.input);
  }

  //--------------------------------------------------------

  float[] getFFT() {
    this.fft.analyze(this.spectrum);
    return this.spectrum;
  }

  //--------------------------------------------------------

  Waveform getWaveform() {
    this.waveform.analyze();
    return this.waveform;
  }

  //--------------------------------------------------------

  float getAmplitude() {
    float amp =  this.amplitude.analyze();
    this.update(amp);
    return amp;
  }


  //--------------------------------------------------------

  float getPitch() {
    return this.pitch.analyze();
  }


  //--------------------------------------------------------

  boolean isBeat() {
    return this.beat.isBeat();
  }

  //--------------------------------------------------------

  void drawWaveform(float scale, float yOffset) {
    this.waveform.analyze();
    beginShape();
    for (int i = 0; i < waveform.data.length; i++) {
      vertex(
        map(i, 0, waveform.data.length, 0, width),
        map(waveform.data[i], -1/scale, 1/scale, 0-yOffset, height-yOffset)
        );
    }
    endShape();
  }

  //--------------------------------------------------------

  void drawSpectrum() {
    this.fft.analyze(this.spectrum);
    for (int i = 0; i < this.spectrum.length; i++) {
      line(i, height, i, height - this.spectrum[i]*height*10 );
    }
  }

  //--------------------------------------------------------

  float getRollingAvg() {
    float sum = 0;
    for (float val : this.rolling) {
      sum += val;
    }
    return sum / float(this.rolling.length);
  }

  //--------------------------------------------------------

  float getPeak() {
    return this.peak;
  }

  //--------------------------------------------------------

  void update(float amp) {
    // reduce peak by falloff % If the amplitude is greater than teh result, set as new peak
    this.peak *= (1.0 - this.peak_fallOff);
    if (amp > this.peak) this.peak = amp;

    this.rolling[this.rolling_index] = this.amplitude.analyze();
    this.rolling_index ++;
    this.rolling_index %= this.rolling.length;
  }
}
