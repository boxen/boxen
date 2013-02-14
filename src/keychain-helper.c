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

  if (ret) {
    fprintf(stderr, "Encountered error code: %d\n", ret);
  }

  return (ret == 0);
}

int main(int argc, char **argv) {
  const char *service  = argv[1];
  const char *login    = argv[2];
  const char *password = argv[3];

  if (!(service && login)) {
    printf("Usage: %s <service> <account> [<password>]\n", argv[0]);
    exit(1);
  }

  void *buf;
  UInt32 len;
  SecKeychainItemRef item;

  if (password) {
    if (key_exists_p(service, login, &item)) {
      SecKeychainItemDelete(item);
    }

    OSStatus create_key = SecKeychainAddGenericPassword(
      NULL, strlen(service), service, strlen(login), login, strlen(password),
      password, &item
    );

    if (create_key) {
      fprintf(stderr, "Encountered error code: %d\n", create_key);
      exit(1);
    }

  } else {
    OSStatus find_key = SecKeychainFindGenericPassword(
      NULL, strlen(service), service, strlen(login), login, &len, &buf, &item);

    if (find_key) {
      fprintf(stderr, "Encountered error code: %d\n", find_key);
      exit(1);
    }

    fwrite(buf, 1, len, stdout);
  }

  exit(0);
}
