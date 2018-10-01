import processing.sound.*;

FFT fft;
AudioIn in;
Amplitude rms;
PImage welcomeImg;
PImage randomImg;
PFont font;

int res = (int)pow(2, 9);
float amplifier = 60;
float[] spectrum = new float[res];
float imgNum;
int state = 0;

int startTime; 
int counter; 
float maxTime; 
boolean done; 

float score;

ArrayList<PVector> points = new ArrayList<PVector>();
ArrayList<PVector> velocities = new ArrayList<PVector>();

int pointTotal = 80;
int distance = 50;
int fade = 60;

float smoothingFactor = 1;
float sum;


void setup() {
  //fullScreen();
  size(480, 320);
  noCursor();    
  font = createFont("Bungee-Regular.ttf", 32);
  welcomeImg = loadImage("welcome.png");
  fft = new FFT(this, res);
  in = new AudioIn(this, 0);
  in.start();  
  fft.input(in);
  textFont(font);
  smooth();
  counter = 0; 
  startTime= millis(); 
  maxTime=random(1, 3)*10000; 
  done=false;

  for (int i = 0; i < pointTotal; i++) {
    points.add(new PVector(random(width), random(height)));
    velocities.add(new PVector(random(-1, 1), random(-1, 1)));
  }
  rms = new Amplitude(this);
  rms.input(in);
}      

void draw() { 
  switch(state) {
  case 0:
    welcome();
    break;
  case 1:
    drawSpectrum();
    break;
  case 2:
    analyzing();
    break;
  case 3:
    result();
    break;
  }
}

void welcome() {
  pointTotal = 20;
  distance = 80;

  fill(255, 100);
  rect(-10, -10, width+10, height+10);
  stroke(1);
  strokeWeight(1);
  for (int i = 0; i < points.size()-1; i++) {
    PVector p1 = points.get(i);
    for (int j = i; j < points.size(); j++) {
      PVector p2 = points.get(j);
      float myDist = dist(p1.x, p1.y, p2.x, p2.y);
      if (myDist<distance) {
        line(p1.x, p1.y, p2.x, p2.y);
      }
    }
  }
  move();

  fill(255);
  rect(-10, height/2-85, width+10, 170);

  imageMode(CENTER);
  image(welcomeImg, width/2, height/2);
}

void drawSpectrum() {
  fill(255,1);
  rect(0,0,width,height);
  stroke(255, 0, 0);

  sum += (rms.analyze() - sum) * smoothingFactor;
  float rms_scaled = sum * (height/2) * 5;
  pointTotal = int(rms_scaled*10);

  strokeWeight(0);
  for (int i = 0; i < points.size()-1; i++) {
    PVector p1 = points.get(i);
    for (int j = i; j < points.size(); j++) {
      PVector p2 = points.get(j);
      float myDist = dist(p1.x, p1.y, p2.x, p2.y);
      pointTotal = int(rms_scaled);
      distance = int(rms_scaled);
      if (myDist<distance) {
        line(p1.x, p1.y, p2.x, p2.y);
      }
    }
  }
  move();
  startTime= millis();
}

void analyzing() {
  pointTotal = 100;
  distance = 200;
  background(255);

  fill(255, fade);
  rect(-10, -10, width+10, height+10);
  strokeWeight(0);
  stroke(0, 255, 0);

  for (int i = 0; i < points.size()-1; i++) {
    PVector p1 = points.get(i);
    for (int j = i; j < points.size(); j++) {
      PVector p2 = points.get(j);
      float myDist = dist(p1.x, p1.y, p2.x, p2.y);
      if (myDist<distance) {
        line(p1.x, p1.y, p2.x, p2.y);
      }
    }
  }
  move();

  fill(255, 200);
  rect(-10, height/2-85, width+10, 170);

  rectMode(CORNER);
  textAlign(CENTER);
  textSize(32);
  fill(0, 200, 0);
  text("ANALYZING", width/2, height/2-20);

  if (counter-startTime < maxTime) {
    counter=millis();
  } else {
    done=true;
  }

  noStroke();
  rect(width/2-100, height/2-5, map(counter-startTime, 0, maxTime, 0, 200), 19 );
  textMode(CENTER);
  textSize(22);
  text(counter- startTime+" " + int(maxTime) +  " " + int ( map(counter-startTime, 0, maxTime, 0, 200)), width/2, height/2+50);
  noFill();
  //stroke(0);
  rect(width/2-100, height/2-5, 200, 19);

  if (done) {
    state++;
    counter = 0; 
    startTime= millis(); 
    maxTime=random(1, 3)*10000; 
    done=false;
    score = random(0, 100);
    imgNum = random(0, 24);
  }
}

void result() {
  background(255);
  randomImg = loadImage(int(imgNum) +".png");
  imageMode(CENTER);
  image(randomImg, width/2, height/2, randomImg.width, randomImg.width);
}

void mouseReleased() {
  background(255);
  state++;
  if (state==4) {
    state=0;
  }
}

void move() {
  for (int i = 0; i < points.size()-1; i++) {
    PVector p = points.get(i);
    PVector v = velocities.get(i);
    p.add(v);
    if (p.x > width)p.x -= width;
    if (p.y > height)p.y -= height;
    if (p.x < 0)p.x += width;
    if (p.y < 0)p.y += height;
  }
}