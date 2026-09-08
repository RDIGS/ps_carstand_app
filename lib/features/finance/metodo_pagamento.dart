import '../../l10n/app_localizations.dart';

// Mesma lista fixa do backend (src/common/constants/metodos-pagamento.ts).
const metodosPagamento = ['numerario', 'transferencia', 'multibanco', 'cartao', 'cheque', 'outro'];

String metodoPagamentoLabel(AppLocalizations l10n, String? metodo) {
  switch (metodo) {
    case 'numerario':
      return l10n.metodoPagamentoNumerario;
    case 'transferencia':
      return l10n.metodoPagamentoTransferencia;
    case 'multibanco':
      return l10n.metodoPagamentoMultibanco;
    case 'cartao':
      return l10n.metodoPagamentoCartao;
    case 'cheque':
      return l10n.metodoPagamentoCheque;
    case 'outro':
      return l10n.metodoPagamentoOutro;
    default:
      return '';
  }
}
