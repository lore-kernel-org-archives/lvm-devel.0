From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Nov 2007 21:16:22 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/cluster_locking.c ...
Message-ID: <20071116211622.18370.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-16 21:16:21

Modified files:
	.              : WHATS_NEW 
	lib/locking    : cluster_locking.c file_locking.c locking.c 
	tools          : pvresize.c toollib.c 

Log message:
	Decode cluster locking state in log message. (untested)
	Change file locking state messages from debug to very verbose.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.738&r2=1.739
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/WHATS_NEW	2007/11/15 21:59:10	1.738
+++ LVM2/WHATS_NEW	2007/11/16 21:16:20	1.739
@@ -1,5 +1,7 @@
 Version 2.02.29 -
 ==================================
+  Decode cluster locking state in log message.
+  Change file locking state messages from debug to very verbose.
   Fix --addtag to drop @ prefix from name.
   Stop clvmd going haywire if a pre_function fails.
   Convert some vg_reads into vg_lock_and_reads.
--- LVM2/lib/locking/cluster_locking.c	2007/08/23 15:43:19	1.21
+++ LVM2/lib/locking/cluster_locking.c	2007/11/16 21:16:20	1.22
@@ -378,6 +378,8 @@
 {
 	char lockname[PATH_MAX];
 	int cluster_cmd = 0;
+	const char *lock_scope;
+	const char *lock_type = "";
 
 	assert(strlen(resource) < sizeof(lockname));
 	assert(resource);
@@ -393,6 +395,7 @@
 			dm_snprintf(lockname, sizeof(lockname), "V_%s",
 				     resource);
 
+		lock_scope = "VG";
 		cluster_cmd = CLVMD_CMD_LOCK_VG;
 		flags &= LCK_TYPE_MASK;
 		break;
@@ -400,6 +403,7 @@
 	case LCK_LV:
 		cluster_cmd = CLVMD_CMD_LOCK_LV;
 		strcpy(lockname, resource);
+		lock_scope = "LV";
 		flags &= 0xffdf;	/* Mask off HOLD flag */
 		break;
 
@@ -409,9 +413,40 @@
 		return 0;
 	}
 
-	/* Send a message to the cluster manager */
-	log_very_verbose("Locking %s@0x%x", lockname, flags);
+	switch(flags & LCK_TYPE_MASK) {
+	case LCK_UNLOCK:
+		lock_type = "UN";
+		break;
+	case LCK_NULL:
+		lock_type = "NL";
+		break;
+	case LCK_READ:
+		lock_type = "CR";
+		break;
+	case LCK_PREAD:
+		lock_type = "PR";
+		break;
+	case LCK_WRITE:
+		lock_type = "PW";
+		break;
+	case LCK_EXCL:
+		lock_type = "EX";
+		break;
+	default:
+		log_error("Unrecognised lock type: %u",
+			  flags & LCK_TYPE_MASK);
+		return 0;
+	}
+
+	log_very_verbose("Locking %s %s %s %s%s%s%s (0x%x)", lock_scope, lockname,
+			 lock_type,
+			 flags & LCK_NONBLOCK ? "" : "B", 
+			 flags & LCK_HOLD ? "H" : "", 
+			 flags & LCK_LOCAL ? "L" : "", 
+			 flags & LCK_CLUSTER_VG ? "C" : "", 
+			 flags);
 
+	/* Send a message to the cluster manager */
 	return _lock_for_cluster(cluster_cmd, flags, lockname);
 }
 
--- LVM2/lib/locking/file_locking.c	2007/08/23 15:02:26	1.32
+++ LVM2/lib/locking/file_locking.c	2007/11/16 21:16:20	1.33
@@ -208,8 +208,6 @@
 {
 	char lockfile[PATH_MAX];
 
-	assert(resource);
-
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
 		if (!*resource)	/* FIXME Deprecated */
@@ -238,27 +236,30 @@
 	case LCK_LV:
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_UNLOCK:
-			log_debug("Unlocking LV %s", resource);
+			log_very_verbose("Unlocking LV %s", resource);
 			if (!lv_resume_if_active(cmd, resource))
 				return 0;
 			break;
 		case LCK_NULL:
-			log_debug("Locking LV %s (NL)", resource);
+			log_very_verbose("Locking LV %s (NL)", resource);
 			if (!lv_deactivate(cmd, resource))
 				return 0;
 			break;
 		case LCK_READ:
-			log_debug("Locking LV %s (R)", resource);
+			log_very_verbose("Locking LV %s (R)", resource);
 			if (!lv_activate_with_filter(cmd, resource, 0))
 				return 0;
 			break;
+		case LCK_PREAD:
+			log_very_verbose("Locking LV %s (PR) - ignored", resource);
+			break;
 		case LCK_WRITE:
-			log_debug("Locking LV %s (W)", resource);
+			log_very_verbose("Locking LV %s (W)", resource);
 			if (!lv_suspend_if_active(cmd, resource))
 				return 0;
 			break;
 		case LCK_EXCL:
-			log_debug("Locking LV %s (EX)", resource);
+			log_very_verbose("Locking LV %s (EX)", resource);
 			if (!lv_activate_with_filter(cmd, resource, 1))
 				return 0;
 			break;
--- LVM2/lib/locking/locking.c	2007/11/15 21:30:52	1.42
+++ LVM2/lib/locking/locking.c	2007/11/16 21:16:20	1.43
@@ -318,6 +318,8 @@
 	_block_signals(flags);
 	_lock_memory(flags);
 
+	assert(resource);
+
 	if (!(_locking.lock_resource(cmd, resource, flags))) {
 		_unlock_memory(flags);
 		_unblock_signals();
--- LVM2/tools/pvresize.c	2007/11/15 22:11:18	1.18
+++ LVM2/tools/pvresize.c	2007/11/16 21:16:20	1.19
@@ -23,10 +23,10 @@
 	unsigned total;
 };
 
-int pv_resize_single(struct cmd_context *cmd,
-		     struct volume_group *vg,
-		     struct physical_volume *pv,
-		     const uint64_t new_size)
+static int _pv_resize_single(struct cmd_context *cmd,
+			     struct volume_group *vg,
+			     struct physical_volume *pv,
+			     const uint64_t new_size)
 {
 	struct pv_list *pvl;
 	int consistent = 1;
@@ -186,7 +186,7 @@
 
 	params->total++;
 
-	if (!pv_resize_single(cmd, vg, pv, params->new_size))
+	if (!_pv_resize_single(cmd, vg, pv, params->new_size))
 		return ECMD_FAILED;
 	
 	params->done++;
--- LVM2/tools/toollib.c	2007/11/15 21:30:52	1.117
+++ LVM2/tools/toollib.c	2007/11/16 21:16:20	1.118
@@ -428,7 +428,7 @@
 	int ret_max = 0;
 	int ret;
 
-	if (!vg) {
+	if (!vg && !is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
 
 		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_READ,


