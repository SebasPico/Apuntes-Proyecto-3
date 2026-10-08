import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.syncing = false});

  final bool syncing;

  @override
  Widget build(BuildContext context) {
    final label = syncing
        ? 'Sincronizando cambios...'
        : 'Sin conexión - mostrando el último inventario guardado';

    return Material(
      color: syncing ? const Color(0xFFE8EFE8) : const Color(0xFFFFEBD6),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                syncing ? Icons.sync_rounded : Icons.cloud_off_rounded,
                size: 18,
                color: syncing
                    ? const Color(0xFF315448)
                    : const Color(0xFF9A5A32),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: syncing
                        ? const Color(0xFF315448)
                        : const Color(0xFF744D3E),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
