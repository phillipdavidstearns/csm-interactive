//Was in the draw 2D function
//Sorting Row by Row
//int[] row = new int[width];
//for(int y = 0; y < height; y++){
//  for(int x = 0; x < width; x++){
//    row[x] = pixels[y * width + x];
//  }
//  row = sort(row);
//  for(int x = 0; x < width; x++){
//    pixels[y * width + x] = row[x];
//  }
//}

// void draw1DNoise(){
//  noiseDetail(3, 0.25);
//  beginShape();
//  for(int i = 0; i < ceil(width/1.0); i++){
//    vertex(
//      map(i, 0, ceil(width/1.0), 0.0, width),
//      map(10.0 * hang.getAmplitude() * noise(i/100.0, noiseOffset, frameCount/1000.0),0.0,1.0,0.0,height)
//    );
//  }
//  endShape();
//}

// Was in the draw loop as a diagnostic
//if(false){
//  hang.drawWaveform(4, 0);
//  hang.drawSpectrum();
//  textSize(120);
//  text("PITCH: " + hang.getPitch(), 0, height/3);
//  text("AMP: " + nf(hang.getAmplitude(),2,2), 0, 2*height/3);
//  background(hang.isBeat() ? 255 : 0);
//  draw1DNoise();
//}

//3D Perlin Noise => 2D RGB colorfield
//for(int y = 0; y < height; y++){
//  for(int x = 0; x < width; x++){
//    pixels[y * width + x] = color(
//      colorChannelNoise3D(x, y, kalimbaOffset, rOffset),
//      colorChannelNoise3D(x, y, kalimbaOffset, gOffset),
//      colorChannelNoise3D(x, y, kalimbaOffset, bOffset)
//    );
//  }
//}

//int colorChannelNoise3D(float x, float y, float z, float offset){
//  return round( 255 * noise(
//    offset + ( y / float(height)),
//    offset + ( x / float(width)),
//    offset + z
//  ));
//}
