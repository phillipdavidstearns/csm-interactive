class Palette {
  String name;
  float[] background;
  float[][] pastels;

  Palette(String _name, float[] _background, float[][] _pastels) {
    this.name = _name;
    this.background = _background;
    this.pastels = _pastels;
  }

  float[] getFlattenedPalette() {
    float[] flattened = new float[this.pastels.length * 4]; // 4 for RGBA
    for (int i = 0; i < this.pastels.length; i++) {
      for (int j = 0; j < this.pastels[i].length; j++) { // should iterate for RGB values
        flattened[i * 4 + j] = this.pastels[i][j];
      }
      flattened[i * 4 + 3] = 1.0; // manually set the A to 1.0
    }
    return flattened;
  }
}

void loadPalettes() {
  palettes = new ArrayList<Palette>();

  palettes.add(new Palette(
    "473",
    new float[]{194/255.0, 173/255.0, 115/255.0}, // background
    new float[][]{
      {162/255.0, 32/255.0, 32/255.0}, // red
      {67/255.0, 15/255.0, 32/255.0}, // dark red
      {42/255.0, 40/255.0, 40/255.0}, // dark grey
      {16/255.0, 47/255.0, 150/255.0}, // blue
      {234/255.0, 232/255.0, 229/255.0} // white
    }));

  palettes.add(new Palette(
    "453",
    new float[]{196/255.0, 91/255.0, 71/255.0}, // background
    new float[][]{
      {196/255.0, 91/255.0, 71/255.0}, // background
      {127/255.0, 23/255.0, 18/255.0}, // red
      {222/255.0, 173/255.0, 100/255.0}, // yellow
      {127/255.0, 145/255.0, 223/255.0} // periwinkle
    }));

  palettes.add(new Palette(
    "444",
    new float[]{203/255.0, 197/255.0, 185/255.0}, // background
    new float[][]{
      {65/255.0, 94/255.0, 135/255.0}, // blue
      {112/255.0, 37/255.0, 90/255.0}, // violet
      {216/255.0, 194/255.0, 92/255.0} // yellow
    }
    ));

  palettes.add(new Palette(
    "443",
    new float[]{222/255.0, 195/255.0, 137/255.0}, // background
    new float[][]{
      {131/255.0, 51/255.0, 113/255.0}, // violet
      {147/255.0, 28/255.0, 18/255.0}, // red
      {220/255.0, 167/255.0, 57/255.0}, // yellow
      {85/255.0, 113/255.0, 132/255.0}, // light blue
      {170/255.0, 189/255.0, 154/255.0} // aqua
    }));

  palettes.add(new Palette(
    "441",
    new float[]{234/255.0, 209/255.0, 155/255.0}, // background
    new float[][]{
      {196/255.0, 121/255.0, 87/255.0}, // red
      {86/255.0, 111/255.0, 134/255.0}, // blue
      {239/255.0, 234/255.0, 232/255.0} // white
    }));

  palettes.add(new Palette(
    "180",
    new float[]{149/255.0, 118/255.0, 145/255.0}, // background
    new float[][]{
      {36/255.0, 34/255.0, 33/255.0}, // dark grey
      {134/255.0, 25/255.0, 37/255.0}, // red
      {178/255.0, 41/255.0, 25/255.0}, // orange
      {59/255.0, 67/255.0, 61/255.0} // green
    }));

  palettes.add(new Palette(
    "178",
    new float[]{103/255.0, 116/255.0, 146/255.0}, // background
    new float[][]{
      {37/255.0, 36/255.0, 37/255.0}, // dark grey
      {101/255.0, 16/255.0, 29/255.0}, // maroon
      {162/255.0, 54/255.0, 25/255.0}, // orange
      {218/255.0, 204/255.0, 95/255.0}, // yellow
      {222/255.0, 222/255.0, 220/255.0}, // white
      {31/255.0, 73/255.0, 155/255.0} // blue
    }));

  palettes.add(new Palette(
    "177",
    new float[]{70/255.0, 64/255.0, 68/255.0}, // background
    new float[][]{
      {26/255.0, 64/255.0, 160/255.0}, // blue
      {153/255.0, 58/255.0, 25/255.0}, // orange
      {237/255.0, 222/255.0, 125/255.0}, // yellow
      {226/255.0, 225/255.0, 223/255.0} // white
    }));

  palettes.add(new Palette(
    "176",
    new float[]{178/255.0, 57/255.0, 83/255.0}, // background
    new float[][]{
      {24/255.0, 63/255.0, 164/255.0}, // blue
      {176/255.0, 36/255.0, 25/255.0}, // red
      {206/255.0, 167/255.0, 79/255.0}, // yellow
      {31/255.0, 29/255.0, 29/255.0} // dark grey
    }));

  palettes.add(new Palette(
    "161",
    new float[]{187/255.0, 93/255.0, 81/255.0}, // background
    new float[][]{
      {31/255.0, 76/255.0, 182/255.0}, // blue
      {194/255.0, 60/255.0, 30/255.0}, // red
      {229/255.0, 229/255.0, 235/255.0}, // white
      {39/255.0, 35/255.0, 35/255.0} // dark grey
    }));

  palettes.add(new Palette(
    "273",
    new float[]{150/255.0, 162/255.0, 186/255.0}, // background
    new float[][]{
      {32/255.0, 67/255.0, 196/255.0}, // blue
      {171/255.0, 62/255.0, 33/255.0}, // orange
      {230/255.0, 212/255.0, 123/255.0} // yellow
    }));

  palettes.add(new Palette(
    "256",
    new float[]{183/255.0, 95/255.0, 66/255.0}, // background
    new float[][]{
      {228/255.0, 225/255.0, 223/255.0}, // white
      {100/255.0, 75/255.0, 125/255.0}, // violet
      {155/255.0, 37/255.0, 20/255.0}, // red
      {112/255.0, 19/255.0, 15/255.0} // dark red
    }));

  palettes.add(new Palette(
    "151",
    new float[]{61/255.0, 60/255.0, 58/255.0}, // background
    new float[][]{
      {25/255.0, 65/255.0, 167/255.0}, // blue
      {125/255.0, 53/255.0, 21/255.0}, // orange
      {86/255.0, 12/255.0, 19/255.0}, // red
      {239/255.0, 238/255.0, 237/255.0} // white
    }));

  palettes.add(new Palette(
    "120",
    new float[]{61/255.0, 60/255.0, 58/255.0}, // background
    new float[][]{
      {25/255.0, 65/255.0, 167/255.0}, // violet
      {125/255.0, 53/255.0, 21/255.0}, // orange
      {86/255.0, 12/255.0, 19/255.0}, // black
      {239/255.0, 238/255.0, 237/255.0} // white
    }));

  palettes.add(new Palette(
    "119",
    new float[]{200/255.0, 150/255.0, 154/255.0}, // background
    new float[][]{
      {161/255.0, 92/255.0, 58/255.0}, // brown
      {173/255.0, 51/255.0, 25/255.0}, // orange
      {212/255.0, 168/255.0, 82/255.0}, // yellow
      {221/255.0, 214/255.0, 205/255.0}, // white
      {128/255.0, 105/255.0, 160/255.0}, // violet
      {21/255.0, 52/255.0, 140/255.0}, // blue
      {42/255.0, 39/255.0, 41/255.0} // black
    }));

  palettes.add(new Palette(
    "339",
    new float[]{146/255.0, 36/255.0, 68/255.0}, // background
    new float[][]{
      {170/255.0, 34/255.0, 23/255.0}, // red
      {38/255.0, 36/255.0, 39/255.0}, // black
      {63/255.0, 65/255.0, 79/255.0} // grey
    }));

  palettes.add(new Palette(
    "332",
    new float[]{197/255.0, 187/255.0, 166/255.0}, // background
    new float[][]{
      {225/255.0, 208/255.0, 91/255.0}, // yellow
      {36/255.0, 36/255.0, 40/255.0}, // black
      {24/255.0, 63/255.0, 159/255.0}, // blue
      {229/255.0, 228/255.0, 228/255.0} // white
    }));

  palettes.add(new Palette(
    "332",
    new float[]{142/255.0, 146/255.0, 140/255.0}, // background
    new float[][]{
      {115/255.0, 20/255.0, 30/255.0}, // red
      {142/255.0, 40/255.0, 20/255.0}, // orange
      {30/255.0, 75/255.0, 177/255.0}, // blue
    }));
}
