From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Oct 2006 23:03:56 -0000
Subject: LVM2 ./WHATS_NEW man/lvchange.8 tools/args.h t ...
Message-ID: <20061023230356.28539.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-23 23:03:55

Modified files:
	.              : WHATS_NEW 
	man            : lvchange.8 
	tools          : args.h commands.h lvchange.c 

Log message:
	Add lvchange --forcesync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.478&r2=1.479
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/WHATS_NEW	2006/10/23 15:54:51	1.478
+++ LVM2/WHATS_NEW	2006/10/23 23:03:55	1.479
@@ -1,5 +1,6 @@
 Version 2.02.13 -
 ===================================
+  Add lvchange --forcesync.
   Perform high-level free space check before each allocation attempt.
   Don't allow a node to remove an LV that's exclusively active on anther node.
   Cope if same PV is included more than once in cmdline PE range list.
--- LVM2/man/lvchange.8	2006/08/18 22:27:01	1.8
+++ LVM2/man/lvchange.8	2006/10/23 23:03:55	1.9
@@ -7,6 +7,7 @@
 [\-A/\-\-autobackup y/n] [\-a/\-\-available y/n/ey/en/ly/ln]
 [\-\-alloc AllocationPolicy]
 [\-C/\-\-contiguous y/n] [\-d/\-\-debug] [\-\-deltag Tag]
+[\-\-forcesync]
 [\-h/\-?/\-\-help]
 [\-\-ignorelockingfailure]
 [\-\-monitor {y|n}]
@@ -40,6 +41,14 @@
 logical volume's allocation policy to contiguous, if all of the
 allocated physical extents are already contiguous.
 .TP
+.I \-\-forcesync
+This option only make sense if the logical volume being operated
+on is a mirrored logical volume.  This option is used to
+resynchronize the devices in a mirrored logical volume.  Since
+resynchronization can take considerable time and resources, you
+should consider using this option only if you have reason to
+believe that the devices in your mirror are no longer the same.
+.TP
 .I \-\-minor minor
 Set the minor number.
 .TP
--- LVM2/tools/args.h	2006/09/26 09:35:43	1.47
+++ LVM2/tools/args.h	2006/10/23 23:03:55	1.48
@@ -46,6 +46,7 @@
 arg(separator_ARG, '\0', "separator", string_arg)
 arg(mirrorsonly_ARG, '\0', "mirrorsonly", NULL)
 arg(nosync_ARG, '\0', "nosync", NULL)
+arg(forcesync_ARG, '\0', "forcesync", NULL)
 arg(corelog_ARG, '\0', "corelog", NULL)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg)
 arg(config_ARG, '\0', "config", string_arg)
--- LVM2/tools/commands.h	2006/10/07 23:04:36	1.88
+++ LVM2/tools/commands.h	2006/10/23 23:03:55	1.89
@@ -61,6 +61,7 @@
    "\t[-d|--debug]\n"
    "\t[--deltag Tag]\n"
    "\t[-f|--force]\n"
+   "\t[--forcesync]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--monitor {y|n}]\n"
@@ -71,13 +72,14 @@
    "\t[--refresh]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
+   "\t[-y|--yes]\n"
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
-   ignorelockingfailure_ARG, major_ARG, minor_ARG, monitor_ARG,
+   forcesync_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG, monitor_ARG,
    partial_ARG, permission_ARG, persistent_ARG, readahead_ARG,
-   refresh_ARG, addtag_ARG, deltag_ARG, test_ARG)
+   refresh_ARG, addtag_ARG, deltag_ARG, test_ARG, yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -274,6 +276,7 @@
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
+   "\t[-y|--yes]\n"
    "\t[--version]" "\n"
    "\tLogicalVolume[Path]\n",
 
