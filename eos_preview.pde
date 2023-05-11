import oscP5.*;
import netP5.*;

OscP5 oscP5;
OscProperties oscProps;

ArrayList points;

Boolean showBlankLines = true;
Boolean drawProjection = true;
Boolean drawBeams = true;

float intensity = 1.0;
ArrayList<Point> testPoints;
PImage laserTex;

void setup() {
  size(1920, 1080, P3D);
  textSize(32);
  oscProps = new OscProperties();
  oscProps.setDatagramSize(65535);
  oscProps.setListeningPort(12000);
  oscP5 = new OscP5(this, oscProps);
  
  surface.setResizable(true);
  laserTex = loadImage("laser_gaussian4.png");
  //testPoints = makeTestPoints();
  noLoop();
  blendMode(ADD);
}


void draw() {
  if (points == null || points.size() == 0) {
    return;
  }

  background(0);
  hint(DISABLE_DEPTH_MASK);
  ArrayList lpoints = new ArrayList(points);
  
  camera(0, 0, 1000,
         0, 0, 0,
         0, 1, 0);
  
  float fovy = PI / 3.0; // 60 degrees
  float aspect = width / (float)height;
  float zNear = 0.01;
  float zFar =2000;
  perspective(fovy, aspect, zNear, zFar);

  if (drawBeams) {
    drawBeamsBB(lpoints);
  }

  // 2D 
  camera();
  
  if (drawProjection) {
    drawProjection(lpoints); 
  }
  
  fill(255);
  text("FPS: " + int(frameRate), 10, 36);
}


void drawBeamsBB(ArrayList ppoints) {
    int npoints = ppoints.size();
    float len = 2000.0;
    float beamWidth = 8;
    blendMode(ADD);
    textureMode(NORMAL);
    noStroke();
    
    beginShape(QUADS);
    for (int i = 0; i < npoints; i++) {
      // billboard texture - surface normal always points
      // at the view vector
      Point originalP = (Point)ppoints.get(i);
      PVector p = new PVector(originalP.x, originalP.y, len);
      PVector beamVec = new PVector(p.x, p.y, len).normalize();
      PVector projAxis = new PVector(0, 0, len).normalize();
      PVector faceNormal = PVector.sub(beamVec, projAxis);
      PVector cornerDir = faceNormal.cross(beamVec).normalize();
      PVector p1 = PVector.sub(p, PVector.mult(cornerDir, beamWidth));
      PVector p2 = PVector.add(p, PVector.mult(cornerDir, beamWidth));
      
      // at the laser source
      PVector p3 = PVector.mult(cornerDir, beamWidth);
      PVector p4 = PVector.mult(cornerDir, -beamWidth);
      
      tint(originalP.r, originalP.g, originalP.b, 192);
      texture(laserTex);
      vertex(p3.x, p3.y, p3.z, 0, 0);
      vertex(p4.x, p4.y, p4.z, 0, 1);
      vertex(p1.x, p1.y, p1.z, 1, 1);
      vertex(p2.x, p2.y, p2.z, 1, 0);
    }
    endShape();
}

void drawProjection(ArrayList ppoints) {
  int npoints = ppoints.size();
  blendMode(REPLACE);
  noFill();
  pushMatrix();
  translate(width/2, height/2);
  beginShape(LINES);
  for (int i = 0; i < npoints; i++) {
    int pidx1 = i;
    int pidx2 = (i+1) % npoints;
    Point p1 = (Point)ppoints.get(pidx1);
    Point p2 = (Point)ppoints.get(pidx2);
       
    if (p1.r==0.0 && p1.g==0.0 && p1.b==0.0) {
      if (showBlankLines) {
        strokeWeight(1);
        stroke(64, 64, 64);
      } else {
        noStroke();
      }
    } else {
      //int[] rgb = {};
      strokeWeight(8);
      stroke(p1.r, p1.g, p1.b, intensity*255);
    }
    vertex(p1.x, p1.y);
    //vertex(0.0, 0.0);
    vertex(p2.x, p2.y);
    
    //strokeWeight(2);
    //stroke(r1, g1, b1, 192);
    //line(0, 0, x1, y1);
  }
  endShape();
  popMatrix();
}


