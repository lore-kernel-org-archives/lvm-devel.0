From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 18:09:53 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20091209180953.24797.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 18:09:53

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Remove newly created log volume if initial deactivation fails.
	
	If there is problem deactivate LV and
	_init_mirror_log is called with remove_on_failure = 1,
	remove the newly created log LV from metadata.
	
	(This can happen if there is active device with the same name
	but different UUID.)
	
	The main reason for this "workaround" patch is to
	- do not keep _mlog volume in metadata, so user can repeat the action
	- print better error message describing the real problem
	
	# lvcreate -m 2 -n lv1 -l 1 --nosync vg_bar
	WARNING: New mirror won't be synchronised. Don't read what you didn't write!
	/dev/vg_bar/lv1_mlog: not found: device not cleared
	Aborting. Failed to wipe mirror log.
	Error locking on node bar-01: Input/output error
	Unable to deactivate mirror log LV. Manual intervention required.
	Failed to create mirror log.
	
	# lvcreate -m 2 -n lv1 -l 1 --nosync vg_bar
	WARNING: New mirror won't be synchronised. Don't read what you didn't write!
	Aborting. Unable to deactivate mirror log.
	Failed to initialise mirror log.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1342&r2=1.1343
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW	2009/12/04 14:26:22	1.1342
+++ LVM2/WHATS_NEW	2009/12/09 18:09:52	1.1343
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Remove log volume from metadata if initial deactivation fails.
   Give better error message for pvmove when all data is skipped.
   Fix memory lock imbalance in lv_suspend if already suspended.
   Fix pvmove test mode to not fail and do not poll.
--- LVM2/lib/metadata/mirror.c	2009/11/24 22:55:56	1.96
+++ LVM2/lib/metadata/mirror.c	2009/12/09 18:09:52	1.97
@@ -255,8 +255,16 @@
 
 	/* If the LV is active, deactivate it first. */
 	if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
-		if (!deactivate_lv(cmd, log_lv))
-			return_0;
+		(void)deactivate_lv(cmd, log_lv);
+		/*
+		 * FIXME: workaround to fail early
+		 * Ensure that log is really deactivated because deactivate_lv
+		 * on cluster do not fail if there is log_lv with different UUID.
+		 */
+		if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
+			log_error("Aborting. Unable to deactivate mirror log.");
+			goto revert_new_lv;
+		}
 		was_active = 1;
 	}
 
@@ -1354,7 +1362,7 @@
 	}
 
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
-		log_error("Failed to create mirror log.");
+		log_error("Failed to initialise mirror log.");
 		return NULL;
 	}
 


