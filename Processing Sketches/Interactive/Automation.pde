//Basic physics for a mass teathered to an origin by a simple "spring"
// Can map isBeat to striking forces and then map location or velocity to offsets.

class Mass {

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

  Mass() {
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
    ) {
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

  Mass setOrigin(PVector _origin) {
    this.origin = _origin.copy();
    return this;
  }

  void update() {
    applyForce();
  }

  void applyForce() {
    //F = m * a >> a = F / m
    PVector fExt = this.force.div(this.m);
    PVector fOrigin = new PVector();

    if (this.k !=0) {
      fOrigin = PVector.sub(this.origin, this.loc).mult(k);
    }

    //PVector fOrigin = PVector.sub(this.origin, this.loc) // vector pointing from loc to origin
    //  .setMag(PVector.dist(this.loc, this.origin) * this.k);
    this.acc = PVector.add(fExt, fOrigin);
    this.vel.mult(1 - this.drag).add(this.acc);
    this.loc.add(this.vel);
    this.loc.x = constrain(this.loc.x, 0, 1);
    this.loc.y = constrain(this.loc.y, 0, 1);
    this.loc.z = constrain(this.loc.z, 0.95, 1.05);
    this.acc = new PVector(0.0, 0.0, 0.0);
    this.force = new PVector(0.0, 0.0, 0.0);
  }

  void addForce(PVector _force) {
    this.force = this.force.add(_force);
  }

  void render() {
    if (!this.stroke) {
      noStroke();
    } else {
      stroke(this.c);
    }

    if (!this.fill) {
      noFill();
    } else {
      fill(255);
    }

    circle(loc.x * width, loc.y * height, 2*this.radius);
  }
}

//================================================================

class Wind {
  float zOffset = random(-30, 30);
  float magOffset = random(-30, 30);
  float dirOffset = random(-30, 30);
  float scale = 10;

  Wind() {
  }

  Wind(float _scale) {
    this.scale = _scale;
  }


  PVector wind(float x, float y) {

    float dir = noise(x * this.scale, y * this.scale, dirOffset);
    float z = noise(x * this.scale, y * this.scale, this.zOffset);
    PVector _wind = PVector.fromAngle(
      map(constrain(dir, 0.25, 0.75), 0.25, 0.75, 0, 2*PI));
    _wind.z = map(constrain(z, 0.25, 0.75), 0.25, 0.75, -1, 1);
    float mag = noise(x * this.scale, y * this.scale, magOffset);
    _wind.setMag(mag);

    return _wind;
  }

  void stepOffsets(float mag, float dir) {
    magOffset += mag;
    dirOffset += dir;
    zOffset += 0.5 * (mag + dir);
  }
}

PVector accumulatedWind = new PVector();

void accumulateWind(PVector wind) {
  accumulatedWind = accumulatedWind.add(wind);
}
