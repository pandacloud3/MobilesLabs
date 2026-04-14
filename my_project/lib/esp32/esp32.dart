// #include <WiFi.h>
// #include <PubSubClient.h>
// #include <ESP32Servo.h>

// const char* ssid = "AndroidAP_7164";
// const char* password = "Vlad007007";
// const char* mqtt_server = "broker.hivemq.com";
// const char* topic_level = "smart_bin/trash_level";
// const char* topic_lid = "smart_bin/lid_status";
// const char* topic_command = "smart_bin/command";

// const int ledGreen = 16;
// const int ledYellow = 17;
// const int ledRed = 5;
// const int pinFC51 = 18;
// const int pinTrig = 19;
// const int pinEcho = 21;
// const int pinServo = 25;

// Servo myServo;
// WiFiClient espClient;
// PubSubClient client(espClient);

// unsigned long lastMsg = 0;
// unsigned long lastReconnectAttempt = 0;
// unsigned long lidOpenTime = 0;
// bool isLidOpen = false;
// bool isLidLocked = false;

// void callback(char* topic, byte* payload, unsigned int length) {
//   String message = "";
//   for (int i = 0; i < length; i++) {
//     message += (char)payload[i];
//   }
  
//   if (String(topic) == topic_command) {
//     if (message == "lock_on") {
//       isLidLocked = true;
//     } 
//     else if (message == "lock_off") {
//       isLidLocked = false;
//     }
//   }
// }

// void setup() {
//   Serial.begin(115200);

//   pinMode(ledGreen, OUTPUT);
//   pinMode(ledYellow, OUTPUT);
//   pinMode(ledRed, OUTPUT);
//   pinMode(pinFC51, INPUT);
//   pinMode(pinTrig, OUTPUT);
//   pinMode(pinEcho, INPUT);

//   myServo.attach(pinServo);
//   myServo.write(0);

//   setup_wifi();
//   client.setServer(mqtt_server, 1883);
//   client.setCallback(callback);
// }

// void setup_wifi() {
//   WiFi.begin(ssid, password);
//   unsigned long startAttemptTime = millis();
//   while (WiFi.status() != WL_CONNECTED) {
//     if (millis() - startAttemptTime >= 500) {
//       startAttemptTime = millis();
//     }
//   }
// }

// boolean reconnect() {
//   String clientId = "SmartBinESP32-" + String(random(0xffff), HEX);
//   if (client.connect(clientId.c_str())) {
//     client.subscribe(topic_command);
//     return true;
//   } else {
//     return false;
//   }
// }

// void loop() {
//   unsigned long currentMillis = millis();

//   if (!client.connected()) {
//     if (currentMillis - lastReconnectAttempt > 5000) {
//       lastReconnectAttempt = currentMillis;
//       if (reconnect()) {
//         lastReconnectAttempt = 0;
//       }
//     }
//   } else {
//     client.loop();
//   }

//   if (digitalRead(pinFC51) == LOW && !isLidLocked) {
//     lidOpenTime = currentMillis; 
//     if (!isLidOpen) {
//       myServo.write(90);
//       isLidOpen = true;
//       client.publish(topic_lid, "Opened");
//     }
//   }

//   if (isLidOpen && (currentMillis - lidOpenTime >= 3000)) {
//     myServo.write(0);
//     isLidOpen = false;
//     client.publish(topic_lid, "Closed");
//   }

//   digitalWrite(pinTrig, LOW);
//   delayMicroseconds(2);
//   digitalWrite(pinTrig, HIGH);
//   delayMicroseconds(10);
//   digitalWrite(pinTrig, LOW);

//   long duration = pulseIn(pinEcho, HIGH);
//   int distance = duration * 0.034 / 2;

//   String statusMessage = "Unknown";
  
//   digitalWrite(ledGreen, LOW);
//   digitalWrite(ledYellow, LOW);
//   digitalWrite(ledRed, LOW);

//   if (distance > 20 || distance == 0) {
//     digitalWrite(ledGreen, HIGH);
//     statusMessage = "Empty";
//   } 
//   else if (distance >= 10 && distance <= 20) {
//     digitalWrite(ledYellow, HIGH);
//     statusMessage = "Medium";
//   } 
//   else {
//     digitalWrite(ledRed, HIGH);
//     statusMessage = "Full";
//   }

//   if (currentMillis - lastMsg > 5000) {
//     lastMsg = currentMillis;
//     client.publish(topic_level, statusMessage.c_str());
//   }
// }