import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_client.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/image_source_picker.dart';
import 'finance_repository.dart';
import 'invoice_extraction_result.dart';

/// Abaixo disto um campo extraído por OCR é assinalado para confirmação
/// manual — mesma lógica de "não confiar cegamente" já usada no DUA.
const kConfiancaBaixa = 0.6;

enum OrigemDespesa { foto, manual }

/// Escolha explícita entre inserir a despesa a partir da foto da fatura (OCR)
/// ou à mão (secção despesas, 2026-09-09) — antes a foto era só um botão
/// dentro do formulário manual, sem nenhuma escolha inicial.
Future<OrigemDespesa?> escolherOrigemDespesa(BuildContext context) {
  final l10n = context.l10n;
  return showModalBottomSheet<OrigemDespesa>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(l10n.despesaOrigemFoto),
            onTap: () => Navigator.of(context).pop(OrigemDespesa.foto),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: Text(l10n.despesaOrigemManual),
            onTap: () => Navigator.of(context).pop(OrigemDespesa.manual),
          ),
        ],
      ),
    ),
  );
}

class CapturaFatura {
  const CapturaFatura({required this.bytes, this.resultado});

  final Uint8List bytes;
  final InvoiceExtractionResult? resultado;
}

/// Escolhe fonte (câmara/galeria), tira/escolhe a foto e tenta extrair os
/// dados via OCR — devolve sempre os bytes da foto (mesmo que a extração
/// falhe, a foto fica na mesma como comprovativo), ou `null` se o utilizador
/// desistir antes de escolher uma foto.
Future<CapturaFatura?> capturarEExtrairFatura(BuildContext context, FinanceRepository repo) async {
  final fonte = await escolherFonteImagem(context);
  if (fonte == null || !context.mounted) return null;
  final ficheiro = await ImagePicker().pickImage(source: fonte, imageQuality: 90, maxWidth: 2000);
  if (ficheiro == null) return null;
  final bytes = await ficheiro.readAsBytes();
  if (!context.mounted) return CapturaFatura(bytes: bytes);
  try {
    final resultado = await repo.extractInvoice(bytes);
    return CapturaFatura(bytes: bytes, resultado: resultado);
  } on ApiException {
    return CapturaFatura(bytes: bytes);
  }
}

/// NIF português (9 dígitos) — dígito de controlo mod 11. Só gera um aviso,
/// nunca bloqueia: o campo continua texto livre, pode haver casos que o
/// algoritmo não preveja.
bool nifValido(String nif) {
  final digitos = nif.replaceAll(RegExp(r'\D'), '');
  if (digitos.length != 9) return false;
  var soma = 0;
  for (var i = 0; i < 8; i++) {
    soma += int.parse(digitos[i]) * (9 - i);
  }
  final resto = soma % 11;
  final digitoControlo = resto < 2 ? 0 : 11 - resto;
  return digitoControlo == int.parse(digitos[8]);
}

/// Texto de ajuda (amarelo) para mostrar sob um campo quando a confiança da
/// extração nesse campo foi baixa — `campo` usa os nomes do schema do
/// backend (`valor_total`, `fornecedor_nif`, etc.), ver invoice-response-schema.ts.
String? avisoConfiancaBaixa(BuildContext context, InvoiceExtractionResult? extracao, String campo) {
  final confianca = extracao?.confianca[campo];
  if (confianca == null || confianca >= kConfiancaBaixa) return null;
  return context.l10n.despesaConfirmaValorLido;
}

String _avisoFaturaLabel(AppLocalizations l10n, String codigo) {
  switch (codigo) {
    case 'iva_misto':
      return l10n.despesaAvisoIvaMisto;
    default:
      return codigo;
  }
}

/// Banner com os avisos da extração (ex. "iva_misto") e o aviso de NIF
/// inválido — mostrado no topo do formulário sempre que há uma extração em
/// curso e algo merece confirmação.
class AvisosExtracaoFatura extends StatelessWidget {
  const AvisosExtracaoFatura({super.key, required this.avisos, required this.nifInvalido});

  final List<String> avisos;
  final bool nifInvalido;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mensagens = [
      ...avisos.map((a) => _avisoFaturaLabel(l10n, a)),
      if (nifInvalido) l10n.despesaNifInvalido,
    ];
    if (mensagens.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final m in mensagens)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, size: 16, color: AppColors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(m, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
