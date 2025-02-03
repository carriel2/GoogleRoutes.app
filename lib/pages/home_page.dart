import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../api/api_service.dart';
import '../utils/maps_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<TextEditingController> _enderecosControllers = [];
  String? _localizacaoAtual;
  
  @override
  void initState() {
    super.initState();
    _enderecosControllers = List.generate(2, (_) => TextEditingController());
    _obterLocalizacaoAtual();
  }
  
  @override
  void dispose() {
    for (var controller in _enderecosControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  Future<void> _obterLocalizacaoAtual() async {
    try {
      Position posicao = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(posicao.latitude, posicao.longitude);
      Placemark local = placemarks.first;
      String endereco = "${local.street}, ${local.subLocality}, ${local.locality}, ${local.administrativeArea}";
      
      setState(() {
        _localizacaoAtual = endereco;
      });
      
      print("Localização Atual: $_localizacaoAtual");
    } catch (e) {
      print("Erro ao obter localização: $e");
    }
  }
  
  void buscarRota() async {
    if (_localizacaoAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aguardando localização...")),
      );
      return;
    }
    
    List<String> enderecos = _enderecosControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    if (enderecos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insira pelo menos um destino!")),
      );
      return;
    }
    
    String origem = _localizacaoAtual!;
    print("Endereços enviados para API: $enderecos");
    
    try {
      // Envia um JSON contendo 'origem' e 'enderecos' para o backend.
      Map<String, dynamic> requestData = {
        'origem': origem,
        'enderecos': enderecos,
      };
      
      List<dynamic> rotaOtimizada = await ApiService.otimizarRota(requestData);
      abrirGoogleMaps(rotaOtimizada.cast<String>());
    } catch (e) {
      print("Erro: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao buscar rota!")),
      );
    }
  }
  
  void adicionarCampo() {
    setState(() {
      _enderecosControllers.add(TextEditingController());
    });
  }
  
  void removerCampo(int index) {
    if (_enderecosControllers.length > 1) {
      setState(() {
        _enderecosControllers[index].dispose();
        _enderecosControllers.removeAt(index);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Otimização de Rotas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizacaoAtual != null ? "Localização Atual: $_localizacaoAtual" : "Obtendo localização...",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _enderecosControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _enderecosControllers[index],
                          decoration: InputDecoration(
                            labelText: "Endereço ${index + 1}",
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      if (_enderecosControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => removerCampo(index),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: adicionarCampo,
              icon: const Icon(Icons.add),
              label: const Text("Adicionar Endereço"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: buscarRota,
              child: const Text("Buscar Rota"),
            ),
          ],
        ),
      ),
    );
  }
}
