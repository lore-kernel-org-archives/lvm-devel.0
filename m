From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:22:54 -0000
Subject: LVM2/lib/cache lvmetad.h
Message-ID: <20120228182254.23593.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:22:52

Modified files:
	lib/cache      : lvmetad.h 

Log message:
	Bypass lvmetad fns when not configured to use lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/cache/lvmetad.h	2012/02/26 08:50:13	1.2
+++ LVM2/lib/cache/lvmetad.h	2012/02/28 18:22:52	1.3
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2012 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -19,6 +19,7 @@
 struct cmd_context;
 struct dm_config_tree;
 
+#ifdef LVMETAD_SUPPORT
 /*
  * Initialise the communication with lvmetad. Normally called by
  * lvmcache_init. Sets up a global handle for our process.
@@ -100,5 +101,22 @@
  */
 int pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv);
 
-#endif
+#  else		/* LVMETAD_SUPPORT */
+
+#    define lvmetad_init()	do { } while (0)
+#    define lvmetad_set_active(a)	do { } while (0)
+#    define lvmetad_active()	(0)
+#    define lvmetad_vg_update(vg)	(1)
+#    define lvmetad_vg_remove(vg)	(1)
+#    define lvmetad_pv_found(pvid, device, fmt, label_sector, vg)	(1)
+#    define lvmetad_pv_gone(device)	(1)
+#    define lvmetad_pv_list_to_lvmcache(cmd)	(1)
+#    define lvmetad_pv_lookup(cmd, pvid)	(0)
+#    define lvmetad_pv_lookup_by_devt(cmd, dev)	(0)
+#    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
+#    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
+#    define pvscan_lvmetad(cmd, argc, argv)	(0)
 
+#  endif	/* LVMETAD_SUPPORT */
+
+#endif


