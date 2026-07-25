import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Conteúdo final do banner, já confirmado pelo utilizador — puramente
/// visual, sem ligação de volta aos dados do veículo (o utilizador pode ter
/// editado qualquer campo antes de gerar).
class BannerContent {
  const BannerContent({
    required this.titulo,
    required this.subtitulo,
    required this.potencia,
    required this.ano,
    required this.combustivel,
    required this.preco,
    required this.prestacao,
    required this.social,
    required this.contacto,
    required this.corDestaque,
    required this.foto,
  });

  final String titulo;
  final String subtitulo;
  final String potencia;
  final String ano;
  final String combustivel;
  final String preco;
  final String prestacao;
  final String social;
  final String contacto;
  final Color corDestaque;

  /// Bytes da foto escolhida pelo utilizador, ou da imagem-placeholder de
  /// exemplo (assets/images/banner_placeholder.jpg) se ainda não carregou
  /// nenhuma — nunca fica sem imagem de fundo.
  final Uint8List? foto;
}
