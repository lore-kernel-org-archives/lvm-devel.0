From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 May 2016 08:19:43 +0000 (UTC)
Subject: master - coverity: missing check for id_write_format return value
Message-ID: <20160531081943.B7AF160B3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48877e215d882f89294396d79f5d8d71395e427d
Commit:        48877e215d882f89294396d79f5d8d71395e427d
Parent:        5b3a4a95956fe467a2c5fe1cce3925e67366d4fe
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 31 09:56:10 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 31 09:56:10 2016 +0200

coverity: missing check for id_write_format return value

---
 daemons/lvmetad/testclient.c |    5 ++++-
 lib/cache/lvmcache.c         |    6 ++++--
 lib/format_pool/disk_rep.c   |    9 ++++++---
 lib/uuid/uuid.c              |    2 ++
 tools/toollib.c              |   11 ++++++-----
 5 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/daemons/lvmetad/testclient.c b/daemons/lvmetad/testclient.c
index 56940d9..c9efbe6 100644
--- a/daemons/lvmetad/testclient.c
+++ b/daemons/lvmetad/testclient.c
@@ -75,7 +75,10 @@ int scan(daemon_handle h, char *fn) {
 	}
 
 	char uuid[64];
-	id_write_format(dev->pvid, uuid, 64);
+	if (!id_write_format(dev->pvid, uuid, 64)) {
+		fprintf(stderr, "[C] Failed to format PV UUID for %s", dev_name(dev));
+		return;
+	}
 	fprintf(stderr, "[C] found PV: %s\n", uuid);
 	struct lvmcache_info *info = (struct lvmcache_info *) label->info;
 	struct physical_volume pv = { 0, };
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0934b20..9e232f6 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -995,7 +995,8 @@ next:
 			alt = devl;
 		}
 
-		id_write_format((const struct id *)dev1->pvid, uuid, sizeof(uuid));
+		if (!id_write_format((const struct id *)dev1->pvid, uuid, sizeof(uuid)))
+			stack;
 		log_warn("WARNING: PV %s prefers device %s because %s.", uuid, dev_name(dev1), reason);
 	}
 
@@ -2066,7 +2067,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 
 	strncpy(pvid_s, pvid, sizeof(pvid_s) - 1);
 	pvid_s[sizeof(pvid_s) - 1] = '\0';
-	id_write_format((const struct id *)&pvid_s, uuid, sizeof(uuid));
+	if (!id_write_format((const struct id *)&pvid_s, uuid, sizeof(uuid)))
+		stack;
 
 	/*
 	 * Find existing info struct in _pvid_hash or create a new one.
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index fd11380..0462eb4 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -60,7 +60,8 @@ static void _add_pl_to_list(struct cmd_context *cmd, struct dm_list *head, struc
 		if (id_equal(&data->pv_uuid, &pl->pv_uuid)) {
 			char uuid[ID_LEN + 7] __attribute__((aligned(8)));
 
-			id_write_format(&pl->pv_uuid, uuid, ID_LEN + 7);
+			if (!id_write_format(&pl->pv_uuid, uuid, ID_LEN + 7))
+				stack;
 
 			if (!dev_subsystem_part_major(cmd->dev_types, data->dev)) {
 				log_very_verbose("Ignoring duplicate PV %s on "
@@ -90,11 +91,13 @@ int read_pool_label(struct pool_list *pl, struct labeller *l,
 	pool_label_in(pd, buf);
 
 	get_pool_pv_uuid(&pvid, pd);
-	id_write_format(&pvid, uuid, ID_LEN + 7);
+	if (!id_write_format(&pvid, uuid, ID_LEN + 7))
+		stack;
 	log_debug_metadata("Calculated uuid %s for %s", uuid, dev_name(dev));
 
 	get_pool_vg_uuid(&vgid, pd);
-	id_write_format(&vgid, uuid, ID_LEN + 7);
+	if (!id_write_format(&vgid, uuid, ID_LEN + 7))
+		stack;
 	log_debug_metadata("Calculated uuid %s for %s", uuid, pd->pl_pool_name);
 
 	if (!(info = lvmcache_add(l, (char *) &pvid, dev, pd->pl_pool_name,
diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index d52353f..aa44dc4 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -171,6 +171,8 @@ int id_write_format(const struct id *id, char *buffer, size_t size)
 
 	/* split into groups separated by dashes */
 	if (size < (32 + 6 + 1)) {
+		if (size > 0)
+			buffer[0] = '\0';
 		log_error("Couldn't write uuid, buffer too small.");
 		return 0;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index b41db0f..0de6ee8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1858,8 +1858,8 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		skip = 0;
 		notfound = 0;
 
-		if (vg_uuid)
-			id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid));
+		if (vg_uuid && !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
+			stack;
 
 		log_very_verbose("Processing VG %s %s", vg_name, vg_uuid ? uuid : "");
 
@@ -1954,7 +1954,8 @@ static int _resolve_duplicate_vgnames(struct cmd_context *cmd,
 			 * name/vgid and checks system_id in the metadata.
 			 */
 			if (lvmcache_vg_is_foreign(cmd, vgnl->vg_name, vgnl->vgid)) {
-				id_write_format((const struct id*)vgnl->vgid, uuid, sizeof(uuid));
+				if (!id_write_format((const struct id*)vgnl->vgid, uuid, sizeof(uuid)))
+					stack;
 				log_warn("WARNING: Ignoring foreign VG with matching name %s UUID %s.",
 					 vgnl->vg_name, uuid);
 				dm_list_del(&vgnl->list);
@@ -2659,8 +2660,8 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 			}
 		}
 
-		if (vg_uuid)
-			id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid));
+		if (vg_uuid && !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
+			stack;
 
 		log_very_verbose("Processing VG %s %s", vg_name, vg_uuid ? uuid : "");
 


