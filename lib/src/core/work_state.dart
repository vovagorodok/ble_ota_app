class WorkState<Status, Error> {
  WorkState({
    required this.status,
    required this.error,
    this.errorCode = 0,
  });

  Status status;
  Error error;
  int errorCode;
}

enum WorkStatus {
  idle,
  working,
  success,
  error,
}
