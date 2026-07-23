import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @standTokenIntro.
  ///
  /// In pt, this message translates to:
  /// **'Introduz o token do teu stand. Só é preciso uma vez — depois disso entras só com email e password.'**
  String get standTokenIntro;

  /// No description provided for @standTokenLabel.
  ///
  /// In pt, this message translates to:
  /// **'Token do stand'**
  String get standTokenLabel;

  /// No description provided for @standTokenContinuar.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get standTokenContinuar;

  /// No description provided for @standTokenErroGenerico.
  ///
  /// In pt, this message translates to:
  /// **'Token inválido.'**
  String get standTokenErroGenerico;

  /// No description provided for @loginTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginTitulo;

  /// No description provided for @loginEmail.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In pt, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginErroGenerico.
  ///
  /// In pt, this message translates to:
  /// **'Email ou password inválidos.'**
  String get loginErroGenerico;

  /// No description provided for @appBarStandNome.
  ///
  /// In pt, this message translates to:
  /// **'PS CarStand · {standNome}'**
  String appBarStandNome(String standNome);

  /// No description provided for @erroTokenInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Token não encontrado ou revogado.'**
  String get erroTokenInvalido;

  /// No description provided for @erroCredenciaisInvalidas.
  ///
  /// In pt, this message translates to:
  /// **'Email ou password inválidos.'**
  String get erroCredenciaisInvalidas;

  /// No description provided for @erroSessaoInvalida.
  ///
  /// In pt, this message translates to:
  /// **'Sessão expirada, inicia sessão novamente.'**
  String get erroSessaoInvalida;

  /// No description provided for @erroSessaoComprometida.
  ///
  /// In pt, this message translates to:
  /// **'Sessão inválida — inicia sessão novamente em todos os dispositivos.'**
  String get erroSessaoComprometida;

  /// No description provided for @erroTokenExpirado.
  ///
  /// In pt, this message translates to:
  /// **'Subscrição expirada ou por ativar. Contacta o suporte da PS CarStand.'**
  String get erroTokenExpirado;

  /// No description provided for @erroNaoAutenticado.
  ///
  /// In pt, this message translates to:
  /// **'Sessão não iniciada.'**
  String get erroNaoAutenticado;

  /// No description provided for @erroSemPermissao.
  ///
  /// In pt, this message translates to:
  /// **'Não tens permissão para esta ação.'**
  String get erroSemPermissao;

  /// No description provided for @erroNaoEncontrado.
  ///
  /// In pt, this message translates to:
  /// **'Não encontrado.'**
  String get erroNaoEncontrado;

  /// No description provided for @erroPedidoInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Pedido inválido — verifica os dados.'**
  String get erroPedidoInvalido;

  /// No description provided for @erroDemasiadosPedidos.
  ///
  /// In pt, this message translates to:
  /// **'Demasiados pedidos. Tenta novamente daqui a pouco.'**
  String get erroDemasiadosPedidos;

  /// No description provided for @erroOcrIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível processar o documento neste momento. Tenta novamente.'**
  String get erroOcrIndisponivel;

  /// No description provided for @erroDocumentoNaoReconhecido.
  ///
  /// In pt, this message translates to:
  /// **'As imagens não parecem ser um DUA português válido.'**
  String get erroDocumentoNaoReconhecido;

  /// No description provided for @erroNifInvalido.
  ///
  /// In pt, this message translates to:
  /// **'NIF do comprador inválido.'**
  String get erroNifInvalido;

  /// No description provided for @erroEstadoInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação não é possível no estado atual.'**
  String get erroEstadoInvalido;

  /// No description provided for @erroMembroJaExiste.
  ///
  /// In pt, this message translates to:
  /// **'Esta pessoa já faz parte da equipa.'**
  String get erroMembroJaExiste;

  /// No description provided for @erroVeiculoJaConfirmado.
  ///
  /// In pt, this message translates to:
  /// **'Este veículo já foi confirmado anteriormente.'**
  String get erroVeiculoJaConfirmado;

  /// No description provided for @erroCamposEmFalta.
  ///
  /// In pt, this message translates to:
  /// **'É necessário enviar a frente e o verso do documento.'**
  String get erroCamposEmFalta;

  /// No description provided for @erroRede.
  ///
  /// In pt, this message translates to:
  /// **'Sem ligação ao servidor. Verifica a tua ligação à internet.'**
  String get erroRede;

  /// No description provided for @erroGenerico.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro inesperado. Tenta novamente.'**
  String get erroGenerico;

  /// No description provided for @terminarSessao.
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessão'**
  String get terminarSessao;

  /// No description provided for @menuAuditoria.
  ///
  /// In pt, this message translates to:
  /// **'Auditoria'**
  String get menuAuditoria;

  /// No description provided for @auditoriaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Auditoria'**
  String get auditoriaTitulo;

  /// No description provided for @auditoriaFiltroTodos.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get auditoriaFiltroTodos;

  /// No description provided for @auditoriaEntidadeVehicle.
  ///
  /// In pt, this message translates to:
  /// **'Veículo'**
  String get auditoriaEntidadeVehicle;

  /// No description provided for @auditoriaEntidadeVehicleExpense.
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get auditoriaEntidadeVehicleExpense;

  /// No description provided for @auditoriaEntidadeSale.
  ///
  /// In pt, this message translates to:
  /// **'Venda'**
  String get auditoriaEntidadeSale;

  /// No description provided for @auditoriaEntidadeFinanceEntry.
  ///
  /// In pt, this message translates to:
  /// **'Movimento financeiro'**
  String get auditoriaEntidadeFinanceEntry;

  /// No description provided for @auditoriaEntidadeStandMember.
  ///
  /// In pt, this message translates to:
  /// **'Membro de equipa'**
  String get auditoriaEntidadeStandMember;

  /// No description provided for @auditoriaAcaoCriado.
  ///
  /// In pt, this message translates to:
  /// **'Criado'**
  String get auditoriaAcaoCriado;

  /// No description provided for @auditoriaAcaoAtualizado.
  ///
  /// In pt, this message translates to:
  /// **'Atualizado'**
  String get auditoriaAcaoAtualizado;

  /// No description provided for @auditoriaAcaoAprovado.
  ///
  /// In pt, this message translates to:
  /// **'Aprovado'**
  String get auditoriaAcaoAprovado;

  /// No description provided for @auditoriaAcaoRejeitado.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitado'**
  String get auditoriaAcaoRejeitado;

  /// No description provided for @auditoriaAcaoEstadoAlterado.
  ///
  /// In pt, this message translates to:
  /// **'Estado alterado'**
  String get auditoriaAcaoEstadoAlterado;

  /// No description provided for @auditoriaAcaoRevertida.
  ///
  /// In pt, this message translates to:
  /// **'Revertido'**
  String get auditoriaAcaoRevertida;

  /// No description provided for @auditoriaAcaoConvidado.
  ///
  /// In pt, this message translates to:
  /// **'Convidado'**
  String get auditoriaAcaoConvidado;

  /// No description provided for @auditoriaAcaoRemovido.
  ///
  /// In pt, this message translates to:
  /// **'Removido'**
  String get auditoriaAcaoRemovido;

  /// No description provided for @auditoriaFeitoPor.
  ///
  /// In pt, this message translates to:
  /// **'por {nome} · {data}'**
  String auditoriaFeitoPor(String nome, String data);

  /// No description provided for @auditoriaSemRegistos.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há registos de auditoria.'**
  String get auditoriaSemRegistos;

  /// No description provided for @auditoriaValorAnterior.
  ///
  /// In pt, this message translates to:
  /// **'Antes'**
  String get auditoriaValorAnterior;

  /// No description provided for @auditoriaValorNovo.
  ///
  /// In pt, this message translates to:
  /// **'Depois'**
  String get auditoriaValorNovo;

  /// No description provided for @vehiclesEmptyTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tens veículos'**
  String get vehiclesEmptyTitulo;

  /// No description provided for @vehiclesEmptySubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Adiciona o teu primeiro veículo, manualmente ou a partir do DUA.'**
  String get vehiclesEmptySubtitulo;

  /// No description provided for @vehiclesEmptyBotao.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar o primeiro veículo'**
  String get vehiclesEmptyBotao;

  /// No description provided for @tentarNovamente.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tentarNovamente;

  /// No description provided for @adicionarVeiculo.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar veículo'**
  String get adicionarVeiculo;

  /// No description provided for @adicionarManualmente.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar manualmente'**
  String get adicionarManualmente;

  /// No description provided for @adicionarPorDua.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar a partir do DUA'**
  String get adicionarPorDua;

  /// No description provided for @fichaVeiculoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Ficha do veículo'**
  String get fichaVeiculoTitulo;

  /// No description provided for @specKms.
  ///
  /// In pt, this message translates to:
  /// **'Kms'**
  String get specKms;

  /// No description provided for @specPrimeiraMatricula.
  ///
  /// In pt, this message translates to:
  /// **'1ª matrícula'**
  String get specPrimeiraMatricula;

  /// No description provided for @specCategoria.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get specCategoria;

  /// No description provided for @specCombustivel.
  ///
  /// In pt, this message translates to:
  /// **'Combustível'**
  String get specCombustivel;

  /// No description provided for @specCilindrada.
  ///
  /// In pt, this message translates to:
  /// **'Cilindrada'**
  String get specCilindrada;

  /// No description provided for @specPotencia.
  ///
  /// In pt, this message translates to:
  /// **'Potência'**
  String get specPotencia;

  /// No description provided for @specCor.
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get specCor;

  /// No description provided for @specLugares.
  ///
  /// In pt, this message translates to:
  /// **'Lugares'**
  String get specLugares;

  /// No description provided for @specTara.
  ///
  /// In pt, this message translates to:
  /// **'Tara'**
  String get specTara;

  /// No description provided for @specPesoBruto.
  ///
  /// In pt, this message translates to:
  /// **'Peso bruto'**
  String get specPesoBruto;

  /// No description provided for @specChassis.
  ///
  /// In pt, this message translates to:
  /// **'Chassis'**
  String get specChassis;

  /// No description provided for @precoCompra.
  ///
  /// In pt, this message translates to:
  /// **'Compra'**
  String get precoCompra;

  /// No description provided for @precoVendaRecomendado.
  ///
  /// In pt, this message translates to:
  /// **'Venda recomendado'**
  String get precoVendaRecomendado;

  /// No description provided for @precoVendaFinal.
  ///
  /// In pt, this message translates to:
  /// **'Venda final'**
  String get precoVendaFinal;

  /// No description provided for @veiculoImportado.
  ///
  /// In pt, this message translates to:
  /// **'Veículo importado'**
  String get veiculoImportado;

  /// No description provided for @matriculaAnteriorLabel.
  ///
  /// In pt, this message translates to:
  /// **'Matrícula anterior: {matricula}'**
  String matriculaAnteriorLabel(String matricula);

  /// No description provided for @paisOrigemLabel.
  ///
  /// In pt, this message translates to:
  /// **'País de origem: {pais}'**
  String paisOrigemLabel(String pais);

  /// No description provided for @confiancaBaixaAviso.
  ///
  /// In pt, this message translates to:
  /// **'Confiança baixa nesta informação — confirma os dados na página do fabricante.'**
  String get confiancaBaixaAviso;

  /// No description provided for @aprovarVeiculo.
  ///
  /// In pt, this message translates to:
  /// **'Aprovar veículo'**
  String get aprovarVeiculo;

  /// No description provided for @rejeitar.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitar'**
  String get rejeitar;

  /// No description provided for @reservar.
  ///
  /// In pt, this message translates to:
  /// **'Reservar'**
  String get reservar;

  /// No description provided for @cancelarReserva.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar reserva'**
  String get cancelarReserva;

  /// No description provided for @vender.
  ///
  /// In pt, this message translates to:
  /// **'Vender'**
  String get vender;

  /// No description provided for @estimativaMercadoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Estimativa de mercado'**
  String get estimativaMercadoTitulo;

  /// No description provided for @estimativaMercadoSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Consultar preços semelhantes (OLX, StandVirtual, ...)'**
  String get estimativaMercadoSubtitulo;

  /// No description provided for @consultar.
  ///
  /// In pt, this message translates to:
  /// **'Consultar'**
  String get consultar;

  /// No description provided for @estimativaMercadoErro.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível obter a estimativa: {erro}'**
  String estimativaMercadoErro(String erro);

  /// No description provided for @estimativaMercadoSemDados.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados de mercado disponíveis para este veículo ainda.'**
  String get estimativaMercadoSemDados;

  /// No description provided for @estimativaMercadoIntervalo.
  ///
  /// In pt, this message translates to:
  /// **'Entre {min}€ e {max}€, média {media}€'**
  String estimativaMercadoIntervalo(String min, String max, String media);

  /// No description provided for @estimativaMercadoFontes.
  ///
  /// In pt, this message translates to:
  /// **'Baseado em {n} fonte(s).'**
  String estimativaMercadoFontes(int n);

  /// No description provided for @estimativaMercadoAtualizar.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get estimativaMercadoAtualizar;

  /// No description provided for @estimativaMercadoJanelaNormal.
  ///
  /// In pt, this message translates to:
  /// **'Ano ±1'**
  String get estimativaMercadoJanelaNormal;

  /// No description provided for @estimativaMercadoJanelaAmpliada.
  ///
  /// In pt, this message translates to:
  /// **'Ano ±2 (amostra maior)'**
  String get estimativaMercadoJanelaAmpliada;

  /// No description provided for @estimativaMercadoSemAmostra.
  ///
  /// In pt, this message translates to:
  /// **'Sem lista de anúncios ainda — toca em atualizar para veres os anúncios usados no cálculo.'**
  String get estimativaMercadoSemAmostra;

  /// No description provided for @estimativaMercadoUsarComoRecomendado.
  ///
  /// In pt, this message translates to:
  /// **'Usar {valor}€ como preço recomendado'**
  String estimativaMercadoUsarComoRecomendado(String valor);

  /// No description provided for @estimativaMercadoNumAnuncios.
  ///
  /// In pt, this message translates to:
  /// **'{n} anúncios'**
  String estimativaMercadoNumAnuncios(int n);

  /// No description provided for @estimativaMercadoVerAnuncios.
  ///
  /// In pt, this message translates to:
  /// **'Ver os {n} anúncios'**
  String estimativaMercadoVerAnuncios(int n);

  /// No description provided for @confirmarDuaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar dados do DUA'**
  String get confirmarDuaTitulo;

  /// No description provided for @duaRevisaoAviso.
  ///
  /// In pt, this message translates to:
  /// **'Revê e corrige os dados extraídos do DUA antes de guardar. Nada é gravado sem a tua confirmação.'**
  String get duaRevisaoAviso;

  /// No description provided for @possivelImportadoAviso.
  ///
  /// In pt, this message translates to:
  /// **'Confiança baixa em alguns campos — confirma com atenção, sobretudo matrícula e chassis.'**
  String get possivelImportadoAviso;

  /// No description provided for @importadoComPais.
  ///
  /// In pt, this message translates to:
  /// **'Veículo importado de {pais}. Matrícula anterior: {matricula}.'**
  String importadoComPais(String pais, String matricula);

  /// No description provided for @importadoSemPais.
  ///
  /// In pt, this message translates to:
  /// **'Veículo importado. Matrícula anterior: {matricula}.'**
  String importadoSemPais(String matricula);

  /// No description provided for @seccaoIdentificacao.
  ///
  /// In pt, this message translates to:
  /// **'Identificação'**
  String get seccaoIdentificacao;

  /// No description provided for @seccaoEspecificacoes.
  ///
  /// In pt, this message translates to:
  /// **'Especificações'**
  String get seccaoEspecificacoes;

  /// No description provided for @seccaoPrecos.
  ///
  /// In pt, this message translates to:
  /// **'Preços'**
  String get seccaoPrecos;

  /// No description provided for @campoMatricula.
  ///
  /// In pt, this message translates to:
  /// **'Matrícula *'**
  String get campoMatricula;

  /// No description provided for @campoMatriculaHint.
  ///
  /// In pt, this message translates to:
  /// **'AA-00-AA'**
  String get campoMatriculaHint;

  /// No description provided for @campoMarca.
  ///
  /// In pt, this message translates to:
  /// **'Marca *'**
  String get campoMarca;

  /// No description provided for @campoModelo.
  ///
  /// In pt, this message translates to:
  /// **'Modelo *'**
  String get campoModelo;

  /// No description provided for @campoVersao.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get campoVersao;

  /// No description provided for @campoQuilometros.
  ///
  /// In pt, this message translates to:
  /// **'Quilómetros *'**
  String get campoQuilometros;

  /// No description provided for @campoCategoria.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get campoCategoria;

  /// No description provided for @campoCombustivel.
  ///
  /// In pt, this message translates to:
  /// **'Combustível'**
  String get campoCombustivel;

  /// No description provided for @campoCilindrada.
  ///
  /// In pt, this message translates to:
  /// **'Cilindrada (cm³)'**
  String get campoCilindrada;

  /// No description provided for @campoPotencia.
  ///
  /// In pt, this message translates to:
  /// **'Potência (kW)'**
  String get campoPotencia;

  /// No description provided for @campoCor.
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get campoCor;

  /// No description provided for @campoChassis.
  ///
  /// In pt, this message translates to:
  /// **'Chassis'**
  String get campoChassis;

  /// No description provided for @campoPrecoCompra.
  ///
  /// In pt, this message translates to:
  /// **'Preço de compra (€)'**
  String get campoPrecoCompra;

  /// No description provided for @campoPrecoVendaRecomendado.
  ///
  /// In pt, this message translates to:
  /// **'Preço de venda recomendado (€)'**
  String get campoPrecoVendaRecomendado;

  /// No description provided for @validacaoMatriculaInvalida.
  ///
  /// In pt, this message translates to:
  /// **'Matrícula em formato inválido.'**
  String get validacaoMatriculaInvalida;

  /// No description provided for @validacaoCampoObrigatorio.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório'**
  String get validacaoCampoObrigatorio;

  /// No description provided for @validacaoNumeroInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Introduz um número válido'**
  String get validacaoNumeroInvalido;

  /// No description provided for @confirmarEGuardar.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar e guardar'**
  String get confirmarEGuardar;

  /// No description provided for @duaCaptureTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar por DUA'**
  String get duaCaptureTitulo;

  /// No description provided for @duaCaptureInstrucoes.
  ///
  /// In pt, this message translates to:
  /// **'Tira uma foto da frente e do verso do DUA (Certificado de Matrícula).'**
  String get duaCaptureInstrucoes;

  /// No description provided for @duaFrente.
  ///
  /// In pt, this message translates to:
  /// **'Frente'**
  String get duaFrente;

  /// No description provided for @duaVerso.
  ///
  /// In pt, this message translates to:
  /// **'Verso'**
  String get duaVerso;

  /// No description provided for @extrairDados.
  ///
  /// In pt, this message translates to:
  /// **'Extrair dados'**
  String get extrairDados;

  /// No description provided for @venderTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Vender {matricula}'**
  String venderTitulo(String matricula);

  /// No description provided for @dadosComprador.
  ///
  /// In pt, this message translates to:
  /// **'Dados do comprador'**
  String get dadosComprador;

  /// No description provided for @campoNome.
  ///
  /// In pt, this message translates to:
  /// **'Nome *'**
  String get campoNome;

  /// No description provided for @campoNif.
  ///
  /// In pt, this message translates to:
  /// **'NIF *'**
  String get campoNif;

  /// No description provided for @campoMorada.
  ///
  /// In pt, this message translates to:
  /// **'Morada'**
  String get campoMorada;

  /// No description provided for @campoCodigoPostal.
  ///
  /// In pt, this message translates to:
  /// **'Código postal'**
  String get campoCodigoPostal;

  /// No description provided for @campoDocumentoIdentificacao.
  ///
  /// In pt, this message translates to:
  /// **'Documento de identificação'**
  String get campoDocumentoIdentificacao;

  /// No description provided for @documentoCC.
  ///
  /// In pt, this message translates to:
  /// **'Cartão de Cidadão'**
  String get documentoCC;

  /// No description provided for @documentoBI.
  ///
  /// In pt, this message translates to:
  /// **'Bilhete de Identidade'**
  String get documentoBI;

  /// No description provided for @documentoOutro.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get documentoOutro;

  /// No description provided for @campoNumeroDocumento.
  ///
  /// In pt, this message translates to:
  /// **'Número do documento'**
  String get campoNumeroDocumento;

  /// No description provided for @validacaoNifInvalido.
  ///
  /// In pt, this message translates to:
  /// **'NIF inválido.'**
  String get validacaoNifInvalido;

  /// No description provided for @condicoesVenda.
  ///
  /// In pt, this message translates to:
  /// **'Condições da venda'**
  String get condicoesVenda;

  /// No description provided for @campoPrecoFinal.
  ///
  /// In pt, this message translates to:
  /// **'Preço final (€) *'**
  String get campoPrecoFinal;

  /// No description provided for @campoComissaoVendedor.
  ///
  /// In pt, this message translates to:
  /// **'Comissão do vendedor (€)'**
  String get campoComissaoVendedor;

  /// No description provided for @validacaoValorInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Introduz um valor válido'**
  String get validacaoValorInvalido;

  /// No description provided for @registarVenda.
  ///
  /// In pt, this message translates to:
  /// **'Registar venda'**
  String get registarVenda;

  /// No description provided for @confirmarVendaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar venda'**
  String get confirmarVendaTitulo;

  /// No description provided for @confirmarVendaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Vais marcar o {matricula} como vendido a {nome} por {preco}€. Esta ação não pode ser desfeita sem reverter a venda.'**
  String confirmarVendaTexto(String matricula, String nome, String preco);

  /// No description provided for @cancelar.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @vendaRegistadaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Venda registada'**
  String get vendaRegistadaTitulo;

  /// No description provided for @vendaRegistadaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Veículo marcado como vendido.'**
  String get vendaRegistadaTexto;

  /// No description provided for @registoCompraLabel.
  ///
  /// In pt, this message translates to:
  /// **'Registo de Compra:'**
  String get registoCompraLabel;

  /// No description provided for @copiarLink.
  ///
  /// In pt, this message translates to:
  /// **'Copiar link'**
  String get copiarLink;

  /// No description provided for @concluir.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get concluir;

  /// No description provided for @equipaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Equipa'**
  String get equipaTitulo;

  /// No description provided for @convidarMembroTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Convidar membro'**
  String get convidarMembroTitulo;

  /// No description provided for @campoFuncao.
  ///
  /// In pt, this message translates to:
  /// **'Função'**
  String get campoFuncao;

  /// No description provided for @funcaoVendedor.
  ///
  /// In pt, this message translates to:
  /// **'Vendedor'**
  String get funcaoVendedor;

  /// No description provided for @funcaoOwner.
  ///
  /// In pt, this message translates to:
  /// **'Owner'**
  String get funcaoOwner;

  /// No description provided for @validacaoEmailInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Email inválido'**
  String get validacaoEmailInvalido;

  /// No description provided for @convidar.
  ///
  /// In pt, this message translates to:
  /// **'Convidar'**
  String get convidar;

  /// No description provided for @contaCriadaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Conta criada'**
  String get contaCriadaTitulo;

  /// No description provided for @contaCriadaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Partilha esta password temporária com {nome} — ainda não há envio automático por email.'**
  String contaCriadaTexto(String nome);

  /// No description provided for @copiar.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get copiar;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @membroSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'{email} · {role}'**
  String membroSubtitulo(String email, String role);

  /// No description provided for @tornarVendedor.
  ///
  /// In pt, this message translates to:
  /// **'Tornar vendedor'**
  String get tornarVendedor;

  /// No description provided for @tornarOwner.
  ///
  /// In pt, this message translates to:
  /// **'Tornar owner'**
  String get tornarOwner;

  /// No description provided for @desativar.
  ///
  /// In pt, this message translates to:
  /// **'Desativar'**
  String get desativar;

  /// No description provided for @ativar.
  ///
  /// In pt, this message translates to:
  /// **'Ativar'**
  String get ativar;

  /// No description provided for @removerAcesso.
  ///
  /// In pt, this message translates to:
  /// **'Remover acesso'**
  String get removerAcesso;

  /// No description provided for @removerAcessoConfirmacao.
  ///
  /// In pt, this message translates to:
  /// **'Remover {nome} da equipa? Pode voltar a ser convidado depois.'**
  String removerAcessoConfirmacao(String nome);

  /// No description provided for @remover.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get remover;

  /// No description provided for @financeiroTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Financeiro'**
  String get financeiroTitulo;

  /// No description provided for @novoMovimentoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Novo movimento'**
  String get novoMovimentoTitulo;

  /// No description provided for @tipoDespesa.
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get tipoDespesa;

  /// No description provided for @tipoReceita.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get tipoReceita;

  /// No description provided for @campoValor.
  ///
  /// In pt, this message translates to:
  /// **'Valor (€)'**
  String get campoValor;

  /// No description provided for @campoCategoriaFinanceira.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get campoCategoriaFinanceira;

  /// No description provided for @campoDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get campoDescricao;

  /// No description provided for @guardar.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @guardado.
  ///
  /// In pt, this message translates to:
  /// **'Guardado'**
  String get guardado;

  /// No description provided for @cashflowDoMes.
  ///
  /// In pt, this message translates to:
  /// **'Cashflow do mês'**
  String get cashflowDoMes;

  /// No description provided for @desvioVsRecomendado.
  ///
  /// In pt, this message translates to:
  /// **'Desvio vs. recomendado'**
  String get desvioVsRecomendado;

  /// No description provided for @vsmercado.
  ///
  /// In pt, this message translates to:
  /// **'Vs. mercado'**
  String get vsmercado;

  /// No description provided for @margemPorMarcaModelo.
  ///
  /// In pt, this message translates to:
  /// **'Margem por marca/modelo'**
  String get margemPorMarcaModelo;

  /// No description provided for @rankingVendedores.
  ///
  /// In pt, this message translates to:
  /// **'Ranking de vendedores'**
  String get rankingVendedores;

  /// No description provided for @margemPorVeiculo.
  ///
  /// In pt, this message translates to:
  /// **'Margem por veículo vendido'**
  String get margemPorVeiculo;

  /// No description provided for @semVendasPeriodo.
  ///
  /// In pt, this message translates to:
  /// **'Sem vendas neste período.'**
  String get semVendasPeriodo;

  /// No description provided for @numVendas.
  ///
  /// In pt, this message translates to:
  /// **'{n} venda(s)'**
  String numVendas(int n);

  /// No description provided for @comissaoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Comissão: {valor} €'**
  String comissaoLabel(String valor);

  /// No description provided for @diasEmStock.
  ///
  /// In pt, this message translates to:
  /// **'{dias} dias em stock'**
  String diasEmStock(int dias);

  /// No description provided for @movimento.
  ///
  /// In pt, this message translates to:
  /// **'Movimento'**
  String get movimento;

  /// No description provided for @subscricaoAvisoExpira.
  ///
  /// In pt, this message translates to:
  /// **'A subscrição do stand termina em {dias} dias.'**
  String subscricaoAvisoExpira(int dias);

  /// No description provided for @subscricaoAvisoCarencia.
  ///
  /// In pt, this message translates to:
  /// **'Subscrição vencida — {dias} dias de carência antes de bloquear o acesso.'**
  String subscricaoAvisoCarencia(int dias);

  /// No description provided for @atualizacaoObrigatoriaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Atualização necessária'**
  String get atualizacaoObrigatoriaTitulo;

  /// No description provided for @atualizacaoObrigatoriaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Esta versão da app já não é suportada. Atualiza para continuares a usar a PS CarStand.'**
  String get atualizacaoObrigatoriaTexto;

  /// No description provided for @atualizacaoObrigatoriaBotao.
  ///
  /// In pt, this message translates to:
  /// **'Ver instruções de atualização'**
  String get atualizacaoObrigatoriaBotao;

  /// No description provided for @atualizacaoRecomendadaAviso.
  ///
  /// In pt, this message translates to:
  /// **'Já há uma versão mais recente disponível ({versao}).'**
  String atualizacaoRecomendadaAviso(String versao);

  /// No description provided for @atualizacaoRecomendadaBotao.
  ///
  /// In pt, this message translates to:
  /// **'Ver novidades'**
  String get atualizacaoRecomendadaBotao;

  /// No description provided for @checklistTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Checklist de preparação'**
  String get checklistTitulo;

  /// No description provided for @checklistVazio.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem itens de checklist.'**
  String get checklistVazio;

  /// No description provided for @checklistAplicarModelo.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar modelo'**
  String get checklistAplicarModelo;

  /// No description provided for @checklistAdicionarItem.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item'**
  String get checklistAdicionarItem;

  /// No description provided for @checklistNovoItemTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Novo item'**
  String get checklistNovoItemTitulo;

  /// No description provided for @checklistNovoItemHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Lavagem exterior'**
  String get checklistNovoItemHint;

  /// No description provided for @checklistEscolherModeloTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Escolher modelo'**
  String get checklistEscolherModeloTitulo;

  /// No description provided for @checklistSemModelos.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não criaste nenhum modelo.'**
  String get checklistSemModelos;

  /// No description provided for @checklistCriarModelo.
  ///
  /// In pt, this message translates to:
  /// **'Criar modelo'**
  String get checklistCriarModelo;

  /// No description provided for @checklistNomeModelo.
  ///
  /// In pt, this message translates to:
  /// **'Nome do modelo'**
  String get checklistNomeModelo;

  /// No description provided for @checklistNomeModeloHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Checklist Diesel Standard'**
  String get checklistNomeModeloHint;

  /// No description provided for @checklistItensModelo.
  ///
  /// In pt, this message translates to:
  /// **'Itens'**
  String get checklistItensModelo;

  /// No description provided for @checklistAdicionarItemModelo.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar item'**
  String get checklistAdicionarItemModelo;

  /// No description provided for @fotosJaProntasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Fotos já cortadas e prontas?'**
  String get fotosJaProntasTitulo;

  /// No description provided for @fotosJaProntasSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sem fundo à volta, só o documento. Se sim, ficam guardadas como digitalização. Se não, só são usadas para preencher os dados.'**
  String get fotosJaProntasSubtitulo;

  /// No description provided for @legalTermosTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Serviço'**
  String get legalTermosTitulo;

  /// No description provided for @legalPrivacidadeTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get legalPrivacidadeTitulo;

  /// No description provided for @legalDpaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Acordo de Subcontratação de Dados'**
  String get legalDpaTitulo;

  /// No description provided for @legalProgresso.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{Falta 1 documento} other{Faltam {n} documentos}} para aceitar.'**
  String legalProgresso(int n);

  /// No description provided for @legalLiEAceito.
  ///
  /// In pt, this message translates to:
  /// **'Li e aceito.'**
  String get legalLiEAceito;

  /// No description provided for @legalAceitarEContinuar.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar e continuar'**
  String get legalAceitarEContinuar;

  /// No description provided for @trocarDeStandTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Trocar de stand'**
  String get trocarDeStandTitulo;

  /// No description provided for @trocarDeStandTexto.
  ///
  /// In pt, this message translates to:
  /// **'Isto esquece o token do stand guardado neste dispositivo — da próxima vez que abrires a app, vais ter de introduzir um token de novo. Continuar?'**
  String get trocarDeStandTexto;

  /// No description provided for @identidadeCaptureTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Documento do comprador'**
  String get identidadeCaptureTitulo;

  /// No description provided for @identidadeCaptureInstrucoes.
  ///
  /// In pt, this message translates to:
  /// **'Tira uma foto da frente e do verso do Cartão de Cidadão ou Título de Residência do comprador.'**
  String get identidadeCaptureInstrucoes;

  /// No description provided for @digitalizarDocumento.
  ///
  /// In pt, this message translates to:
  /// **'Digitalizar documento'**
  String get digitalizarDocumento;

  /// No description provided for @documentoTituloResidencia.
  ///
  /// In pt, this message translates to:
  /// **'Título de Residência'**
  String get documentoTituloResidencia;

  /// No description provided for @vendasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Vendas'**
  String get vendasTitulo;

  /// No description provided for @minhasVendasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'As minhas vendas'**
  String get minhasVendasTitulo;

  /// No description provided for @semVendasRegistadas.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há vendas registadas.'**
  String get semVendasRegistadas;

  /// No description provided for @statusDisponivel.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get statusDisponivel;

  /// No description provided for @statusReservado.
  ///
  /// In pt, this message translates to:
  /// **'Reservado'**
  String get statusReservado;

  /// No description provided for @statusVendido.
  ///
  /// In pt, this message translates to:
  /// **'Vendido'**
  String get statusVendido;

  /// No description provided for @statusPendenteAprovacao.
  ///
  /// In pt, this message translates to:
  /// **'Pendente de aprovação'**
  String get statusPendenteAprovacao;

  /// No description provided for @statusRejeitado.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitado'**
  String get statusRejeitado;

  /// No description provided for @navVeiculos.
  ///
  /// In pt, this message translates to:
  /// **'Veículos'**
  String get navVeiculos;

  /// No description provided for @navVendas.
  ///
  /// In pt, this message translates to:
  /// **'Vendas'**
  String get navVendas;

  /// No description provided for @navEquipa.
  ///
  /// In pt, this message translates to:
  /// **'Equipa'**
  String get navEquipa;

  /// No description provided for @navFinanceiro.
  ///
  /// In pt, this message translates to:
  /// **'Financeiro'**
  String get navFinanceiro;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
