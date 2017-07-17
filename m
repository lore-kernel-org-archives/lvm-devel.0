From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:47 -0400
Subject: master - cleanup: drop extra compare
Message-ID: <201707171140.v6HBelTs022591@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7e62bc55ccc7ab012325ba2ecc4a2009339989a
Commit:        f7e62bc55ccc7ab012325ba2ecc4a2009339989a
Parent:        55f9e2f39996ad325425d99d4631120e8271cfcd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 10:22:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:32:18 2017 +0200

cleanup: drop extra compare

dm_free() already validates for NULL itself.
---
 daemons/lvmetad/lvmetad-core.c |   21 +++++++--------------
 lib/cache/lvmcache.c           |    9 +++------
 lib/format_text/export.c       |    4 ++--
 lib/format_text/format-text.c  |    3 +--
 libdm/libdm-report.c           |    4 ++--
 libdm/libdm-stats.c            |   12 ++++--------
 6 files changed, 19 insertions(+), 34 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index f56eede..64d4fbb 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -884,16 +884,13 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 
 	/* free the unmapped data */
 
-	if (info_lookup)
-		dm_free(info_lookup);
 	if (meta_lookup)
 		dm_config_destroy(meta_lookup);
-	if (name_lookup)
-		dm_free(name_lookup);
 	if (outdated_pvs_lookup)
 		dm_config_destroy(outdated_pvs_lookup);
-	if (vgid_lookup)
-		dm_free(vgid_lookup);
+	dm_free(info_lookup);
+	dm_free(name_lookup);
+	dm_free(vgid_lookup);
 	return 1;
 }
 
@@ -1220,10 +1217,8 @@ static int _update_metadata_add_new(lvmetad_state *s, const char *new_name, cons
 out:
 out_free:
 	if (!new_name_dup || !new_vgid_dup || abort_daemon) {
-		if (new_name_dup)
-			dm_free(new_name_dup);
-		if (new_vgid_dup)
-			dm_free(new_vgid_dup);
+		dm_free(new_name_dup);
+		dm_free(new_vgid_dup);
 		ERROR(s, "lvmetad could not be updated and is aborting.");
 		exit(EXIT_FAILURE);
 	}
@@ -1813,8 +1808,7 @@ static response pv_gone(lvmetad_state *s, request r)
 	}
 
 	dm_config_destroy(pvmeta);
-	if (old_pvid)
-		dm_free(old_pvid);
+	dm_free(old_pvid);
 
 	return daemon_reply_simple("OK", NULL );
 }
@@ -2238,8 +2232,7 @@ static response pv_found(lvmetad_state *s, request r)
 	}
 
 	/* This was unhashed from device_to_pvid above. */
-	if (prev_pvid_on_dev)
-		dm_free((void *)prev_pvid_on_dev);
+	dm_free((void *)prev_pvid_on_dev);
 
 	return daemon_reply_simple("OK",
 				   "status = %s", vg_status,
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a15481f..8431ca1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1898,8 +1898,7 @@ static int _lvmcache_update_vgstatus(struct lvmcache_info *info, uint32_t vgstat
 						   info->vginfo->creation_host))
 		goto set_lock_type;
 
-	if (info->vginfo->creation_host)
-		dm_free(info->vginfo->creation_host);
+	dm_free(info->vginfo->creation_host);
 
 	if (!(info->vginfo->creation_host = dm_strdup(creation_host))) {
 		log_error("cache creation host alloc failed for %s.",
@@ -1918,8 +1917,7 @@ set_lock_type:
 	if (info->vginfo->lock_type && !strcmp(lock_type, info->vginfo->lock_type))
 		goto set_system_id;
 
-	if (info->vginfo->lock_type)
-		dm_free(info->vginfo->lock_type);
+	dm_free(info->vginfo->lock_type);
 
 	if (!(info->vginfo->lock_type = dm_strdup(lock_type))) {
 		log_error("cache lock_type alloc failed for %s", lock_type);
@@ -1937,8 +1935,7 @@ set_system_id:
 	if (info->vginfo->system_id && !strcmp(system_id, info->vginfo->system_id))
 		goto out;
 
-	if (info->vginfo->system_id)
-		dm_free(info->vginfo->system_id);
+	dm_free(info->vginfo->system_id);
 
 	if (!(info->vginfo->system_id = dm_strdup(system_id))) {
 		log_error("cache system_id alloc failed for %s", system_id);
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index f369089..7a84909 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -910,8 +910,8 @@ static int _print_historical_lv(struct formatter *f, struct historical_logical_v
 
 	r = 1;
 out:
-	if (descendants_buffer)
-		dm_free(descendants_buffer);
+	dm_free(descendants_buffer);
+
 	return r;
 }
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 9e99c85..bf8cd02 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -268,8 +268,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 
 	r = 1;
  out:
-	if (buf)
-		dm_free(buf);
+	dm_free(buf);
 	if (!dev_close(area->dev))
 		stack;
 	return r;
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 20a0827..a0ad26c 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -547,8 +547,8 @@ static int _report_field_string_list(struct dm_report *rh,
 out:
 	if (!r && sort_value)
 		dm_pool_free(rh->mem, sort_value);
-	if (arr)
-		dm_free(arr);
+	dm_free(arr);
+
 	return r;
 }
 
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 541823b..bc49867 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -330,11 +330,9 @@ static void _stats_region_destroy(struct dm_stats_region *region)
 	region->counters = NULL;
 	region->bounds = NULL;
 
-	if (region->program_id)
-		dm_free(region->program_id);
+	dm_free(region->program_id);
 	region->program_id = NULL;
-	if (region->aux_data)
-		dm_free(region->aux_data);
+	dm_free(region->aux_data);
 	region->aux_data = NULL;
 	region->region_id = DM_STATS_REGION_NOT_PRESENT;
 }
@@ -415,8 +413,7 @@ static void _stats_clear_binding(struct dm_stats *dms)
 		dm_pool_free(dms->mem, dms->bind_name);
 	if (dms->bind_uuid)
 		dm_pool_free(dms->mem, dms->bind_uuid);
-	if (dms->name)
-		dm_free((char *) dms->name);
+	dm_free((char *) dms->name);
 
 	dms->bind_name = dms->bind_uuid = NULL;
 	dms->bind_major = dms->bind_minor = -1;
@@ -2996,8 +2993,7 @@ int dm_stats_set_program_id(struct dm_stats *dms, int allow_empty,
 	if (!program_id)
 		program_id = "";
 
-	if (dms->program_id)
-		dm_free(dms->program_id);
+	dm_free(dms->program_id);
 
 	if (!(dms->program_id = dm_strdup(program_id)))
 		return_0;


