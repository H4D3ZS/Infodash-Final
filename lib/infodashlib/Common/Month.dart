class Month {
  List months = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december'
  ];

  String GetMonth(int monthNumber) {
    return months[monthNumber - 1];
  }
}
