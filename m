From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Mar 2012 16:58:42 -0000
Subject: LVM2 lib/cache/lvmetad.c lib/cache/lvmetad.h t ...
Message-ID: <20120302165842.29124.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-02 16:58:41

Modified files:
	lib/cache      : lvmetad.c lvmetad.h 
	tools          : commands.h pvremove.c pvscan.c 
	man            : pvscan.8.in 

Log message:
	Allow multiple device names with pvscan --lvmetad.
	Hold global lock in pvscan --lvmetad.  (This might need refinement.)
	Add PV name to "PV gone" messages.
	Adjust some log message severities.  (More changes needed.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/lib/cache/lvmetad.c	2012/03/01 22:52:59	1.12
+++ LVM2/lib/cache/lvmetad.c	2012/03/02 16:58:41	1.13
@@ -31,7 +31,7 @@
 	if (_using_lvmetad) { /* configured by the toolcontext */
 		_lvmetad = lvmetad_open(socket ?: DEFAULT_RUN_DIR "/lvmetad.socket");
 		if (_lvmetad.socket_fd < 0 || _lvmetad.error) {
-			log_warn("Failed to connect to lvmetad: %s. Falling back to scanning.", strerror(_lvmetad.error));
+			log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to scanning.", strerror(_lvmetad.error));
 			_using_lvmetad = 0;
 		}
 	}
@@ -91,7 +91,7 @@
 	struct format_type *fmt = fmt_name ? get_format_by_name(cmd, fmt_name) : NULL;
 
 	if (!fmt) {
-		log_warn("No format for PV %s. It is probably missing.", pvid_txt);
+		log_error("PV %s not recognised. Is the device missing?", pvid_txt);
 		return NULL;
 	}
 
@@ -100,12 +100,12 @@
 		device = dev_cache_get_by_devt(fallback, cmd->filter);
 
 	if (!device) {
-		log_warn("No device for PV %s.", pvid_txt);
+		log_error("No device found for PV %s.", pvid_txt);
 		return NULL;
 	}
 
 	if (!pvid_txt || !id_read_format(&pvid, pvid_txt)) {
-		log_warn("Missing or ill-formatted PVID for PV: %s.", pvid_txt);
+		log_error("Missing or ill-formatted PVID for PV: %s.", pvid_txt);
 		return NULL;
 	}
 
@@ -556,7 +556,7 @@
 	return _lvmetad_handle_reply(reply, "update PV", uuid);
 }
 
-int lvmetad_pv_gone(dev_t device)
+static int _lvmetad_pv_gone(dev_t device, const char *pv_name)
 {
 	if (!_using_lvmetad)
 		return 1;
@@ -564,7 +564,12 @@
 	daemon_reply reply =
 		daemon_send_simple(_lvmetad, "pv_gone", "device = %d", device, NULL);
 
-	return _lvmetad_handle_reply(reply, "drop PV", "");
+	return _lvmetad_handle_reply(reply, "drop PV", pv_name);
+}
+
+int lvmetad_pv_gone(struct device *dev)
+{
+	return _lvmetad_pv_gone(dev->dev, dev_name(dev));
 }
 
 int lvmetad_active(void)
@@ -623,7 +628,7 @@
 	return MKDEV(major, minor);
 }
 
-int pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
+int pvscan_lvmetad_single(struct cmd_context *cmd, const char *pv_name)
 {
 	struct device *dev;
 	struct label *label;
@@ -633,37 +638,32 @@
 	/* Create a dummy instance. */
 	struct format_instance_ctx fic = { .type = 0 };
 
-	if (argc != 1) {
-		log_error("Exactly one device parameter required.");
-		return 0;
-	}
-
 	if (!lvmetad_active()) {
 		log_error("Cannot proceed since lvmetad is not active.");
 		return 0;
 	}
 
-	dev = dev_cache_get(argv[0], NULL);
-	if (!dev && _parse_devt(argv[0]) != -1)
-		dev = dev_cache_get_by_devt(_parse_devt(argv[0]), NULL);
+	dev = dev_cache_get(pv_name, NULL);
+	if (!dev && _parse_devt(pv_name) != -1)
+		dev = dev_cache_get_by_devt(_parse_devt(pv_name), NULL);
 
 	if (!dev) {
-		if (_parse_devt(argv[0]) == -1) {
-			log_error("For devices that do not exist, we need a MAJOR:MINOR pair.");
+		if (_parse_devt(pv_name) == -1) {
+			log_error("Unrecognised device name %s.  (Use MAJOR:MINOR for new devices.)", pv_name);
 			return 0;
 		}
 
-		if (!lvmetad_pv_gone(_parse_devt(argv[0])))
-			goto fatal;
+		if (!_lvmetad_pv_gone(_parse_devt(pv_name), pv_name))
+			goto_bad;
 
-		log_info("Device %s not found and was wiped from lvmetad.", argv[0]);
+		log_print("Device %s not found.  Cleared from lvmetad cache.", pv_name);
 		return 1;
 	}
 
 	if (!label_read(dev, &label, 0)) {
-		log_warn("No PV label found on %s.", dev_name(dev));
-		if (!lvmetad_pv_gone(dev->dev))
-			goto fatal;
+		log_print("No PV label found on %s.", dev_name(dev));
+		if (!lvmetad_pv_gone(dev))
+			goto_bad;
 		return 1;
 	}
 
@@ -684,13 +684,15 @@
 	 * sync needs to be killed.
 	 */
 	if (!lvmetad_pv_found(*(struct id *)dev->pvid, dev, lvmcache_fmt(info),
-			      label->sector, baton.vg))
-		goto fatal;
+			      label->sector, baton.vg)) {
+		release_vg(baton.vg);
+		goto_bad;
+	}
 
 	release_vg(baton.vg);
 	return 1;
