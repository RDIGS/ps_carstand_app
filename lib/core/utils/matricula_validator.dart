// Espelha src/common/utils/matricula.util.ts do backend — cobre o formato
// atual e anteriores a 2020 (3 blocos de 2, letras ou números).
final RegExp matriculaRegex = RegExp(r'^[A-Z0-9]{2}-[A-Z0-9]{2}-[A-Z0-9]{2}$');

bool isValidMatricula(String matricula) => matriculaRegex.hasMatch(matricula);
