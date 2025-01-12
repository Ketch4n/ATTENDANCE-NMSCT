String pageTitleValue(int type) {
  if (type == 0) {
    const value = "ADMIN-DASHBOARD";
    return value;
  } else if (type == 1) {
    const value = "ADMIN-PROFILE";
    return value;
  } else {
    const value = "Invalid Index";
    return value;
  }
}
