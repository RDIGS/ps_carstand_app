class Lead {
  Lead({
    required this.id,
    required this.nome,
    required this.estado,
    required this.criadoEm,
    this.vehicleId,
    this.telefone,
    this.email,
    this.origem,
    this.notas,
    this.proximoContacto,
  });

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: json['id'] as String,
        nome: json['nome'] as String,
        estado: json['estado'] as String,
        criadoEm: json['criado_em'] as String,
        vehicleId: json['vehicle_id'] as String?,
        telefone: json['telefone'] as String?,
        email: json['email'] as String?,
        origem: json['origem'] as String?,
        notas: json['notas'] as String?,
        proximoContacto: json['proximo_contacto'] as String?,
      );

  final String id;
  final String nome;
  final String estado;
  final String criadoEm;
  final String? vehicleId;
  final String? telefone;
  final String? email;
  final String? origem;
  final String? notas;
  final String? proximoContacto;
}

const leadOrigens = ['telefone', 'whatsapp', 'presencial', 'standvirtual', 'olx', 'custojusto', 'outro'];
const leadEstados = ['novo', 'contactado', 'agendado', 'convertido', 'perdido'];