--- LVM2/tools/lvchange.c	2006/10/13 21:33:31	1.69
+++ LVM2/tools/lvchange.c	2006/10/23 23:03:55	1.70
@@ -127,10 +127,10 @@
 		}
 	} else {
 		if (lockingfailed() && (lv->vg->status & CLUSTERED)) {
-                	log_verbose("Locking failed: ignoring clustered "
+			log_verbose("Locking failed: ignoring clustered "
 				    "logical volume %s", lv->name);
-                	return 0;
-        	}
+			return 0;
+		}
 
 		if (lv_is_origin(lv) || (activate == CHANGE_AE)) {
 			log_verbose("Activating logical volume \"%s\" "
@@ -175,6 +175,158 @@
 	return 1;
 }
 
+static int lvchange_forcesync(struct cmd_context *cmd,
+			      struct logical_volume *lv)
+{
+	int active = 0;
+	struct lvinfo info;
+	struct logical_volume *log_lv;
+
+	if (!(lv->status & MIRRORED)) {
+		log_error("Unable to resync %s because it is not mirrored.",
+			  lv->name);
+		return 1;
+	}
+
+	if (lv->status & PVMOVE) {
+		log_error("Unable to resync pvmove volume %s", lv->name);
+		return 0;
+	}
+
+	if (lv->status & LOCKED) {
+		log_error("Unable to resync locked volume %s", lv->name);
+		return 0;
+	}
+
+	if (lv_info(cmd, lv, &info, 1)) {
+		if (info.open_count) {
+			log_error("Can't resync open logical volume \"%s\"",
+				  lv->name);
+			return ECMD_FAILED;
+		}
+
+		if (info.exists && !arg_count(cmd, yes_ARG)) {
+			if (yes_no_prompt("Do you really want to deactivate "
+					  "logical volume %s to resync it? [y/n]: ",
+					  lv->name) == 'n') {
+				log_print("Logical volume \"%s\" not resynced",
+					  lv->name);
+				return ECMD_FAILED;
+			}
+		}
+
+		active = 1;
+	}
+
+	if ((lv->vg->status & CLUSTERED) && !activate_lv_excl(cmd, lv)) {
+		log_error("Can't get exclusive access to clustered volume %s",
+			  lv->name);
+		return ECMD_FAILED;
+	}
+
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Unable to deactivate %s for resync", lv->name);
+		return 0;
+	}
+
+	log_lv = first_seg(lv)->log_lv;
+
+	log_very_verbose("Starting resync of %s%s%s mirror \"%s\"",
+			 (active) ? "active " : "",
+			 (lv->vg->status & CLUSTERED) ? "clustered " : "",
+			 (log_lv) ? "disk-logged" : "core-logged",
+			 lv->name);
+
+	/*
+	 * If this mirror has a core log (i.e. !log_lv),
+	 * then simply deactivating/activating will cause
+	 * it to reset the sync status.  We only need to
+	 * worry about persistent logs.
+	 */
+	if (!log_lv && !(lv->status & MIRROR_NOTSYNCED)) {
+		if (active && !activate_lv(cmd, lv)) {
+			log_error("Failed to reactivate %s to resynchronize "
+				  "mirror", lv->name);
+			return 0;
+		}
+		return 1;
+	}
+
+	lv->status &= ~MIRROR_NOTSYNCED;
+
+	if (log_lv) {
+		/* Separate mirror log so we can clear it */
+		first_seg(lv)->log_lv = NULL;
+		log_lv->status &= ~MIRROR_LOG;
+		log_lv->status |= VISIBLE_LV;
+
+		if (!vg_write(lv->vg)) {
+			log_error("Failed to write intermediate VG metadata.");
+			if (active) {
+				first_seg(lv)->log_lv = log_lv;
+				log_lv->status |= MIRROR_LOG;
+				log_lv->status &= ~VISIBLE_LV;
+				if (!activate_lv(cmd, lv))
+					stack;
+			}
+			return 0;
+		}
+
+		backup(lv->vg);
+
+		if (!vg_commit(lv->vg)) {
+			log_error("Failed to commit intermediate VG metadata.");
+			if (active) {
+				first_seg(lv)->log_lv = log_lv;
+				log_lv->status |= MIRROR_LOG;
+				log_lv->status &= ~VISIBLE_LV;
+				if (!activate_lv(cmd, lv))
+					stack;
+			}
+			return 0;
+		}
+
+		if (!activate_lv(cmd, log_lv)) {
+			log_error("Unable to activate %s for mirror log resync",
+				  log_lv->name);
+			return 0;
+		}
+
+		log_very_verbose("Clearing log device %s", log_lv->name);
+		if (!set_lv(cmd, log_lv, 0)) {
+			log_error("Unable to reset sync status for %s", lv->name);
+			if (!deactivate_lv(cmd, log_lv))
+				log_error("Failed to deactivate log LV after "
+					  "wiping failed");
+			return 0;
+		}
+
+		if (!deactivate_lv(cmd, log_lv)) {
+			log_error("Unable to deactivate log LV %s after wiping "
+				  "for resync", log_lv->name);
+			return 0;
+		}
+
+		/* Put mirror log back in place */
+		first_seg(lv)->log_lv = log_lv;
+		log_lv->status |= MIRROR_LOG;
+		log_lv->status &= ~VISIBLE_LV;
+	}
+
+	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg)) {
+		log_error("Failed to update metadata on disk.");
+		return 0;
+	}
+
+	if (active && !activate_lv(cmd, lv)) {
+		log_error("Failed to reactivate %s after resync", lv->name);
+		return 0;
+	}
+
+	return 1;
+}
+
 static int lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	int want_contiguous = 0;
@@ -495,6 +647,10 @@
 	if (doit)
 		log_print("Logical volume \"%s\" changed", lv->name);
 
+	if (arg_count(cmd, forcesync_ARG))
+		if (!lvchange_forcesync(cmd, lv))
+			return ECMD_FAILED;
+
 	/* availability change */
 	if (arg_count(cmd, available_ARG)) {
 		if (!lvchange_availability(cmd, lv))
@@ -522,9 +678,10 @@
 	    && !arg_count(cmd, minor_ARG) && !arg_count(cmd, major_ARG)
 	    && !arg_count(cmd, persistent_ARG) && !arg_count(cmd, addtag_ARG)
 	    && !arg_count(cmd, deltag_ARG) && !arg_count(cmd, refresh_ARG)
-	    && !arg_count(cmd, alloc_ARG) && !arg_count(cmd, monitor_ARG)) {
+	    && !arg_count(cmd, alloc_ARG) && !arg_count(cmd, monitor_ARG)
+	    && !arg_count(cmd, forcesync_ARG)) {
 		log_error("Need 1 or more of -a, -C, -j, -m, -M, -p, -r, "
-			  "--refresh, --alloc, --addtag, --deltag "
+			  "--forcesync, --refresh, --alloc, --addtag, --deltag "
 			  "or --monitor");
 		return EINVALID_CMD_LINE;
 	}


