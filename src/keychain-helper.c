#include <stdio.h>
#include <stdlib.h>
#include <Security/Security.h>

signed long key_exists(
  const char *service,
  const char *login,
  SecKeychainItemRef *item
) {
  void *buf;
  UInt32 len;

  signed long ret = SecKeychainFindGenericPassword(
    NULL, strlen(service), service, strlen(login), login, &len, &buf, item
  );

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
    if (key_exists(service, login, &item)) {
      SecKeychainItemDelete(item);
    }

    OSStatus createKey = SecKeychainAddGenericPassword(
      NULL, strlen(service), service, strlen(login), login, strlen(password),
      password, &item
    );

    if (createKey) {
      printf("Error %d", createKey);
      exit(1);
    }

  } else {
    OSStatus findKey = SecKeychainFindGenericPassword(
      NULL, strlen(service), service, strlen(login), login, &len, &buf, &item);

    if (findKey) {
      printf("Error %d", findKey);
      exit(1);
    }

    fwrite(buf, 1, len, stdout);
  }

  exit(0);
}
