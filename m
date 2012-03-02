From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Mar 2012 20:46:39 -0000
Subject: LVM2 daemons/lvmetad/lvmetad-core.c lib/cache/ ...
Message-ID: <20120302204639.19383.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-02 20:46:37

Modified files:
	daemons/lvmetad: lvmetad-core.c 
	lib/cache      : lvmetad.c lvmetad.h 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c 

Log message:
	Pass struct device around internally rather than dev_t.
	Add 3rd daemon return state "unknown" for lookups that are carried out
	successfully but don't find the item requested.
	Avoid issuing error messages when it's expected that a device that's
	being looked up in lvmetad might not be there.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.198&r2=1.199
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.496&r2=1.497

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/03/01 22:52:59	1.46
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/03/02 20:46:36	1.47
@@ -47,6 +47,7 @@
 	fprintf(stderr, "[D %lu] ", pthread_self());
 	vfprintf(stderr, fmt, ap);
 	va_end(ap);
+	fflush(stderr);
 }
 
 static int debug_cft_line(const char *line, void *baton) {
@@ -412,14 +413,14 @@
 		debug("pv_lookup: could not find device %" PRIu64 "\n", devt);
 		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(res.cft);
-		return daemon_reply_simple("failed", "reason = %s", "device not found", NULL);
+		return daemon_reply_simple("unknown", "reason = %s", "device not found", NULL);
 	}
 
 	pv = make_pv_node(s, pvid, res.cft, NULL, res.cft->root);
 	if (!pv) {
 		unlock_pvid_to_pvmeta(s);
 		dm_config_destroy(res.cft);
-		return daemon_reply_simple("failed", "reason = %s", "PV not found", NULL);
+		return daemon_reply_simple("unknown", "reason = %s", "PV not found", NULL);
 	}
 
 	pv->key = "physical_volume";
@@ -520,12 +521,12 @@
 	debug("vg_lookup: updated uuid = %s, name = %s\n", uuid, name);
 
 	if (!uuid)
-		return daemon_reply_simple("failed", "reason = %s", "VG not found", NULL);
+		return daemon_reply_simple("unknown", "reason = %s", "VG not found", NULL);
 
 	cft = lock_vg(s, uuid);
 	if (!cft || !cft->root) {
 		unlock_vg(s, uuid);
-		return daemon_reply_simple("failed", "reason = %s", "UUID not found", NULL);
+		return daemon_reply_simple("unknown", "reason = %s", "UUID not found", NULL);
 	}
 
 	metadata = cft->root;
@@ -821,7 +822,7 @@
 		pvid = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
 	if (!pvid) {
 		unlock_pvid_to_pvmeta(s);
-		return daemon_reply_simple("failed", "reason = %s", "device not in cache", NULL);
+		return daemon_reply_simple("unknown", "reason = %s", "device not in cache", NULL);
 	}
 
 	debug("pv_gone (updated): %s / %" PRIu64 "\n", pvid, device);
@@ -836,7 +837,7 @@
 		dm_config_destroy(pvmeta);
 		return daemon_reply_simple("OK", NULL);
 	} else
-		return daemon_reply_simple("failed", "reason = %s", "PVID does not exist", NULL);
+		return daemon_reply_simple("unknown", "reason = %s", "PVID does not exist", NULL);
 }
 
 static response pv_found(lvmetad_state *s, request r)
@@ -912,6 +913,7 @@
 		else {
 			unlock_vg(s, vgid);
 			return daemon_reply_simple("failed", "reason = %s",
+// FIXME provide meaningful-to-user error message
 						   "internal treason!", NULL);
 		}
 		unlock_vg(s, vgid);
--- LVM2/lib/cache/lvmetad.c	2012/03/02 18:09:46	1.14
+++ LVM2/lib/cache/lvmetad.c	2012/03/02 20:46:37	1.15
@@ -31,7 +31,7 @@
 	if (_using_lvmetad) { /* configured by the toolcontext */
 		_lvmetad = lvmetad_open(socket ?: DEFAULT_RUN_DIR "/lvmetad.socket");
 		if (_lvmetad.socket_fd < 0 || _lvmetad.error) {
-			log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to scanning.", strerror(_lvmetad.error));
+			log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.", strerror(_lvmetad.error));
 			_using_lvmetad = 0;
 		}
 	}
@@ -39,20 +39,41 @@
 
 /*
  * Helper; evaluate the reply from lvmetad, check for errors, print diagnostics
- * and return a summary success/failure exit code. Frees up the reply resources
- * as well.
+ * and return a summary success/failure exit code.
+ *
+ * If found is set, *found indicates whether or not device exists,
+ * and missing device is not treated as an error.
  */