-fatal:
-	release_vg(baton.vg);
+
+bad:
 	/* FIXME kill lvmetad automatically if we can */
 	log_error("Update of lvmetad failed. This is a serious problem.\n  "
 		  "It is strongly recommended that you restart lvmetad immediately.");
--- LVM2/lib/cache/lvmetad.h	2012/02/28 18:22:52	1.3
+++ LVM2/lib/cache/lvmetad.h	2012/03/02 16:58:41	1.4
@@ -71,7 +71,7 @@
  * multiple device names, so this needs a unique and stable name, the same as
  * provided to lvmetad_pv_found.
  */
-int lvmetad_pv_gone(dev_t device);
+int lvmetad_pv_gone(struct device *dev);
 
 /*
  * Request a list of all PVs available to lvmetad. If requested, this will also
@@ -99,7 +99,7 @@
  * Scan a single device and update lvmetad with the result(s). If the device
  * node does not exist, it must be supplied in a major:minor format.
  */
-int pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv);
+int pvscan_lvmetad_single(struct cmd_context *cmd, const char *pv_name);
 
 #  else		/* LVMETAD_SUPPORT */
 
@@ -109,7 +109,7 @@
 #    define lvmetad_vg_update(vg)	(1)
 #    define lvmetad_vg_remove(vg)	(1)
 #    define lvmetad_pv_found(pvid, device, fmt, label_sector, vg)	(1)
-#    define lvmetad_pv_gone(device)	(1)
+#    define lvmetad_pv_gone(dev)	(1)
 #    define lvmetad_pv_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_pv_lookup(cmd, pvid)	(0)
 #    define lvmetad_pv_lookup_by_devt(cmd, dev)	(0)
--- LVM2/tools/commands.h	2012/02/28 18:08:08	1.169
+++ LVM2/tools/commands.h	2012/03/02 16:58:41	1.170
@@ -670,7 +670,7 @@
    "\t[-P|--partial] " "\n"
    "\t[-s|--short] " "\n"
    "\t[-u|--uuid] " "\n"
-   "\t[--lvmetad DevicePath] " "\n"
+   "\t[--lvmetad DevicePath [DevicePath...]] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
--- LVM2/tools/pvremove.c	2012/03/02 02:55:45	1.40
+++ LVM2/tools/pvremove.c	2012/03/02 16:58:41	1.41
@@ -129,7 +129,7 @@
 	}
 
 	/* FIXME Avoid error if we expect that daemon might not know device */
-	if (!lvmetad_pv_gone(dev->dev))
+	if (!lvmetad_pv_gone(dev))
 		goto_out;
 
 	log_print("Labels on physical volume \"%s\" successfully wiped",
--- LVM2/tools/pvscan.c	2012/02/28 18:08:08	1.55
+++ LVM2/tools/pvscan.c	2012/03/02 16:58:41	1.56
@@ -99,6 +99,35 @@
 					   pv_pe_size(pv)));
 }
 
+static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
+{
+	int ret = ECMD_PROCESSED;
+
+	if (!argc) {
+		log_error("List of Physical Volumes to tell lvmetad to cache required.");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
+		log_error("Unable to obtain global lock.");
+		return ECMD_FAILED;
+	}
+
+	log_verbose("Using physical volume(s) on command line");
+	while (argc--) {
+		if (!pvscan_lvmetad_single(cmd, *argv++)) {
+			ret = ECMD_FAILED;
+			break;
+		}
+		if (sigint_caught())
+			break;
+	}
+
+	unlock_vg(cmd, VG_GLOBAL);
+
+	return ret;
+}
+
 int pvscan(struct cmd_context *cmd, int argc, char **argv)
 {
 	int new_pvs_found = 0;
@@ -115,20 +144,14 @@
 	pv_max_name_len = 0;
 	vg_max_name_len = 0;
 
-	if (arg_count(cmd, lvmetad_ARG)) {
-		if (!pvscan_lvmetad(cmd, argc, argv)) {
-			stack;
-			return ECMD_FAILED;
-		}
-		return ECMD_PROCESSED;
-	}
+	if (arg_count(cmd, lvmetad_ARG))
+		return _pvscan_lvmetad(cmd, argc, argv);
 
 	if (arg_count(cmd, novolumegroup_ARG) && arg_count(cmd, exported_ARG)) {
 		log_error("Options -e and -n are incompatible");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, exported_ARG) || arg_count(cmd, novolumegroup_ARG))
 		log_warn("WARNING: only considering physical volumes %s",
 			  arg_count(cmd, exported_ARG) ?
 			  "of exported volume group(s)" : "in no volume group");
--- LVM2/man/pvscan.8.in	2012/02/28 18:17:37	1.6
+++ LVM2/man/pvscan.8.in	2012/03/02 16:58:41	1.7
@@ -12,7 +12,7 @@
 .RB [ \-n | \-\-novolumegroup ]
 .RB [ \-s | \-\-short ]
 .RB [ \-u | \-\-uuid ]
-.RB [ \-\-lvmetad " " DevicePath ]
+.RB [ \-\-lvmetad " " DevicePath [ DevicePath ... ] ]
 .SH DESCRIPTION
 .B pvscan
 scans all supported LVM block devices in the system for physical volumes.
@@ -31,7 +31,7 @@
 .BR \-u ", " \-\-uuid
 Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
 .TP
-.BR \-\-lvmetad " " DevicePath
+.BR \-\-lvmetad " " DevicePath [ DevicePath... ]
 Scan a single device and contact lvmetad to update its cached state. Called
 internally by udev rules. The device is processed \fBregardless\fP of any device
 filters set in lvm.conf.


