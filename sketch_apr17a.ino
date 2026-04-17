// Final Arduino Radar Code
#include <Servo.h> 

const int trigPin = 8;
const int echoPin = 9;
const int buzzer = 7;

long duration;
int distance;
Servo myServo; 

void setup() {
  pinMode(trigPin, OUTPUT); 
  pinMode(echoPin, INPUT); 
  pinMode(buzzer, OUTPUT); 
  Serial.begin(9600);
  myServo.attach(10); 
}

void loop() {
  // Sweep from 0 to 160 degrees
  for(int i=0; i<=160; i++){  
    myServo.write(i);
    delay(30); 
    distance = calculateDistance();
    
    // SEND DATA TO PROCESSING: angle,distance.
    Serial.print(i);        
    Serial.print(",");      
    Serial.print(distance); 
    Serial.print(".");      
  }
  
  // Sweep back from 160 to 0 degrees
  for(int i=160; i>0; i--){  
    myServo.write(i);
    delay(30);
    distance = calculateDistance();
    
    Serial.print(i);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(".");
  }
}

int calculateDistance(){ 
  digitalWrite(trigPin, LOW); 
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH); 
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  duration = pulseIn(echoPin, HIGH);
  distance = duration * 0.034 / 2;

  // Buzzer logic for close objects
  if (distance > 0 && distance < 25) {
    digitalWrite(buzzer, HIGH);
  } else {
    digitalWrite(buzzer, LOW);
  }
  return distance;
}