-static int _lvmetad_handle_reply(daemon_reply reply, const char *action, const char *object) {
-	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-		log_error("Request to %s %s in lvmetad has failed. Reason: %s",
-			  action, object, reply.error ? strerror(reply.error) :
-			  daemon_reply_str(reply, "reason", "Unknown."));
-		daemon_reply_destroy(reply);
+static int _lvmetad_handle_reply(daemon_reply reply, const char *action, const char *object,
+				 int *found)
+{
+	if (reply.error) {
+		log_error("Request to %s %s%sin lvmetad gave response %s.",
+			  action, object, *object ? " " : "", strerror(reply.error));
 		return 0;
 	}
 
-	daemon_reply_destroy(reply);
-	return 1;
+	/* All OK? */
+	if (!strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		if (found)
+			*found = 1;
+		return 1;
+	}
+
+	/* Unknown device permitted? */
+	if (found && !strcmp(daemon_reply_str(reply, "response", ""), "unknown")) {
+		log_very_verbose("Request to %s %s%sin lvmetad did not find object.",
+				 action, object, *object ? " " : "");
+		*found = 0;
+		return 1;
+	}
+
+	log_error("Request to %s %s%sin lvmetad gave response %s. Reason: %s",
+		  action, object, *object ? " " : "", 
+		  daemon_reply_str(reply, "response", "<missing>"),
+		  daemon_reply_str(reply, "reason", "<missing>"));
+
+	return 0;
 }
 
 static int _read_mda(struct lvmcache_info *info,
@@ -268,8 +289,10 @@
 				   NULL);
 	dm_free(buf);
 
-	if (!_lvmetad_handle_reply(reply, "update VG", vg->name))
+	if (!_lvmetad_handle_reply(reply, "update VG", vg->name, NULL)) {
+		daemon_reply_destroy(reply);
 		return 0;
+	}
 
 	n = (vg->fid && vg->fid->metadata_areas_index) ?
 		dm_hash_get_first(vg->fid->metadata_areas_index) : NULL;
@@ -304,6 +327,7 @@
 {
 	char uuid[64];
 	daemon_reply reply;
+	int result;
 
 	if (!_using_lvmetad)
 		return 1; /* just fake it */
@@ -313,14 +337,18 @@
 
 	reply = daemon_send_simple(_lvmetad, "vg_remove", "uuid = %s", uuid, NULL);
 
-	return _lvmetad_handle_reply(reply, "remove VG", vg->name);
+	result = _lvmetad_handle_reply(reply, "remove VG", vg->name, NULL);
+
+	daemon_reply_destroy(reply);
+
+	return result;
 }
 
-int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid)
+int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found)
 {
 	char uuid[64];
 	daemon_reply reply;
-	int result = 1;
+	int result = 0;
 	struct dm_config_node *cn;
 
 	if (!_using_lvmetad)
@@ -331,40 +359,51 @@
 
 	reply = daemon_send_simple(_lvmetad, "pv_lookup", "uuid = %s", uuid, NULL);
 
-	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-		_lvmetad_handle_reply(reply, "lookup PVs", "");
-		return_0;
-	}
+	if (!_lvmetad_handle_reply(reply, "lookup PV", "", found))
+		goto_out;
+
+	if (found && !*found)
+		goto out_success;
 
 	if (!(cn = dm_config_find_node(reply.cft->root, "physical_volume")))
-		result = 0;
+		goto_out;
         else if (!_pv_populate_lvmcache(cmd, cn, 0))
-		result = 0;
+		goto_out;
 
+out_success:
+	result = 1;
+
+out:
 	daemon_reply_destroy(reply);
+
 	return result;
 }
 
-int lvmetad_pv_lookup_by_devt(struct cmd_context *cmd, dev_t device)
+int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *found)
 {
-	int result = 1;
+	int result = 0;
 	daemon_reply reply;
 	struct dm_config_node *cn;
 
 	if (!_using_lvmetad)
 		return_0;
 
-	reply = daemon_send_simple(_lvmetad, "pv_lookup", "device = %d", device, NULL);
+	reply = daemon_send_simple(_lvmetad, "pv_lookup", "device = %d", dev->dev, NULL);
 
-	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-		_lvmetad_handle_reply(reply, "lookup PVs", "");
-		return_0;
-	}
+	if (!_lvmetad_handle_reply(reply, "lookup PV", dev_name(dev), found))
+		goto_out;
+
+	if (found && !*found)
+		goto out_success;
 
 	cn = dm_config_find_node(reply.cft->root, "physical_volume");
-	if (!cn || !_pv_populate_lvmcache(cmd, cn, device))
-		result = 0;
+	if (!cn || !_pv_populate_lvmcache(cmd, cn, dev->dev))
+		goto_out;
 
+out_success:
+	result = 1;
+
+out:
 	daemon_reply_destroy(reply);
 	return result;
 }
@@ -379,8 +418,8 @@
 
 	reply = daemon_send_simple(_lvmetad, "pv_list", NULL);
 
-	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-		_lvmetad_handle_reply(reply, "list PVs", "");
+	if (!_lvmetad_handle_reply(reply, "list PVs", "", NULL)) {
+		daemon_reply_destroy(reply);
 		return_0;
 	}
 
@@ -389,6 +428,7 @@
 			_pv_populate_lvmcache(cmd, cn, 0);
 
 	daemon_reply_destroy(reply);
