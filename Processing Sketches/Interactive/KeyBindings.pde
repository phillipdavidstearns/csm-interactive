void keyPressed(){ 
  switch(key){
    case ' ':
      activePalette = palettes.get(int(random(palettes.size())));
    break;
  }
}
