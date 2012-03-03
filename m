From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Mar 2012 18:32:55 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmetad.c lib/cache ...
Message-ID: <20120303183255.14505.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-03 18:32:54

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmetad.c lvmetad.h 
	man            : pvscan.8.in 
	tools          : commands.h pvremove.c pvscan.c 

Log message:
	Scan all devices for lvmetad if 'pvscan --cache' used without device list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2338&r2=1.2339
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2012/03/03 02:08:37	1.2338
+++ LVM2/WHATS_NEW	2012/03/03 18:32:53	1.2339
@@ -1,5 +1,8 @@
 Version 2.02.95 -
 ================================
+  Scan all devices for lvmetad if 'pvscan --cache' used without device list.
+  Populate lvmcache from lvmetad before displaying PVs in pvscan. (2.02.94)
+  Suppress incorrect -n pvscan warning now always displayed. (2.02.94)
 
 Version 2.02.94 - 3rd March 2012
 ================================
--- LVM2/lib/cache/lvmetad.c	2012/03/02 22:44:31	1.17
+++ LVM2/lib/cache/lvmetad.c	2012/03/03 18:32:54	1.18
@@ -607,7 +607,7 @@
 	return result;
 }
 
-static int _lvmetad_pv_gone(dev_t device, const char *pv_name)
+int lvmetad_pv_gone(dev_t device, const char *pv_name)
 {
 	int result;
 	int found;
@@ -625,9 +625,9 @@
 	return result;
 }
 
-int lvmetad_pv_gone(struct device *dev)
+int lvmetad_pv_gone_by_dev(struct device *dev)
 {
-	return _lvmetad_pv_gone(dev->dev, dev_name(dev));
+	return lvmetad_pv_gone(dev->dev, dev_name(dev));
 }
 
 int lvmetad_active(void)
@@ -663,33 +663,8 @@
 	return 1;
 }
 
-static dev_t _parse_devt(const char *str)
-{	/* Oh. */
-	char *where = (char *) str;
-	int major = strtol(str, &where, 10);
-	int minor;
-
-	if (where == str)
-		return -1;
-
-	if (*where != ':')
-		return -1;
-
-	str = ++where;
-	minor = strtol(str, &where, 10);
-
-	if (where == str)
-		return -1;
-
-	if (*where)
-		return -1;
-
-	return MKDEV(major, minor);
-}
-
-int pvscan_lvmetad_single(struct cmd_context *cmd, const char *pv_name)
+int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev)
 {
-	struct device *dev;
 	struct label *label;
 	struct lvmcache_info *info;
 	struct physical_volume pv;
@@ -702,26 +677,9 @@
 		return 0;
 	}
 
-	dev = dev_cache_get(pv_name, NULL);
-	if (!dev && _parse_devt(pv_name) != -1)
-		dev = dev_cache_get_by_devt(_parse_devt(pv_name), NULL);
-
-	if (!dev) {
-		if (_parse_devt(pv_name) == -1) {
-			log_error("Unrecognised device name %s.  (Use MAJOR:MINOR for new devices.)", pv_name);
-			return 0;
-		}
-
-		if (!_lvmetad_pv_gone(_parse_devt(pv_name), pv_name))
-			goto_bad;
-
-		log_print("Device %s not found.  Cleared from lvmetad cache.", pv_name);
-		return 1;
-	}
-
 	if (!label_read(dev, &label, 0)) {
 		log_print("No PV label found on %s.", dev_name(dev));
-		if (!lvmetad_pv_gone(dev))
+		if (!lvmetad_pv_gone_by_dev(dev))
 			goto_bad;
 		return 1;
 	}
--- LVM2/lib/cache/lvmetad.h	2012/03/02 21:50:02	1.6
+++ LVM2/lib/cache/lvmetad.h	2012/03/03 18:32:54	1.7
@@ -67,11 +67,10 @@
 		     struct volume_group *vg);
 
 /*
- * Inform the daemon that the device no longer exists. We do not support
- * multiple device names, so this needs a unique and stable name, the same as
- * provided to lvmetad_pv_found.
+ * Inform the daemon that the device no longer exists.
  */
