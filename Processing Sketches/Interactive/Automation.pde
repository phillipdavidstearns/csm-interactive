//Basic physics for a mass teathered to an origin by a simple "spring"
// Can map isBeat to striking forces and then map location or velocity to offsets.

class Mass{

  PVector origin = new PVector(0.5, 0.5, 1.0); // GL Coordinates for XY center and "Z"
  PVector loc =  new PVector(0.5, 0.5, 1.0);
  PVector vel = new PVector(0.0, 0.0, 0.0);
  PVector acc = new PVector(0.0, 0.0, 0.0);
  PVector force = new PVector(0.0, 0.0, 0.0);
  float m = 2500.0;
  float drag = 0.025;
  float k = 0.0125;
  float radius = 5;
  
  void update(){
    applyForce();
    render();
  }
  
  void applyForce(){
    //F = m * a >> a = F / m
    PVector fExt = this.force.div(this.m);
    PVector fOrigin = PVector.sub(this.origin, this.loc) // vector pointing from loc to origin
      .setMag(PVector.dist(this.loc, this.origin) * this.k);
    this.acc = PVector.add(fExt, fOrigin);
    this.vel = this.vel.mult(1 - this.drag).add(this.acc);
    this.loc = this.loc.add(this.vel);
    this.force = new PVector(0.0, 0.0, 0.0);
  }
  
  void addForce(PVector _force){
    this.force = this.force.add(_force);
  }
  
  void render(){
    noStroke();
    fill(255);
    circle(loc.x * width, loc.y * height, 2*this.radius);
  }
  
}
