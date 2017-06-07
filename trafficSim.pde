import interfascia.*;
GUIController c;
IFButton b1, b2, b3, b4;
IFLabel l;

int fRate = 60;
int carNum = 0; //number of cars
int beginSim = 0; //determines status of program (opening scene, runSim, pause...)
boolean openingCarMovement = false; //determines whether opening scene balls should be redrawn in starting spots
int circleCenter = 450; //center coordinates
int innerRadius = 300;
int outerRadius = 330;
int carRadius = 5;

void setup() {
  size(900, 900);
  frameRate(fRate);
  
  c = new GUIController (this);
  
  b1 = new IFButton ("Play", 690, 15, 50, 20);
  b2 = new IFButton ("+", 20, 15, 20, 20);
  b3 = new IFButton ("-", 50, 15, 20, 20);
  b4 = new IFButton ("Pause", 690, 45, 50, 20);
  
  b1.addActionListener(this);
  b2.addActionListener(this);
  b3.addActionListener(this);
  b4.addActionListener(this);
  
  c.add (b1);
  c.add (b2);
  c.add (b3);
  c.add (b4);
  
}

void actionPerformed (GUIEvent e) {
  if (e.getSource() == b1) { //play
    beginSim = 1; //begins simulation
  } else if (e.getSource() == b2) { //+
    if (carNum < 15) {
      carNum ++;
      openingCarMovement = false;
    }
  } else if (e.getSource() == b3) {//-
    if (carNum > 0) {
      carNum --;
      openingCarMovement = false;
    }
    openingCarMovement = false;
  } else if (e.getSource() == b4) {
    beginSim = 2;
  }
}

class Car {
  float position; //(0 to 2pi radians in a circle)
  double velocity; //revolutions per second
  double acceleration; //revolutions per second per second
  double reactionTime;
  int lane;
  Car(float p, double v, double a, double r, int l){
    position = p;
    velocity = v;
    acceleration = a;
    reactionTime = r;
    lane = l;
  }
  
}

class Node {
  Car c;
  Node next;
  
  Node() {
    c = null;
    next = null;
  }
  
  Node(Car data) {
    c = data;
    next = null;
  }
  
}
//see http://www.studytonight.com/data-structures/circular-linked-list

class cLinkedList {
  Node first;
  Node last;
  
  cLinkedList(){
    first = null;
    last = null;
  }
  
  void add(Node n) { //adds a node to the cLinkedList
    if (first == null){
      first = n;
      last = n;
      n.next = n;
    }
    else{
      last.next = n;
      last = n;
      last.next = first;
    }
  }
  
  int length() { //iterates through the entire circle to find the length
    if (first != null){
      int counter = 0;
      for(Node i = first; i.next != first; i = i.next){
        counter ++;
      }
      return (counter + 1);
    }
    else {
      return 0;
    }
  }
  
  void remove() { //removes node directly after the "current" node
    if (first.next == first){
      first = null;
      last = null;
    }
    else if (first != null){
      last.next = first.next;
      first.next = first;
    }
  }
  
  void clear() { //brings linked list length to zero
    first = null;
    last = null;
  }
  
  
}

cLinkedList cars1 = new cLinkedList();
cLinkedList cars2 = new cLinkedList();

void pointUpdate (Node i){
  
  if (i.next.c.position < i.c.position){
    i.next.c.position += 2*PI;
  }

  if ((i.next.c.position - i.c.position) < PI/75){
    beginSim = 2;
  }
  else if ((i.next.c.position-i.c.position) < PI/8) {
    i.c.acceleration = -.001;
  }
  else if ((i.next.c.position-i.c.position) > PI/4){
    i.c.acceleration = .001;
  }
  else{
    i.c.acceleration = 0;
  }
  
  if ((i.c.velocity + i.c.acceleration) > .25){
    i.c.velocity = .25;
  }
  else if ((i.c.velocity + i.c.acceleration) >= 0){
    i.c.velocity += i.c.acceleration;
  }
  else {
    i.c.velocity = 0;
  }
  
  i.c.position += i.c.velocity/fRate*2*PI;
  i.c.position = i.c.position%(2*PI);
  i.next.c.position = i.next.c.position%(2*PI);
}

