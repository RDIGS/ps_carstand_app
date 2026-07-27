import 'package:flutter/material.dart';

import '../../core/l10n_extension.dart';
import '../../shared/widgets/max_width_body.dart';
import '../vehicles/vehicle_detail.dart';
import 'banner_content.dart';
import 'banner_form_screen.dart';
import 'banner_widget.dart';
import 'templates/banner_template.dart';

/// Conteúdo de demonstração só para as miniaturas dos templates — o
/// conteúdo real do veículo só entra no ecrã seguinte (BannerFormScreen).
BannerContent _conteudoDemo(BannerTemplateId id) => BannerContent(
      templateId: id,
      titulo: 'Seat Leon FR',
      subtitulo: '2.0 TDI',
      potencia: '184 CV',
      ano: '2022',
      combustivel: 'DIESEL',
      preco: '18.990 €',
      prestacao: '229 € / MÊS',
      social: '@teu_stand',
      contacto: '912 345 678',
      corDestaque: const Color(0xFFE50914),
      foto: null,
    );

/// Ecrã de escolha de template — 1º passo depois de "Gerar banner de
/// venda". Templates "premium" (nenhum por agora) ficam bloqueados, à
/// espera de uma futura loja de templates pagos.
class BannerTemplatePickerScreen extends StatelessWidget {
  const BannerTemplatePickerScreen({super.key, required this.vehicle});

  final VehicleDetail vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bannerEscolherTemplateTitulo)),
      body: MaxWidthBody(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.82,
          ),
          itemCount: bannerTemplates.length,
          itemBuilder: (context, index) {
            final template = bannerTemplates[index];
            return _TemplateCard(
              nome: template.nome,
              premium: template.premium,
              content: _conteudoDemo(template.id),
              onTap: template.premium
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BannerFormScreen(vehicle: vehicle, templateId: template.id),
                        ),
                      ),
            );
          },
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.nome, required this.premium, required this.content, required this.onTap});

  final String nome;
  final bool premium;
  final BannerContent content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Opacity(
      opacity: premium ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: IgnorePointer(child: BannerWidget(content: content)),
                        ),
                      ),
                      if (premium)
                        Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: const Icon(Icons.lock_outline, color: Colors.white, size: 32),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(nome, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
              if (premium)
                Text(
                  l10n.bannerTemplateBrevemente,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
