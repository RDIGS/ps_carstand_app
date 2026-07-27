// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get standTokenIntro =>
      'Introduz o token do teu stand. Só é preciso uma vez — depois disso entras só com email e password.';

  @override
  String get standTokenLabel => 'Token do stand';

  @override
  String get standTokenContinuar => 'Continuar';

  @override
  String get standTokenErroGenerico => 'Token inválido.';

  @override
  String get loginTitulo => 'Entrar';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginErroGenerico => 'Email ou password inválidos.';

  @override
  String get loginEsqueceuPassword => 'Esqueceste-te da password?';

  @override
  String get esqueceuPasswordTitulo => 'Esqueceste-te da password?';

  @override
  String get esqueceuPasswordTexto =>
      'Se és vendedor, pede ao responsável do teu stand para te repor a password em Equipa. Se és owner, contacta o suporte PS CarStand: +351 911 038 529.';

  @override
  String appBarStandNome(String standNome) {
    return 'PS CarStand · $standNome';
  }

  @override
  String get erroTokenInvalido => 'Token não encontrado ou revogado.';

  @override
  String get erroCredenciaisInvalidas => 'Email ou password inválidos.';

  @override
  String get erroSessaoInvalida => 'Sessão expirada, inicia sessão novamente.';

  @override
  String get erroSessaoComprometida =>
      'Sessão inválida — inicia sessão novamente em todos os dispositivos.';

  @override
  String get erroTokenExpirado =>
      'Subscrição expirada ou por ativar. Contacta o suporte da PS CarStand.';

  @override
  String get erroNaoAutenticado => 'Sessão não iniciada.';

  @override
  String get erroSemPermissao => 'Não tens permissão para esta ação.';

  @override
  String get erroNaoEncontrado => 'Não encontrado.';

  @override
  String get erroPedidoInvalido => 'Pedido inválido — verifica os dados.';

  @override
  String get erroDemasiadosPedidos =>
      'Demasiados pedidos. Tenta novamente daqui a pouco.';

  @override
  String get erroOcrIndisponivel =>
      'Não foi possível processar o documento neste momento. Tenta novamente.';

  @override
  String get erroDocumentoNaoReconhecido =>
      'As imagens não parecem ser um DUA português válido.';

  @override
  String get erroNifInvalido => 'NIF do comprador inválido.';

  @override
  String get erroEstadoInvalido => 'Esta ação não é possível no estado atual.';

  @override
  String get erroMembroJaExiste => 'Esta pessoa já faz parte da equipa.';

  @override
  String get erroVeiculoJaConfirmado =>
      'Este veículo já foi confirmado anteriormente.';

  @override
  String get erroCamposEmFalta =>
      'É necessário enviar a frente e o verso do documento.';

  @override
  String get erroRede =>
      'Sem ligação ao servidor. Verifica a tua ligação à internet.';

  @override
  String get erroGenerico => 'Ocorreu um erro inesperado. Tenta novamente.';

  @override
  String get terminarSessao => 'Terminar sessão';

  @override
  String get menuAuditoria => 'Auditoria';

  @override
  String get menuModoEscuro => 'Modo escuro';

  @override
  String get auditoriaTitulo => 'Auditoria';

  @override
  String get auditoriaFiltroTodos => 'Todos';

  @override
  String get auditoriaEntidadeVehicle => 'Veículo';

  @override
  String get auditoriaEntidadeVehicleExpense => 'Despesa';

  @override
  String get auditoriaEntidadeSale => 'Venda';

  @override
  String get auditoriaEntidadeFinanceEntry => 'Movimento financeiro';

  @override
  String get auditoriaEntidadeStandMember => 'Membro de equipa';

  @override
  String get auditoriaAcaoCriado => 'Criado';

  @override
  String get auditoriaAcaoAtualizado => 'Atualizado';

  @override
  String get auditoriaAcaoAprovado => 'Aprovado';

  @override
  String get auditoriaAcaoRejeitado => 'Rejeitado';

  @override
  String get auditoriaAcaoEstadoAlterado => 'Estado alterado';

  @override
  String get auditoriaAcaoRevertida => 'Revertido';

  @override
  String get auditoriaAcaoConvidado => 'Convidado';

  @override
  String get auditoriaAcaoRemovido => 'Removido';

  @override
  String auditoriaFeitoPor(String nome, String data) {
    return 'por $nome · $data';
  }

  @override
  String get auditoriaSemRegistos => 'Ainda não há registos de auditoria.';

  @override
  String get auditoriaValorAnterior => 'Antes';

  @override
  String get auditoriaValorNovo => 'Depois';

  @override
  String get vehiclesEmptyTitulo => 'Ainda não tens veículos';

  @override
  String get vehiclesEmptySubtitulo =>
      'Adiciona o teu primeiro veículo, manualmente ou a partir do DUA.';

  @override
  String get vehiclesEmptyBotao => 'Adicionar o primeiro veículo';

  @override
  String get tentarNovamente => 'Tentar novamente';

  @override
  String get adicionarVeiculo => 'Adicionar veículo';

  @override
  String get adicionarManualmente => 'Adicionar manualmente';

  @override
  String get adicionarPorDua => 'Adicionar a partir do DUA';

  @override
  String get fonteImagemCamara => 'Câmara';

  @override
  String get fonteImagemGaleria => 'Galeria';

  @override
  String get fichaVeiculoTitulo => 'Ficha do veículo';

  @override
  String get specKms => 'Kms';

  @override
  String get specPrimeiraMatricula => '1ª matrícula';

  @override
  String get specCategoria => 'Categoria';

  @override
  String get specCombustivel => 'Combustível';

  @override
  String get specCilindrada => 'Cilindrada';

  @override
  String get specPotencia => 'Potência';

  @override
  String get specCor => 'Cor';

  @override
  String get specLugares => 'Lugares';

  @override
  String get specTara => 'Tara';

  @override
  String get specPesoBruto => 'Peso bruto';

  @override
  String get specChassis => 'Chassis';

  @override
  String get precoCompra => 'Compra';

  @override
  String get precoVendaRecomendado => 'Venda recomendado';

  @override
  String get precoVendaFinal => 'Venda final';

  @override
  String get veiculoImportado => 'Veículo importado';

  @override
  String matriculaAnteriorLabel(String matricula) {
    return 'Matrícula anterior: $matricula';
  }

  @override
  String paisOrigemLabel(String pais) {
    return 'País de origem: $pais';
  }

  @override
  String get confiancaBaixaAviso =>
      'Confiança baixa nesta informação — confirma os dados na página do fabricante.';

  @override
  String get aprovarVeiculo => 'Aprovar veículo';

  @override
  String get rejeitar => 'Rejeitar';

  @override
  String get reservar => 'Reservar';

  @override
  String get cancelarReserva => 'Cancelar reserva';

  @override
  String get vender => 'Vender';

  @override
  String get estimativaMercadoTitulo => 'Estimativa de mercado';

  @override
  String get estimativaMercadoSubtitulo =>
      'Consultar preços semelhantes (OLX, StandVirtual, ...)';

  @override
  String get consultar => 'Consultar';

  @override
  String estimativaMercadoErro(String erro) {
    return 'Não foi possível obter a estimativa: $erro';
  }

  @override
  String get estimativaMercadoSemDados =>
      'Sem dados de mercado disponíveis para este veículo ainda.';

  @override
  String estimativaMercadoIntervalo(String min, String max, String media) {
    return 'Entre $min€ e $max€, média $media€';
  }

  @override
  String estimativaMercadoFontes(int n) {
    return 'Baseado em $n fonte(s).';
  }

  @override
  String get estimativaMercadoAtualizar => 'Atualizar';

  @override
  String get estimativaMercadoJanelaNormal => 'Ano ±1';

  @override
  String get estimativaMercadoJanelaAmpliada => 'Ano ±2 (amostra maior)';

  @override
  String get estimativaMercadoSemAmostra =>
      'Sem lista de anúncios ainda — toca em atualizar para veres os anúncios usados no cálculo.';

  @override
  String estimativaMercadoUsarComoRecomendado(String valor) {
    return 'Usar $valor€ como preço recomendado';
  }

  @override
  String estimativaMercadoNumAnuncios(int n) {
    return '$n anúncios';
  }

  @override
  String estimativaMercadoVerAnuncios(int n) {
    return 'Ver os $n anúncios';
  }

  @override
  String get confirmarDuaTitulo => 'Confirmar dados do DUA';

  @override
  String get duaRevisaoAviso =>
      'Revê e corrige os dados extraídos do DUA antes de guardar. Nada é gravado sem a tua confirmação.';

  @override
  String get possivelImportadoAviso =>
      'Confiança baixa em alguns campos — confirma com atenção, sobretudo matrícula e chassis.';

  @override
  String importadoComPais(String pais, String matricula) {
    return 'Veículo importado de $pais. Matrícula anterior: $matricula.';
  }

  @override
  String importadoSemPais(String matricula) {
    return 'Veículo importado. Matrícula anterior: $matricula.';
  }

  @override
  String get seccaoIdentificacao => 'Identificação';

  @override
  String get seccaoEspecificacoes => 'Especificações';

  @override
  String get seccaoPrecos => 'Preços';

  @override
  String get campoMatricula => 'Matrícula *';

  @override
  String get campoMatriculaHint => 'AA-00-AA';

  @override
  String get campoMarca => 'Marca *';

  @override
  String get campoModelo => 'Modelo *';

  @override
  String get campoVersao => 'Versão';

  @override
  String get campoQuilometros => 'Quilómetros *';

  @override
  String get campoCategoria => 'Categoria';

  @override
  String get campoCombustivel => 'Combustível';

  @override
  String get campoCilindrada => 'Cilindrada (cm³)';

  @override
  String get campoPotencia => 'Potência (kW)';

  @override
  String get campoCor => 'Cor';

  @override
  String get campoChassis => 'Chassis';

  @override
  String get campoPrecoCompra => 'Preço de compra (€)';

  @override
  String get campoPrecoVendaRecomendado => 'Preço de venda recomendado (€)';

  @override
  String get validacaoMatriculaInvalida => 'Matrícula em formato inválido.';

  @override
  String get validacaoCampoObrigatorio => 'Campo obrigatório';

  @override
  String get validacaoNumeroInvalido => 'Introduz um número válido';

  @override
  String get confirmarEGuardar => 'Confirmar e guardar';

  @override
  String get duaCaptureTitulo => 'Adicionar por DUA';

  @override
  String get duaCaptureInstrucoes =>
      'Tira uma foto da frente e do verso do DUA (Certificado de Matrícula).';

  @override
  String get duaFrente => 'Frente';

  @override
  String get duaVerso => 'Verso';

  @override
  String get extrairDados => 'Extrair dados';

  @override
  String venderTitulo(String matricula) {
    return 'Vender $matricula';
  }

  @override
  String get dadosComprador => 'Dados do comprador';

  @override
  String get campoNome => 'Nome *';

  @override
  String get campoNif => 'NIF *';

  @override
  String get campoMorada => 'Morada';

  @override
  String get campoCodigoPostal => 'Código postal';

  @override
  String get campoDocumentoIdentificacao => 'Documento de identificação';

  @override
  String get documentoCC => 'Cartão de Cidadão';

  @override
  String get documentoBI => 'Bilhete de Identidade';

  @override
  String get documentoOutro => 'Outro';

  @override
  String get campoNumeroDocumento => 'Número do documento';

  @override
  String get validacaoNifInvalido => 'NIF inválido.';

  @override
  String get condicoesVenda => 'Condições da venda';

  @override
  String get campoPrecoFinal => 'Preço final (€) *';

  @override
  String get campoComissaoVendedor => 'Comissão do vendedor (€)';

  @override
  String get validacaoValorInvalido => 'Introduz um valor válido';

  @override
  String get registarVenda => 'Registar venda';

  @override
  String get confirmarVendaTitulo => 'Confirmar venda';

  @override
  String confirmarVendaTexto(String matricula, String nome, String preco) {
    return 'Vais marcar o $matricula como vendido a $nome por $preco€. Esta ação não pode ser desfeita sem reverter a venda.';
  }

  @override
  String get cancelar => 'Cancelar';

  @override
  String get vendaRegistadaTitulo => 'Venda registada';

  @override
  String get vendaRegistadaTexto => 'Veículo marcado como vendido.';

  @override
  String get registoCompraLabel => 'Registo de Compra:';

  @override
  String get copiarLink => 'Copiar link';

  @override
  String get concluir => 'Concluir';

  @override
  String get equipaTitulo => 'Equipa';

  @override
  String get convidarMembroTitulo => 'Convidar membro';

  @override
  String get campoFuncao => 'Função';

  @override
  String get funcaoVendedor => 'Vendedor';

  @override
  String get funcaoOwner => 'Owner';

  @override
  String get validacaoEmailInvalido => 'Email inválido';

  @override
  String get convidar => 'Convidar';

  @override
  String get contaCriadaTitulo => 'Conta criada';

  @override
  String contaCriadaTexto(String nome) {
    return 'Partilha esta password temporária com $nome — ainda não há envio automático por email.';
  }

  @override
  String get reporPasswordTitulo => 'Repor password';

  @override
  String reporPasswordConfirmacao(String nome) {
    return 'Isto define uma password temporária nova para $nome e termina a sessão dele em todos os dispositivos. Continuar?';
  }

  @override
  String get passwordRepostaTitulo => 'Password reposta';

  @override
  String passwordRepostaTexto(String nome) {
    return 'Partilha esta password temporária nova com $nome — ainda não há envio automático por email.';
  }

  @override
  String get copiar => 'Copiar';

  @override
  String get ok => 'Ok';

  @override
  String membroSubtitulo(String email, String role) {
    return '$email · $role';
  }

  @override
  String get tornarVendedor => 'Tornar vendedor';

  @override
  String get tornarOwner => 'Tornar owner';

  @override
  String get desativar => 'Desativar';

  @override
  String get ativar => 'Ativar';

  @override
  String get removerAcesso => 'Remover acesso';

  @override
  String removerAcessoConfirmacao(String nome) {
    return 'Remover $nome da equipa? Pode voltar a ser convidado depois.';
  }

  @override
  String get remover => 'Remover';

  @override
  String get financeiroTitulo => 'Financeiro';

  @override
  String get novoMovimentoTitulo => 'Novo movimento';

  @override
  String get tipoDespesa => 'Despesa';

  @override
  String get tipoReceita => 'Receita';

  @override
  String get campoValor => 'Valor (€)';

  @override
  String get campoCategoriaFinanceira => 'Categoria';

  @override
  String get campoDescricao => 'Descrição';

  @override
  String get guardar => 'Guardar';

  @override
  String get guardado => 'Guardado';

  @override
  String get cashflowDoMes => 'Cashflow do mês';

  @override
  String get desvioVsRecomendado => 'Desvio vs. recomendado';

  @override
  String get vsmercado => 'Vs. mercado';

  @override
  String get margemPorMarcaModelo => 'Margem por marca/modelo';

  @override
  String get rankingVendedores => 'Ranking de vendedores';

  @override
  String get margemPorVeiculo => 'Margem por veículo vendido';

  @override
  String get semVendasPeriodo => 'Sem vendas neste período.';

  @override
  String numVendas(int n) {
    return '$n venda(s)';
  }

  @override
  String comissaoLabel(String valor) {
    return 'Comissão: $valor €';
  }

  @override
  String diasEmStock(int dias) {
    return '$dias dias em stock';
  }

  @override
  String get movimento => 'Movimento';

  @override
  String subscricaoAvisoExpira(int dias) {
    return 'A subscrição do stand termina em $dias dias.';
  }

  @override
  String subscricaoAvisoCarencia(int dias) {
    return 'Subscrição vencida — $dias dias de carência antes de bloquear o acesso.';
  }

  @override
  String get atualizacaoObrigatoriaTitulo => 'Atualização necessária';

  @override
  String get atualizacaoObrigatoriaTexto =>
      'Esta versão da app já não é suportada. Atualiza para continuares a usar a PS CarStand.';

  @override
  String get atualizacaoObrigatoriaBotao => 'Ver instruções de atualização';

  @override
  String atualizacaoRecomendadaAviso(String versao) {
    return 'Já há uma versão mais recente disponível ($versao).';
  }

  @override
  String get atualizacaoRecomendadaBotao => 'Ver novidades';

  @override
  String get checklistTitulo => 'Checklist de preparação';

  @override
  String get checklistVazio => 'Ainda sem itens de checklist.';

  @override
  String get checklistAplicarModelo => 'Aplicar modelo';

  @override
  String get checklistAdicionarItem => 'Adicionar item';

  @override
  String get checklistNovoItemTitulo => 'Novo item';

  @override
  String get checklistNovoItemHint => 'Ex.: Lavagem exterior';

  @override
  String get checklistEscolherModeloTitulo => 'Escolher modelo';

  @override
  String get checklistSemModelos => 'Ainda não criaste nenhum modelo.';

  @override
  String get checklistCriarModelo => 'Criar modelo';

  @override
  String get checklistNomeModelo => 'Nome do modelo';

  @override
  String get checklistNomeModeloHint => 'Ex.: Checklist Diesel Standard';

  @override
  String get checklistItensModelo => 'Itens';

  @override
  String get checklistAdicionarItemModelo => 'Adicionar item';

  @override
  String get despesasTitulo => 'Despesas do veículo';

  @override
  String get despesasVazio => 'Ainda sem despesas registadas.';

  @override
  String get despesasAdicionar => 'Adicionar despesa';

  @override
  String get despesasNovaTitulo => 'Nova despesa';

  @override
  String get despesasEditarTitulo => 'Editar despesa';

  @override
  String get despesasApagarTitulo => 'Apagar despesa';

  @override
  String get despesasApagarConfirmacao =>
      'Tens a certeza que queres apagar esta despesa? Não é possível desfazer.';

  @override
  String get despesaCategoriaReparacao => 'Reparação';

  @override
  String get despesaCategoriaTransporte => 'Transporte';

  @override
  String get despesaCategoriaLegalizacao => 'Legalização';

  @override
  String get despesaCategoriaLimpezaDetalhe => 'Limpeza / Detalhe';

  @override
  String get despesaCategoriaOutro => 'Outro';

  @override
  String get editar => 'Editar';

  @override
  String get financeCategoriaRenda => 'Renda';

  @override
  String get financeCategoriaSalarios => 'Salários';

  @override
  String get financeCategoriaMarketing => 'Marketing';

  @override
  String get financeCategoriaServicosTerceiros => 'Serviços de terceiros';

  @override
  String get financeCategoriaImpostosTaxas => 'Impostos e taxas';

  @override
  String get financeCategoriaSeguros => 'Seguros';

  @override
  String get financeCategoriaManutencaoInstalacoes =>
      'Manutenção das instalações';

  @override
  String get financeCategoriaComissoesRecebidas => 'Comissões recebidas';

  @override
  String get financeCategoriaFinanciamento => 'Financiamento';

  @override
  String get financeCategoriaOutro => 'Outro';

  @override
  String get financeSemCategoria => 'Sem categoria';

  @override
  String get filtrosTitulo => 'Filtros';

  @override
  String get filtroDataInicio => 'Data de início';

  @override
  String get filtroDataFim => 'Data de fim';

  @override
  String get filtroVendedor => 'Vendedor';

  @override
  String get filtroMarca => 'Marca';

  @override
  String get filtroModelo => 'Modelo';

  @override
  String get filtroTodos => 'Todos';

  @override
  String get campoTipo => 'Tipo';

  @override
  String get filtroLimpar => 'Limpar filtros';

  @override
  String get filtroAplicar => 'Aplicar';

  @override
  String get filtroEsteMes => 'Este mês';

  @override
  String get filtroUltimos90Dias => 'Últimos 90 dias';

  @override
  String get filtroEsteAno => 'Este ano';

  @override
  String get filtroPersonalizado => 'Personalizado';

  @override
  String get evolucaoTitulo => 'Evolução (últimos 12 meses)';

  @override
  String get margemPotencialTitulo => 'Margem potencial do stock';

  @override
  String get margemPotencialVazio =>
      'Sem veículos em stock disponíveis/reservados.';

  @override
  String get margemPotencialTotal => 'Total potencial';

  @override
  String get despesasGeraisPorCategoriaTitulo => 'Despesas gerais da empresa';

  @override
  String get despesasVeiculosPorCategoriaTitulo => 'Despesas por veículo';

  @override
  String get despesasSemLancamentos => 'Sem despesas neste período.';

  @override
  String get lancamentosTitulo => 'Lançamentos';

  @override
  String get lancamentosVerTodos => 'Ver lançamentos';

  @override
  String get lancamentosVazio => 'Sem lançamentos neste período.';

  @override
  String get lancamentosEditarTitulo => 'Editar lançamento';

  @override
  String get lancamentosApagarTitulo => 'Apagar lançamento';

  @override
  String get lancamentosApagarConfirmacao =>
      'Tens a certeza que queres apagar este lançamento? Não é possível desfazer.';

  @override
  String get fotosJaProntasTitulo => 'Fotos já cortadas e prontas?';

  @override
  String get fotosJaProntasSubtitulo =>
      'Sem fundo à volta, só o documento. Se sim, ficam guardadas como digitalização. Se não, só são usadas para preencher os dados.';

  @override
  String get legalTermosTitulo => 'Termos de Serviço';

  @override
  String get legalPrivacidadeTitulo => 'Política de Privacidade';

  @override
  String get legalDpaTitulo => 'Acordo de Subcontratação de Dados';

  @override
  String legalProgresso(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltam $n documentos',
      one: 'Falta 1 documento',
    );
    return '$_temp0 para aceitar.';
  }

  @override
  String get legalLiEAceito => 'Li e aceito.';

  @override
  String get legalAceitarEContinuar => 'Aceitar e continuar';

  @override
  String get trocarDeStandTitulo => 'Trocar de stand';

  @override
  String get trocarDeStandTexto =>
      'Isto esquece o token do stand guardado neste dispositivo — da próxima vez que abrires a app, vais ter de introduzir um token de novo. Continuar?';

  @override
  String get identidadeCaptureTitulo => 'Documento do comprador';

  @override
  String get identidadeCaptureInstrucoes =>
      'Tira uma foto da frente e do verso do Cartão de Cidadão ou Título de Residência do comprador.';

  @override
  String get digitalizarDocumento => 'Digitalizar documento';

  @override
  String get documentoTituloResidencia => 'Título de Residência';

  @override
  String get vendasTitulo => 'Vendas';

  @override
  String get minhasVendasTitulo => 'As minhas vendas';

  @override
  String get semVendasRegistadas => 'Ainda não há vendas registadas.';

  @override
  String get statusDisponivel => 'Disponível';

  @override
  String get statusReservado => 'Reservado';

  @override
  String get statusVendido => 'Vendido';

  @override
  String get statusPendenteAprovacao => 'Pendente de aprovação';

  @override
  String get statusRejeitado => 'Rejeitado';

  @override
  String get navVeiculos => 'Veículos';

  @override
  String get navVendas => 'Vendas';

  @override
  String get navEquipa => 'Equipa';

  @override
  String get navFinanceiro => 'Financeiro';

  @override
  String get bannerGerarBotao => 'Gerar banner de venda';

  @override
  String get bannerTitulo => 'Banner de venda';

  @override
  String get bannerPreviewTitulo => 'Pré-visualização';

  @override
  String get bannerCampoTitulo => 'Título';

  @override
  String get bannerCampoSubtitulo => 'Versão / motor';

  @override
  String get bannerCampoPotencia => 'Potência';

  @override
  String get bannerCampoAno => 'Ano';

  @override
  String get bannerCampoCombustivel => 'Combustível';

  @override
  String get bannerCampoPreco => 'Preço';

  @override
  String get bannerCampoPrestacao => 'Prestação / mês';

  @override
  String get bannerPerfilLojaSecao => 'Perfil da loja (aparece no banner)';

  @override
  String get bannerCampoSocial => 'Redes sociais (@handle)';

  @override
  String get bannerCampoContacto => 'Contacto';

  @override
  String get bannerEscolherCor => 'Cor de destaque';

  @override
  String get bannerCarregarFoto => 'Carregar foto';

  @override
  String get bannerTrocarFoto => 'Trocar foto';

  @override
  String get bannerFotoObrigatoria =>
      'É necessário carregar uma foto do veículo antes de gerar o banner.';

  @override
  String get bannerAvisoExemplo =>
      'Ainda sem foto — carrega a foto real do veículo antes de gerar.';

  @override
  String get bannerContinuar => 'Pré-visualizar';

  @override
  String get bannerPartilhar => 'Partilhar';

  @override
  String bannerGuardadoSucesso(String caminho) {
    return 'Banner guardado em $caminho';
  }

  @override
  String get bannerErroGuardar =>
      'Não foi possível guardar o banner. Tenta novamente.';

  @override
  String get bannerEscolherTemplateTitulo => 'Escolher template';

  @override
  String get bannerTemplateBrevemente => 'Brevemente';

  @override
  String get menuSugestoes => 'Sugestões';

  @override
  String get sugestoesTitulo => 'Sugestões';

  @override
  String get sugestoesIntro =>
      'Tens alguma ideia, pedido ou reparaste nalgum problema? Escreve aqui — vai diretamente para a equipa PS CarStand.';

  @override
  String get sugestoesCampoTexto => 'A tua sugestão';

  @override
  String get sugestoesEnviar => 'Enviar';

  @override
  String get sugestaoEnviada => 'Sugestão enviada. Obrigado!';
}
