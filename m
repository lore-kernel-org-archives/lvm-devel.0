From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2011 16:37:04 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/mirr ...
Message-ID: <20111222163704.24692.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-22 16:37:03

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	daemons/dmeventd/plugins/raid: dmeventd_raid.c 
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	Use new dmeventd_lvm2_command function in dmeventd plugins.
	
	For snapshot, prepare whole command in front into private buffer.
	Add also some missing '\n' for syslog messages.
	For raid and mirror only convert creation of command line string.
	This should avoid any unbound growth of mempool for dm_split_names.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2215&r2=1.2216
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/raid/dmeventd_raid.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2011/12/22 15:55:21	1.2215
+++ LVM2/WHATS_NEW	2011/12/22 16:37:01	1.2216
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Use dmeventd_lvm2_command in dmeventd plugins snapshot, raid, mirror.
   Add helper dmeventd_lvm2_command() into libdevmapper-event-lvm2 library.
   Updated documentation for dmeventd.
   Drop extra stat call before opening device.
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/08/16 18:19:46	1.37
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2011/12/22 16:37:02	1.38
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -133,32 +133,15 @@
 	int r;
 #define CMD_SIZE 256	/* FIXME Use system restriction */
 	char cmd_str[CMD_SIZE];
-	char *vg = NULL, *lv = NULL, *layer = NULL;
 
-	if (strlen(device) > 200)  /* FIXME Use real restriction */
-		return -ENAMETOOLONG;	/* FIXME These return code distinctions are not used so remove them! */
-
-	if (!dm_split_lvm_name(dmeventd_lvm2_pool(), device, &vg, &lv, &layer)) {
-		syslog(LOG_ERR, "Unable to determine VG name from %s.",
-		       device);
-		return -ENOMEM;	/* FIXME Replace with generic error return - reason for failure has already got logged */
-	}
-
-	/* strip off the mirror component designations */
-	layer = strstr(lv, "_mlog");
-	if (layer)
-		*layer = '\0';
-
-	/* FIXME Is any sanity-checking required on %s? */
-	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
-		/* this error should be caught above, but doesn't hurt to check again */
-		syslog(LOG_ERR, "Unable to form LVM command: Device name too long.");
+	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
+				  "lvconvert --config devices{ignore_suspended_devices=1} "
+				  "--repair --use-policies", device))
 		return -ENAMETOOLONG; /* FIXME Replace with generic error return - reason for failure has already got logged */
-	}
 
 	r = dmeventd_lvm2_run(cmd_str);
 
-	syslog(LOG_INFO, "Repair of mirrored LV %s/%s %s.", vg, lv,
+	syslog(LOG_INFO, "Repair of mirrored device %s %s.", device,
 	       (r == ECMD_PROCESSED) ? "finished successfully" : "failed");
 
 	return (r == ECMD_PROCESSED) ? 0 : -1;
@@ -227,9 +210,12 @@
 		    int minor __attribute__((unused)),
 		    void **unused __attribute__((unused)))
 {
-	int r = dmeventd_lvm2_init();
+	if (!dmeventd_lvm2_init())
+		return 0;
+
 	syslog(LOG_INFO, "Monitoring mirror device %s for events.", device);
-	return r;
+
+	return 1;
 }
 
 int unregister_device(const char *device,
@@ -241,5 +227,6 @@
 	syslog(LOG_INFO, "No longer monitoring mirror device %s for events.",
 	       device);
 	dmeventd_lvm2_exit();
+
 	return 1;
 }
--- LVM2/daemons/dmeventd/plugins/raid/dmeventd_raid.c	2011/12/06 19:30:16	1.2
+++ LVM2/daemons/dmeventd/plugins/raid/dmeventd_raid.c	2011/12/22 16:37:02	1.3
@@ -33,28 +33,16 @@
 	int r;
 #define CMD_SIZE 256	/* FIXME Use system restriction */
 	char cmd_str[CMD_SIZE];
-	char *vg = NULL, *lv = NULL, *layer = NULL;
 
-	if (strlen(device) > 200)  /* FIXME Use real restriction */
+	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
+				  "lvconvert --config devices{ignore_suspended_devices=1} "
+				  "--repair --use-policies", device))
 		return -1;
 
-	if (!dm_split_lvm_name(dmeventd_lvm2_pool(), device, &vg, &lv, &layer)) {
-		syslog(LOG_ERR, "Unable to determine VG name from %s.",
-		       device);
-		return -1;
-	}
-
-	/* FIXME Is any sanity-checking required on %s? */
-	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
-		/* this error should be caught above, but doesn't hurt to check again */
-		syslog(LOG_ERR, "Unable to form LVM command: Device name too long.");
-		return -1;
-	}
-
 	r = dmeventd_lvm2_run(cmd_str);
 
 	if (r != ECMD_PROCESSED)
