Robot theRobot;
PowerCell powerCells[];
int step;
float scale = 1000/30;
int autonomousMillis = 15000;
int teleOpMillis = 120000;
int startMillis;

void setup() {
  size(1200, 760);
  step = 0;
  startMillis = 0;
  theRobot = new Robot(1.3, 5);
  powerCells = new PowerCell[3];
  powerCells[0] = new PowerCell(7.5, 7.5);
  powerCells[1] = new PowerCell(12.5, 10);
  powerCells[2] = new PowerCell(15, 2.5);
}

int ellapsedMillis() {
  return millis() - startMillis;
}

void draw() {
  background(80);
  if (startMillis == 0) {
    fill(#000088);
    rectMode(CORNER);
    rect(0, 0, width, 60);
    fill(0);
    textSize(30);
    text("Click to begin autonomous", 240, 40);
  } else if (ellapsedMillis() < autonomousMillis) {
    fill(#880000);
    rectMode(CORNER);
    rect(0, 0, width, 60);
    fill(0);
    textSize(30);
    text("Autonomous Period: " + int((autonomousMillis-ellapsedMillis())/1000), 240, 40);
    autonomousPeriodic();
  } else {
    fill(#008800);
    rectMode(CORNER);
    rect(0, 0, width, 60);
    fill(0);
    textSize(30);
    int timeLeft = int((teleOpMillis-ellapsedMillis()+autonomousMillis)/1000);
    text("Teleop period. Cell count " + theRobot.numberCells, 20, 40);
    text("time left: " + timeLeft, 720, 40);
  }

  pushMatrix();
  translate(100, 160);
  scale(scale);
  drawField(scale);
  theRobot.draw();
  for (PowerCell p : powerCells) {
    p.draw();
  }
  popMatrix();
}

void mouseClicked() {
  startMillis = millis();
}

void keyReleased() {
  if (key == 'w' || key == 's') {
    theRobot.stop();
  }
  if (key == 'a' || key == 'd') {
    theRobot.torque = 0;
  }
}

void keyPressed() {  //teleopPeriodic
  if (ellapsedMillis() < autonomousMillis)
    return;

  if (key == 'w') {
    theRobot.powerForward();
  }

  if (key == 's') {
    theRobot.powerBack();
  }

  if (key == 'a') {
    theRobot.turnLeft();
  }

  if (key == 'd') {
    theRobot.turnRight();
  }  

  if (key == 'p') {
    for (PowerCell p : powerCells) {
      theRobot.pickUp(p);
    }
  }
}

void autonomousPeriodic() {
  //Exercise 10: fix autonomous to pick up 3 power cells and end in red zone
  if (step == 0 && ellapsedMillis() >= 500) {
    step = 1;
  }

  if (step == 1 && ellapsedMillis() >= 1300) {
    step = 2;
  }

  if (step == 2 && ellapsedMillis() >= 1400) {
    step = 3;
  }

  if (step == 3 && ellapsedMillis() >= 1500) {
    step = 4;
  }
  if (step == 4 && ellapsedMillis() >= 2100) {
    step = 5;
  }
  if (step == 5 && ellapsedMillis() >= 3100) {
    step = 2;
  }
  if (step == 2 && ellapsedMillis() >= 3200) {
    step = 6;
  }
  if (step == 6 && ellapsedMillis() >= 3300) {
    step = 7;
  }
  if (step == 7 && ellapsedMillis() >= 4250) {
    step = 2;
  }
  if (step == 2 && ellapsedMillis() >= 4300) {
    step = 5;
  }
  if (step == 5 && ellapsedMillis() >= 5600) {
    step = 2;
  }
  if (step == 2 && ellapsedMillis() >= 5700) {
    step = 8;
  }
  if (step == 8 && ellapsedMillis() >= 6400) {
    step = 2 ;
  }
  //Turn right and go straight
  if (step == 2 && ellapsedMillis() >= 6500) {
    step = 1;
  }
  if (step == 1 && ellapsedMillis() >= 7300) {
    step = 2;
  }
  if (step == 2 && ellapsedMillis() >= 7400) {
    step = 5;
  }
  if (step == 5 && ellapsedMillis() >= 9700) {
    step = 2;
  }


  switch(step) {
  case 0:
    theRobot.powerForward();
    break;
  case 1:
    theRobot.turnRight();
    break;
  case 2:
    theRobot.stop();
    theRobot.goStrait();
    break;
  case 3:
    theRobot.pickUp(powerCells[0]);
    break;
  case 4:
    theRobot.turnLeft();
    break;
  case 5:
    theRobot.goStrait();
    theRobot.powerForward();
    break;
  case 6:
    theRobot.pickUp(powerCells[1]);
    break;
  case 7:
    theRobot.turnLeft();
    break;
    case 8:
    theRobot.pickUp(powerCells[2]);
  }
}

void drawField(float s) {

  rectMode(CORNER);
  fill(120);
  stroke(#ff4444);
  strokeWeight(2/s);  
  rect(0, 0, 30, 15);

  noStroke();
  fill(#88ff88);
  rect(0, 0, 2.5, 15);
  fill(#ff8888);
  rect(27.5, 0, 2.5, 15);

  strokeWeight(1/s);
  noFill();
  stroke(180);
  for (float x = 2.5; x < 30; x += 2.5) {
    line(x, 0, x, 15);
  }
  for (float y = 2.5; y < 15; y += 2.5) {
    line(0, y, 30, y);
  }

  noFill();
  stroke(#ff4444);
  strokeWeight(2/s);  
  rect(0, 0, 30, 15);
}

//--------------------------------Robot-------------------------------
class Robot {
  float x;
  float y;
  float angle;
  float velo;
  float torque;
  int numberCells;

  Robot(float x, float y) {
    this.x = x;
    this.y = y;
    this.angle = 0;
    this.velo = 0;
    this.torque = 0;
    this.numberCells = 0;
  }

  void draw() {
    rectMode(CENTER);
    pushMatrix();
    translate(x, y);
    rotate(angle);
    fill(50, 200, 20);
    stroke(0, 0, 0);
    rect(-1, 1, .5, .5);
    rect(1, 1, .5, .5);
    rect(-1, -1, .5, .5);
    rect(1, -1, .5, .5);
    noStroke();
    fill(50, 40, 200);
    rect(0, 0, 2, 2);
    fill(50, 200, 20);
    ellipse(1, .05, .5, .5);
    //Exercise 1. Add code to draw robot: Note: measurements in feet. Center of robot should be (0,0)
    popMatrix();
    move();
  }

  void move() {
    x += velo * cos(angle);
    y += velo * sin(angle);
    angle += torque;
  }

  void stop() {
    //Exercise 2: Add code to make robot stop
    velo = 0;
  }

  void powerForward() {
    //Exercise 3: add code to move forward
    velo = .1;
  }

  void powerBack() {
    //Exercise 4: add code to move back
    velo = -.1;
  }

  void turnLeft() {
    //Exercise 5: add code to add left torque
    torque = -.03;
  }

  void turnRight() {
    //Exercise 6: add code to add right torque
    torque = .03;
  }

  void goStrait() {
    //Exercise 7: add code to stop turning
    torque = 0;
  }

  void pickUp(PowerCell p) {
    //Exercise 8: add code to pick up powerCell p (if close enough)
    if (dist(theRobot.x, theRobot.y, p.x, p.y) < 1) {
      p.picked = true;
    }
  }
}

class PowerCell {
  float x;
  float y;
  boolean picked;

  PowerCell(float x, float y) {
    this.x = x;
    this.y = y;
    picked = false;
  }

  void draw() {
    //Exercise 9: add code to draw powerCell (units in feet)
    pushMatrix();
    translate(x, y);
    fill(#F7FF1C);
    if (picked == false) {
      ellipse(0, 0, .5, .5);
    }

    popMatrix();
  }
}
