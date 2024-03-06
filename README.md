---
title: Flutter. Bloc a pèl
tags: DAW, Flutter
---

<div style="width: 30%; margin-left: auto;">
    
![](https://hackmd.io/_uploads/HJiR4eGJT.png)    
    
</div>

![imagen](https://hackmd.io/_uploads/SJTyK2rpp.png)


<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Llicència de Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />Aquesta obra està subjecta a una llicència de <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Reconeixement-CompartirIgual 4.0 Internacional de Creative Commons</a>




[Veure a Hackmd](https://hackmd.io/@JdaXaviQ/rJ_w_nHpT)

# BLoC a pèl (Vanilla version BLoC). [Behind the scenes]
## Projecte de partida.
### 1. Partirem de l'exemple per defecte que ens genera flutter:
```bash=
xavi@portatil:~/Documentos/flutter$ flutter create bloc_a_pel
Creating project bloc_a_pel...
Resolving dependencies in bloc_a_pel... (1.1s)
Got dependencies in bloc_a_pel.
Wrote 129 files.

All done!
You can find general documentation for Flutter at: https://docs.flutter.dev/
Detailed API documentation is available at: https://api.flutter.dev/
If you prefer video documentation, consider:
https://www.youtube.com/c/flutterdev

In order to run your application, type:

  $ cd bloc_a_pel
  $ flutter run

Your application code is in bloc_a_pel/lib/main.dart.
```
Que és el arxiconegut comptador; al meu Ubuntu-Linux es veu amb aquesta pinta.
![imagen](https://hackmd.io/_uploads/SJg4chBap.png)

### 2. Afegir un botó de decrementar amb la seva funció controladora.
```dart=
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

```
![imagen](https://hackmd.io/_uploads/rJCJohH6a.png)

### 3. Definir els events que afecten al nostre comptador.
A partir d'aquest punt ens separem de manera substancial de l'exemple bàsic de Flutter.
En aquest pas crearem un fitxer .\lib\events_comptador.dart que contindrà les classes que definiran els events que afecten al nostre comptador.
```dart=
abstract class ComptadorEvent {}

class IncrementEvent extends ComptadorEvent {}
class DecrementEvent extends ComptadorEvent {}

```
Com podem veure, hem creat una classe base abstracta: ComptadorEvent i dues classes que implementen a aquesta:
- IncrementEvent
- DecrementEvent

Cadascuna d'aquestes classes derivades identifiquen a un event que pot rebre el nostre comptador.

### 4. Treballs de fontaneria.
En aquest punt crearem dos 'StreamController', pel primer viatjarà l'estat del comptador (un nombre enter) i pel segon els events que s'escaiguin (del tipus ComptadorEvent).
El següent codi pertany al fitxer '.\lib\bloc_comptador.dart':
```dart=
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
```

### 5.- Adaptant la interface al nou paradigma.
Tornem al fitxer main.dart i esborrem les dues funcions que decrementen i incrementen el comptador, així com també la variable comptador i les reeplacem per una nova variable, que podem anomenar _bloc del tipus BlocComptador.
També hem d'adaptar la interface del comptador per a que es generi de manera adient amb un widget del tipus StreamBuilder com es mostra a continuació.
```dart=
import 'package:bloc_a_pel/bloc_comptador.dart';
import 'package:bloc_a_pel/events_comptador.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _bloc = BlocComptador();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder(
          stream: _bloc.counter,
          initialData: 0,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot)
          {
            return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${snapshot.data}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        );
          }),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _bloc.counterEventSink.add(IncrementEvent()),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () => _bloc.counterEventSink.add(DecrementEvent()),
            tooltip: 'Increment',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
  @override 
  void dispose(){
    _bloc.dispose();
    super.dispose();
  }
}
``