-int lvmetad_pv_gone(struct device *dev);
+int lvmetad_pv_gone(dev_t devno, const char *pv_name);
+int lvmetad_pv_gone_by_dev(struct device *dev);
 
 /*
  * Request a list of all PVs available to lvmetad. If requested, this will also
@@ -101,10 +100,9 @@
 				       const char *vgname, const char *vgid);
 
 /*
- * Scan a single device and update lvmetad with the result(s). If the device
- * node does not exist, it must be supplied in a major:minor format.
+ * Scan a single device and update lvmetad with the result(s).
  */
-int pvscan_lvmetad_single(struct cmd_context *cmd, const char *pv_name);
+int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev);
 
 #  else		/* LVMETAD_SUPPORT */
 
@@ -114,13 +112,14 @@
 #    define lvmetad_vg_update(vg)	(1)
 #    define lvmetad_vg_remove(vg)	(1)
 #    define lvmetad_pv_found(pvid, device, fmt, label_sector, vg)	(1)
-#    define lvmetad_pv_gone(dev)	(1)
+#    define lvmetad_pv_gone(devno, pv_name)	(1)
+#    define lvmetad_pv_gone_by_dev(dev)	(1)
 #    define lvmetad_pv_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_pv_lookup(cmd, pvid, found)	(0)
 #    define lvmetad_pv_lookup_by_dev(cmd, dev, found)	(0)
 #    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
-#    define pvscan_lvmetad_single(cmd, pv_name)	(0)
+#    define pvscan_lvmetad_single(cmd, dev)	(0)
 
 #  endif	/* LVMETAD_SUPPORT */
 
--- LVM2/man/pvscan.8.in	2012/03/02 18:09:47	1.8
+++ LVM2/man/pvscan.8.in	2012/03/03 18:32:54	1.9
@@ -3,7 +3,7 @@
 pvscan \- scan all disks for physical volumes
 .SH SYNOPSIS
 .B pvscan
-.RB [ \-\-cache " " DevicePath [ DevicePath ... ] ]
+.RB [ \-\-cache " " [ DevicePath ... ] ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-v | \-\-verbose ]
@@ -31,10 +31,11 @@
 .BR \-u ", " \-\-uuid
 Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
 .TP
-.BR \-\-cache " " DevicePath [ DevicePath... ]
-Scan a single device and instruct the lvmetad daemon to update its cached
-state.  Called internally by udev rules. The device is processed
-\fBregardless\fP of any device filters set in lvm.conf.
+.BR \-\-cache " " [ DevicePath... ]
+Scan one or more devices and instruct the lvmetad daemon to update its cached
+state accordingly.  Called internally by udev rules.
+All devices listed explicitly are processed \fBregardless\fP of any device
+filters set in lvm.conf.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8),
--- LVM2/tools/commands.h	2012/03/02 18:09:48	1.171
+++ LVM2/tools/commands.h	2012/03/03 18:32:54	1.172
@@ -663,7 +663,7 @@
    "List all physical volumes",
    PERMITTED_READ_ONLY,
    "pvscan " "\n"
-   "\t[--cache DevicePath [DevicePath...]] " "\n"
+   "\t[--cache [DevicePath...]] " "\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
    "\t[-h|-?|--help]" "\n"
--- LVM2/tools/pvremove.c	2012/03/02 16:58:41	1.41
+++ LVM2/tools/pvremove.c	2012/03/03 18:32:54	1.42
@@ -128,8 +128,7 @@
 		goto out;
 	}
 
