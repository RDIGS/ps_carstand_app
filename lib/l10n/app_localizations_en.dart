// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get standTokenIntro =>
      'Enter your stand\'s token. You\'ll only need it once — after that you sign in with just email and password.';

  @override
  String get standTokenLabel => 'Stand token';

  @override
  String get standTokenContinuar => 'Continue';

  @override
  String get standTokenErroGenerico => 'Invalid token.';

  @override
  String get loginTitulo => 'Sign in';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginErroGenerico => 'Invalid email or password.';

  @override
  String get loginEsqueceuPassword => 'Forgot your password?';

  @override
  String get esqueceuPasswordTitulo => 'Forgot your password?';

  @override
  String get esqueceuPasswordTexto =>
      'If you\'re a salesperson, ask your stand\'s owner to reset your password in Team. If you\'re the owner, contact PS CarStand support: +351 911 038 529.';

  @override
  String appBarStandNome(String standNome) {
    return 'PS CarStand · $standNome';
  }

  @override
  String get erroTokenInvalido => 'Token not found or revoked.';

  @override
  String get erroCredenciaisInvalidas => 'Invalid email or password.';

  @override
  String get erroSessaoInvalida => 'Session expired, please sign in again.';

  @override
  String get erroSessaoComprometida =>
      'Invalid session — please sign in again on all devices.';

  @override
  String get erroTokenExpirado =>
      'Subscription expired or not yet activated. Contact PS CarStand support.';

  @override
  String get erroNaoAutenticado => 'Not signed in.';

  @override
  String get erroSemPermissao => 'You don\'t have permission for this action.';

  @override
  String get erroNaoEncontrado => 'Not found.';

  @override
  String get erroPedidoInvalido => 'Invalid request — check the data.';

  @override
  String get erroDemasiadosPedidos => 'Too many requests. Try again shortly.';

  @override
  String get erroOcrIndisponivel =>
      'Couldn\'t process the document right now. Please try again.';

  @override
  String get erroDocumentoNaoReconhecido =>
      'The images don\'t look like a valid Portuguese vehicle registration document.';

  @override
  String get erroNifInvalido => 'Buyer\'s NIF is invalid.';

  @override
  String get erroEstadoInvalido =>
      'This action isn\'t possible in the current state.';

  @override
  String get erroMembroJaExiste => 'This person is already part of the team.';

  @override
  String get erroVeiculoJaConfirmado =>
      'This vehicle has already been confirmed.';

  @override
  String get erroCamposEmFalta =>
      'You need to send both the front and back of the document.';

  @override
  String get erroRede =>
      'No connection to the server. Check your internet connection.';

  @override
  String get erroGenerico => 'An unexpected error occurred. Please try again.';

  @override
  String get terminarSessao => 'Sign out';

  @override
  String get menuAuditoria => 'Audit log';

  @override
  String get menuModoEscuro => 'Dark mode';

  @override
  String get auditoriaTitulo => 'Audit log';

  @override
  String get auditoriaFiltroTodos => 'All';

  @override
  String get auditoriaEntidadeVehicle => 'Vehicle';

  @override
  String get auditoriaEntidadeVehicleExpense => 'Expense';

  @override
  String get auditoriaEntidadeSale => 'Sale';

  @override
  String get auditoriaEntidadeFinanceEntry => 'Financial entry';

  @override
  String get auditoriaEntidadeStandMember => 'Team member';

  @override
  String get auditoriaAcaoCriado => 'Created';

  @override
  String get auditoriaAcaoAtualizado => 'Updated';

  @override
  String get auditoriaAcaoAprovado => 'Approved';

  @override
  String get auditoriaAcaoRejeitado => 'Rejected';

  @override
  String get auditoriaAcaoEstadoAlterado => 'Status changed';

  @override
  String get auditoriaAcaoRevertida => 'Reverted';

  @override
  String get auditoriaAcaoConvidado => 'Invited';

  @override
  String get auditoriaAcaoRemovido => 'Removed';

  @override
  String auditoriaFeitoPor(String nome, String data) {
    return 'by $nome · $data';
  }

  @override
  String get auditoriaSemRegistos => 'No audit records yet.';

  @override
  String get auditoriaValorAnterior => 'Before';

  @override
  String get auditoriaValorNovo => 'After';

  @override
  String get vehiclesEmptyTitulo => 'You don\'t have any vehicles yet';

  @override
  String get vehiclesEmptySubtitulo =>
      'Add your first vehicle, manually or from the registration document.';

  @override
  String get vehiclesEmptyBotao => 'Add your first vehicle';

  @override
  String get tentarNovamente => 'Try again';

  @override
  String get adicionarVeiculo => 'Add vehicle';

  @override
  String get adicionarManualmente => 'Add manually';

  @override
  String get adicionarPorDua => 'Add from registration document';

  @override
  String get fonteImagemCamara => 'Camera';

  @override
  String get fonteImagemGaleria => 'Gallery';

  @override
  String get fichaVeiculoTitulo => 'Vehicle details';

  @override
  String get specKms => 'Mileage';

  @override
  String get specPrimeiraMatricula => 'First registration';

  @override
  String get specCategoria => 'Category';

  @override
  String get specCombustivel => 'Fuel';

  @override
  String get specCilindrada => 'Engine size';

  @override
  String get specPotencia => 'Power';

  @override
  String get specCor => 'Colour';

  @override
  String get specLugares => 'Seats';

  @override
  String get specTara => 'Unladen weight';

  @override
  String get specPesoBruto => 'Gross weight';

  @override
  String get specChassis => 'Chassis';

  @override
  String get precoCompra => 'Purchase';

  @override
  String get precoVendaRecomendado => 'Recommended sale';

  @override
  String get precoVendaFinal => 'Final sale';

  @override
  String get veiculoImportado => 'Imported vehicle';

  @override
  String matriculaAnteriorLabel(String matricula) {
    return 'Previous plate: $matricula';
  }

  @override
  String paisOrigemLabel(String pais) {
    return 'Country of origin: $pais';
  }

  @override
  String get confiancaBaixaAviso =>
      'Low confidence on this information — double-check against the manufacturer\'s page.';

  @override
  String get aprovarVeiculo => 'Approve vehicle';

  @override
  String get rejeitar => 'Reject';

  @override
  String get reservar => 'Reserve';

  @override
  String get cancelarReserva => 'Cancel reservation';

  @override
  String get vender => 'Sell';

  @override
  String get estimativaMercadoTitulo => 'Market estimate';

  @override
  String get estimativaMercadoSubtitulo =>
      'Check similar listing prices (OLX, StandVirtual, ...)';

  @override
  String get consultar => 'Check';

  @override
  String estimativaMercadoErro(String erro) {
    return 'Couldn\'t get the market estimate: $erro';
  }

  @override
  String get estimativaMercadoSemDados =>
      'No market data available for this vehicle yet.';

  @override
  String estimativaMercadoIntervalo(String min, String max, String media) {
    return 'Between $min€ and $max€, average $media€';
  }

  @override
  String estimativaMercadoFontes(int n) {
    return 'Based on $n source(s).';
  }

  @override
  String get estimativaMercadoAtualizar => 'Refresh';

  @override
  String get estimativaMercadoJanelaNormal => 'Year ±1';

  @override
  String get estimativaMercadoJanelaAmpliada => 'Year ±2 (larger sample)';

  @override
  String get estimativaMercadoSemAmostra =>
      'No listings shown yet — tap refresh to see the ads used in the calculation.';

  @override
  String estimativaMercadoUsarComoRecomendado(String valor) {
    return 'Use $valor€ as recommended price';
  }

  @override
  String estimativaMercadoNumAnuncios(int n) {
    return '$n listings';
  }

  @override
  String estimativaMercadoVerAnuncios(int n) {
    return 'See the $n listings';
  }

  @override
  String get confirmarDuaTitulo => 'Confirm registration document data';

  @override
  String get duaRevisaoAviso =>
      'Review and correct the data extracted from the document before saving. Nothing is saved without your confirmation.';

  @override
  String get possivelImportadoAviso =>
      'Low confidence on some fields — check carefully, especially plate and chassis.';

  @override
  String importadoComPais(String pais, String matricula) {
    return 'Vehicle imported from $pais. Previous plate: $matricula.';
  }

  @override
  String importadoSemPais(String matricula) {
    return 'Imported vehicle. Previous plate: $matricula.';
  }

  @override
  String get seccaoIdentificacao => 'Identification';

  @override
  String get seccaoEspecificacoes => 'Specifications';

  @override
  String get seccaoPrecos => 'Prices';

  @override
  String get campoMatricula => 'Plate *';

  @override
  String get campoMatriculaHint => 'AA-00-AA';

  @override
  String get campoMarca => 'Make *';

  @override
  String get campoModelo => 'Model *';

  @override
  String get campoVersao => 'Version';

  @override
  String get campoQuilometros => 'Mileage *';

  @override
  String get campoCategoria => 'Category';

  @override
  String get campoCombustivel => 'Fuel';

  @override
  String get campoCilindrada => 'Engine size (cc)';

  @override
  String get campoPotencia => 'Power (kW)';

  @override
  String get campoCor => 'Colour';

  @override
  String get campoChassis => 'Chassis';

  @override
  String get campoPrecoCompra => 'Purchase price (€)';

  @override
  String get campoPrecoVendaRecomendado => 'Recommended sale price (€)';

  @override
  String get validacaoMatriculaInvalida => 'Invalid plate format.';

  @override
  String get validacaoCampoObrigatorio => 'Required field';

  @override
  String get validacaoNumeroInvalido => 'Enter a valid number';

  @override
  String get confirmarEGuardar => 'Confirm and save';

  @override
  String get duaCaptureTitulo => 'Add from registration document';

  @override
  String get duaCaptureInstrucoes =>
      'Take a photo of the front and back of the registration document.';

  @override
  String get duaFrente => 'Front';

  @override
  String get duaVerso => 'Back';

  @override
  String get extrairDados => 'Extract data';

  @override
  String venderTitulo(String matricula) {
    return 'Sell $matricula';
  }

  @override
  String get dadosComprador => 'Buyer details';

  @override
  String get campoNome => 'Name *';

  @override
  String get campoNif => 'Tax number *';

  @override
  String get campoMorada => 'Address';

  @override
  String get campoCodigoPostal => 'Postal code';

  @override
  String get campoDocumentoIdentificacao => 'ID document';

  @override
  String get documentoCC => 'Citizen Card';

  @override
  String get documentoBI => 'ID Card';

  @override
  String get documentoOutro => 'Other';

  @override
  String get campoNumeroDocumento => 'Document number';

  @override
  String get validacaoNifInvalido => 'Invalid tax number.';

  @override
  String get condicoesVenda => 'Sale conditions';

  @override
  String get campoPrecoFinal => 'Final price (€) *';

  @override
  String get campoComissaoVendedor => 'Salesperson commission (€)';

  @override
  String get validacaoValorInvalido => 'Enter a valid amount';

  @override
  String get registarVenda => 'Register sale';

  @override
  String get confirmarVendaTitulo => 'Confirm sale';

  @override
  String confirmarVendaTexto(String matricula, String nome, String preco) {
    return 'You\'re about to mark $matricula as sold to $nome for $preco€. This action can\'t be undone without reverting the sale.';
  }

  @override
  String get cancelar => 'Cancel';

  @override
  String get vendaRegistadaTitulo => 'Sale registered';

  @override
  String get vendaRegistadaTexto => 'Vehicle marked as sold.';

  @override
  String get registoCompraLabel => 'Purchase record:';

  @override
  String get copiarLink => 'Copy link';

  @override
  String get concluir => 'Done';

  @override
  String get equipaTitulo => 'Team';

  @override
  String get convidarMembroTitulo => 'Invite member';

  @override
  String get campoFuncao => 'Role';

  @override
  String get funcaoVendedor => 'Salesperson';

  @override
  String get funcaoOwner => 'Owner';

  @override
  String get validacaoEmailInvalido => 'Invalid email';

  @override
  String get convidar => 'Invite';

  @override
  String get contaCriadaTitulo => 'Account created';

  @override
  String contaCriadaTexto(String nome) {
    return 'Share this temporary password with $nome — there\'s no automatic email yet.';
  }

  @override
  String get reporPasswordTitulo => 'Reset password';

  @override
  String reporPasswordConfirmacao(String nome) {
    return 'This sets a new temporary password for $nome and signs them out on every device. Continue?';
  }

  @override
  String get passwordRepostaTitulo => 'Password reset';

  @override
  String passwordRepostaTexto(String nome) {
    return 'Share this new temporary password with $nome — there\'s no automatic email yet.';
  }

  @override
  String get copiar => 'Copy';

  @override
  String get ok => 'Ok';

  @override
  String membroSubtitulo(String email, String role) {
    return '$email · $role';
  }

  @override
  String get tornarVendedor => 'Make salesperson';

  @override
  String get tornarOwner => 'Make owner';

  @override
  String get desativar => 'Deactivate';

  @override
  String get ativar => 'Activate';

  @override
  String get removerAcesso => 'Remove access';

  @override
  String removerAcessoConfirmacao(String nome) {
    return 'Remove $nome from the team? They can be invited again later.';
  }

  @override
  String get remover => 'Remove';

  @override
  String get financeiroTitulo => 'Finance';

  @override
  String get novoMovimentoTitulo => 'New entry';

  @override
  String get tipoDespesa => 'Expense';

  @override
  String get tipoReceita => 'Income';

  @override
  String get campoValor => 'Amount (€)';

  @override
  String get campoCategoriaFinanceira => 'Category';

  @override
  String get campoDescricao => 'Description';

  @override
  String get guardar => 'Save';

  @override
  String get guardado => 'Saved';

  @override
  String get cashflowDoMes => 'This month\'s cashflow';

  @override
  String get desvioVsRecomendado => 'Deviation vs. recommended';

  @override
  String get vsmercado => 'Vs. market';

  @override
  String get margemPorMarcaModelo => 'Margin by make/model';

  @override
  String get rankingVendedores => 'Salesperson ranking';

  @override
  String get margemPorVeiculo => 'Margin by vehicle sold';

  @override
  String get semVendasPeriodo => 'No sales in this period.';

  @override
  String numVendas(int n) {
    return '$n sale(s)';
  }

  @override
  String comissaoLabel(String valor) {
    return 'Commission: $valor €';
  }

  @override
  String diasEmStock(int dias) {
    return '$dias days in stock';
  }

  @override
  String get movimento => 'Entry';

  @override
  String subscricaoAvisoExpira(int dias) {
    return 'The stand\'s subscription ends in $dias days.';
  }

  @override
  String subscricaoAvisoCarencia(int dias) {
    return 'Subscription overdue — $dias grace days left before access is blocked.';
  }

  @override
  String get atualizacaoObrigatoriaTitulo => 'Update required';

  @override
  String get atualizacaoObrigatoriaTexto =>
      'This version of the app is no longer supported. Update to keep using PS CarStand.';

  @override
  String get atualizacaoObrigatoriaBotao => 'See update instructions';

  @override
  String atualizacaoRecomendadaAviso(String versao) {
    return 'A newer version is already available ($versao).';
  }

  @override
  String get atualizacaoRecomendadaBotao => 'See what\'s new';

  @override
  String get checklistTitulo => 'Prep checklist';

  @override
  String get checklistVazio => 'No checklist items yet.';

  @override
  String get checklistAplicarModelo => 'Apply template';

  @override
  String get checklistAdicionarItem => 'Add item';

  @override
  String get checklistNovoItemTitulo => 'New item';

  @override
  String get checklistNovoItemHint => 'E.g.: Exterior wash';

  @override
  String get checklistEscolherModeloTitulo => 'Choose template';

  @override
  String get checklistSemModelos => 'You haven\'t created any template yet.';

  @override
  String get checklistCriarModelo => 'Create template';

  @override
  String get checklistNomeModelo => 'Template name';

  @override
  String get checklistNomeModeloHint => 'E.g.: Standard Diesel Checklist';

  @override
  String get checklistItensModelo => 'Items';

  @override
  String get checklistAdicionarItemModelo => 'Add item';

  @override
  String get despesasTitulo => 'Vehicle expenses';

  @override
  String get despesasVazio => 'No expenses recorded yet.';

  @override
  String get despesasAdicionar => 'Add expense';

  @override
  String get despesasNovaTitulo => 'New expense';

  @override
  String get despesaCategoriaReparacao => 'Repair';

  @override
  String get despesaCategoriaTransporte => 'Transport';

  @override
  String get despesaCategoriaLegalizacao => 'Legal/registration';

  @override
  String get despesaCategoriaLimpezaDetalhe => 'Cleaning / Detailing';

  @override
  String get despesaCategoriaOutro => 'Other';

  @override
  String get fotosJaProntasTitulo => 'Photos already cropped and ready?';

  @override
  String get fotosJaProntasSubtitulo =>
      'No background around it, just the document. If yes, they\'re saved as a scan. If no, they\'re only used to fill in the data.';

  @override
  String get legalTermosTitulo => 'Terms of Service';

  @override
  String get legalPrivacidadeTitulo => 'Privacy Policy';

  @override
  String get legalDpaTitulo => 'Data Processing Agreement';

  @override
  String legalProgresso(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n documents left',
      one: '1 document left',
    );
    return '$_temp0 to accept.';
  }

  @override
  String get legalLiEAceito => 'I\'ve read and I accept.';

  @override
  String get legalAceitarEContinuar => 'Accept and continue';

  @override
  String get trocarDeStandTitulo => 'Switch stand';

  @override
  String get trocarDeStandTexto =>
      'This forgets the stand token saved on this device — next time you open the app, you\'ll need to enter a token again. Continue?';

  @override
  String get identidadeCaptureTitulo => 'Buyer\'s document';

  @override
  String get identidadeCaptureInstrucoes =>
      'Take a photo of the front and back of the buyer\'s Citizen Card or Residence Permit.';

  @override
  String get digitalizarDocumento => 'Scan document';

  @override
  String get documentoTituloResidencia => 'Residence Permit';

  @override
  String get vendasTitulo => 'Sales';

  @override
  String get minhasVendasTitulo => 'My sales';

  @override
  String get semVendasRegistadas => 'No sales registered yet.';

  @override
  String get statusDisponivel => 'Available';

  @override
  String get statusReservado => 'Reserved';

  @override
  String get statusVendido => 'Sold';

  @override
  String get statusPendenteAprovacao => 'Pending approval';

  @override
  String get statusRejeitado => 'Rejected';

  @override
  String get navVeiculos => 'Vehicles';

  @override
  String get navVendas => 'Sales';

  @override
  String get navEquipa => 'Team';

  @override
  String get navFinanceiro => 'Finance';

  @override
  String get bannerGerarBotao => 'Generate sales banner';

  @override
  String get bannerTitulo => 'Sales banner';

  @override
  String get bannerPreviewTitulo => 'Preview';

  @override
  String get bannerCampoTitulo => 'Title';

  @override
  String get bannerCampoSubtitulo => 'Trim / engine';

  @override
  String get bannerCampoPotencia => 'Power';

  @override
  String get bannerCampoAno => 'Year';

  @override
  String get bannerCampoCombustivel => 'Fuel';

  @override
  String get bannerCampoPreco => 'Price';

  @override
  String get bannerCampoPrestacao => 'Monthly payment';

  @override
  String get bannerPerfilLojaSecao => 'Dealer profile (shown on the banner)';

  @override
  String get bannerCampoSocial => 'Social media (@handle)';

  @override
  String get bannerCampoContacto => 'Contact';

  @override
  String get bannerEscolherCor => 'Accent colour';

  @override
  String get bannerCarregarFoto => 'Upload photo';

  @override
  String get bannerTrocarFoto => 'Change photo';

  @override
  String get bannerFotoObrigatoria =>
      'You need to upload a photo of the vehicle before generating the banner.';

  @override
  String get bannerAvisoExemplo =>
      'No photo yet — upload the real vehicle photo before generating.';

  @override
  String get bannerContinuar => 'Preview';

  @override
  String get bannerPartilhar => 'Share';

  @override
  String bannerGuardadoSucesso(String caminho) {
    return 'Banner saved to $caminho';
  }

  @override
  String get bannerErroGuardar =>
      'Could not save the banner. Please try again.';

  @override
  String get bannerEscolherTemplateTitulo => 'Choose template';

  @override
  String get bannerTemplateBrevemente => 'Coming soon';

  @override
  String get menuSugestoes => 'Suggestions';

  @override
  String get sugestoesTitulo => 'Suggestions';

  @override
  String get sugestoesIntro =>
      'Got an idea, request, or noticed a problem? Write it here — it goes straight to the PS CarStand team.';

  @override
  String get sugestoesCampoTexto => 'Your suggestion';

  @override
  String get sugestoesEnviar => 'Send';

  @override
  String get sugestaoEnviada => 'Suggestion sent. Thank you!';
}
