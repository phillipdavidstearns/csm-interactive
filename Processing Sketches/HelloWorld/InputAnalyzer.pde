class InputAnalyzer {
  AudioIn input;
  
  Amplitude amplitude;
  PitchDetector pitch;
  Waveform waveform;
  BeatDetector beat;
  FFT fft;
  
  int channel;
  int blockSize;
  int bands;
  float[] spectrum;
  
  InputAnalyzer(PApplet parent, int channel, int blockSize, int bands){
    this.channel = channel;
    this.blockSize = blockSize;
    this.bands = bands;
    this.spectrum = new float[bands];
    
    try {
      this.input = new AudioIn(parent, this.channel);
      this.input.start();
    } catch(Exception e){
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
  
  float[] getFFT(){
    this.fft.analyze(this.spectrum);
    return this.spectrum;
  }
  
  Waveform getWaveform(){
    this.waveform.analyze();
    return this.waveform;
  }
  
    float getAmplitude(){
    return this.amplitude.analyze();
  }
  
  float getPitch(){
    return this.pitch.analyze();
  }
  
  boolean isBeat(){
    return this.beat.isBeat();
  }
  
  void drawWaveform(float scale, float yOffset){
    this.waveform.analyze();
    beginShape();
    for(int i = 0; i < waveform.data.length; i++){
      vertex(
        map(i, 0, waveform.data.length, 0, width),
        map(waveform.data[i], -1/scale, 1/scale, 0-yOffset, height-yOffset)
      );
    }
    endShape();
  }
  
  void drawSpectrum(){
    this.fft.analyze(this.spectrum);
    for(int i = 0; i < this.spectrum.length; i++){
      line(i, height, i, height - this.spectrum[i]*height*10 );
    } 
  }

}
