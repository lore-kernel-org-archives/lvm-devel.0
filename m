From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:35 +0000 (UTC)
Subject: master - metadata: also validate historical LVs in VG in vg_validate and check_lv_segments
Message-ID: <20160303132035.9F58660310@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1297b0c8bef38a9269186ca26d6827560ce0fddf
Commit:        1297b0c8bef38a9269186ca26d6827560ce0fddf
Parent:        fc628e92ba1b403988a0b058d0d3283d23bab5bf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:32:01 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

metadata: also validate historical LVs in VG in vg_validate and check_lv_segments

---
 lib/metadata/merge.c    |   20 +++++++++++
 lib/metadata/metadata.c |   88 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 108 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index a36cafd..17227c1 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -80,6 +80,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 	unsigned seg_count = 0, seg_found;
 	uint32_t area_multiplier, s;
 	struct seg_list *sl;
+	struct glv_list *glvl;
 	int error_count = 0;
 	struct replicator_site *rsite;
 	struct replicator_device *rdev;
@@ -495,6 +496,25 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		}
 	}
 
+	dm_list_iterate_items(glvl, &lv->indirect_glvs) {
+		if (glvl->glv->is_historical) {
+			if (glvl->glv->historical->indirect_origin != lv->this_glv) {
+				log_error("LV %s is indirectly used by historical LV %s"
+					  "but that historical LV does not point back to LV %s",
+					   lv->name, glvl->glv->historical->name, lv->name);
+				inc_error_count;
+			}
+		} else {
+			if (!(seg = first_seg(glvl->glv->live)) ||
+			    seg->indirect_origin != lv->this_glv) {
+				log_error("LV %s is indirectly used by LV %s"
+					  "but that LV does not point back to LV %s",
+					  lv->name, glvl->glv->live->name, lv->name);
+				inc_error_count;
+			}
+		}
+	}
+
 	if (le != lv->le_count) {
 		log_error("LV %s: inconsistent LE count %u != %u",
 			  lv->name, le, lv->le_count);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5ab6f8e..4951d71 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2613,7 +2613,9 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
 
 struct validate_hash {
 	struct dm_hash_table *lvname;
+	struct dm_hash_table *historical_lvname;
 	struct dm_hash_table *lvid;
+	struct dm_hash_table *historical_lvid;
 	struct dm_hash_table *pvid;
 	struct dm_hash_table *lv_lock_args;
 };
@@ -2733,6 +2735,8 @@ int vg_validate(struct volume_group *vg)
 {
 	struct pv_list *pvl;
 	struct lv_list *lvl;
+	struct glv_list *glvl;
+	struct historical_logical_volume *hlv;
 	struct lv_segment *seg;
 	struct dm_str_list *sl;
 	char uuid[64] __attribute__((aligned(8)));
@@ -3166,11 +3170,95 @@ int vg_validate(struct volume_group *vg)
 		}
 	}
 
+	if (!(vhash.historical_lvname = dm_hash_create(dm_list_size(&vg->historical_lvs)))) {
+		log_error("Failed to allocate historical LV name hash");
+		r = 0;
+		goto out;
+	}
+
+        if (!(vhash.historical_lvid = dm_hash_create(dm_list_size(&vg->historical_lvs)))) {
+                log_error("Failed to allocate historical LV uuid hash");
+                r = 0;
+                goto out;
+        }
+
+	dm_list_iterate_items(glvl, &vg->historical_lvs) {
+		if (!glvl->glv->is_historical) {
+			log_error(INTERNAL_ERROR "LV %s/%s appearing in VG's historical list is not a historical LV",
+				  vg->name, glvl->glv->live->name);
+			r = 0;
+			continue;
+		}
+
+		hlv = glvl->glv->historical;
+
+		if (hlv->vg != vg) {
+			log_error(INTERNAL_ERROR "Historical LV %s points to different VG %s while it is listed in VG %s",
+				  hlv->name, hlv->vg->name, vg->name);
+			r = 0;
+			continue;
+		}
+
+		if (!id_equal(&hlv->lvid.id[0], &hlv->vg->id)) {
+			if (!id_write_format(&hlv->lvid.id[0], uuid, sizeof(uuid)))
+				stack;
+			if (!id_write_format(&hlv->vg->id, uuid2, sizeof(uuid2)))
+				stack;
+			log_error(INTERNAL_ERROR "Historical LV %s has VG UUID %s but its VG %s has UUID %s",
+				  hlv->name, uuid, hlv->vg->name, uuid2);
+			r = 0;
+			continue;
+                }
+
+		if (dm_hash_lookup_binary(vhash.historical_lvid, &hlv->lvid.id[1], sizeof(hlv->lvid.id[1]))) {
+			if (!id_write_format(&hlv->lvid.id[1], uuid,sizeof(uuid)))
+				stack;
+			log_error(INTERNAL_ERROR "Duplicate historical LV id %s detected for %s in %s",
+				  uuid, hlv->name, vg->name);
+                        r = 0;
+                }
+
+		if (dm_hash_lookup(vhash.historical_lvname, hlv->name)) {
+			log_error(INTERNAL_ERROR "Duplicate historical LV name %s detected in %s", hlv->name, vg->name);
+			r = 0;
+			continue;
+		}
+
+                if (!dm_hash_insert(vhash.historical_lvname, hlv->name, hlv)) {
+                        log_error("Failed to hash historical LV name");
+                        r = 0;
+                        break;
+                }
+
+                if (!dm_hash_insert_binary(vhash.historical_lvid, &hlv->lvid.id[1], sizeof(hlv->lvid.id[1]), hlv)) {
+                        log_error("Failed to hash historical LV id");
+                        r = 0;
+                        break;
+                }
+
+		if (dm_hash_lookup(vhash.lvname, hlv->name)) {
+			log_error(INTERNAL_ERROR "Name %s appears as live and historical LV at the same time in VG %s",
+				  hlv->name, vg->name);
+			r = 0;
+			continue;
+		}
+
+		if (!hlv->indirect_origin && !dm_list_size(&hlv->indirect_glvs)) {
+			log_error(INTERNAL_ERROR "Historical LV %s is not part of any LV chain in VG %s", hlv->name, vg->name);
+			r = 0;
+			continue;
+		}
+	}
+
 out:
 	if (vhash.lvid)
 		dm_hash_destroy(vhash.lvid);
 	if (vhash.lvname)
 		dm_hash_destroy(vhash.lvname);
+	if (vhash.historical_lvid)
+		dm_hash_destroy(vhash.historical_lvid);
+	if (vhash.historical_lvname)
+		dm_hash_destroy(vhash.historical_lvname);
 	if (vhash.pvid)
 		dm_hash_destroy(vhash.pvid);
 	if (vhash.lv_lock_args)


