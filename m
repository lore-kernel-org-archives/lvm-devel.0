From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Mar 2012 18:09:51 -0000
Subject: LVM2 doc/lvmetad_design.txt doc/udev_assembly. ...
Message-ID: <20120302180951.6387.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-02 18:09:48

Modified files:
	doc            : lvmetad_design.txt udev_assembly.txt 
	lib/cache      : lvmetad.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : metadata.c 
	man            : pvscan.8.in 
	test/lib       : aux.sh 
	tools          : args.h commands.h pvscan.c 
	udev           : 69-dm-lvm-metad.rules 

Log message:
	Change pvscan --lvmetad to pvscan --cache.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/lvmetad_design.txt.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/udev_assembly.txt.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.495&r2=1.496
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.170&r2=1.171
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/69-dm-lvm-metad.rules.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/doc/lvmetad_design.txt	2011/07/08 18:55:28	1.1
+++ LVM2/doc/lvmetad_design.txt	2012/03/02 18:09:46	1.2
@@ -51,8 +51,8 @@
 system. I imagine we could extend the pvscan command (or add a new one, say
 lvmetad_client, if pvscan is found to be inappropriate):
 
-    $ pvscan --lvmetad /dev/foo
-    $ pvscan --lvmetad --remove /dev/foo
+    $ pvscan --cache /dev/foo
+    $ pvscan --cache --remove /dev/foo
 
 These commands would simply read the label and the MDA (if applicable) from the
 given PV and feed that data to the running lvmetad, using
--- LVM2/doc/udev_assembly.txt	2011/05/25 21:43:12	1.1
+++ LVM2/doc/udev_assembly.txt	2012/03/02 18:09:46	1.2
@@ -32,11 +32,11 @@
 
 For LVM, the crucial piece of the puzzle is lvmetad, which allows us to build up
 VGs from PVs as they appear, and at the same time collect information on what is
-already available. A command, pvscan --lvmetad is expected to be used to
+already available. A command, pvscan --cache is expected to be used to
 implement udev rules. It is relatively easy to make this command print out a
 list of VGs (and possibly LVs) that have been made available by adding any
 particular device to the set of visible devices. In othe words, udev says "hey,
-/dev/sdb just appeared", calls pvscan --lvmetad, which talks to lvmetad, which
+/dev/sdb just appeared", calls pvscan --cache, which talks to lvmetad, which
 says "cool, that makes vg0 complete". Pvscan takes this info and prints it out,
 and the udev rule can then somehow decide whether anything needs to be done
 about this "vg0". Presumably a table of devices that need to be activated
