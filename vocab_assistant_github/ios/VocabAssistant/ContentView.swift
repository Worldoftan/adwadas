import SwiftUI
import Speech
import AVFoundation
import CoreBluetooth

struct ContentView: View {
    @StateObject private var m=AssistantModel()
    var body: some View {
        VStack(spacing:18) {
            Text("Vocab Assistant").font(.title2).bold()
            Text(m.status).font(.footnote)
            Text(m.word.isEmpty ? "—" : m.word).font(.system(size:38,weight:.bold))
            Text(m.translation.isEmpty ? "—" : m.translation).font(.title3)
            Button(m.micOn ? "MIC ON" : "MIC OFF") {
                m.micOn.toggle(); m.setMic(m.micOn)
            }.buttonStyle(.borderedProminent)
            Button("Распознать одно слово") { m.recognizeOne() }
                .buttonStyle(.bordered)
        }.padding().onAppear{m.prepare()}
    }
}

final class AssistantModel:NSObject,ObservableObject,CBCentralManagerDelegate,CBPeripheralDelegate,SFSpeechRecognizerDelegate {
    @Published var micOn=false
    @Published var word=""
    @Published var translation=""
    @Published var status="Ищу Vocab-M5…"
    private let speech=SFSpeechRecognizer(locale:Locale(identifier:"en-US"))
    private let audio=AVAudioEngine()
    private var central:CBCentralManager!
    private var peripheral:CBPeripheral?
    private var rx:CBCharacteristic?
    private let serviceUUID=CBUUID(string:"7f8a0001-5b7a-4d9e-9c11-000000000001")
    private let rxUUID=CBUUID(string:"7f8a0002-5b7a-4d9e-9c11-000000000001")
    private let dict=[
      "optimistic":"оптимистичный","sensitive":"чувствительный","caring":"заботливый",
      "patient":"терпеливый","easy-going":"спокойный, лёгкий в общении","sociable":"общительный",
      "honest":"честный","reliable":"надёжный","stubborn":"упрямый",
      "selfish":"эгоистичный","shy":"застенчивый"]

    func prepare(){
        speech?.delegate=self
        SFSpeechRecognizer.requestAuthorization{_ in}
        AVAudioSession.sharedInstance().requestRecordPermission{_ in}
        central=CBCentralManager(delegate:self,queue:.main)
    }
    func centralManagerDidUpdateState(_ c:CBCentralManager){
        if c.state == .poweredOn { status="Ищу Vocab-M5…";c.scanForPeripherals(withServices:[serviceUUID]) }
    }
    func centralManager(_ c:CBCentralManager,didDiscover p:CBPeripheral,advertisementData:[String:Any],rssi:NSNumber){
        peripheral=p;c.stopScan();p.delegate=self;c.connect(p)
    }
    func centralManager(_ c:CBCentralManager,didConnect p:CBPeripheral){
        status="M5Stick подключён";p.discoverServices([serviceUUID])
    }
    func peripheral(_ p:CBPeripheral,didDiscoverServices error:Error?){
        p.services?.first.map{p.discoverCharacteristics([rxUUID],for:$0)}
    }
    func peripheral(_ p:CBPeripheral,didDiscoverCharacteristicsFor s:CBService,error:Error?){
        rx=s.characteristics?.first
    }
    func setMic(_ on:Bool){if !on{audio.stop()};status=on ? "MIC ON":"MIC OFF"}
    func recognizeOne(){
        guard micOn,let speech else{return}
        let req=SFSpeechAudioBufferRecognitionRequest()
        let input=audio.inputNode
        let session=AVAudioSession.sharedInstance()
        try? session.setCategory(.record,mode:.measurement,options:[.duckOthers])
        try? session.setActive(true)
        input.removeTap(onBus:0)
        input.installTap(onBus:0,bufferSize:1024,format:input.outputFormat(forBus:0)){req.append($0)}
        audio.prepare();try? audio.start()
        speech.recognitionTask(with:req){[weak self] result,error in
            guard let self,let t=result?.bestTranscription.formattedString.lowercased() else{return}
            let s=t.trimmingCharacters(in:.whitespacesAndNewlines)
            guard let ru=self.dict[s] else{return}
            DispatchQueue.main.async{
                self.word=s;self.translation=ru;self.send(s)
                self.audio.stop();input.removeTap(onBus:0)
            }
        }
    }
    private func send(_ s:String){
        guard let rx,let p=peripheral,let d=s.data(using:.utf8) else{return}
        p.writeValue(d,for:rx,type:.withResponse)
    }
}
