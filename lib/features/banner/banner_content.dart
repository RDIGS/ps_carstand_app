import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'templates/banner_template.dart';

/// Conteúdo final do banner, já confirmado pelo utilizador — puramente
/// visual, sem ligação de volta aos dados do veículo (o utilizador pode ter
/// editado qualquer campo antes de gerar).
class BannerContent {
  const BannerContent({
    required this.templateId,
    required this.titulo,
    required this.subtitulo,
    required this.potencia,
    required this.ano,
    required this.combustivel,
    required this.kms,
    required this.preco,
    required this.prestacao,
    required this.social,
    required this.contacto,
    required this.corDestaque,
    required this.foto,
    this.fotosGaleria = const [],
    this.logo,
  });

  final BannerTemplateId templateId;
  final String titulo;
  final String subtitulo;
  final String potencia;
  final String ano;
  final String combustivel;
  final String kms;
  final String preco;
  final String prestacao;
  final String social;
  final String contacto;
  final Color corDestaque;

  /// Bytes da foto escolhida pelo utilizador — enquanto for `null`, os
  /// templates mostram um placeholder desenhado na app (nunca uma foto de
  /// stock): "Gerar" continua bloqueado até haver foto real.
  final Uint8List? foto;

  /// Fotos adicionais (grelha), só usadas pelo template "Galeria de Fotos" —
  /// vêm da galeria já guardada do veículo, não de uma escolha nova
  /// (ao contrário de `foto`). Ordem = ordem de exibição na grelha.
  final List<Uint8List> fotosGaleria;

  /// Logótipo do stand — só desenhado se não for `null` E o utilizador tiver
  /// deixado o interruptor "incluir logótipo" ligado no formulário (pedido
  /// do utilizador, 2026-09-07).
  final Uint8List? logo;
}
