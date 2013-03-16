From: Mikulas Patocka <mpatocka@redhat.com>
Date: Sat, 16 Mar 2013 12:22:23 -0400 (EDT)
Subject: [PATCH] libdevmapper.h: make this include file standard-compliant
Message-ID: <Pine.LNX.4.64.1303161221480.4777@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

libdevmapper.h: make this include file standard-compliant

This file may be included by other programs, so it should be compliant
with the C standard.

* use __linux__ instead of linux - __linux__ is always defined, linux is
  not defined when gcc runs in standard-compliant mode (with -std=c89 or
  -std=c99) because the C standard doesn't allow polluting namespace
  with arbitrary defines.

* the inline keyword is not present in the c89 standard (with gcc
  -std=c89). If the compiler runs in c89 mode, use __inline__ (which is
  gcc extension), or nothing at all if we don't use gcc.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 libdm/libdevmapper.h |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

Index: LVM2.2.02.98/libdm/libdevmapper.h
===================================================================
--- LVM2.2.02.98.orig/libdm/libdevmapper.h	2013-03-16 02:10:56.000000000 +0100
+++ LVM2.2.02.98/libdm/libdevmapper.h	2013-03-16 02:20:51.000000000 +0100
@@ -21,7 +21,7 @@
 #include <sys/types.h>
 #include <sys/stat.h>
 
-#ifdef linux
+#ifdef __linux__
 #  include <linux/types.h>
 #endif
 
@@ -940,7 +940,13 @@ int dm_bit_get_next(dm_bitset_t bs, int 
    memcpy((bs1) + 1, (bs2) + 1, ((*(bs1) / DM_BITS_PER_INT) + 1) * sizeof(int))
 
 /* Returns number of set bits */
-static inline unsigned hweight32(uint32_t i)
+static
+#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901
+inline
+#elif defined(__GNUC__)
+__inline__
+#endif
+unsigned hweight32(uint32_t i)
 {
 	unsigned r = (i & 0x55555555) + ((i >> 1) & 0x55555555);
 


