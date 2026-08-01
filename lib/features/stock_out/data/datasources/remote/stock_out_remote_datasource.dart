class StockOutRemoteDataSource {
  Future<void> syncStockOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
