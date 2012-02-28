From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:08:09 -0000
Subject: LVM2/tools vgscan.c vgrename.c toollib.c pvsca ...
Message-ID: <20120228180809.14259.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:08:08

Modified files:
	tools          : vgscan.c vgrename.c toollib.c pvscan.c 
	                 pvremove.c commands.h 

Log message:
	Check return values after calling new lvmetad fns
	(Haven't checked error path handling though)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.243&r2=1.244
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.168&r2=1.169

--- LVM2/tools/vgscan.c	2012/02/23 13:11:10	1.39
+++ LVM2/tools/vgscan.c	2012/02/28 18:08:08	1.40
@@ -24,7 +24,10 @@
 		  vg->fid->fmt->name);
 
 	check_current_backup(vg);
-	lvmetad_vg_update(vg); /* keep lvmetad up to date */
+
+	/* keep lvmetad up to date */
+	if (!lvmetad_vg_update(vg))
+		stack;
 
 	return ECMD_PROCESSED;
 }
--- LVM2/tools/vgrename.c	2012/02/23 13:11:10	1.78
+++ LVM2/tools/vgrename.c	2012/02/28 18:08:08	1.79
@@ -79,7 +79,9 @@
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
-	lvmetad_vg_list_to_lvmcache(cmd); /* populate lvmcache */
+	/* populate lvmcache */
+	if (!lvmetad_vg_list_to_lvmcache(cmd))
+		stack;
 
 	/* Avoid duplicates */
 	if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
--- LVM2/tools/toollib.c	2012/02/28 14:24:59	1.243
+++ LVM2/tools/toollib.c	2012/02/28 18:08:08	1.244
@@ -305,7 +305,8 @@
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
-		lvmetad_vg_list_to_lvmcache(cmd);
+		if (!lvmetad_vg_list_to_lvmcache(cmd))
+			stack;
 		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
 			log_error("No volume groups found");
 			return ret_max;
@@ -582,7 +583,8 @@
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all volume groups");
-		lvmetad_vg_list_to_lvmcache(cmd);
+		if (!lvmetad_vg_list_to_lvmcache(cmd))
+			stack;
 		if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 			log_error("No volume groups found");
 			return ret_max;
--- LVM2/tools/pvscan.c	2012/02/23 13:11:10	1.54
+++ LVM2/tools/pvscan.c	2012/02/28 18:08:08	1.55
@@ -116,8 +116,10 @@
 	vg_max_name_len = 0;
 
 	if (arg_count(cmd, lvmetad_ARG)) {
-		if (!pvscan_lvmetad(cmd, argc, argv))
+		if (!pvscan_lvmetad(cmd, argc, argv)) {
+			stack;
 			return ECMD_FAILED;
+		}
 		return ECMD_PROCESSED;
 	}
 
--- LVM2/tools/pvremove.c	2012/02/23 13:11:10	1.37
+++ LVM2/tools/pvremove.c	2012/02/28 18:08:08	1.38
@@ -107,35 +107,36 @@
 	}
 
 	if (!pvremove_check(cmd, pv_name))
-		goto error;
+		goto out;
 
 	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
 		log_error("%s: Couldn't find device.  Check your filters?",
 			  pv_name);
-		goto error;
+		goto out;
 	}
 
 	if (!dev_test_excl(dev)) {
 		/* FIXME Detect whether device-mapper is still using the device */
 		log_error("Can't open %s exclusively - not removing. "
 			  "Mounted filesystem?", dev_name(dev));
-		goto error;
+		goto out;
 	}
 
 	/* Wipe existing label(s) */
 	if (!label_remove(dev)) {
 		log_error("Failed to wipe existing label(s) on %s", pv_name);
-		goto error;
+		goto out;
 	}
 
-	lvmetad_pv_gone(dev->dev);
+	if (!lvmetad_pv_gone(dev->dev))
+		goto_out;
 
 	log_print("Labels on physical volume \"%s\" successfully wiped",
 		  pv_name);
 
 	ret = ECMD_PROCESSED;
 
-      error:
+out:
 	unlock_vg(cmd, VG_ORPHANS);
 
 	return ret;
--- LVM2/tools/commands.h	2012/02/23 13:11:10	1.168
+++ LVM2/tools/commands.h	2012/02/28 18:08:08	1.169
@@ -670,7 +670,7 @@
    "\t[-P|--partial] " "\n"
    "\t[-s|--short] " "\n"
    "\t[-u|--uuid] " "\n"
-   "\t[--lvmetad DEVICE] " "\n"
+   "\t[--lvmetad DevicePath] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 


