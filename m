From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 9 Aug 2007 21:25:09 -0000
Subject: LVM2/tools args.h commands.h lvconvert.c lvcre ...
Message-ID: <20070809212509.30243.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2007-08-09 21:25:08

Modified files:
	tools          : args.h commands.h lvconvert.c lvcreate.c 

Log message:
	- change new log_ARG variable to more explicit mirrorlog_ARG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/tools/args.h	2007/08/01 21:01:06	1.51
+++ LVM2/tools/args.h	2007/08/09 21:25:08	1.52
@@ -48,7 +48,7 @@
 arg(nosync_ARG, '\0', "nosync", NULL)
 arg(resync_ARG, '\0', "resync", NULL)
 arg(corelog_ARG, '\0', "corelog", NULL)
-arg(log_ARG, '\0', "log", string_arg)
+arg(mirrorlog_ARG, '\0', "log", string_arg)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg)
 arg(config_ARG, '\0', "config", string_arg)
 arg(trustcache_ARG, '\0', "trustcache", NULL)
--- LVM2/tools/commands.h	2007/08/01 21:01:06	1.98
+++ LVM2/tools/commands.h	2007/08/09 21:25:08	1.99
@@ -107,7 +107,7 @@
    "\t[--version]" "\n"
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
-   alloc_ARG, chunksize_ARG, mirrors_ARG, corelog_ARG, log_ARG,
+   alloc_ARG, chunksize_ARG, mirrors_ARG, corelog_ARG, mirrorlog_ARG,
    regionsize_ARG, snapshot_ARG, test_ARG, zero_ARG)
 
 xx(lvcreate,
@@ -156,7 +156,7 @@
    "\tOriginalLogicalVolume[Path] [PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
-   corelog_ARG, log_ARG, extents_ARG, major_ARG, minor_ARG, mirrors_ARG, name_ARG,
+   corelog_ARG, mirrorlog_ARG, extents_ARG, major_ARG, minor_ARG, mirrors_ARG, name_ARG,
    nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG,
    size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
    zero_ARG)
--- LVM2/tools/lvconvert.c	2007/08/01 21:01:06	1.31
+++ LVM2/tools/lvconvert.c	2007/08/09 21:25:08	1.32
@@ -107,7 +107,7 @@
 
 	memset(lp, 0, sizeof(*lp));
 
-	if (arg_count(cmd, log_ARG) > 1) {
+	if (arg_count(cmd, mirrorlog_ARG) > 1) {
 		log_error("Too many --log arguments supplied.");
 		return 0;
 	}
@@ -119,7 +119,7 @@
 		log_error("Too many --snapshot arguments supplied.");
 		return 0;
 	}
-	if (arg_count(cmd, log_ARG) || arg_count(cmd, mirrors_ARG))
+	if (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG))
 		count = 1;
 	count += arg_count(cmd, snapshot_ARG);
 
@@ -294,8 +294,8 @@
 		corelog = 1;
 	}
 
-	if (arg_count(cmd, log_ARG)) {
-		log_arg = arg_str_value(cmd, log_ARG, "disk");
+	if (arg_count(cmd, mirrorlog_ARG)) {
+		log_arg = arg_str_value(cmd, mirrorlog_ARG, "disk");
 		if (!strcmp("disk", log_arg)) {
 			log_verbose("Setting logging type to \"disk\"");
 			corelog = 0;
@@ -588,7 +588,7 @@
 	}
 
 	if (arg_count(cmd, mirrors_ARG) ||
-	    ((lv->status & MIRRORED) && arg_count(cmd, log_ARG))) {
+	    ((lv->status & MIRRORED) && arg_count(cmd, mirrorlog_ARG))) {
 		if (!archive(lv->vg))
 			return ECMD_FAILED;
 		if (!lvconvert_mirrors(cmd, lv, lp))
--- LVM2/tools/lvcreate.c	2007/08/01 21:01:06	1.139
+++ LVM2/tools/lvcreate.c	2007/08/09 21:25:08	1.140
@@ -290,8 +290,8 @@
 		lp->corelog = 1;
 	}
 
-	if (arg_count(cmd, log_ARG)) {
-		log_arg = arg_str_value(cmd, log_ARG, "disk");
+	if (arg_count(cmd, mirrorlog_ARG)) {
+		log_arg = arg_str_value(cmd, mirrorlog_ARG, "disk");
 		if (!strcmp("disk", log_arg)) {
 			log_verbose("Setting logging type to \"disk\"");
 			lp->corelog = 0;


