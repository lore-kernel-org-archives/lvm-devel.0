From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jun 2011 14:30:59 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/f ...
Message-ID: <20110617143059.11769.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-17 14:30:58

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/format_text: flags.c 
	lib/metadata   : metadata-exported.h metadata.h 

Log message:
	Remove unused internal flag ACTIVATE_EXCL from the code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2020&r2=1.2021
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.201&r2=1.202
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.193&r2=1.194
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.245&r2=1.246

--- LVM2/WHATS_NEW	2011/06/17 14:27:34	1.2020
+++ LVM2/WHATS_NEW	2011/06/17 14:30:58	1.2021
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Remove unused internal flag ACTIVATE_EXCL from the code.
   Remove useless test of ACTIVATE_EXCL in lv_add_mirrors() clustered code path.
   Use lv_activate_opts struct instead of MERGING status flag.
   Use lv_activate_opts struct instead of ACTIVATE_EXCL status flag.
--- LVM2/lib/activate/activate.c	2011/06/17 14:24:18	1.201
+++ LVM2/lib/activate/activate.c	2011/06/17 14:30:58	1.202
@@ -1293,14 +1293,6 @@
 		goto out;
 	}
 
-	/*
-	 * When targets are activated exclusively in a cluster, the
-	 * non-clustered target should be used.  This only happens
-	 * if ACTIVATE_EXCL is set in lv->status.
-	 */
-	if (laopts->exclusive)
-		lv->status |= ACTIVATE_EXCL;
-
 	if (!_lv_activate_lv(lv, laopts))
 		goto_out;
 
--- LVM2/lib/format_text/flags.c	2011/03/29 12:51:57	1.44
+++ LVM2/lib/format_text/flags.c	2011/06/17 14:30:58	1.45
@@ -62,7 +62,6 @@
 	{VIRTUAL, NULL, 0},
 	{SNAPSHOT, NULL, 0},
 	{MERGING, NULL, 0},
-	{ACTIVATE_EXCL, NULL, 0},
 	{CONVERTING, NULL, 0},
 	{PARTIAL_LV, NULL, 0},
 	{POSTORDER_FLAG, NULL, 0},
--- LVM2/lib/metadata/metadata-exported.h	2011/06/11 00:03:07	1.193
+++ LVM2/lib/metadata/metadata-exported.h	2011/06/17 14:30:58	1.194
@@ -62,7 +62,6 @@
 #define MIRROR_LOG		0x00020000U	/* LV */
 #define MIRROR_IMAGE		0x00040000U	/* LV */
 #define LV_NOTSYNCED		0x00080000U	/* LV */
-//#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 //#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 #define CONVERTING		0x00400000U	/* LV */
 
--- LVM2/lib/metadata/metadata.h	2011/06/15 17:45:03	1.245
+++ LVM2/lib/metadata/metadata.h	2011/06/17 14:30:58	1.246
@@ -71,7 +71,6 @@
 //#define MIRROR_LOG		0x00020000U	/* LV */
 //#define MIRROR_IMAGE		0x00040000U	/* LV */
 //#define MIRROR_NOTSYNCED	0x00080000U	/* LV */
-#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 #define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 //#define CONVERTING		0x00400000U	/* LV */
 


