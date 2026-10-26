import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n_extension.dart';
import 'declaracao.dart';
import 'declaracoes_repository.dart';
import 'emitir_declaracao.dart';

final _fmt = DateFormat('dd/MM/yyyy HH:mm');

/// Declarações do veículo na ficha: emitir circulação/características (e a
/// de compra, se não foi feita ao inserir o veículo) e reabrir as emitidas.
class VehicleDeclaracoesCard extends StatefulWidget {
  const VehicleDeclaracoesCard({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  State<VehicleDeclaracoesCard> createState() => _VehicleDeclaracoesCardState();
}

class _VehicleDeclaracoesCardState extends State<VehicleDeclaracoesCard> {
  late Future<List<Declaracao>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<DeclaracoesRepository>().listar(widget.vehicleId);
  }

  void _recarregar() {
    setState(() => _future = context.read<DeclaracoesRepository>().listar(widget.vehicleId));
  }

  Future<void> _emitir(String tipo) async {
    final emitida = await emitirDeclaracao(context, vehicleId: widget.vehicleId, tipo: tipo);
    if (emitida != null && mounted) _recarregar();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.declaracoesTitulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in ['circulacao', 'caracteristicas', 'compra'])
                  OutlinedButton.icon(
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: Text(tituloDeclaracao(l10n, tipo)),
                    onPressed: () => _emitir(tipo),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Declaracao>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator());
                }
                final lista = snapshot.data ?? const <Declaracao>[];
                if (lista.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(l10n.declaracoesVazio, style: Theme.of(context).textTheme.bodySmall),
                  );
                }
                return Column(
                  children: [
                    for (final d in lista)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.picture_as_pdf_outlined),
                        title: Text(tituloDeclaracao(l10n, d.tipo)),
                        subtitle: Text([_fmt.format(d.criadoEm), if (d.clienteNome != null) d.clienteNome!].join(' · ')),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => launchUrl(Uri.parse(d.url), mode: LaunchMode.externalApplication),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
