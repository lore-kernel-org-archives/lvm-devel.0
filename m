From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:47 +0000 (UTC)
Subject: master - lvmetad: Use "%" PRId64 in place of "%d" for extra clarity.
Message-ID: <20120926175547.9222EA33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9f56d639b6c6ddfae7749c64eba64a776ecc7d9
Commit:        c9f56d639b6c6ddfae7749c64eba64a776ecc7d9
Parent:        c7b17836ea139ba7448f5a5c1d2fbe93676baa36
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Sep 9 21:57:59 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:16 2012 +0200

lvmetad: Use "%" PRId64 in place of "%d" for extra clarity.

---
 lib/cache/lvmetad.c              |   15 +++++++++------
 lib/format_text/format-text.c    |    8 ++++----
 libdaemon/client/daemon-shared.c |    8 ++++----
 libdaemon/server/daemon-server.c |    2 +-
 4 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 90d43dd..1e185da 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -508,7 +508,7 @@ int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *f
 	if (!lvmetad_active())
 		return_0;
 
-	reply = _lvmetad_send("pv_lookup", "device = %d", dev->dev, NULL);
+	reply = _lvmetad_send("pv_lookup", "device = %" PRId64, (int64_t) dev->dev, NULL);
 	if (!_lvmetad_handle_reply(reply, "lookup PV", dev_name(dev), found))
 		goto_out;
 
@@ -624,7 +624,10 @@ static int _extract_da(struct disk_locn *da, void *baton)
 	dm_snprintf(id, 32, "da%d", b->i);
 	if (!(cn = make_config_node(b->cft, id, b->cft->root, b->pre_sib)))
 		return 0;
-	if (!config_make_nodes(b->cft, cn, NULL, "offset = %d", da->offset, "size = %d", da->size, NULL))
+	if (!config_make_nodes(b->cft, cn, NULL,
+			       "offset = %"PRId64, (int64_t) da->offset,
+			       "size = %"PRId64, (int64_t) da->size,
+			       NULL))
 		return 0;
 
 	b->i ++;
@@ -676,10 +679,10 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 	}
 
 	if (!config_make_nodes(pvmeta, pvmeta->root, NULL,
-			       "device = %d", device->dev,
-			       "dev_size = %d", info ? lvmcache_device_size(info) : 0,
+			       "device = %"PRId64, (int64_t) device->dev,
+			       "dev_size = %"PRId64, (int64_t) (info ? lvmcache_device_size(info) : 0),
 			       "format = %s", fmt->name,
-			       "label_sector = %d", label_sector,
+			       "label_sector = %"PRId64, (int64_t) label_sector,
 			       "id = %s", uuid,
 			       NULL))
 	{
@@ -751,7 +754,7 @@ int lvmetad_pv_gone(dev_t device, const char *pv_name, activation_handler handle
          *        the whole stack from top to bottom (not yet upstream).
          */
 
-	reply = _lvmetad_send("pv_gone", "device = %d", device, NULL);
+	reply = _lvmetad_send("pv_gone", "device = %" PRId64, (int64_t) device, NULL);
 
 	result = _lvmetad_handle_reply(reply, "drop PV", pv_name, &found);
 	/* We don't care whether or not the daemon had the PV cached. */
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index ff8757f..b562cfa 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1617,10 +1617,10 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
 
 	return config_make_nodes(cft, parent, NULL,
-				 "ignore = %d", mda_is_ignored(mda),
-				 "start = %d", mdc->area.start,
-				 "size = %d", mdc->area.size,
-				 "free_sectors = %d", mdc->free_sectors,
+				 "ignore = %" PRId64, (int64_t) mda_is_ignored(mda),
+				 "start = %" PRId64, (int64_t) mdc->area.start,
+				 "size = %" PRId64, (int64_t) mdc->area.size,
+				 "free_sectors = %" PRId64, (int64_t) mdc->free_sectors,
 				 NULL) ? 1 : 0;
 }
 
diff --git a/libdaemon/client/daemon-shared.c b/libdaemon/client/daemon-shared.c
index 4b98f51..6a1cf05 100644
--- a/libdaemon/client/daemon-shared.c
+++ b/libdaemon/client/daemon-shared.c
@@ -115,9 +115,9 @@ char *format_buffer_v(const char *head, va_list ap)
 			goto fail;
 		}
 		keylen = strchr(next, '=') - next;
-		if (strstr(next, "%d")) {
-			int value = va_arg(ap, int);
-			dm_asprintf(&buffer, "%s%.*s= %d\n", buffer, keylen, next, value);
+		if (strstr(next, "%d") || strstr(next, "%" PRId64)) {
+			int64_t value = va_arg(ap, int64_t);
+			dm_asprintf(&buffer, "%s%.*s= %" PRId64 "\n", buffer, keylen, next, value);
 			dm_free(old);
 		} else if (strstr(next, "%s")) {
 			char *value = va_arg(ap, char *);
@@ -301,7 +301,7 @@ struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
 		char *key = dm_pool_strdup(cft->mem, next);
 		*strchr(key, '=') = 0;
 
-		if (!strcmp(fmt, "%d")) {
+		if (!strcmp(fmt, "%d") || !strcmp(fmt, "%" PRId64)) {
 			int64_t value = va_arg(ap, int64_t);
 			if (!(cn = make_int_node(cft, key, value, parent, pre_sib)))
 				return 0;
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 76627c0..50bf065 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -360,7 +360,7 @@ static response builtin_handler(daemon_state s, client_handle h, request r)
 
 	if (!strcmp(rq, "hello")) {
 		return daemon_reply_simple("OK", "protocol = %s", s.protocol ?: "default",
-					   "version = %d", s.protocol_version, NULL);
+					   "version = %" PRId64, (int64_t) s.protocol_version, NULL);
 	}
 
 	response res = { .buffer = NULL, .error = EPROTO };


