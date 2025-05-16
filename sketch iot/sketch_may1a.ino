#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>

// WiFi credentials
#define WIFI_SSID "xrp"
#define WIFI_PASSWORD "mstahulhaq"

// Firebase credentials
#define API_KEY "AIzaSyBz7EAZbKYOCMELCun4rv9Oahvci0DRtos"
#define DATABASE_URL "https://iot2-affcc-default-rtdb.firebaseio.com/"

// LED configuration
#define LED1_PIN 2
#define LED2_PIN 4

// Firebase Data
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// LED state
bool patient1LedState = false;
bool patient2LedState = false;

void setup() {
  Serial.begin(115200);

  // LED pins
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);

  // WiFi connection
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi");

  // Firebase config
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  auth.user.email = "ulhaq@gmail.com";
  auth.user.password = "ulhaq123";

  Firebase.begin(&config, &auth);
  fbdo.setBSSLBufferSize(4096, 1024);

  // Optional: Set default state
  FirebaseJson json;
  json.set("patient1/pesan", "sudah ditangani");
  json.set("patient1/count", 0);
  json.set("patient2/pesan", "sudah ditangani");
  json.set("patient2/count", 0);
  json.set("led1", false);
  json.set("led2", false);
  Firebase.setJSON(fbdo, "/iot", json);

  Serial.println("Firebase initialized");
}

void loop() {
  if (Firebase.ready()) {
    // ==== Patient 1 ====
    if (Firebase.getString(fbdo, "/iot/patient1/pesan")) {
      String message = fbdo.stringData();

      if (message == "pasien 1 meminta bantuan" && !patient1LedState) {
        digitalWrite(LED1_PIN, HIGH);
        patient1LedState = true;

        // Tambah counter
        if (Firebase.getInt(fbdo, "/iot/patient1/count")) {
          int count = fbdo.intData() + 1;
          Firebase.setInt(fbdo, "/iot/patient1/count", count);
          Serial.print("Patient 1 meminta bantuan - Total: ");
          Serial.println(count);
        }
      } else if (message != "pasien 1 meminta bantuan" && patient1LedState) {
        digitalWrite(LED1_PIN, LOW);
        patient1LedState = false;
      }
    }

    // ==== Patient 2 ====
    if (Firebase.getString(fbdo, "/iot/patient2/pesan")) {
      String message = fbdo.stringData();

      if (message == "pasien 2 meminta bantuan" && !patient2LedState) {
        digitalWrite(LED2_PIN, HIGH);
        patient2LedState = true;

        // Tambah counter
        if (Firebase.getInt(fbdo, "/iot/patient2/count")) {
          int count = fbdo.intData() + 1;
          Firebase.setInt(fbdo, "/iot/patient2/count", count);
          Serial.print("Patient 2 meminta bantuan - Total: ");
          Serial.println(count);
        }
      } else if (message != "pasien 2 meminta bantuan" && patient2LedState) {
        digitalWrite(LED2_PIN, LOW);
        patient2LedState = false;
      }
    }

    delay(100);
  }
}
