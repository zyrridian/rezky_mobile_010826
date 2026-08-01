class ItemRemoteDataSource {
  Future<void> syncItem() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
