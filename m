From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 3 Mar 2011 13:05:42 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/clvmd/clvmd.c libd ...
Message-ID: <20110303130542.8237.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-03 13:05:41

Modified files:
	.              : WHATS_NEW_DM 
	daemons/clvmd  : clvmd.c 
	libdm          : libdm-common.c 

Log message:
	Lower severity of selabel_lookup and matchpathcon failure to log_debug.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.452&r2=1.453
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/WHATS_NEW_DM	2011/03/02 02:44:56	1.452
+++ LVM2/WHATS_NEW_DM	2011/03/03 13:05:40	1.453
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Lower severity of selabel_lookup and matchpathcon failure to log_debug.
   Accept multiple mapped device names on many dmsetup command lines.
   Fix dm_udev_wait calls in dmsetup to occur before readahead display not after.
   Include an implicit dm_task_update_nodes() within dm_udev_wait().
--- LVM2/daemons/clvmd/clvmd.c	2011/03/01 20:17:56	1.97
+++ LVM2/daemons/clvmd/clvmd.c	2011/03/03 13:05:40	1.98
@@ -432,7 +432,7 @@
 	if (!foreground_mode)
 		be_daemon(start_timeout);
 
-        dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
+        (void) dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
         old_mask = umask(0077);
         if (dm_create_dir(DEFAULT_RUN_DIR) == 0) {
                 DEBUGLOG("clvmd: unable to create %s directory\n",
--- LVM2/libdm/libdm-common.c	2011/03/02 08:40:28	1.112
+++ LVM2/libdm/libdm-common.c	2011/03/03 13:05:41	1.113
@@ -400,12 +400,14 @@
 	}
 
 	if (selabel_lookup(_selabel_handle, scontext, path, mode)) {
-		log_error("selabel_lookup failed: %s", strerror(errno));
+		log_debug("selabel_lookup failed for %s: %s",
+			  path, strerror(errno));
 		return 0;
 	}
 #else
 	if (matchpathcon(path, mode, scontext)) {
-		log_error("matchpathcon failed: %s", strerror(errno));
+		log_debug("matchpathcon failed for %s: %s",
+			  path, strerror(errno));
 		return 0;
 	}
 #endif


