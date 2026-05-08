void keyPressed() {

  if (key == ESC) {
    key = 0;  // Fools! don't let them escape!
  }

  switch(key) {
  case ' ':
    activePaletteA = palettes.get(int(random(palettes.size())));
    activePaletteA.randomizePastels();
    activePaletteB = palettes.get(int(random(palettes.size())));
    activePaletteB.randomizePastels();
    break;
  case 'a':
    shiftShader = !shiftShader; // toggle pixel shifting for just the shader
    break;
  case 's':
    sortShader = !sortShader; // toggle pixel sorting for just the shader
    break;
  case 'r':
    reverseSort = !reverseSort;
    break;
  case 'S':
    shiftSort = !shiftSort; // toggle pixel sorting for the feedback loop
    break;
  case 'i':
    devMode = !devMode;
    break;
  case 'm':
    sortMode ++;
    sortMode %= 8;
    break;
  case 'p':
    preProcess = !preProcess;
    break;
  case 'P':
    postProcess = !postProcess;
    break;
  case 'b':
    mass.addForce( new PVector(
      random(-100, 100),
      random(-100, 100),
      random(-100, 100)
      ));
  }
}
