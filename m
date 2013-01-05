From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Jan 2013 00:41:59 +0000 (UTC)
Subject: master - lvmetad: add basic client-side debug logging
Message-ID: <20130105004159.3B8E9A0C48@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48e1ae7f6a48469be7bff795fde6ba978354ca7d
Commit:        48e1ae7f6a48469be7bff795fde6ba978354ca7d
Parent:        41e7f45258555bf28871a8243487a12751932842
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jan 5 00:35:50 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jan 5 00:35:50 2013 +0000

lvmetad: add basic client-side debug logging

First attempt at showing precisely what use any command is making of
lvmetad in the -vvvv trace information.
---
 lib/cache/lvmetad.c |   25 ++++++++++++++++++++++---
 1 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 0999fbd..db33553 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -91,6 +91,9 @@ void lvmetad_set_active(int active)
 	_lvmetad_use = active;
 }
 
+/*
+ * Use a crc of the strings in the filter as the lvmetad token.
+ */
 void lvmetad_set_token(const struct dm_config_value *filter)
 {
 	int ft = 0;
@@ -153,6 +156,7 @@ retry:
 
 static int _token_update(void)
 {
+	log_debug("Sending updated token to lvmetad: %s", _lvmetad_token ? : "<NONE>");
 	daemon_reply repl = _lvmetad_send("token_update", NULL);
 
 	if (repl.error || strcmp(daemon_reply_str(repl, "response", ""), "OK")) {
@@ -189,7 +193,7 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *action, const c
 
 	/* Unknown device permitted? */
 	if (found && !strcmp(daemon_reply_str(reply, "response", ""), "unknown")) {
-		log_very_verbose("Request to %s %s%sin lvmetad did not find object.",
+		log_very_verbose("Request to %s %s%sin lvmetad did not find any matching object.",
 				 action, object, *object ? " " : "");
 		*found = 0;
 		return 1;
@@ -319,10 +323,12 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	if (vgid) {
 		if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
 			return_NULL;
+		log_debug("Asking lvmetad for VG %s (%s)", uuid, vgname ? : "name unknown");
 		reply = _lvmetad_send("vg_lookup", "uuid = %s", uuid, NULL);
 	} else {
 		if (!vgname)
 			log_error(INTERNAL_ERROR "VG name required (VGID not available)");
+		log_debug("Asking lvmetad for VG %s", vgname);
 		reply = _lvmetad_send("vg_lookup", "name = %s", vgname, NULL);
 	}
 
@@ -433,6 +439,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 	if (!(vgmeta = _export_vg_to_config_tree(vg)))
 		return_0;
 
+	log_debug("Sending lvmetad updated metadata for VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
 	reply = _lvmetad_send("vg_update", "vgname = %s", vg->name,
 			      "metadata = %t", vgmeta, NULL);
 	dm_config_destroy(vgmeta);
@@ -485,6 +492,7 @@ int lvmetad_vg_remove(struct volume_group *vg)
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
 		return_0;
 
+	log_debug("Telling lvmetad to remove VGID %s (%s)", uuid, vg->name);
 	reply = _lvmetad_send("vg_remove", "uuid = %s", uuid, NULL);
 	result = _lvmetad_handle_reply(reply, "remove VG", vg->name, NULL);
 
@@ -506,6 +514,7 @@ int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found)
 	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
 		return_0;
 
+	log_debug("Asking lvmetad for PV %s", uuid);
 	reply = _lvmetad_send("pv_lookup", "uuid = %s", uuid, NULL);
 	if (!_lvmetad_handle_reply(reply, "lookup PV", "", found))
 		goto_out;
@@ -536,6 +545,7 @@ int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *f
 	if (!lvmetad_active())
 		return_0;
 
+	log_debug("Asking lvmetad for PV on %s", dev_name(dev));
 	reply = _lvmetad_send("pv_lookup", "device = %" PRId64, (int64_t) dev->dev, NULL);
 	if (!_lvmetad_handle_reply(reply, "lookup PV", dev_name(dev), found))
 		goto_out;
@@ -563,6 +573,7 @@ int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
 	if (!lvmetad_active())
 		return 1;
 
+	log_debug("Asking lvmetad for complete list of known PVs");
 	reply = _lvmetad_send("pv_list", NULL);
 	if (!_lvmetad_handle_reply(reply, "list PVs", "", NULL)) {
 		daemon_reply_destroy(reply);
@@ -589,6 +600,7 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 	if (!lvmetad_active())
 		return 1;
 
+	log_debug("Asking lvmetad for complete list of known VGs");
 	reply = _lvmetad_send("vg_list", NULL);
 	if (!_lvmetad_handle_reply(reply, "list VGs", "", NULL)) {
 		daemon_reply_destroy(reply);
@@ -726,6 +738,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 			return_0;
 		}
 
+		log_debug("Telling lvmetad to store PV %s (%s) in VG %s", dev_name(dev), uuid, vg->name);
 		reply = _lvmetad_send("pv_found",
 				      "pvmeta = %t", pvmeta,
 				      "vgname = %s", vg->name,
@@ -733,7 +746,11 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 				      NULL);
 		dm_config_destroy(vgmeta);
 	} else {
-		/* There are no MDAs on this PV. */
+		/*
+		 * There is no VG metadata stored on this PV.
+		 * It might or might not be an orphan.
+		 */
+		log_debug("Telling lvmetad to store PV %s (%s)", dev_name(dev), uuid);
 		reply = _lvmetad_send("pv_found", "pvmeta = %t", pvmeta, NULL);
 	}
 
@@ -781,6 +798,7 @@ int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler
          *        the whole stack from top to bottom (not yet upstream).
          */
 
+	log_debug("Telling lvmetad to forget any PV on %s", pv_name);
 	reply = _lvmetad_send("pv_gone", "device = %" PRId64, (int64_t) devno, NULL);
 
 	result = _lvmetad_handle_reply(reply, "drop PV", pv_name, &found);
@@ -907,8 +925,9 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 		return 0;
 	}
 
+	log_debug("Telling lvmetad to clear its cache");
 	reply = _lvmetad_send("pv_clear_all", NULL);
-	if (!_lvmetad_handle_reply(reply, "clear status on all PVs", "", NULL))
+	if (!_lvmetad_handle_reply(reply, "clear info about all PVs", "", NULL))
 		r = 0;
 	daemon_reply_destroy(reply);
 


