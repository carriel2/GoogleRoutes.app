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
      Position posicao = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        posicao.latitude,
        posicao.longitude,
      );

      Placemark local = placemarks.first;
      String endereco =
          "${local.street}, ${local.subLocality}, ${local.locality}, ${local.administrativeArea}";

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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Otimização de Rotas",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        backgroundColor: Colors.grey[200],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exibe a localização atual em um Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _localizacaoAtual != null
                        ? "Localização Atual: $_localizacaoAtual"
                        : "Obtendo localização...",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Insira os endereços:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _enderecosControllers.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading:
                            const Icon(Icons.location_on, color: Colors.black),
                        title: TextField(
                          controller: _enderecosControllers[index],
                          decoration: InputDecoration(
                            labelText: "Endereço ${index + 1}",
                            labelStyle: TextStyle(
                                color: Colors.black), // Mantém o texto preto
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 14),
                          ),
                        ),
                        trailing: _enderecosControllers.length > 1
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => removerCampo(index),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: adicionarCampo,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Adicionar Endereço",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: buscarRota,
                    child: const Text(
                      "Buscar Rota",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
