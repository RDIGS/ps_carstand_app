import 'package:flutter/material.dart';

/// Paleta "Ficha Técnica" (secção 11) — nada de cream+terracota nem
/// dark+neon. Azul + âmbar evocam a faixa da matrícula europeia sem a
/// copiar literalmente; é elemento de assinatura, não decoração.
class AppColors {
  const AppColors._();

  static const grafiteAsfalto = Color(0xFF1E2430); // texto principal, cabeçalhos
  static const cinzaChapa = Color(0xFFF4F5F7); // fundo principal (legível ao sol)
  static const azulMatricula = Color(0xFF1D3F72); // cor primária de marca
  static const amberSinal = Color(0xFFE8A93B); // estado "reservado" + alertas suaves
  static const verdeDisponivel = Color(0xFF2F8F5B); // estado "disponivel"
  static const grafiteVendido = Color(0xFF6B7280); // estado "vendido" — neutro

  static Color paraEstado(String estado) {
    switch (estado) {
      case 'disponivel':
        return verdeDisponivel;
      case 'reservado':
        return amberSinal;
      case 'vendido':
        return grafiteVendido;
      case 'pendente_aprovacao':
        return azulMatricula;
      case 'rejeitado':
        return grafiteVendido;
      default:
        return grafiteVendido;
    }
  }
}
