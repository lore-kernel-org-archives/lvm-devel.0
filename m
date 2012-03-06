From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Mar 2012 02:30:51 -0000
Subject: LVM2 ./WHATS_NEW man/pvscan.8.in tools/args.h ...
Message-ID: <20120306023051.13816.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-06 02:30:50

Modified files:
	.              : WHATS_NEW 
	man            : pvscan.8.in 
	tools          : args.h commands.h lvchange.c lvcreate.c 
	                 lvmcmdline.c pvscan.c tools.h 
	udev           : 69-dm-lvm-metad.rules 

Log message:
	Switch pvscan --cache major:minor to --major --minor.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2345&r2=1.2346
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.261&r2=1.262
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/69-dm-lvm-metad.rules.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2012/03/05 15:05:24	1.2345
+++ LVM2/WHATS_NEW	2012/03/06 02:30:49	1.2346
@@ -4,6 +4,7 @@
   Print just warning on thin pool check callback path for failing check.
   Always use 64bit math with VG extent_size expression.
   Validate udev structures in _insert_udev_dir().
+  Take repeatable --major --minor with pvscan --cache instead of major:minor.
   Scan all devices for lvmetad if 'pvscan --cache' used without device list.
   Populate lvmcache from lvmetad before displaying PVs in pvscan. (2.02.94)
   Suppress incorrect -n pvscan warning now always displayed. (2.02.94)
--- LVM2/man/pvscan.8.in	2012/03/03 18:32:54	1.9
+++ LVM2/man/pvscan.8.in	2012/03/06 02:30:50	1.10
@@ -3,7 +3,6 @@
 pvscan \- scan all disks for physical volumes
 .SH SYNOPSIS
 .B pvscan
-.RB [ \-\-cache " " [ DevicePath ... ] ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-v | \-\-verbose ]
@@ -13,6 +12,19 @@
 .RB [ \-n | \-\-novolumegroup ]
 .RB [ \-s | \-\-short ]
 .RB [ \-u | \-\-uuid ]
+.BR
+
+.B pvscan
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB \-\-cache
+.RB [ \-\-major
+.IR major
+.RB \-\-minor
+.IR minor
+|
+.RI DevicePath 
+] ...
 .SH DESCRIPTION
 .B pvscan
 scans all supported LVM block devices in the system for physical volumes.
@@ -31,7 +43,7 @@
 .BR \-u ", " \-\-uuid
 Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
 .TP
-.BR \-\-cache " " [ DevicePath... ]
+.BR \-\-cache " " [ " " \-\-major " " major " " \-\-minor " " minor " " | " " DevicePath " " ] " " ...
 Scan one or more devices and instruct the lvmetad daemon to update its cached
 state accordingly.  Called internally by udev rules.
 All devices listed explicitly are processed \fBregardless\fP of any device
--- LVM2/tools/args.h	2012/03/02 18:09:48	1.88
+++ LVM2/tools/args.h	2012/03/06 02:30:50	1.89
@@ -44,7 +44,7 @@
 arg(deltag_ARG, '\0', "deltag", tag_arg, ARG_GROUPABLE)
 arg(refresh_ARG, '\0', "refresh", NULL, 0)
 arg(mknodes_ARG, '\0', "mknodes", NULL, 0)
-arg(minor_ARG, '\0', "minor", minor_arg, 0)
+arg(minor_ARG, '\0', "minor", minor_arg, ARG_GROUPABLE)
 arg(type_ARG, '\0', "type", segtype_arg, 0)
 arg(alloc_ARG, '\0', "alloc", alloc_arg, 0)
 arg(separator_ARG, '\0', "separator", string_arg, 0)
@@ -115,7 +115,7 @@
 arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0)
 arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0)
 arg(merge_ARG, '\0', "merge", NULL, 0)
-arg(major_ARG, 'j', "major", major_arg, 0)
+arg(major_ARG, 'j', "major", major_arg, ARG_GROUPABLE)
 arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0)
 arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0)
 arg(maps_ARG, 'm', "maps", NULL, 0)