--- LVM2/lib/cache/lvmetad.c	2012/03/02 16:58:41	1.13
+++ LVM2/lib/cache/lvmetad.c	2012/03/02 18:09:46	1.14
@@ -583,7 +583,7 @@
 }
 
 /*
- * The following code implements pvscan --lvmetad.
+ * The following code implements pvscan --cache.
  */
 
 struct _pvscan_lvmetad_baton {
--- LVM2/lib/format_text/import_vsn1.c	2012/02/27 11:40:58	1.102
+++ LVM2/lib/format_text/import_vsn1.c	2012/03/02 18:09:46	1.103
@@ -60,7 +60,7 @@
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 
-	// TODO if this is pvscan --lvmetad, we want this check back.
+	// TODO if this is pvscan --cache, we want this check back.
 	if (lvmetad_active())
 		return 1;
 
--- LVM2/lib/metadata/metadata.c	2012/03/01 09:46:38	1.495
+++ LVM2/lib/metadata/metadata.c	2012/03/02 18:09:47	1.496
@@ -3620,6 +3620,7 @@
 
 	if (lvmetad_active()) {
 		info = lvmcache_info_from_pvid(dev->pvid, 0);
+// FIXME AGK no error unless 'warnings' set!
 		if (!info && !lvmetad_pv_lookup_by_devt(cmd, dev->dev))
 			return NULL;
 		info = lvmcache_info_from_pvid(dev->pvid, 0);
--- LVM2/man/pvscan.8.in	2012/03/02 16:58:41	1.7
+++ LVM2/man/pvscan.8.in	2012/03/02 18:09:47	1.8
@@ -3,6 +3,7 @@
 pvscan \- scan all disks for physical volumes
 .SH SYNOPSIS
 .B pvscan
+.RB [ \-\-cache " " DevicePath [ DevicePath ... ] ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-v | \-\-verbose ]
@@ -12,7 +13,6 @@
 .RB [ \-n | \-\-novolumegroup ]
 .RB [ \-s | \-\-short ]
 .RB [ \-u | \-\-uuid ]
-.RB [ \-\-lvmetad " " DevicePath [ DevicePath ... ] ]
 .SH DESCRIPTION
 .B pvscan
 scans all supported LVM block devices in the system for physical volumes.
@@ -31,10 +31,10 @@
 .BR \-u ", " \-\-uuid
 Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
 .TP
-.BR \-\-lvmetad " " DevicePath [ DevicePath... ]
-Scan a single device and contact lvmetad to update its cached state. Called
-internally by udev rules. The device is processed \fBregardless\fP of any device
-filters set in lvm.conf.
+.BR \-\-cache " " DevicePath [ DevicePath... ]
+Scan a single device and instruct the lvmetad daemon to update its cached
+state.  Called internally by udev rules. The device is processed
+\fBregardless\fP of any device filters set in lvm.conf.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8),
--- LVM2/test/lib/aux.sh	2012/02/23 23:58:42	1.39
+++ LVM2/test/lib/aux.sh	2012/03/02 18:09:47	1.40
@@ -80,7 +80,7 @@
 
 notify_lvmetad() {
 	if test -e LOCAL_LVMETAD; then
-		pvscan --lvmetad "$@" || true
+		pvscan --cache "$@" || true
 	fi
 }
 
--- LVM2/tools/args.h	2012/02/23 13:11:10	1.87
+++ LVM2/tools/args.h	2012/03/02 18:09:48	1.88
@@ -61,7 +61,7 @@
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
 arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
-arg(lvmetad_ARG, '\0', "lvmetad", NULL, 0)
+arg(cache_ARG, '\0', "cache", NULL, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
--- LVM2/tools/commands.h	2012/03/02 16:58:41	1.170
+++ LVM2/tools/commands.h	2012/03/02 18:09:48	1.171
@@ -663,6 +663,7 @@
    "List all physical volumes",
    PERMITTED_READ_ONLY,
    "pvscan " "\n"
+   "\t[--cache DevicePath [DevicePath...]] " "\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
    "\t[-h|-?|--help]" "\n"
@@ -670,12 +671,11 @@
    "\t[-P|--partial] " "\n"
    "\t[-s|--short] " "\n"
    "\t[-u|--uuid] " "\n"
-   "\t[--lvmetad DevicePath [DevicePath...]] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   exported_ARG, ignorelockingfailure_ARG, novolumegroup_ARG, partial_ARG,
-   short_ARG, uuid_ARG, lvmetad_ARG)
+   cache_ARG, exported_ARG, ignorelockingfailure_ARG, novolumegroup_ARG,
+   partial_ARG, short_ARG, uuid_ARG)
 
 xx(segtypes,
    "List available segment types",
--- LVM2/tools/pvscan.c	2012/03/02 16:58:41	1.56
+++ LVM2/tools/pvscan.c	2012/03/02 18:09:48	1.57
@@ -104,7 +104,7 @@
 	int ret = ECMD_PROCESSED;
 
 	if (!argc) {
-		log_error("List of Physical Volumes to tell lvmetad to cache required.");
+		log_error("List of Physical Volumes to be cached by the lvmetad daemon required.");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -144,7 +144,7 @@
 	pv_max_name_len = 0;
 	vg_max_name_len = 0;
 
-	if (arg_count(cmd, lvmetad_ARG))
+	if (arg_count(cmd, cache_ARG))
 		return _pvscan_lvmetad(cmd, argc, argv);
 
 	if (arg_count(cmd, novolumegroup_ARG) && arg_count(cmd, exported_ARG)) {
--- LVM2/udev/69-dm-lvm-metad.rules	2012/02/24 09:53:12	1.1
+++ LVM2/udev/69-dm-lvm-metad.rules	2012/03/02 18:09:48	1.2
@@ -20,6 +20,6 @@
 KERNEL=="dm-[0-9]*", ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
 
 # Only process devices already marked as a PV - this requires blkid to be called before.
-ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="$env{DM_SBIN_PATH}/pvscan --lvmetad $major:$minor"
+ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="$env{DM_SBIN_PATH}/pvscan --cache $major:$minor"
 
 LABEL="lvm_end"