-		syslog(LOG_INFO, "Repair of RAID LV %s/%s failed.", vg, lv);
+		syslog(LOG_INFO, "Repair of RAID device %s failed.", device);
 
 	return (r == ECMD_PROCESSED) ? 0 : -1;
 }
@@ -162,9 +150,12 @@
 		    int minor __attribute__((unused)),
 		    void **unused __attribute__((unused)))
 {
-	int r = dmeventd_lvm2_init();
+	if (!dmeventd_lvm2_init())
+		return 0;
+
 	syslog(LOG_INFO, "Monitoring RAID device %s for events.", device);
-	return r;
+
+	return 1;
 }
 
 int unregister_device(const char *device,
@@ -176,5 +167,6 @@
 	syslog(LOG_INFO, "No longer monitoring RAID device %s for events.",
 	       device);
 	dmeventd_lvm2_exit();
+
 	return 1;
 }
--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/11/21 12:31:18	1.17
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/12/22 16:37:03	1.18
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2007-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -43,6 +43,7 @@
 struct dso_state {
 	int percent_check;
 	int known_size;
+	char cmd_str[1024];
 };
 
 /* FIXME possibly reconcile this with target_percent when we gain
@@ -120,22 +121,9 @@
         return 1; /* all good */
 }
 
-static int _extend(const char *device)
+static int _extend(const char *cmd)
 {
-	char *vg = NULL, *lv = NULL, *layer = NULL;
-	char cmd_str[1024];
-
-	if (!dm_split_lvm_name(dmeventd_lvm2_pool(), device, &vg, &lv, &layer)) {
-		syslog(LOG_ERR, "Unable to determine VG name from %s.", device);
-		return 0;
-	}
-	if (dm_snprintf(cmd_str, sizeof(cmd_str),
-			"lvextend --use-policies %s/%s", vg, lv) < 0) {
-		syslog(LOG_ERR, "Unable to form LVM command: Device name too long.");
-		return 0;
-	}
-
-	return dmeventd_lvm2_run(cmd_str) == ECMD_PROCESSED;
+	return dmeventd_lvm2_run(cmd) == ECMD_PROCESSED;
 }
 
 static void _umount(const char *device, int major, int minor)
@@ -165,9 +153,9 @@
 		if (S_ISBLK(st.st_mode) &&
 		    major(st.st_rdev) == major &&
 		    minor(st.st_rdev) == minor) {
-			syslog(LOG_ERR, "Unmounting invalid snapshot %s from %s.", device, words[1]);
+			syslog(LOG_ERR, "Unmounting invalid snapshot %s from %s.\n", device, words[1]);
                         if (!_run(UMOUNT_COMMAND, "-fl", words[1], NULL))
-                                syslog(LOG_ERR, "Failed to umount snapshot %s from %s: %s.",
+                                syslog(LOG_ERR, "Failed to umount snapshot %s from %s: %s.\n",
                                        device, words[1], strerror(errno));
 		}
 	}
@@ -235,8 +223,8 @@
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
 			syslog(LOG_WARNING, "Snapshot %s is now %i%% full.\n", device, percent);
 		/* Try to extend the snapshot, in accord with user-set policies */
-		if (!_extend(device))
-			syslog(LOG_ERR, "Failed to extend snapshot %s.", device);
+		if (!_extend(state->cmd_str))
+			syslog(LOG_ERR, "Failed to extend snapshot %s.\n", device);
 	}
 
 out:
@@ -249,17 +237,33 @@
 		    int minor __attribute__((unused)),
 		    void **private)
 {
-	struct dso_state **state = (struct dso_state **) private;
-	int r = dmeventd_lvm2_init();
+	struct dso_state *state;
+
+	if (!dmeventd_lvm2_init())
+		goto out;
 
-	if (!(*state = dm_malloc(sizeof (struct dso_state))))
-		return 0;
+	if (!(state = dm_zalloc(sizeof(*state))))
+		goto bad;
 
-	(*state)->percent_check = CHECK_MINIMUM;
-	(*state)->known_size = 0;
+	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(),
+                                   state->cmd_str, sizeof(state->cmd_str),
+				   "lvextend --use-policies", device))
+		goto bad;
+
+	state->percent_check = CHECK_MINIMUM;
+	state->known_size = 0;
+	*private = state;
 
 	syslog(LOG_INFO, "Monitoring snapshot %s\n", device);
-	return r;
+
+	return 1;
+bad:
+	dm_free(state);
+	dmeventd_lvm2_exit();
+out:
+	syslog(LOG_ERR, "Failed to monitor snapshot %s.\n", device);
+
+	return 0;
 }
 
 int unregister_device(const char *device,
@@ -269,10 +273,10 @@
 		      void **private)
 {
 	struct dso_state *state = *private;
-	syslog(LOG_INFO, "No longer monitoring snapshot %s\n",
-	       device);
 
+	syslog(LOG_INFO, "No longer monitoring snapshot %s\n", device);
 	dm_free(state);
 	dmeventd_lvm2_exit();
+
 	return 1;
 }