+
 	return 1;
 }
 
@@ -404,8 +444,9 @@
 		return 1;
 
 	reply = daemon_send_simple(_lvmetad, "vg_list", NULL);
-	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
-		_lvmetad_handle_reply(reply, "list VGs", "");
+
+	if (!_lvmetad_handle_reply(reply, "list VGs", "", NULL)) {
+		daemon_reply_destroy(reply);
 		return_0;
 	}
 
@@ -497,6 +538,7 @@
 	const char *mdas = NULL;
 	char *pvmeta;
 	char *buf = NULL;
+	int result;
 
 	if (!_using_lvmetad)
 		return 1;
@@ -553,18 +595,29 @@
 	}
 
 	dm_free(pvmeta);
-	return _lvmetad_handle_reply(reply, "update PV", uuid);
+
+	result = _lvmetad_handle_reply(reply, "update PV", uuid, NULL);
+	daemon_reply_destroy(reply);
+
+	return result;
 }
 
 static int _lvmetad_pv_gone(dev_t device, const char *pv_name)
 {
+	int result;
+	int found;
+
 	if (!_using_lvmetad)
 		return 1;
 
-	daemon_reply reply =
-		daemon_send_simple(_lvmetad, "pv_gone", "device = %d", device, NULL);
+	daemon_reply reply = daemon_send_simple(_lvmetad, "pv_gone", "device = %d", device, NULL);
+
+	result = _lvmetad_handle_reply(reply, "drop PV", pv_name, &found);
+	/* We don't care whether or not the daemon had the PV cached. */
 
-	return _lvmetad_handle_reply(reply, "drop PV", pv_name);
+	daemon_reply_destroy(reply);
+
+	return result;
 }
 
 int lvmetad_pv_gone(struct device *dev)
--- LVM2/lib/cache/lvmetad.h	2012/03/02 16:58:41	1.4
+++ LVM2/lib/cache/lvmetad.h	2012/03/02 20:46:37	1.5
@@ -79,8 +79,13 @@
  */
 int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd);
 
-int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid);
-int lvmetad_pv_lookup_by_devt(struct cmd_context *cmd, dev_t dev);
+/*
+ * Lookup an individual PV.
+ * If found is not NULL, it is set according to whether or not the PV is found,
+ * otherwise if the PV is not found an error is returned.
+ */
+int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found);
+int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *found);
 
 /*
  * Request a list of all VGs available to lvmetad and use it to fill in
@@ -111,8 +116,8 @@
 #    define lvmetad_pv_found(pvid, device, fmt, label_sector, vg)	(1)
 #    define lvmetad_pv_gone(dev)	(1)
 #    define lvmetad_pv_list_to_lvmcache(cmd)	(1)
-#    define lvmetad_pv_lookup(cmd, pvid)	(0)
-#    define lvmetad_pv_lookup_by_devt(cmd, dev)	(0)
+#    define lvmetad_pv_lookup(cmd, pvid, found)	(0)
+#    define lvmetad_pv_lookup_by_dev(cmd, dev, found)	(0)
 #    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
 #    define pvscan_lvmetad(cmd, argc, argv)	(0)
--- LVM2/lib/format_text/format-text.c	2012/02/29 02:35:36	1.198
+++ LVM2/lib/format_text/format-text.c	2012/03/02 20:46:37	1.199
@@ -1445,7 +1445,7 @@
 
 	if (lvmetad_active()) {
 		info = lvmcache_info_from_pvid(dev->pvid, 0);
-		if (!info && !lvmetad_pv_lookup_by_devt(fmt->cmd, dev->dev))
+		if (!info && !lvmetad_pv_lookup_by_dev(fmt->cmd, dev, NULL))
 			return 0;
 		info = lvmcache_info_from_pvid(dev->pvid, 0);
 	} else {
--- LVM2/lib/metadata/metadata.c	2012/03/02 18:09:47	1.496
+++ LVM2/lib/metadata/metadata.c	2012/03/02 20:46:37	1.497
@@ -3614,15 +3614,23 @@
 	struct lvmcache_info *info;
 	struct device *dev;
 	const struct format_type *fmt;
+	int found;
 
 	if (!(dev = dev_cache_get(pv_name, cmd->filter)))
 		return_NULL;
 
 	if (lvmetad_active()) {
 		info = lvmcache_info_from_pvid(dev->pvid, 0);
-// FIXME AGK no error unless 'warnings' set!
-		if (!info && !lvmetad_pv_lookup_by_devt(cmd, dev->dev))
-			return NULL;
+		if (!info) {
+			if (!lvmetad_pv_lookup_by_dev(cmd, dev, &found))
+				return_NULL;
+			if (!found) {
+				if (warnings)
+					log_error("No physical volume found in lvmetad cache for %s",
+						  pv_name);
+				return NULL;
+			}
+		}
 		info = lvmcache_info_from_pvid(dev->pvid, 0);
 		label = lvmcache_get_label(info);
 	} else {


