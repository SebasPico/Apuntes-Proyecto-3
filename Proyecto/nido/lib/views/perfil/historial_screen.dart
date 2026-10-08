import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      ['Sebastian', 'actualizó la cantidad de Café', 'Cocina · Hoy, 7:42 p. m.', Icons.edit_rounded],
      ['Laura', 'agregó Detergente', 'Lavandería · Ayer, 4:10 p. m.', Icons.add_circle_outline_rounded],
      ['Sebastian', 'eliminó Jabón líquido', 'Baño principal · Ayer, 10:05 a. m.', Icons.delete_outline_rounded],
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de cambios'), backgroundColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 32), children: [
        const Text('Actividad del hogar', style: TextStyle(color: Color(0xFF153A3A), fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Consulta los cambios realizados por los integrantes.', style: TextStyle(color: Color(0xFF6E756D))),
        const SizedBox(height: 24),
        for (final event in events) ListTile(contentPadding: const EdgeInsets.symmetric(vertical: 8), leading: CircleAvatar(backgroundColor: const Color(0xFFE8EFE8), child: Icon(event[3] as IconData, color: const Color(0xFF315448), size: 20)), title: Text.rich(TextSpan(children: [TextSpan(text: '${event[0]} ', style: const TextStyle(fontWeight: FontWeight.w800)), TextSpan(text: event[1] as String)]), style: const TextStyle(color: Color(0xFF153A3A))), subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(event[2] as String)),),
      ]),
    );
  }
}
