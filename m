From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Mar 2009 16:25:37 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20090305162537.31662.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-03-05 16:25:36

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Fix possible increasing in memory allocation if refreshing_context
	(for example when CLVMD_CMD_LOCK_VG for is called during vgscan).
	
	If clvmd calls LV lock, it calls
	/* clean the pool for another command */
	dm_pool_empty(cmd->mem);
	to clean up memory pool after command.
	
	Unfortunately, do_refresh_cache() do not call this
	and because during it operation it allocates some memory,
	the pool increases.
	
	Also do_refresh_cache should use lvm_lock
	(it manipulates with lvm internal data).
	
	The same applies for lvm_backup command.
	
	Signed-off-by: Milan Broz <mbroz@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1061&r2=1.1062
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2009/03/03 18:25:05	1.1061
+++ LVM2/WHATS_NEW	2009/03/05 16:25:35	1.1062
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Flush memory pool and fix locking in clvmd refresh and backup command.
 
 Version 2.02.45 - 3rd March 2009
 ================================
--- LVM2/daemons/clvmd/lvm-functions.c	2009/02/22 21:14:38	1.57
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/03/05 16:25:36	1.58
@@ -406,16 +406,15 @@
 	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 		 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
-	pthread_mutex_lock(&lvm_lock);
 	if (!cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (do_refresh_cache()) {
 			log_error("Updated config file invalid. Aborting.");
-			pthread_mutex_unlock(&lvm_lock);
 			return EINVAL;
 		}
 	}
 
+	pthread_mutex_lock(&lvm_lock);
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(1);
 
@@ -538,9 +537,14 @@
 	DEBUGLOG("Refreshing context\n");
 	log_notice("Refreshing context");
 
+	pthread_mutex_lock(&lvm_lock);
+
 	ret = refresh_toolcontext(cmd);
 	init_full_scan_done(0);
 	lvmcache_label_scan(cmd, 2);
+	dm_pool_empty(cmd->mem);
+
+	pthread_mutex_unlock(&lvm_lock);
 
 	return ret==1?0:-1;
 }
@@ -711,14 +715,18 @@
 
 	DEBUGLOG("Triggering backup of VG metadata for %s. suspended=%d\n", vgname, suspended);
 
+	pthread_mutex_lock(&lvm_lock);
+
 	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, &consistent);
-	if (vg) {
-		if (consistent)
-			check_current_backup(vg);
-	}
-	else {
+
+	if (vg && consistent)
+		check_current_backup(vg);
+	else
 		log_error("Error backing up metadata, can't find VG for group %s", vgname);
-	}
+
+	dm_pool_empty(cmd->mem);
+
+	pthread_mutex_unlock(&lvm_lock);
 }
 
 /* Called to initialise the LVM context of the daemon */


