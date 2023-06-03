class VaccinatedInfo {
  late DateTime _asOfDate;
  late int _firstDose;
  late int _secondDose;
  late int _totalPopulation;

  int get totalPopulation => _totalPopulation;

  set totalPopulation(int totalPopulation) {
    _totalPopulation = totalPopulation;
  }

  int get secondDose => _secondDose;

  set secondDose(int secondDose) {
    _secondDose = secondDose;
  }

  int get firstDose => _firstDose;

  set firstDose(int firstDose) {
    _firstDose = firstDose;
  }

  DateTime get asOfDate => _asOfDate;

  set asOfDate(DateTime asOfDate) {
    _asOfDate = asOfDate;
  }
}
