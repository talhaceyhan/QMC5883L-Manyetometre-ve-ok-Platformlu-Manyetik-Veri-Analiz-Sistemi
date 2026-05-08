#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_HMC5883_U.h>

Adafruit_HMC5883_Unified mag = Adafruit_HMC5883_Unified(12345);

const int ledPin = 13;      // Görev 5: Alarm LED'i
const float threshold = 500.0; // Örnek eşik değeri (uT)

void setup() {
  Serial.begin(9600);
  pinMode(ledPin, OUTPUT);
  if(!mag.begin()) {
    while(1);
  }
}

void loop() {
  sensors_event_t event; 
  mag.getEvent(&event);

  // Toplam alan şiddeti hesaplama: |B| = sqrt(Bx^2 + By^2 + Bz^2)
  float x = event.magnetic.x;
  float y = event.magnetic.y;
  float z = event.magnetic.z;
  float totalB = sqrt(x*x + y*y + z*z);

  // Görev 2: İstenen veri formatı (t, Bx, By, Bz, |B|)
  Serial.print(millis()); Serial.print(",");
  Serial.print(x); Serial.print(",");
  Serial.print(y); Serial.print(",");
  Serial.print(z); Serial.print(",");
  Serial.println(totalB);

  // Görev 5: Eşik kontrolü ve Alarm
  if(totalB > threshold) {
    digitalWrite(ledPin, HIGH);
  } else {
    digitalWrite(ledPin, LOW);
  }

  delay(200); // Daha akıcı grafik için bekleme süresini düşürdük
}