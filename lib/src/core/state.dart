class State<Status, Error> {
  State({
    required this.status,
    required this.error,
    this.errorCode = 0,
  });

  Status status;
  Error error;
  int errorCode;
}
