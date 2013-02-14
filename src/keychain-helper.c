#include <stdio.h>
#include <stdlib.h>
#include <Security/Security.h>

int key_exists_p(
  const char *service,
  const char *login,
  SecKeychainItemRef *item
) {
  void *buf;
  UInt32 len;

  OSStatus ret = SecKeychainFindGenericPassword(
    NULL, strlen(service), service, strlen(login), login, &len, &buf, item
  );

  if (ret == 0) {
    return 0;
  } else {
    fprintf(stderr, "Boxen Keychain Helper: Encountered error code: %d\n", ret);
    return ret;
  }
}

int main(int argc, char **argv) {
  if ((argc < 2) || (argc > 3)) {
    printf("Usage: %s <service> <account> [<password>]\n", argv[0]);
    exit(1);
  }

  const char *service  = argv[1];
  const char *login    = argv[2];
  char *password       = NULL;

  if (argc == 3) {
    password = argv[3];
  }

  void *buf;
  UInt32 len;
  SecKeychainItemRef item;

  if (password != NULL) {
    if (key_exists_p(service, login, &item) == 0) {
      SecKeychainItemDelete(item);
    }

    OSStatus create_key = SecKeychainAddGenericPassword(
      NULL, strlen(service), service, strlen(login), login, strlen(password),
      password, &item
    );

    if (create_key != 0) {
      fprintf(stderr, "Boxen Keychain Helper: Encountered error code: %d\n", create_key);
      return 1;
    }

  } else {
    OSStatus find_key = SecKeychainFindGenericPassword(
      NULL, strlen(service), service, strlen(login), login, &len, &buf, &item);

    if (find_key != 0) {
      fprintf(stderr, "Boxen Keychain Helper: Encountered error code: %d\n", find_key);
      return 1;
    }

    fwrite(buf, 1, len, stdout);
  }

  return 0;
}
