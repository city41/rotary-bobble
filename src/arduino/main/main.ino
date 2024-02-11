
                // on pcb <----> from RB15
int BTN_D = 12; // purple <----> blue
int BTN_C = 11; // blue   <----> orange
int BTN_B = 10; // green  <----> red
int DIR_R = 9;  // yellow <----> yellow
int DIR_L = 4;  // red    <----> white
int DIR_D = 3;  // orange <----> green
int DIR_U = 2;  // brown  <----> orange
//  GND                   <----> white 

int MIN_EXTENT = 0;
int MAX_EXTENT = 127;
int MIN_ANGLE = -60;
int MAX_ANGLE = 60;

int BTN_D_INDEX = 6;

int pins[7] = { DIR_U, DIR_D, DIR_L, DIR_R, BTN_B, BTN_C, BTN_D };

void setup() {
  pinMode(BTN_D, OUTPUT);
  pinMode(BTN_C, OUTPUT);
  pinMode(BTN_B, OUTPUT);
  pinMode(DIR_R, OUTPUT);
  pinMode(DIR_L, OUTPUT);
  pinMode(DIR_D, OUTPUT);
  pinMode(DIR_U, OUTPUT);

  //Serial.begin(9600);
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

int bitplane[7] = { 0, 0, 0, 0, 0, 0, 0 };

void toBitplane(int value) {
  for (int i = 0; i < 7; ++i) {
    bitplane[i] = value & 1;
    value = value >> 1;
  }
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

  toBitplane(abs(angle));

  if (angle < 0) {
    bitplane[BTN_D_INDEX] = 1;
  } else {
    bitplane[BTN_D_INDEX] = 0;
  }

  //Serial.print("angle: ");
  //Serial.print(angle);
  //Serial.print(" bp: ");
  for (int i = 0; i < 7; ++i) {
    //Serial.print(bitplane[i]);
    digitalWrite(pins[i], bitplane[i]);
  }
  //Serial.println();

  delay(8);
}
