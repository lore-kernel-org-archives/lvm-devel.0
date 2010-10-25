From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:36:10 -0000
Subject: LVM2/lib/misc crc.c
Message-ID: <20101025133610.26415.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:36:09

Modified files:
	lib/misc       : crc.c 

Log message:
	Fix constness warning
	
	Keep using const pointers.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/crc.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/lib/misc/crc.c	2010/09/27 19:10:46	1.8
+++ LVM2/lib/misc/crc.c	2010/10/25 13:36:09	1.9
@@ -59,8 +59,8 @@
 		0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
 		0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94, 0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d,
 	};
-	uint32_t *start = (uint32_t *) buf;
-	uint32_t *end = (uint32_t *) (buf + (size & 0xfffffffc));
+	const uint32_t *start = (const uint32_t *) buf;
+	const uint32_t *end = (const uint32_t *) (buf + (size & 0xfffffffc));
 	uint32_t crc = initial;
    
 	/* Process 4 bytes per iteration */
@@ -73,7 +73,7 @@
 	}
 
 	/* Process any bytes left over */
-	buf = (uint8_t *) start;
+	buf = (const uint8_t *) start;
 	size = size & 0x3;
 	while (size--) {
 		crc = crc ^ *buf++;


