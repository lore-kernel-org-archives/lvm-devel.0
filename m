From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Dec 2018 19:12:46 -0500
Subject: master - debug: drop some unneeded backtraces
Message-ID: <201812230012.wBN0CkRe005376@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88faf5a53b34cdfe2d4932a6800af8530f8f5396
Commit:        88faf5a53b34cdfe2d4932a6800af8530f8f5396
Parent:        44aeb6d6b8766dc547ba56a7d1580ccb0da974c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 22 23:44:42 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 22 23:55:48 2018 +0100

debug: drop some unneeded backtraces

---
 lib/format_text/export.c      |    4 ++--
 lib/format_text/format-text.c |    2 +-
 libdm/libdm-stats.c           |    2 +-
 tools/lvconvert.c             |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 48e4c9a..841e06d 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -1098,13 +1098,13 @@ struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg)
 
 	if (!export_vg_to_buffer(vg, &buf)) {
 		log_error("Could not format metadata for VG %s.", vg->name);
-		return_NULL;
+		return NULL;
 	}
 
 	if (!(vg_cft = config_tree_from_string_without_dup_node_check(buf))) {
 		log_error("Error parsing metadata for VG %s.", vg->name);
 		free(buf);
-		return_NULL;
+		return NULL;
 	}
 
 	free(buf);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index f5bbf9e..414941f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -567,7 +567,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 
 	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda))) {
 		log_error("Failed to read vg %s from %s", vgname, dev_name(area->dev));
-		goto_out;
+		goto out;
 	}
 
 	if (!(rlocn = _read_metadata_location_vg(area, mdah, primary_mda, vgname, &precommitted))) {
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 4c7fd46..420e3e1 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4680,7 +4680,7 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 	/* make space for end-of-table marker */
 	if (!(regions = dm_malloc((1 + *count) * sizeof(*regions)))) {
 		log_error("Could not allocate memory for region IDs.");
-		goto_out;
+		goto out;
 	}
 
 	/*
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b63dc34..7139be3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4235,7 +4235,7 @@ static int _lvconvert_cache_attach_single(struct cmd_context *cmd,
 
 	} else {
 		log_error(INTERNAL_ERROR "Invalid cache pool state for %s", cachepool_lv->name);
-		goto_out;
+		goto out;
 	}
 
 	log_print_unless_silent("Logical volume %s is now cached.", display_lvname(lv));


