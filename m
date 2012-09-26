From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:40 +0000 (UTC)
Subject: master - lib/cache/lvmetad: Refactor to use dm_config_tree in requests.
Message-ID: <20120926175540.56C76A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2276379a71ec9d790241633b013a707a07c5046b
Commit:        2276379a71ec9d790241633b013a707a07c5046b
Parent:        ea14d5159cd3a196c0754f4e37539dee1eb2d169
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Aug 11 10:37:28 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 14:49:15 2012 +0200

lib/cache/lvmetad: Refactor to use dm_config_tree in requests.

We were using daemon_send_simple until now, but it is no longer adequate, since
we need to manipulate requests in a generic way (adding a validity token to each
request), and the tree-based request interface is much more suitable for this.
---
 lib/cache/lvmetad.c           |  220 ++++++++++++++++++++++------------------
 lib/cache/lvmetad.h           |    2 +
 lib/format_text/format-text.c |   23 +++--
 lib/metadata/metadata.h       |    3 +-
 4 files changed, 137 insertions(+), 111 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index feab361..53dbab0 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -23,6 +23,7 @@
 
 static int _using_lvmetad = 0;
 static daemon_handle _lvmetad;
+static const char *_lvmetad_token;
 
 void lvmetad_init(void)
 {
@@ -36,6 +37,24 @@ void lvmetad_init(void)
 	}
 }
 
+static daemon_reply _lvmetad_send(const char *id, ...)
+{
+	va_list ap;
+	va_start(ap, id);
+	daemon_reply repl;
+	daemon_request req = daemon_request_make(id);
+
+	// daemon_request_extend(req, "token", _lvmetad_token, NULL);
+	daemon_request_extend_v(req, ap);
+
+	repl = daemon_send(_lvmetad, req);
+
+	daemon_request_destroy(req);
+
+	va_end(ap);
+	return repl;
+}
+
 /*
  * Helper; evaluate the reply from lvmetad, check for errors, print diagnostics
  * and return a summary success/failure exit code.
@@ -190,11 +209,11 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	if (vgid) {
 		if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
 			return_NULL;
-		reply = daemon_send_simple(_lvmetad, "vg_lookup", "uuid = %s", uuid, NULL);
+		reply = _lvmetad_send("vg_lookup", "uuid = %s", uuid, NULL);
 	} else {
 		if (!vgname)
 			log_error(INTERNAL_ERROR "VG name required (VGID not available)");
-		reply = daemon_send_simple(_lvmetad, "vg_lookup", "name = %s", vgname, NULL);
+		reply = _lvmetad_send("vg_lookup", "name = %s", vgname, NULL);
 	}
 
 	if (!strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
@@ -264,9 +283,28 @@ static int _fixup_ignored(struct metadata_area *mda, void *baton) {
 	return 1;
 }
 
-int lvmetad_vg_update(struct volume_group *vg)
+static struct dm_config_tree *_export_vg_to_config_tree(struct volume_group *vg)
 {
 	char *buf = NULL;
+	struct dm_config_tree *vgmeta;
+
+	if (!export_vg_to_buffer(vg, &buf)) {
+		log_error("Could not format VG metadata.");
+		return 0;
+	}
+
+	if (!(vgmeta = dm_config_from_string(buf))) {
+		log_error("Error parsing VG metadata.");
+		dm_free(buf);
+		return 0;
+	}
+
+	dm_free(buf);
+	return vgmeta;
+}
+
+int lvmetad_vg_update(struct volume_group *vg)
+{
 	daemon_reply reply;
 	struct dm_hash_node *n;
 	struct metadata_area *mda;
@@ -274,6 +312,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
 	struct _fixup_baton baton;
+	struct dm_config_tree *vgmeta;
 
 	if (!vg)
 		return 0;
@@ -281,20 +320,12 @@ int lvmetad_vg_update(struct volume_group *vg)
 	if (!_using_lvmetad || test_mode())
 		return 1; /* fake it */
 
-	/* TODO. This is not entirely correct, since export_vg_to_buffer
-	 * adds trailing nodes to the buffer. We may need to use
-	 * export_vg_to_config_tree and format the buffer ourselves. It
-	 * does, however, work for now, since the garbage is well
-	 * formatted and has no conflicting keys with the rest of the
-	 * request.  */
-	if (!export_vg_to_buffer(vg, &buf)) {
-		log_error("Could not format VG metadata.");
-		return 0;
-	}
+	if (!(vgmeta = _export_vg_to_config_tree(vg)))
+		return_0;
 
