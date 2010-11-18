From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 18 Nov 2010 22:32:24 +0100
Subject: [PATCH 10/11] Make existing lvmcache_update_pvid public.
In-Reply-To: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1290115945-27419-11-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When changing PV uuid (and the UUID which is important since the cache
hash is based on its value), we need to update the cache. This is
important for subsequent pv_write which tries to find the new PV with
that new UUID in the cache...

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/cache/lvmcache.c |   17 +++++++++++------
 lib/cache/lvmcache.h |    1 +
 tools/pvchange.c     |    6 ++++++
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d1b6dea..ac871c2 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -872,19 +872,24 @@ void lvmcache_del(struct lvmcache_info *info)
 	return;
 } */
 
-static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
+int lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 {
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+
+	strncpy(pvid_s, pvid, sizeof(pvid_s));
+	pvid_s[sizeof(pvid_s) - 1] = '\0';
+
 	/*
 	 * Nothing to do if already stored with same pvid.
 	 */
-	if (((dm_hash_lookup(_pvid_hash, pvid)) == info) &&
+	if (((dm_hash_lookup(_pvid_hash, pvid_s)) == info) &&
 	    !strcmp(info->dev->pvid, pvid))
 		return 1;
 	if (*info->dev->pvid)
 		dm_hash_remove(_pvid_hash, info->dev->pvid);
-	strncpy(info->dev->pvid, pvid, sizeof(info->dev->pvid));
-	if (!dm_hash_insert(_pvid_hash, pvid, info)) {
-		log_error("_lvmcache_update: pvid insertion failed: %s", pvid);
+	strncpy(info->dev->pvid, pvid_s, sizeof(info->dev->pvid));
+	if (!dm_hash_insert(_pvid_hash, pvid_s, info)) {
+		log_error("_lvmcache_update: pvid insertion failed: %s", pvid_s);
 		return 0;
 	}
 
@@ -1331,7 +1336,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 	info->fmt = (const struct format_type *) labeller->private;
 	info->status |= CACHE_INVALID;
 
-	if (!_lvmcache_update_pvid(info, pvid_s)) {
+	if (!lvmcache_update_pvid(info, pvid_s)) {
 		if (!existing) {
 			dm_free(info);
 			label_destroy(label);
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 32b4579..52f2d68 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -80,6 +80,7 @@ int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt);
 void lvmcache_del(struct lvmcache_info *info);
 
 /* Update things */
+int lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid);
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 				  const char *vgname, const char *vgid,
 				  uint32_t vgstatus, const char *hostname);
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 2633da2..a88e113 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -21,6 +21,8 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv,
 			    void *handle __attribute__((unused)))
 {
+	struct lvmcache_info *info;
+
 	uint32_t orig_pe_alloc_count;
 	/* FIXME Next three only required for format1. */
 	uint32_t orig_pe_count, orig_pe_size;
@@ -141,6 +143,9 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 			goto out;
 	} else {
 		/* --uuid: Change PV ID randomly */
+		if (!(info = info_from_pvid((char *) &pv->id, 0)))
+			goto_out;
+
 		if (!id_create(&pv->id)) {
 			log_error("Failed to generate new random UUID for %s.",
 				  pv_name);
@@ -149,6 +154,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid)))
 			goto_out;
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
+		if (!(lvmcache_update_pvid(info, (char *) &pv->id)));
 		if (!is_orphan(pv)) {
 			orig_vg_name = pv_vg_name(pv);
 			orig_pe_alloc_count = pv_pe_alloc_count(pv);
-- 
1.7.3.2


