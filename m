From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 Jul 2016 11:23:20 +0000 (UTC)
Subject: master - cleanup: gcc warns removal
Message-ID: <20160712112320.AEC0A60F6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd53d86eeada2b03fff2ca0ebb8ad25280b90cdd
Commit:        fd53d86eeada2b03fff2ca0ebb8ad25280b90cdd
Parent:        42e76a1920c9ee1ae13a3ca4ba2fdd96cad8fe3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 11 22:58:21 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 12 10:39:33 2016 +0200

cleanup: gcc warns removal

Ensure vars have always defined value.
---
 lib/cache/lvmetad.c       |    2 +-
 lib/metadata/raid_manip.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 1fecb5e..c320b1c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1784,7 +1784,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 	struct dm_list pvs_scan;
 	struct dm_list pvs_drop;
 	struct dm_list pvs_new;
-	struct lvmcache_info *info;
+	struct lvmcache_info *info = NULL;
 	struct format_instance *fid;
 	struct format_instance_ctx fic = { .type = 0 };
 	struct _lvmetad_pvscan_baton baton;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b67380f..9ac061f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1726,7 +1726,7 @@ static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv
 						       struct dm_list *removal_lvs)
 {
 	uint32_t s, area_le, area_len, le;
-	struct lv_segment *data_seg, *seg, *seg_to;
+	struct lv_segment *data_seg = NULL, *seg, *seg_to;
 	struct dm_list new_segments;
 
 	seg = first_seg(lv);