-	reply = daemon_send_simple(_lvmetad, "vg_update", "vgname = %s", vg->name,
-				   "metadata = %b", strchr(buf, '{'), NULL);
-	dm_free(buf);
+	reply = _lvmetad_send("vg_update", "vgname = %s", vg->name,
+			      "metadata = %t", vgmeta, NULL);
+	dm_config_destroy(vgmeta);
 
 	if (!_lvmetad_handle_reply(reply, "update VG", vg->name, NULL)) {
 		daemon_reply_destroy(reply);
@@ -344,8 +375,7 @@ int lvmetad_vg_remove(struct volume_group *vg)
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
 		return_0;
 
-	reply = daemon_send_simple(_lvmetad, "vg_remove", "uuid = %s", uuid, NULL);
-
+	reply = _lvmetad_send("vg_remove", "uuid = %s", uuid, NULL);
 	result = _lvmetad_handle_reply(reply, "remove VG", vg->name, NULL);
 
 	daemon_reply_destroy(reply);
@@ -366,8 +396,7 @@ int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found)
 	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
 		return_0;
 
-	reply = daemon_send_simple(_lvmetad, "pv_lookup", "uuid = %s", uuid, NULL);
-
+	reply = _lvmetad_send("pv_lookup", "uuid = %s", uuid, NULL);
 	if (!_lvmetad_handle_reply(reply, "lookup PV", "", found))
 		goto_out;
 
@@ -397,8 +426,7 @@ int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *f
 	if (!_using_lvmetad)
 		return_0;
 
-	reply = daemon_send_simple(_lvmetad, "pv_lookup", "device = %d", dev->dev, NULL);
-
+	reply = _lvmetad_send("pv_lookup", "device = %d", dev->dev, NULL);
 	if (!_lvmetad_handle_reply(reply, "lookup PV", dev_name(dev), found))
 		goto_out;
 
@@ -425,8 +453,7 @@ int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
 	if (!_using_lvmetad)
 		return 1;
 
