#include <stdio.h>
#include <stdlib.h>
#include <Security/Security.h>
#include <CoreFoundation/CFString.h>

#define REPORT_KEYCHAIN_ERROR(err_val)  do { \
fprintf(stderr, "Boxen Keychain Helper: Encountered error code: %d\n", err_val); \
fprintf(stderr, "Error: %s\n", CFStringGetCStringPtr(SecCopyErrorMessageString(err_val, NULL), kCFStringEncodingMacRoman)); \
} while(0)

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

  if (ret == errSecSuccess) {
    return 0;
  } else {
    if (ret != errSecItemNotFound) {
       // Item not found is not an error in predicate method context.
       REPORT_KEYCHAIN_ERROR(ret);
    }
    return ret;
  }
}

int main(int argc, char **argv) {
  if ((argc < 3) || (argc > 4)) {
    printf("Usage: %s <service> <account> [<password>]\n", argv[0]);
    return 1;
  }

  const char *service  = argv[1];
  const char *login    = argv[2];
  const char *password = argc == 4 ? argv[3] : NULL;

  void *buf;
  UInt32 len;
  SecKeychainItemRef item;

  if (password != NULL && strlen(password) != 0) {
    if (key_exists_p(service, login, &item) == 0) {
      SecKeychainItemDelete(item);
    }

    OSStatus create_key = SecKeychainAddGenericPassword(
      NULL, strlen(service), service, strlen(login), login, strlen(password),
      password, &item
    );

    if (create_key != 0) {
      REPORT_KEYCHAIN_ERROR(create_key);
      return 1;
    }
  } else if (password != NULL && strlen(password) == 0) {
    if (key_exists_p(service, login, &item) == 0) {
      OSStatus ret = SecKeychainItemDelete(item);
      if (ret != errSecSuccess) {
        REPORT_KEYCHAIN_ERROR(ret);
      }
    }
  } else {
    OSStatus find_key = SecKeychainFindGenericPassword(
      NULL, strlen(service), service, strlen(login), login, &len, &buf, &item);

    if (find_key == errSecItemNotFound) {
      return find_key;
    }
    if (find_key != 0) {
      REPORT_KEYCHAIN_ERROR(find_key);
      return 1;
    }

    fwrite(buf, 1, len, stdout);
  }

  return 0;
}
