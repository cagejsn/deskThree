// Copyright MyScript. All rights reserved.

#ifndef MYCERTIFICATE_H
#define MYCERTIFICATE_H 0x01000000

#include <stddef.h>

#ifndef VO_CERTIFICATE_TYPE
#define VO_CERTIFICATE_TYPE

/**
 * Holds a certificate.
 */
typedef struct _voCertificate
{
  /**
   * Pointer to the bytes composing the certificate.
   */
  const char* bytes;

  /**
   * Length of the certificate.
   */
  size_t length;
}
voCertificate;

#endif // end of: #ifndef VO_CERTIFICATE_TYPE

#ifdef __cplusplus
extern "C"
#else
extern
#endif
/**
 * Certificate that grants your application the right to use MyScript.
 * Usage:
 * <pre>
 *   voEngine e = voCreateEngine(VO_MSE_VER, &myCertificate, NULL);
 * </pre>
 */
voCertificate myCertificate;


#endif // end of: #ifndef MYCERTIFICATE_H
