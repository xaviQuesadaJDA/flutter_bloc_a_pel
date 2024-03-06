import 'dart:async';
import 'package:bloc_a_pel/events_comptador.dart';

class BlocComptador{
  int _comptador = 0; // Variable que representa l'estat del comptador.
  final _blocComptadorStateController = StreamController<int>(); // Tuberia per a un s'envien els estats del comptador.
  // El forat d'entrada de la tuberia el declarem privat perquè només aquesta classe
  // el pugui fer servir.
  StreamSink<int> get _inCounter => _blocComptadorStateController.sink;
  // El forat públic el declarem públic perquè qualsevol altre classe pugui seguir els canvis d'estat del comptador.
  Stream<int> get counter => _blocComptadorStateController.stream;


  final _comptadorEventController = StreamController<ComptadorEvent>(); // Altra tuberia que rep els events del comptador.
  // Fem públic el forat d'entrada i així poder rebre events de qualsevol classe.
  Sink<ComptadorEvent> get counterEventSink => _comptadorEventController.sink;

  BlocComptador(){
    // El constructor de la classe BlocComptador s'encarrega de escoltar els events que arriben
    // per la tuberia _comptadorEventController i cridar a la funció _transformaEventToState cada
    // vegada que arriba un event.
    _comptadorEventController.stream.listen(_transformaEventToState);
  }

  void _transformaEventToState(ComptadorEvent event){
    if(event is IncrementEvent){
      _comptador++;
    }else{
      _comptador--;
    }
    _inCounter.add(_comptador); // Envia el nou estat per la tuberia de sortida.
  }

  void dispose(){
    _comptadorEventController.close();
    _blocComptadorStateController.close();
  }
}