From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 21:35:01 -0000
Subject: LVM2/tools vgchange.c
Message-ID: <20100628213501.9852.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 21:35:00

Modified files:
	tools          : vgchange.c 

Log message:
	Fix compile warning in vgchange.c regarding mda_copies initialization.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/tools/vgchange.c	2010/06/28 20:37:37	1.106
+++ LVM2/tools/vgchange.c	2010/06/28 21:35:00	1.107
@@ -528,7 +528,7 @@
 static int _vgchange_metadata_copies(struct cmd_context *cmd,
 				     struct volume_group *vg)
 {
-	uint32_t mda_copies;
+	uint32_t mda_copies = DEFAULT_VGMETADATACOPIES;
 
 	if (arg_count(cmd, vgmetadatacopies_ARG))
 		mda_copies = arg_uint_value(cmd, vgmetadatacopies_ARG,


