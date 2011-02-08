From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2011 12:41:09 -0000
Subject: LVM2 ./WHATS_NEW lib/misc/crc.c
Message-ID: <20110208124109.12853.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-08 12:41:08

Modified files:
	.              : WHATS_NEW 
	lib/misc       : crc.c 

Log message:
	Fix CRC32 calculation on big endian CPU
	
	Fix regresion from 2.02.75 speedup - so currently crc32 is a little bit
	more complicated on big-endian CPU as the uint32_t needs to be shifted
	on here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1908&r2=1.1909
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/crc.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2011/02/04 22:46:18	1.1908
+++ LVM2/WHATS_NEW	2011/02/08 12:41:08	1.1909
@@ -1,5 +1,6 @@
 Version 2.02.84 - 
 ===================================
+  Fix CRC32 calculation on big endian CPU (2.02.75).
 
 Version 2.02.83 - 4th February 2011
 ===================================
--- LVM2/lib/misc/crc.c	2010/10/25 13:36:09	1.9
+++ LVM2/lib/misc/crc.c	2011/02/08 12:41:08	1.10
@@ -16,6 +16,7 @@
 #include "lib.h"
 
 #include "crc.h"
+#include "xlate.h"
 
 /* Calculate an endian-independent CRC of supplied buffer */
 #ifndef DEBUG_CRC32
@@ -65,7 +66,7 @@
    
 	/* Process 4 bytes per iteration */
 	while (start < end) {
-		crc = crc ^ *start++;
+		crc = crc ^ xlate32(*start++);
 		crc = crctab[crc & 0xff] ^ crc >> 8;
 		crc = crctab[crc & 0xff] ^ crc >> 8;
 		crc = crctab[crc & 0xff] ^ crc >> 8;


