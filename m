From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:44 +0000 (GMT)
Subject: stable-2.02 - lv_manip: get_default_region_size return uint32_t
Message-ID: <20201016191044.D25C3396EC45@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94b5aa0aad3173b19c7424996e28dfdc276a34d2
Commit:        94b5aa0aad3173b19c7424996e28dfdc276a34d2
Parent:        9ffe17d2a85bb3fa1a60af28b45bafcf1af5b2d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 20:07:34 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

lv_manip: get_default_region_size return uint32_t

---
 lib/metadata/lv_manip.c          | 4 ++--
 lib/metadata/metadata-exported.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e7fd43945..708068f17 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -711,7 +711,7 @@ static int _round_down_pow2(int r)
 	return r & ~(r >> 1);
 }
 
-int get_default_region_size(struct cmd_context *cmd)
+uint32_t get_default_region_size(struct cmd_context *cmd)
 {
 	int pagesize = lvm_getpagesize();
 	int region_size = _get_default_region_size(cmd);
@@ -728,7 +728,7 @@ int get_default_region_size(struct cmd_context *cmd)
 			    region_size / 2);
 	}
 
-	return region_size;
+	return (uint32_t) region_size;
 }
 
 int add_seg_to_segs_using_this_lv(struct logical_volume *lv,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9c2413222..bd0eb6ca9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1123,7 +1123,7 @@ int vg_max_lv_reached(struct volume_group *vg);
 /*
 * Mirroring functions
 */
-int get_default_region_size(struct cmd_context *cmd);  /* in lv_manip.c */
+uint32_t get_default_region_size(struct cmd_context *cmd);  /* in lv_manip.c */
 struct lv_segment *find_mirror_seg(struct lv_segment *seg);
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t mirrors, uint32_t stripes, uint32_t stripe_size,