--- LVM2/tools/commands.h	2012/03/03 18:32:54	1.172
+++ LVM2/tools/commands.h	2012/03/06 02:30:50	1.173
@@ -663,7 +663,7 @@
    "List all physical volumes",
    PERMITTED_READ_ONLY,
    "pvscan " "\n"
-   "\t[--cache [DevicePath...]] " "\n"
+   "\t[--cache [ DevicePath | --major major --minor minor]...\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
    "\t[-h|-?|--help]" "\n"
@@ -674,8 +674,8 @@
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   cache_ARG, exported_ARG, ignorelockingfailure_ARG, novolumegroup_ARG,
-   partial_ARG, short_ARG, uuid_ARG)
+   cache_ARG, exported_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG,
+   novolumegroup_ARG, partial_ARG, short_ARG, uuid_ARG)
 
 xx(segtypes,
    "List available segment types",
--- LVM2/tools/lvchange.c	2012/02/28 14:24:58	1.139
+++ LVM2/tools/lvchange.c	2012/03/06 02:30:50	1.140
@@ -456,6 +456,14 @@
 			log_error("Minor number must be specified with -My");
 			return 0;
 		}
+		if (arg_count(cmd, major_ARG) > 1) {
+			log_error("Option -j/--major may not be repeated.");
+			return 0;
+		}
+		if (arg_count(cmd, minor_ARG) > 1) {
+			log_error("Option --minor may not be repeated.");
+			return 0;
+		}
 		if (!arg_count(cmd, major_ARG) && lv->major < 0) {
 			log_error("Major number must be specified with -My");
 			return 0;
--- LVM2/tools/lvcreate.c	2012/03/05 14:19:14	1.261
+++ LVM2/tools/lvcreate.c	2012/03/06 02:30:50	1.262
@@ -587,6 +587,16 @@
 	if (!(lp->permission & LVM_WRITE))
 		lp->zero = 0;
 
+	if (arg_count(cmd, major_ARG) > 1) {
+		log_error("Option -j/--major may not be repeated.");
+		return 0;
+	}
+
+	if (arg_count(cmd, minor_ARG) > 1) {
+		log_error("Option --minor may not be repeated.");
+		return 0;
+	}
+
 	lp->minor = arg_int_value(cmd, minor_ARG, -1);
 	lp->major = arg_int_value(cmd, major_ARG, -1);
 
--- LVM2/tools/lvmcmdline.c	2012/03/01 21:17:29	1.152
+++ LVM2/tools/lvmcmdline.c	2012/03/06 02:30:50	1.153
@@ -89,6 +89,11 @@
 	return grouped_arg_count(av, a) ? av[a].value : def;
 }
 
