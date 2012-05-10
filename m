From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 10 May 2012 10:37:49 -0000
Subject: LVM2/lib/metadata metadata-exported.h
Message-ID: <20120510103749.10345.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-05-10 10:37:49

Modified files:
	lib/metadata   : metadata-exported.h 

Log message:
	Comment on auxiliary metadata areas.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.232&r2=1.233

--- LVM2/lib/metadata/metadata-exported.h	2012/02/23 13:11:09	1.232
+++ LVM2/lib/metadata/metadata-exported.h	2012/05/10 10:37:49	1.233
@@ -208,8 +208,11 @@
 /* Include any existing PV mdas during format_instance initialisation */
 #define FMT_INSTANCE_MDAS		0x00000002U
 
-/* FIXME Define auxiliary here! */
-/* Include any auxiliary mdas during format_instance intialisation */
+/*
+ * Include any auxiliary mdas during format_instance intialisation.
+ * Currently, this includes metadata areas as defined by
+ * metadata/dirs and metadata/raws setting.
+ */
 #define FMT_INSTANCE_AUX_MDAS		0x00000004U
 
 /* Include any other format-specific mdas during format_instance initialisation */


