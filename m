From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 1 Mar 2012 20:04:44 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120301200444.3083.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-03-01 20:04:44

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	Use 64 bit integers for device size & label sector in _pv_populate_lvmcache in
	lvmetad client code. Fixes RHBZ 798267.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/lib/cache/lvmetad.c	2012/02/29 02:35:35	1.10
+++ LVM2/lib/cache/lvmetad.c	2012/03/01 20:04:44	1.11
@@ -85,8 +85,8 @@
 		   *vgname = dm_config_find_str(cn->child, "vgname", NULL),
 		   *fmt_name = dm_config_find_str(cn->child, "format", NULL);
 	dev_t devt = dm_config_find_int(cn->child, "device", 0);
-	uint64_t devsize = dm_config_find_int(cn->child, "dev_size", 0),
-		 label_sector = dm_config_find_int(cn->child, "label_sector", 0);
+	uint64_t devsize = dm_config_find_int64(cn->child, "dev_size", 0),
+		 label_sector = dm_config_find_int64(cn->child, "label_sector", 0);
 
 	struct format_type *fmt = fmt_name ? get_format_by_name(cmd, fmt_name) : NULL;
 


