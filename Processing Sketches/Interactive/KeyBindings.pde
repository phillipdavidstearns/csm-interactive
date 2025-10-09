void keyPressed() {
  switch(key) {
  case ' ':
    activePalette = palettes.get(int(random(palettes.size())));
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
