From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 22 Oct 2019 07:32:33 -0400
Subject: stable-2.02 - debug: drop some unneeded backtraces
Message-ID: <201910221132.x9MBWX9R025361@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3fe2610cff1afc1eaf9bc9c141950fe8ded73793
Commit:        3fe2610cff1afc1eaf9bc9c141950fe8ded73793
Parent:        889c88e9dab33195efc4dc0400a4b0aaa3383948
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 22 23:44:42 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Oct 21 15:26:11 2019 +0200

debug: drop some unneeded backtraces

(cherry picked from commit 88faf5a53b34cdfe2d4932a6800af8530f8f5396)

Conflicts:
	lib/format_text/export.c
	tools/lvconvert.c
---
 lib/format_text/export.c      |    4 ++--
 lib/format_text/format-text.c |    2 +-
 libdm/libdm-stats.c           |    2 +-
 tools/lvconvert.c             |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 7866d56..3e294a1 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -1097,13 +1097,13 @@ struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg)
 
 	if (!export_vg_to_buffer(vg, &buf)) {
 		log_error("Could not format metadata for VG %s.", vg->name);
-		return_NULL;
+		return NULL;
 	}
 
 	if (!(vg_cft = config_tree_from_string_without_dup_node_check(buf))) {
 		log_error("Error parsing metadata for VG %s.", vg->name);
 		dm_free(buf);
-		return_NULL;
+		return NULL;
 	}
 
 	dm_free(buf);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index f39051c..6eea07f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -546,7 +546,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 
 	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda))) {
 		log_error("Failed to read vg %s from %s", vgname, dev_name(area->dev));
-		goto_out;
+		goto out;
 	}
 
 	if (!(rlocn = _read_metadata_location_vg(area, mdah, primary_mda, vgname, &precommitted))) {
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index df4322a..b4b714d 100644
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
index 31ca5a1..677bed1 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4142,7 +4142,7 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 	/* Convert lv to cache vol using cachepool_lv. */
 
 	if (!_lvconvert_to_cache_vol(cmd, lv, cachepool_lv))
-		goto_out;
+		goto out;
 
 	return ECMD_PROCESSED;
 


