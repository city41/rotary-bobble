
                // on pcb <----> from RB15
const int BTN_D = 12; // purple <----> blue
const int BTN_C = 11; // blue   <----> orange
const int BTN_B = 10; // green  <----> red
const int DIR_R = 9;  // yellow <----> yellow
const int DIR_L = 4;  // red    <----> white
const int DIR_D = 3;  // orange <----> green
const int DIR_U = 2;  // brown  <----> orange
//  GND                   <----> white 

const int MIN_EXTENT = 0;
const int MAX_EXTENT = 127;
const int MIN_ANGLE = -60;
const int MAX_ANGLE = 60;

int pins[7] = { DIR_U, DIR_D, DIR_L, DIR_R, BTN_B, BTN_C };

void setup() {
  pinMode(BTN_D, OUTPUT);
  pinMode(BTN_C, OUTPUT);
  pinMode(BTN_B, OUTPUT);
  pinMode(DIR_R, OUTPUT);
  pinMode(DIR_L, OUTPUT);
  pinMode(DIR_D, OUTPUT);
  pinMode(DIR_U, OUTPUT);
}

int getPotValue() {
  int sampleValue = 0;
  int sampleCount = 0;
  
  for (int i = 0; i < 10; ++i) {
    sampleValue += analogRead(A0);
    sampleCount += 1;
    delayMicroseconds(500);
  }

  int sampleAvg = sampleValue / sampleCount;
  return sampleAvg >> 3;
}

int mapValue(float inputMin, float inputMax, float outputMin, float outputMax, float val) {
  return (int)(outputMin + ((outputMax - outputMin) / (inputMax - inputMin)) * (val - inputMin));
}

void loop() {
  int potValue = getPotValue();

  if (potValue < MIN_EXTENT) {
    potValue = MIN_EXTENT;
  }

  if (potValue > MAX_EXTENT) {
    potValue = MAX_EXTENT;
  }

  int angle = mapValue(MIN_EXTENT, MAX_EXTENT, MIN_ANGLE, MAX_ANGLE, potValue);

  // btn D is a sign bit
  digitalWrite(BTN_D, angle < 0);

  angle = abs(angle);
  for (int i = 0; i < 6; ++i) {
    digitalWrite(pins[i], angle & 1);
    angle = angle >> 1;
  }

  delay(8);
}

