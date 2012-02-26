From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 26 Feb 2012 08:50:14 -0000
Subject: LVM2/lib/cache lvmetad.h
Message-ID: <20120226085014.14272.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-26 08:50:14

Modified files:
	lib/cache      : lvmetad.h 

Log message:
	A bit of documentation for lvmetad_vg_lookup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/cache/lvmetad.h	2012/02/23 13:11:08	1.1
+++ LVM2/lib/cache/lvmetad.h	2012/02/26 08:50:13	1.2
@@ -87,7 +87,12 @@
  */
 int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd);
 
-struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgname, const char *vgid);
+/*
+ * Find a VG by its ID or its name in the lvmetad cache. Gives NULL if the VG is
+ * not found.
+ */
+struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
+				       const char *vgname, const char *vgid);
 
 /*
  * Scan a single device and update lvmetad with the result(s). If the device


