void keyPressed() {
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
    reverseShaderSort = !reverseShaderSort;
    break;
  case 'S':
    sortFeedback = !sortFeedback; // toggle pixel sorting for the feedback loop
    break;
  case 'R':
    reverseFeedbackSort = !reverseFeedbackSort;
    break;
  }
}
