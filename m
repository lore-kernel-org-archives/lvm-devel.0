From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Mar 2012 14:15:51 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20120305141551.13730.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-05 14:15:50

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Improve warning
	
	Use thin_dump --repair suggestion in log error message
	and use just warning on  deactivation path without repair info
	(since node has been deactivated).
	
	Also check whether there is not 16 args for thin_check configured.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2342&r2=1.2343
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.273&r2=1.274

--- LVM2/WHATS_NEW	2012/03/05 14:12:57	1.2342
+++ LVM2/WHATS_NEW	2012/03/05 14:15:50	1.2343
@@ -1,5 +1,6 @@
 Version 2.02.95 -
 ================================
+  Print just warning on thin pool check callback path for failing check.
   Use 64bit math for verification of thin pool and snapshot chunk size.
   Validate udev structures in _insert_udev_dir().
   Scan all devices for lvmetad if 'pvscan --cache' used without device list.
--- LVM2/lib/activate/dev_manager.c	2012/03/02 21:49:44	1.273
+++ LVM2/lib/activate/dev_manager.c	2012/03/05 14:15:50	1.274
@@ -1231,15 +1231,28 @@
 	}
 
 	args = dm_split_words(split, 16, 0, argv);
+
+	if (args == 16) {
+		log_error("Too many options for thin check command.");
+		return 0;
+	}
 	argv[args++] = meta_path;
 	argv[args] = NULL;
 
 	if (!(ret = exec_cmd(data->pool_lv->vg->cmd, (const char * const *)argv,
 			     &status, 0))) {
-		log_err_once("Check of thin pool %s/%s failed (status:%d). "
-			     "Manual repair required (thin_repair %s)!",
-			     data->pool_lv->vg->name, data->pool_lv->name,
-			     status, meta_path);
+		switch (type) {
+		case DM_NODE_CALLBACK_PRELOADED:
+			log_err_once("Check of thin pool %s/%s failed (status:%d). "
+				     "Manual repair required (thin_dump --repair %s)!",
+				     data->pool_lv->vg->name, data->pool_lv->name,
+				     status, meta_path);
+			break;
+		default:
+			log_warn("WARNING: Integrity check of metadata for thin pool "
+				 "%s/%s failed.",
+				 data->pool_lv->vg->name, data->pool_lv->name);
+		}
 		/*
 		 * FIXME: What should we do here??
 		 *


