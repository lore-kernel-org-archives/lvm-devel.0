From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 10 May 2012 11:03:08 -0000
Subject: LVM2/lib/metadata metadata-exported.h
Message-ID: <20120510110308.14954.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-05-10 11:03:08

Modified files:
	lib/metadata   : metadata-exported.h 

Log message:
	More comments on metadata area types.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.233&r2=1.234

--- LVM2/lib/metadata/metadata-exported.h	2012/05/10 10:37:49	1.233
+++ LVM2/lib/metadata/metadata-exported.h	2012/05/10 11:03:07	1.234
@@ -205,7 +205,7 @@
  * area information we are working with.
  */
 
-/* Include any existing PV mdas during format_instance initialisation */
+/* Include any existing PV ("on-disk") mdas during format_instance initialisation. */
 #define FMT_INSTANCE_MDAS		0x00000002U
 
 /*
@@ -215,7 +215,10 @@
  */
 #define FMT_INSTANCE_AUX_MDAS		0x00000004U
 
-/* Include any other format-specific mdas during format_instance initialisation */
+/*
+ * Include any other format-specific mdas during format_instance initialisation.
+ * For example metadata areas used during backup/restore/archive handling.
+ */
 #define FMT_INSTANCE_PRIVATE_MDAS	0x00000008U
 
 struct format_instance {