ArrayList<Point> makeTestPoints() {
  ArrayList<Point> points = new ArrayList();
  int npoints = 3;
  float rad = 500;
  for (int i=0; i < npoints; i++) {
    float a = TWO_PI / npoints * i;
    float x = rad * cos(a);
    float y = rad * sin(a);
    points.add(new Point(x, y, 0.0, 255, 0, 0));
  }
  return points;
}


void drawFrame() {

  pushMatrix();
  translate(width/2, height/2);
  //ArrayList lpoints = points;
  //ArrayList lpoints = (ArrayList)points.clone();
  ArrayList lpoints = new ArrayList(points);
  int npoints = lpoints.size();
  Boolean drawBeams = false;
  Boolean drawBeams2 = false;
  Boolean drawBeams3 = true;
  
  Boolean drawProjection = false;
  float beamlen = 50.0;
    
  if (drawBeams2) {
    //strokeWeight(4);
    noStroke();
    beginShape(TRIANGLE_FAN);
    
      //stroke(128,128,128,16);
      //fill(128,128,128,255);
      fill(64, 255);
      vertex(0,0);

    
      for (int i = 0; i < npoints-1; i++) {
        Point p1 = (Point)lpoints.get(i);
        Point p2 = (Point)lpoints.get((i+1) % points.size());
        //stroke(p1.r, p1.g, p1.b, 255);
        fill(p1.r, p1.g, p1.b, 255);
        
        vertex(p1.x*beamlen, p1.y*beamlen);
        //vertex(p2.x*25, p2.y*25);
        
      }
      
      Point p1 = (Point)lpoints.get(0);
      stroke(p1.r, p1.g, p1.b, 32);
      fill(p1.r, p1.g, p1.b, 64);      
      vertex(p1.x*beamlen, p1.y*beamlen);
    endShape();
  }



  if (drawBeams3) {
    float len = 2000.0;
    strokeWeight(2);
    //noStroke();
    //noFill();
    beginShape(TRIANGLES);
    for (int i = 0; i < npoints-1; i++) {
      Point p1 = (Point)lpoints.get(i);
      Point p2 = (Point)lpoints.get((i+1) % points.size());
      //stroke(p1.r, p1.g, p1.b, 128);
      fill(p1.r, p1.g, p1.b, 192);
      
      vertex(0, 0, 0);
      vertex(p1.x, p1.y, len);
      vertex(p2.x, p2.y, len);
      
    }
    endShape();
  }
  
  popMatrix();
  points = null;
}



void oscEvent(OscMessage theOscMessage) {
  ArrayList buf = new ArrayList();
  ArrayList newPoints = new ArrayList();
  if (theOscMessage.addrPattern().equals("/frame-in")) {
    for (int i = 0; i < theOscMessage.typetag().length(); i++) {
      float value = theOscMessage.get(i).floatValue();
      buf.add(value);
    }
    int bufsize = buf.size();

    if(bufsize <= 0) {
      return;
    }
    
    if (bufsize % 5 != 0) {
      println("ERROR: oscEvent: size is not a multiple of 5:", buf.size());
    }
    else {
      int npoints = buf.size() / 5;
      
      for (int i = 0; i < npoints; i++) {
        int pidx1 = i*5;
        float x1 = (height/2) * (float)buf.get(pidx1+0);
        float y1 = (height/2) * (float)buf.get(pidx1+1);
        float r1 = 255 * (float)buf.get(pidx1+2);
        float g1 = 255 * (float)buf.get(pidx1+3);
        float b1 = 255 * (float)buf.get(pidx1+4);
        Point p = new Point(x1, y1, r1, g1, b1);
        newPoints.add(p);
      }
      points = newPoints;
      //points = buf; 
      redraw();
    }   
  }
}

class Point {
  float x, y, z, r, g, b;
  
  Point(float _x, float _y, float _r, float _g, float _b) {
    this.x = _x;
    this.y = _y;
    this.z = 0.0;
    this.r = _r;
    this.g = _g;
    this.b = _b;    
  }
  Point(float _x, float _y, float _z, float _r, float _g, float _b) {
    this.x = _x;
    this.y = _y;
    this.z = _z;
    this.r = _r;
    this.g = _g;
    this.b = _b;    
  }
}
