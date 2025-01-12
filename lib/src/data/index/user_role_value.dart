String userRoleValue(int type) {
  if (type == 1) {
    const value = "SUPER-ADMIN";
    return value;
  } else if (type == 2) {
    const value = "ADMINISTRATOR";
    return value;
  } else if (type == 3) {
    const value = "FACULTY";
    return value;
  } else {
    const value = "Invalid User type";
    return value;
  }
}
