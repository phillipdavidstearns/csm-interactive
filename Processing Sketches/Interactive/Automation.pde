//Basic physics for a mass teathered to an origin by a simple "spring"
// Can map isBeat to striking forces and then map location or velocity to offsets.

class Mass{

  PVector origin = new PVector(0.5, 0.5, 1.0); // GL Coordinates for XY center and "Z"
  PVector loc =  new PVector(0.5, 0.5, 1.0);
  PVector vel = new PVector(0.0, 0.0, 0.0);
  PVector acc = new PVector(0.0, 0.0, 0.0);
  PVector force = new PVector(0.0, 0.0, 0.0);
  float m = 5000.0;
  float drag = 0.0125;
  float k = 0.0125;
  float radius = 5;
  boolean stroke = false;
  boolean fill = true;
  color c = color(255);
  
  Mass(){
  }
  
  Mass(
    PVector pos,
    float m,
    float drag,
    float k,
    float radius,
    boolean stroke,
    boolean fill,
    color c
   ){
     this.loc = pos.copy();
     this.origin = pos.copy();
     this.m = m;
     this.drag = drag;
     this.k = k;
     this.radius = radius;
     this.stroke = stroke;
     this.fill = fill;
     this.c = c;
  }
  
  Mass setOrigin(PVector _origin){
    this.origin = _origin.copy();
    return this;
  }
  
  void update(){
    applyForce();
  }
  
  void applyForce(){
    //F = m * a >> a = F / m
    PVector fExt = this.force.div(this.m);
    PVector fOrigin = new PVector();
    
    if(this.k !=0){
      fOrigin = PVector.sub(this.origin, this.loc).mult(k);
    }
    
    //PVector fOrigin = PVector.sub(this.origin, this.loc) // vector pointing from loc to origin
    //  .setMag(PVector.dist(this.loc, this.origin) * this.k);
    this.acc = PVector.add(fExt, fOrigin);
    this.vel = this.vel.mult(1 - this.drag).add(this.acc);
    this.loc = this.loc.add(this.vel);
    this.force = new PVector(0.0, 0.0, 0.0);
  }
  
  void addForce(PVector _force){
    this.force = this.force.add(_force);
  }
  
  void render(){
    if (!this.stroke) {
      noStroke();
    } else {
      stroke(this.c);
    }
    
    if (!this.fill){
      noFill();
    } else {
      fill(255);
    }
 
    circle(loc.x * width, loc.y * height, 2*this.radius);
  }
  
}

//================================================================

PVector accumulatedWind = new PVector();

PVector getWind(float x, float y, float scale, float gain, float magOffset, float dirOffset){
  PVector out = PVector.fromAngle(0);

  float dir = noise(x * scale, y * scale, dirOffset);
  out.setHeading(2 * PI * dir);

  float mag = noise(x * scale, y * scale, magOffset);
  out.setMag(mag * gain);

  return out;
}

void accumulateWind(PVector wind){
  accumulatedWind = accumulatedWind.add(wind);
}