-	reply = daemon_send_simple(_lvmetad, "pv_list", NULL);
-
+	reply = _lvmetad_send("pv_list", NULL);
 	if (!_lvmetad_handle_reply(reply, "list PVs", "", NULL)) {
 		daemon_reply_destroy(reply);
 		return_0;
@@ -452,8 +479,7 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 	if (!_using_lvmetad)
 		return 1;
 
-	reply = daemon_send_simple(_lvmetad, "vg_list", NULL);
-
+	reply = _lvmetad_send("vg_list", NULL);
 	if (!_lvmetad_handle_reply(reply, "list VGs", "", NULL)) {
 		daemon_reply_destroy(reply);
 		return_0;
@@ -476,66 +502,67 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 	return 1;
 }
 
-struct _print_mda_baton {
+struct _extract_mda_baton {
 	int i;
-	char *buffer;
+	struct dm_config_tree *cft;
+	struct dm_config_node *pre_sib;
 };
 
-static int _print_mda(struct metadata_area *mda, void *baton)
+static int _extract_mda(struct metadata_area *mda, void *baton)
 {
+	struct _extract_mda_baton *b = baton;
+	struct dm_config_node *cn;
 	int result = 0;
-	struct _print_mda_baton *b = baton;
-	char *buf, *mda_txt;
+	char id[32];
 
 	if (!mda->ops->mda_export_text) /* do nothing */
 		return 1;
 
-	buf = b->buffer;
-	mda_txt = mda->ops->mda_export_text(mda);
-	if (!dm_asprintf(&b->buffer, "%s mda%i { %s }", b->buffer ?: "", b->i, mda_txt))
-		goto_out;
+	dm_snprintf(id, 32, "mda%d", b->i);
+	if (!(cn = make_config_node(b->cft, id, b->cft->root, b->pre_sib)))
+		return 0;
+	if (!mda->ops->mda_export_text(mda, b->cft, cn))
+		return 0;
+
 	b->i ++;
-	result = 1;
-out:
-	dm_free(mda_txt);
-	dm_free(buf);
-	return result;
+	b->pre_sib = cn; /* for efficiency */
+
+	return 1;
 }
 
-static int _print_da(struct disk_locn *da, void *baton)
+static int _extract_da(struct disk_locn *da, void *baton)
 {
-	struct _print_mda_baton *b;
-	char *buf;
+	struct _extract_mda_baton *b = baton;
+	struct dm_config_node *cn;
+	char id[32];
 
 	if (!da)
 		return 1;
 
-	b = baton;
-	buf = b->buffer;
-	if (!dm_asprintf(&b->buffer, "%s da%i { offset = %" PRIu64
-			 " size = %" PRIu64 " }",
-			 b->buffer ?: "", b->i, da->offset, da->size))
-	{
-		dm_free(buf);
-		return_0;
-	}
+	dm_snprintf(id, 32, "da%d", b->i);
+	if (!(cn = make_config_node(b->cft, id, b->cft->root, b->pre_sib)))
+		return 0;
+	if (!config_make_nodes(b->cft, cn, NULL, "offset = %d", da->offset, "size = %d", da->size, NULL))
+		return 0;
+
 	b->i ++;
-	dm_free(buf);
+	b->pre_sib = cn; /* for efficiency */
 
 	return 1;
 }
 
-static const char *_print_mdas(struct lvmcache_info *info)
+static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
+			 struct dm_config_node *pre_sib)
 {
-	struct _print_mda_baton baton = { .i = 0, .buffer = NULL };
+	struct _extract_mda_baton baton = { .i = 0, .cft = cft, .pre_sib = NULL };
 
-	if (!lvmcache_foreach_mda(info, &_print_mda, &baton))
-		return NULL;
+	if (!lvmcache_foreach_mda(info, &_extract_mda, &baton))
+		return 0;
 	baton.i = 0;
-	if (!lvmcache_foreach_da(info, &_print_da, &baton))
-		return NULL;
+	if (!lvmcache_foreach_da(info, &_extract_da, &baton))
+		return 0;
 
-	return baton.buffer;
+	return 1;
 }
 
 int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_type *fmt,
@@ -545,8 +572,7 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 	daemon_reply reply;
 	struct lvmcache_info *info;
 	const char *mdas = NULL;
-	char *pvmeta;
-	char *buf = NULL;
+	struct dm_config_tree *pvmeta, *vgmeta;
 	const char *status;
 	int result;
 
@@ -556,46 +582,45 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
                 return_0;
 
-	/* FIXME A more direct route would be much preferable. */
-	if ((info = lvmcache_info_from_pvid((const char *)&pvid, 0)))
-		mdas = _print_mdas(info);
-
-	if (!dm_asprintf(&pvmeta,
-			 "{ device = %" PRIu64 "\n"
-			 "  dev_size = %" PRIu64 "\n"
-			 "  format = \"%s\"\n"
-			 "  label_sector = %" PRIu64 "\n"
-			 "  id = \"%s\"\n"
-			 "  %s"
-			 "}", device->dev,
-			 info ? lvmcache_device_size(info) : 0,
-			 fmt->name, label_sector, uuid, mdas ?: "")) {
-		dm_free((char *)mdas);
+	pvmeta = dm_config_create();
+	if (!pvmeta)
+		return_0;
+
+	info = lvmcache_info_from_pvid((const char *)&pvid, 0);
+
+	if (!(pvmeta->root = make_config_node(pvmeta, "pv", NULL, NULL))) {
+		dm_config_destroy(pvmeta);
+		return_0;
+	}
+
+	if (!config_make_nodes(pvmeta, pvmeta->root, NULL,
+			       "device = %d", device->dev,
+			       "dev_size = %d", info ? lvmcache_device_size(info) : 0,
+			       "format = %s", fmt->name,
+			       "label_sector = %d", label_sector,
+			       "id = %s", uuid,
+			       NULL))
+	{
+		dm_config_destroy(pvmeta);
 		return_0;
 	}
 
-	dm_free((char *)mdas);
+	if (info)
+		/* FIXME A more direct route would be much preferable. */
+		_extract_mdas(info, pvmeta, pvmeta->root);
 
 	if (vg) {
-		/*
-		 * TODO. This is not entirely correct, since export_vg_to_buffer
-		 * adds trailing garbage to the buffer. We may need to use
-		 * export_vg_to_config_tree and format the buffer ourselves. It
-		 * does, however, work for now, since the garbage is well
-		 * formatted and has no conflicting keys with the rest of the
-		 * request.
-		 */
-		if (!export_vg_to_buffer(vg, &buf)) {
-			dm_free(pvmeta);
+		if (!(vgmeta = _export_vg_to_config_tree(vg))) {
+			dm_config_destroy(pvmeta);
 			return_0;
 		}
 
-		reply = daemon_send_simple(_lvmetad,
-					   "pv_found",
-					   "pvmeta = %b", pvmeta,
-					   "vgname = %s", vg->name,
-					   "metadata = %b", strchr(buf, '{'),
-					   NULL);
+		reply = _lvmetad_send("pv_found",
+				      "pvmeta = %t", pvmeta,
+				      "vgname = %s", vg->name,
+				      "metadata = %t", vgmeta,
+				      NULL);
+		dm_config_destroy(vgmeta);
 	} else {
 		if (handler) {
 			log_error(INTERNAL_ERROR "Handler needs existing VG.");
@@ -603,13 +628,10 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 			return 0;
 		}
 		/* There are no MDAs on this PV. */
-		reply = daemon_send_simple(_lvmetad,
-					   "pv_found",
-					   "pvmeta = %b", pvmeta,
-					   NULL);
+		reply = _lvmetad_send("pv_found", "pvmeta = %t", pvmeta, NULL);
 	}
 
-	dm_free(pvmeta);
+	dm_config_destroy(pvmeta);
 
 	result = _lvmetad_handle_reply(reply, "update PV", uuid, NULL);
 
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 9c49440..7a6fe0b 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -15,6 +15,8 @@
 #ifndef _LVM_METAD_H
 #define _LVM_METAD_H
 
+#include "daemon-shared.h" // XXX
+
 struct volume_group;
 struct cmd_context;
 struct dm_config_tree;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index d706c2b..ff8757f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1584,7 +1584,9 @@ static struct metadata_area_ops _metadata_text_file_backup_ops = {
 	.vg_commit = _vg_commit_file_backup
 };
 
-static char *_mda_export_text_raw(struct metadata_area *mda);
+static int _mda_export_text_raw(struct metadata_area *mda,
+				struct dm_config_tree *cft,
+				struct dm_config_node *parent);
 static int _mda_import_text_raw(struct lvmcache_info *info, const struct dm_config_node *cn);
 
 static struct metadata_area_ops _metadata_text_raw_ops = {
@@ -1608,19 +1610,18 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 	.mda_import_text = _mda_import_text_raw
 };
 
-static char *_mda_export_text_raw(struct metadata_area *mda)
+static int _mda_export_text_raw(struct metadata_area *mda,
+				struct dm_config_tree *cft,
+				struct dm_config_node *parent)
 {
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
-	char *result;
 
-	dm_asprintf(&result,
-		    "ignore = %d "
-		    "start = %" PRIu64" "
-		    "size = %" PRIu64 " "
-		    "free_sectors = %" PRIu64,
-		    mda_is_ignored(mda), mdc->area.start, mdc->area.size, mdc->free_sectors);
-
-	return result;
+	return config_make_nodes(cft, parent, NULL,
+				 "ignore = %d", mda_is_ignored(mda),
+				 "start = %d", mdc->area.start,
+				 "size = %d", mdc->area.size,
+				 "free_sectors = %d", mdc->free_sectors,
+				 NULL) ? 1 : 0;
 }
 
 static int _mda_import_text_raw(struct lvmcache_info *info, const struct dm_config_node *cn)
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 6227a33..7bc7eaf 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -148,7 +148,8 @@ struct metadata_area_ops {
 				    struct metadata_area *mda2);
 
 	struct device *(*mda_get_device)(struct metadata_area *mda);
-	char *(*mda_export_text)(struct metadata_area *mda);
+	int (*mda_export_text)(struct metadata_area *mda, struct dm_config_tree *cft,
+			       struct dm_config_node *parent);
 	int (*mda_import_text)(struct lvmcache_info *info, const struct dm_config_node *cn);
 };
 


