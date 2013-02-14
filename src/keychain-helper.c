#include <stdio.h>
#include <stdlib.h>
#include <Security/Security.h>

int main(int argc, char **argv) {
  const char *service = argv[1];
  const char *login   = argv[2];

  if (!(argv[1] && argv[2])) {
    printf("Usage: %s <service> <account>\n", argv[0]);
    exit(1);
  }

  void *buf;
  UInt32 len;
  SecKeychainItemRef item;

  int ret = SecKeychainFindGenericPassword(
    NULL, strlen(service), service, strlen(login), login, &len, &buf, &item);

  if (ret) {
    exit(1);
  }

  fwrite(buf, 1, len, stdout);
  exit(0);
}