-	/* FIXME Avoid error if we expect that daemon might not know device */
-	if (!lvmetad_pv_gone(dev))
+	if (!lvmetad_pv_gone_by_dev(dev))
 		goto_out;
 
 	log_print("Labels on physical volume \"%s\" successfully wiped",
--- LVM2/tools/pvscan.c	2012/03/03 17:12:21	1.59
+++ LVM2/tools/pvscan.c	2012/03/03 18:32:54	1.60
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -21,6 +21,52 @@
 int pv_max_name_len = 0;
 int vg_max_name_len = 0;
 
+static dev_t _parse_devt(const char *str)
+{	/* Oh. */
+	char *where = (char *) str;
+	int major = strtol(str, &where, 10);
+	int minor;
+
+	if (where == str)
+		return -1;
+
+	if (*where != ':')
+		return -1;
+
+	str = ++where;
+	minor = strtol(str, &where, 10);
+
+	if (where == str)
+		return -1;
+
+	if (*where)
+		return -1;
+
+	return MKDEV(major, minor);
+}
+
+/*
+ * Convert pv_name to struct device or to *devno.
+ */
+static struct device *_device_from_pv_name(const char *pv_name, dev_t *devno)
+{
+	struct device *dev;
+
+	if ((dev = dev_cache_get(pv_name, NULL)))
+		return dev;
+	
+        if ((*devno = _parse_devt(pv_name)) == -1) {
+		log_error("Unrecognised device name %s. "
+			  "(Use MAJOR:MINOR for new devices.)", pv_name);
+		return NULL;
+	}
+
+	if ((dev = dev_cache_get_by_devt(*devno, NULL)))
+		return dev;
+
+	return NULL;
+}
+
 static void _pvscan_display_single(struct cmd_context *cmd,
 				   struct physical_volume *pv,
 				   void *handle __attribute__((unused)))
@@ -99,30 +145,78 @@
 					   pv_pe_size(pv)));
 }
 
-static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
+static int _pvscan_lvmetad_all_devs(struct cmd_context *cmd)
 {
-	int ret = ECMD_PROCESSED;
+	struct dev_iter *iter;
+	struct device *dev;
+	int r = 1;
+
+	if (!(iter = dev_iter_create(cmd->filter, 1))) {
+		log_error("dev_iter creation failed");
+		return 0;
+	}
 
-	if (!argc) {
-		log_error("List of Physical Volumes to be cached by the lvmetad daemon required.");
-		return EINVALID_CMD_LINE;
+	while ((dev = dev_iter_get(iter))) {
+		if (!pvscan_lvmetad_single(cmd, dev)) {
+			r = 0;
+			break;
+		}
+
+		if (sigint_caught())
+			break;
 	}
 
+	dev_iter_destroy(iter);
+
+	return r;
+}
+
+static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
+{
+	int ret = ECMD_PROCESSED;
+	struct device *dev;
+	const char *pv_name;
+	dev_t devno;
+
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
 
+	if (!argc) {
+		if (!_pvscan_lvmetad_all_devs(cmd))
+			ret = ECMD_FAILED;
+		goto out;
+	}
+
 	log_verbose("Using physical volume(s) on command line");
+
 	while (argc--) {
-		if (!pvscan_lvmetad_single(cmd, *argv++)) {
+		pv_name = *argv++;
+		dev = _device_from_pv_name(pv_name, &devno);
+
+		if (!dev && devno != -1) {
+			/* FIXME Filters? */
+			if (!lvmetad_pv_gone(devno, pv_name)) {
+				ret = ECMD_FAILED;
+				break;
+			}
+
+			log_print("Device %s not found. "
+				  "Cleared from lvmetad cache.", pv_name);
+			continue;
+		}
+
+		if (!pvscan_lvmetad_single(cmd, dev)) {
 			ret = ECMD_FAILED;
 			break;
 		}
+
 		if (sigint_caught())
 			break;
 	}
 
+out:
 	unlock_vg(cmd, VG_GLOBAL);
 
 	return ret;
@@ -184,6 +278,7 @@
 		     && !(pv_status(pv) & EXPORTED_VG)) ||
 		    (arg_count(cmd, novolumegroup_ARG) && (!is_orphan(pv)))) {
 			dm_list_del(&pvl->list);
+			free_pv_fid(pv);
 			continue;
 		}
 


