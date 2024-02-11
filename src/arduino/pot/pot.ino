int LEFT_PIN = 8;
int RIGHT_PIN = 7;


void setup() {
  pinMode(LEFT_PIN, OUTPUT);
  pinMode(RIGHT_PIN, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
  int sensorValue = 0;
  int sampleCount = 0;
  
  for (int i = 0; i < 10; ++i) {
    sensorValue += analogRead(A0);
    sampleCount += 1;
    delayMicroseconds(500);
  }

  int sensorAvg = sensorValue / sampleCount;
  int val = sensorAvg >> 3;



  if (val < 128 / 3) {
    digitalWrite(LEFT_PIN, 1);
    digitalWrite(RIGHT_PIN, 0);
  } else if (value < (128 * 2 / 3)) {
    digitalWrite(LEFT_PIN, 0);
    digitalWrite(RIGHT_PIN, 0);
  } else {
    digitalWrite(LEFT_PIN, 0);
    digitalWrite(RIGHT_PIN, 1);
  }
  
  delay(8);
}