void play() {
  background(255);
  fill(255);
  ellipse(circleCenter, circleCenter ,2*outerRadius, 2*outerRadius);
  ellipse(circleCenter, circleCenter ,2*innerRadius, 2*innerRadius);
  fill(155,0,0);
  if (cars1.length() > 0){
    for(Node i = cars1.first; i != cars1.last; i = i.next){
      ellipse(circleCenter+innerRadius*cos(i.c.position), circleCenter-innerRadius*sin(i.c.position), 2*carRadius, 2*carRadius);
      pointUpdate(i);
    }
    ellipse(circleCenter+innerRadius*cos(cars1.last.c.position), circleCenter-innerRadius*sin(cars1.last.c.position), 2*carRadius, 2*carRadius);
    pointUpdate(cars1.last);
  }
  if (cars2.length() > 0){
    for(Node i = cars2.first; i != cars2.last; i = i.next){
      ellipse(circleCenter+outerRadius*cos(i.c.position), circleCenter-outerRadius*sin(i.c.position), 2*carRadius, 2*carRadius);
      pointUpdate(i);
    }
    ellipse(circleCenter+outerRadius*cos(cars2.last.c.position), circleCenter-outerRadius*sin(cars2.last.c.position), 2*carRadius, 2*carRadius);
    pointUpdate(cars2.last);
  }
}

void openingScene() {
  if (openingCarMovement == false) {
    background(255);
    fill(255);
    ellipse(circleCenter, circleCenter ,2*outerRadius, 2*outerRadius);
    ellipse(circleCenter, circleCenter ,2*innerRadius, 2*innerRadius);
    cars1.clear();
    cars2.clear();
    for (int i = 0; i< carNum; i++) {
      Car tempC = new Car(0, 0, 0, 0, 0); //creates new car objects
      
      tempC.velocity = .1 + .05*Math.random();
      tempC.acceleration = 0;
      tempC.reactionTime = Math.random()*0.4;
      double random = Math.random();
      if (random > 0.5){
        tempC.position = i*2*PI/(carNum);
        tempC.lane = 2;
        Node tempN = new Node(tempC);
        cars2.add(tempN);
      }
      else {
        tempC.position = i*2*PI/(carNum);
        tempC.lane = 1;
        Node tempN = new Node(tempC);
        cars1.add(tempN);
      }
    
    }
    openingCarMovement = true;
  }
  if (openingCarMovement) {
    background(255);
    fill(255);
    ellipse(circleCenter, circleCenter ,2*outerRadius, 2*outerRadius);
    ellipse(circleCenter, circleCenter ,2*innerRadius, 2*innerRadius);
    if (cars1.first != null){
      for (Node i = cars1.first; i != cars1.last; i = i.next) {
        fill(155,0,0); //red
        ellipse(circleCenter+innerRadius*cos(i.c.position), circleCenter-innerRadius*sin(i.c.position), 2*carRadius, 2*carRadius);
      }
      fill(155,0,0); //red
      ellipse(circleCenter+innerRadius*cos(cars1.last.c.position), circleCenter-innerRadius*sin(cars1.last.c.position), 2*carRadius, 2*carRadius);
    }
    
    if (cars2.first != null){
      for (Node i = cars2.first; i != cars2.last; i = i.next) {
        fill(155,0,0); //red
        ellipse(circleCenter+outerRadius*cos(i.c.position), circleCenter-outerRadius*sin(i.c.position), 2*carRadius, 2*carRadius);
      }
      fill(155,0,0); //red
      ellipse(circleCenter+outerRadius*cos(cars2.last.c.position), circleCenter-outerRadius*sin(cars2.last.c.position), 2*carRadius, 2*carRadius);
    }
    
  }
  
}

void pause() {
}

void draw() {
  if (beginSim == 1) {
    play();
  } else if (beginSim == 0){
    openingScene();
  }
  else if (beginSim == 2){
    pause();
  }
}