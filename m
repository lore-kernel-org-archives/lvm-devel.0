From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 30 Nov 2011 02:20:14 -0000
Subject: LVM2/lib/metadata metadata-exported.h
Message-ID: <20111130022014.9534.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-11-30 02:20:14

Modified files:
	lib/metadata   : metadata-exported.h 

Log message:
	The LV_REBUILD flag is not internal - bad comments in metadata-exported.h updated

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.223&r2=1.224

--- LVM2/lib/metadata/metadata-exported.h	2011/11/30 02:02:11	1.223
+++ LVM2/lib/metadata/metadata-exported.h	2011/11/30 02:20:13	1.224
@@ -63,7 +63,7 @@
 #define MIRROR_IMAGE		UINT64_C(0x00040000)	/* LV */
 
 #define LV_NOTSYNCED		UINT64_C(0x00080000)	/* LV */
-#define LV_REBUILD		UINT64_C(0x00100000)	/* LV - internal use only */
+#define LV_REBUILD		UINT64_C(0x00100000)	/* LV */
 //#define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
 #define CONVERTING		UINT64_C(0x00400000)	/* LV */
 