+int32_t grouped_arg_int_value(const struct arg_values *av, int a, const int32_t def)
+{
+	return grouped_arg_count(av, a) ? av[a].i_value : def;
+}
+
 int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
 {
 	return arg_count(cmd, a) ? cmd->arg_values[a].i_value : def;
--- LVM2/tools/pvscan.c	2012/03/03 18:32:54	1.60
+++ LVM2/tools/pvscan.c	2012/03/06 02:30:50	1.61
@@ -21,52 +21,6 @@
 int pv_max_name_len = 0;
 int vg_max_name_len = 0;
 
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
-/*
- * Convert pv_name to struct device or to *devno.
- */
-static struct device *_device_from_pv_name(const char *pv_name, dev_t *devno)
-{
-	struct device *dev;
-
-	if ((dev = dev_cache_get(pv_name, NULL)))
-		return dev;
-	
-        if ((*devno = _parse_devt(pv_name)) == -1) {
-		log_error("Unrecognised device name %s. "
-			  "(Use MAJOR:MINOR for new devices.)", pv_name);
-		return NULL;
-	}
-
-	if ((dev = dev_cache_get_by_devt(*devno, NULL)))
-		return dev;
-
-	return NULL;
-}
-
 static void _pvscan_display_single(struct cmd_context *cmd,
 				   struct physical_volume *pv,
 				   void *handle __attribute__((unused)))
@@ -176,14 +130,28 @@
 	int ret = ECMD_PROCESSED;
 	struct device *dev;
 	const char *pv_name;
+	int32_t major = -1;
+	int32_t minor = -1;
+	int devno_args = 0;
+	struct arg_value_group_list *current_group;
 	dev_t devno;
+	char *buf;
+
+	if (arg_count(cmd, major_ARG) + arg_count(cmd, minor_ARG))
+		devno_args = 1;
 
+	if (devno_args && (!arg_count(cmd, major_ARG) || !arg_count(cmd, minor_ARG))) {
+		log_error("Both --major and --minor required to identify devices.");
+		return EINVALID_CMD_LINE;
+	}
+	
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
 
-	if (!argc) {
+	/* Scan everything? */
+	if (!argc && !devno_args) {
 		if (!_pvscan_lvmetad_all_devs(cmd))
 			ret = ECMD_FAILED;
 		goto out;
@@ -191,19 +159,52 @@
 
 	log_verbose("Using physical volume(s) on command line");
 
+	/* Process any command line PVs first. */
 	while (argc--) {
 		pv_name = *argv++;
-		dev = _device_from_pv_name(pv_name, &devno);
+		dev = dev_cache_get(pv_name, NULL);
+		if (!dev) {
+			log_error("Physical Volume %s not found.", pv_name);
+			ret = ECMD_FAILED;
+			continue;
+		}
+
+		if (!pvscan_lvmetad_single(cmd, dev)) {
+			ret = ECMD_FAILED;
+			break;
+		}
+		if (sigint_caught())
+			break;
+	}
+
+	if (!devno_args)
+		goto out;
+
+	/* Process any grouped --major --minor args */
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		major = grouped_arg_int_value(current_group->arg_values, major_ARG, major);
+		minor = grouped_arg_int_value(current_group->arg_values, minor_ARG, minor);
+
+		if (major < 0 || minor < 0)
+			continue;
+
+		devno = MKDEV(major, minor);
 
-		if (!dev && devno != -1) {
+		if (!(dev = dev_cache_get_by_devt(devno, NULL))) {
+			if (!dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor))
+				stack;
 			/* FIXME Filters? */
-			if (!lvmetad_pv_gone(devno, pv_name)) {
+			if (!lvmetad_pv_gone(devno, buf ? : "")) {
 				ret = ECMD_FAILED;
+				if (buf)
+					dm_free(buf);
 				break;
 			}
 
 			log_print("Device %s not found. "
-				  "Cleared from lvmetad cache.", pv_name);
+				  "Cleared from lvmetad cache.", buf ? : "");
+			if (buf)
+				dm_free(buf);
 			continue;
 		}
 
@@ -241,6 +242,11 @@
 	if (arg_count(cmd, cache_ARG))
 		return _pvscan_lvmetad(cmd, argc, argv);
 
+	if (arg_count(cmd, major_ARG) + arg_count(cmd, minor_ARG)) {
+		log_error("--major and --minor are only valid with --cache.");
+		return EINVALID_CMD_LINE;
+	}
+
 	if (arg_count(cmd, novolumegroup_ARG) && arg_count(cmd, exported_ARG)) {
 		log_error("Options -e and -n are incompatible");
 		return EINVALID_CMD_LINE;
--- LVM2/tools/tools.h	2012/02/23 13:11:10	1.79
+++ LVM2/tools/tools.h	2012/03/06 02:30:50	1.80
@@ -173,6 +173,7 @@
 unsigned grouped_arg_count(const struct arg_values *av, int a);
 unsigned grouped_arg_is_set(const struct arg_values *av, int a);
 const char *grouped_arg_str_value(const struct arg_values *av, int a, const char *def);
+int32_t grouped_arg_int_value(const struct arg_values *av, int a, const int32_t def); 
 
 const char *command_name(struct cmd_context *cmd);
 
--- LVM2/udev/69-dm-lvm-metad.rules	2012/03/02 18:09:48	1.2
+++ LVM2/udev/69-dm-lvm-metad.rules	2012/03/06 02:30:50	1.3
@@ -20,6 +20,6 @@
 KERNEL=="dm-[0-9]*", ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
 
 # Only process devices already marked as a PV - this requires blkid to be called before.
-ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="$env{DM_SBIN_PATH}/pvscan --cache $major:$minor"
+ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="$env{DM_SBIN_PATH}/pvscan --cache --major $major --minor $minor"
 
 LABEL="lvm_end"


