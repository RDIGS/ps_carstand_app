import '../../l10n/app_localizations.dart';

// Mesma lista fixa do backend (src/finance/finance-categorias.ts) — antes
// era texto livre, "Renda"/"renda"/"Aluguer" viravam categorias diferentes
// nos relatórios.
const financeCategorias = [
  'renda',
  'salarios',
  'marketing',
  'servicos_terceiros',
  'impostos_taxas',
  'seguros',
  'manutencao_instalacoes',
  'comissoes_recebidas',
  'financiamento',
  'outro',
];

String financeCategoriaLabel(AppLocalizations l10n, String? categoria) {
  switch (categoria) {
    case 'renda':
      return l10n.financeCategoriaRenda;
    case 'salarios':
      return l10n.financeCategoriaSalarios;
    case 'marketing':
      return l10n.financeCategoriaMarketing;
    case 'servicos_terceiros':
      return l10n.financeCategoriaServicosTerceiros;
    case 'impostos_taxas':
      return l10n.financeCategoriaImpostosTaxas;
    case 'seguros':
      return l10n.financeCategoriaSeguros;
    case 'manutencao_instalacoes':
      return l10n.financeCategoriaManutencaoInstalacoes;
    case 'comissoes_recebidas':
      return l10n.financeCategoriaComissoesRecebidas;
    case 'financiamento':
      return l10n.financeCategoriaFinanciamento;
    case 'outro':
      return l10n.financeCategoriaOutro;
    default:
      return l10n.financeSemCategoria;
  }
}
