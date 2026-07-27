import 'package:flutter/widgets.dart';
import '../l10n_extension.dart';
import 'api_client.dart';

/// Traduz `ApiException.error` (código estável da secção 13) para texto no
/// idioma atual da app — nunca mostra `message` (PT vindo direto do
/// backend) diretamente ao utilizador.
///
/// Onde o mesmo código é reutilizado em vários sítios do backend com
/// mensagens diferentes (ex.: `nao_encontrado` serve para veículo/venda/
/// membro), a versão aqui fica genérica — perde-se alguma especificidade,
/// mas evita duplicar um sistema de tradução completo no backend só por
/// causa de meia dúzia de mensagens reutilizadas. O único caso com texto
/// dinâmico (transição de estado inválida em `vehicles.service.ts`) não
/// tem tradução própria — cai no fallback genérico de `estado_invalido`.
extension ApiExceptionL10n on ApiException {
  String localizado(BuildContext context) {
    final l10n = context.l10n;
    switch (error) {
      case 'token_invalido':
        return l10n.erroTokenInvalido;
      case 'credenciais_invalidas':
        return l10n.erroCredenciaisInvalidas;
      case 'sessao_invalida':
        return l10n.erroSessaoInvalida;
      case 'sessao_comprometida':
        return l10n.erroSessaoComprometida;
      case 'token_expirado':
        return l10n.erroTokenExpirado;
      case 'nao_autenticado':
        return l10n.erroNaoAutenticado;
      case 'sem_permissao':
        return l10n.erroSemPermissao;
      case 'nao_encontrado':
        return l10n.erroNaoEncontrado;
      case 'pedido_invalido':
        return l10n.erroPedidoInvalido;
      case 'demasiados_pedidos':
        return l10n.erroDemasiadosPedidos;
      case 'ocr_indisponivel':
        return l10n.erroOcrIndisponivel;
      case 'documento_nao_reconhecido':
        return l10n.erroDocumentoNaoReconhecido;
      case 'nif_invalido':
        return l10n.erroNifInvalido;
      case 'estado_invalido':
        return l10n.erroEstadoInvalido;
      case 'membro_ja_existe':
        return l10n.erroMembroJaExiste;
      case 'veiculo_ja_confirmado':
        return l10n.erroVeiculoJaConfirmado;
      case 'veiculo_tem_historico':
        return l10n.erroVeiculoTemHistorico;
      case 'campos_em_falta':
        return l10n.erroCamposEmFalta;
      case 'erro_rede':
        return l10n.erroRede;
      case 'erro_interno':
      case 'erro_desconhecido':
      default:
        return l10n.erroGenerico;
    }
  }
}
