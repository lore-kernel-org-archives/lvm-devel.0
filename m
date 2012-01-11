From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jan 2012 20:38:44 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20120111203844.7038.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-11 20:38:43

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 
	lib/filters    : filter.c 

Log message:
	Give priority to emcpower devices with duplicate PVIDs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2218&r2=1.2219
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/WHATS_NEW	2012/01/09 12:31:52	1.2218
+++ LVM2/WHATS_NEW	2012/01/11 20:38:42	1.2219
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Give priority to emcpower devices with duplicate PVIDs.
   Add check for error in _adjust_policy_params() (lvextend --use-policies).
   Supports rounding of percentage (%LV, %VG...) for LV resize upward.
   Use dmeventd_lvm2_command in dmeventd plugins snapshot, raid, mirror.
--- LVM2/lib/commands/toolcontext.c	2012/01/10 02:03:31	1.145
+++ LVM2/lib/commands/toolcontext.c	2012/01/11 20:38:42	1.146
@@ -98,7 +98,7 @@
 	}
 
 	if (!(fp = fopen(proc_mounts, "r"))) {
-		log_sys_error("_get_sysfs_dir: fopen %s", proc_mounts);
+		log_sys_error("_get_sysfs_dir fopen", proc_mounts);
 		return;
 	}
 
--- LVM2/lib/filters/filter.c	2011/11/18 19:36:10	1.66
+++ LVM2/lib/filters/filter.c	2012/01/11 20:38:42	1.67
@@ -44,6 +44,7 @@
 static int _blkext_major = -1;
 static int _drbd_major = -1;
 static int _device_mapper_major = -1;
+static int _emcpower_major = -1;
 
 int dm_major(void)
 {
@@ -70,6 +71,9 @@
 	if (MAJOR(dev->dev) == _drbd_major)
 		return 1;
 
+	if (MAJOR(dev->dev) == _emcpower_major)
+		return 1;
+
 	if ((MAJOR(dev->dev) == _blkext_major) &&
 	    (get_primary_dev(sysfs_dir_path(), dev, &primary_dev)) &&
 	    (MAJOR(primary_dev) == _md_major))
@@ -86,6 +90,9 @@
 	if (MAJOR(dev->dev) == _drbd_major)
 		return "DRBD";
 
+	if (MAJOR(dev->dev) == _emcpower_major)
+		return "EMCPOWER";
+
 	if (MAJOR(dev->dev) == _blkext_major)
 		return "BLKEXT";
 
@@ -246,6 +253,10 @@
 		if (!strncmp("drbd", line + i, 4) && isspace(*(line + i + 4)))
 			_drbd_major = line_maj;
 
+		/* Look for EMC powerpath */
+		if (!strncmp("emcpower", line + i, 8) && isspace(*(line + i + 8)))
+			_emcpower_major = line_maj;
+
 		/* Look for device-mapper device */
 		/* FIXME Cope with multiple majors */
 		if (!strncmp("device-mapper", line + i, 13) && isspace(*(line + i + 13)))


