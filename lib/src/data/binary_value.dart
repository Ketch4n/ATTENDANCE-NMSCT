String userBinaryValue(int value) {
  if (value == 0) {
    const value = "Super-Admin";
    return value;
  } else if (value == 1) {
    const value = "OJT-Coordinator";
    return value;
  } else if (value == 2) {
    const value = "OJT-Student";
    return value;
  } else {
    const value = "Invalid User";
    return value;
  }
}

String statusBinaryValue(int value) {
  if (value == 0) {
    // NO FACE DATA
    const value = "Inactive";
    return value;
  } else if (value == 1) {
    const value = "Active";
    return value;
  } else if (value == 2) {
    const value = "Archived";
    return value;
  } else {
    const value = "Undefined Status";
    return value;
  }
}
