class FinancialSummary {
  final double totalPemasukan;
  final double totalPengeluaran;
  final double saldoAkhir;

  FinancialSummary({
    required this.totalPemasukan,
    required this.totalPengeluaran,
    required this.saldoAkhir,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalPemasukan: (json['total_pemasukan'] as num?)?.toDouble() ?? 0.0,
      totalPengeluaran: (json['total_pengeluaran'] as num?)?.toDouble() ?? 0.0,
      saldoAkhir: (json['saldo_akhir'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
