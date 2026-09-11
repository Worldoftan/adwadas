#include <M5StickCPlus2.h>
#include <NimBLEDevice.h>

static const char* SERVICE_UUID="7f8a0001-5b7a-4d9e-9c11-000000000001";
static const char* RX_UUID="7f8a0002-5b7a-4d9e-9c11-000000000001";

struct Pair{const char* en;const char* ru;};
Pair words[]={
{"optimistic","оптимистичный"},{"sensitive","чувствительный"},{"caring","заботливый"},
{"patient","терпеливый"},{"easy-going","спокойный, лёгкий в общении"},{"sociable","общительный"},
{"honest","честный"},{"reliable","надёжный"},{"stubborn","упрямый"},
{"selfish","эгоистичный"},{"shy","застенчивый"}};

void showWord(String w){
  String ru="not found";
  for(auto &p:words) if(w==p.en){ru=p.ru;break;}
  M5.Lcd.fillScreen(BLACK); M5.Lcd.setTextColor(WHITE);
  M5.Lcd.setTextSize(2); M5.Lcd.setCursor(8,10); M5.Lcd.println("WORD");
  M5.Lcd.setTextSize(3); M5.Lcd.setCursor(8,42); M5.Lcd.println(w);
  M5.Lcd.setTextSize(2); M5.Lcd.setCursor(8,90); M5.Lcd.println(ru);
}

class CB: public NimBLECharacteristicCallbacks{
  void onWrite(NimBLECharacteristic* c,NimBLEConnInfo&) override{
    auto v=c->getValue(); if(!v.empty()){String s(v.c_str());s.trim();s.toLowerCase();showWord(s);}
  }
};

void setup(){
  auto cfg=M5.config(); M5.begin(cfg); M5.Lcd.setRotation(3);
  M5.Lcd.fillScreen(BLACK);M5.Lcd.setTextColor(WHITE);M5.Lcd.setTextSize(2);
  M5.Lcd.setCursor(8,40);M5.Lcd.println("Vocab Assistant");
  M5.Lcd.setCursor(8,70);M5.Lcd.println("BLE: waiting");
  NimBLEDevice::init("Vocab-M5");
  auto* server=NimBLEDevice::createServer();
  auto* service=server->createService(SERVICE_UUID);
  auto* rx=service->createCharacteristic(RX_UUID,NIMBLE_PROPERTY::WRITE);
  rx->setCallbacks(new CB()); service->start();
  auto* adv=NimBLEDevice::getAdvertising();adv->addServiceUUID(SERVICE_UUID);adv->start();
}
void loop(){M5.update();delay(10);}
