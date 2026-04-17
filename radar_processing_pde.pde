import processing.serial.*; 

Serial myPort; 
String angle="";
String distance="";
String data="";
String noObject;
float pixsDistance;
int iAngle, iDistance;
int index1=0;

void setup() {
  // Use fullScreen() if you want it to cover the whole projector screen
  size(1280, 720); 
  smooth();
  
  // STEP 1: Change "COM3" to your actual port if it's different!
  try {
    myPort = new Serial(this, "COM3", 9600); 
    myPort.bufferUntil('.'); 
  } catch (Exception e) {
    println("SERIAL ERROR: Check your USB cable or COM port number.");
  }
}

void draw() {
  // Motion blur effect - lower the '15' for longer trails
  fill(0, 15); 
  noStroke();
  rect(0, 0, width, height); 
  
  fill(98, 245, 31); 
  drawRadar(); 
  drawLine();
  drawObject();
  drawText();
}

void serialEvent (Serial myPort) { 
  try {
    data = myPort.readStringUntil('.');
    if (data != null && data.length() > 1) {
      data = data.substring(0, data.length() - 1);
      index1 = data.indexOf(","); 
      
      if (index1 > 0) {
        angle = data.substring(0, index1); 
        distance = data.substring(index1 + 1, data.length()); 
        
        // trim() is crucial to prevent crashes from hidden characters
        iAngle = int(trim(angle));
        iDistance = int(trim(distance));
      }
    }
  } catch (Exception e) {
    // Keeps the program running even if data is corrupted
  }
}

void drawRadar() {
  pushMatrix();
  translate(width/2, height - 70); 
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);
  
  // Draw arcs based on screen width
  float r = width * 0.9;
  arc(0, 0, r, r, PI, TWO_PI);
  arc(0, 0, r*0.75, r*0.75, PI, TWO_PI);
  arc(0, 0, r*0.5, r*0.5, PI, TWO_PI);
  arc(0, 0, r*0.25, r*0.25, PI, TWO_PI);
  
  // Angle lines
  for (int a = 30; a <= 150; a += 30) {
    line(0, 0, (-r/2) * cos(radians(a)), (-r/2) * sin(radians(a)));
  }
  line(-r/2, 0, r/2, 0);
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(width/2, height - 70); 
  strokeWeight(9);
  stroke(255, 10, 10); // Red for detected objects
  
  // Map 40cm range to screen radius
  pixsDistance = iDistance * ((width * 0.45)/40); 
  
  if (iDistance < 40 && iDistance > 0) { 
    float x = pixsDistance * cos(radians(iAngle));
    float y = -pixsDistance * sin(radians(iAngle));
    float xEnd = (width*0.48) * cos(radians(iAngle));
    float yEnd = -(width*0.48) * sin(radians(iAngle));
    line(x, y, xEnd, yEnd);
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60); 
  translate(width/2, height - 70); 
  line(0, 0, (width*0.475) * cos(radians(iAngle)), -(width*0.475) * sin(radians(iAngle))); 
  popMatrix();
}

void drawText() { 
  noObject = (iDistance > 40 || iDistance <= 0) ? "Out of Range" : "In Range";
  
  fill(0);
  noStroke();
  rect(0, height - 80, width, 80); // Text panel
  
  fill(98, 245, 31);
  textSize(width * 0.015);
  text("10cm", width/2 + (width*0.1), height - 100);
  text("20cm", width/2 + (width*0.2), height - 100);
  text("30cm", width/2 + (width*0.3), height - 100);
  text("40cm", width/2 + (width*0.4), height - 100);
  
  textSize(width * 0.02);
  text("Object: " + noObject, 50, height - 30);
  text("Angle: " + iAngle + "°", width/2 - 50, height - 30);
  text("Distance: " + (iDistance < 40 && iDistance > 0 ? iDistance + " cm" : "---"), width/2 + 150, height - 30);
}
