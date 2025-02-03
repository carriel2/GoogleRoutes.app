import 'package:url_launcher/url_launcher.dart';

void abrirGoogleMaps(List<String> enderecos) async {
  if (enderecos.isEmpty) return;
  
  // O primeiro endereço é a origem e o último o destino fixo.
  // Os endereços intermediários serão os waypoints.
  String waypoints = "";
  if (enderecos.length > 2) {
    waypoints = enderecos.sublist(1, enderecos.length - 1).join('|');
  }
  
  String url =
      "https://www.google.com/maps/dir/?api=1&origin=${Uri.encodeComponent(enderecos.first)}&destination=${Uri.encodeComponent(enderecos.last)}";
  if (waypoints.isNotEmpty) {
    url += "&waypoints=${Uri.encodeComponent(waypoints)}";
  }
  
  final Uri uri = Uri.parse(url);
  print("URL Maps: $url");
  
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw "Não foi possível abrir o Google Maps";
  }
}
