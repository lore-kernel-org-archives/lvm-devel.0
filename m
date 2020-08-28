From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:11 +0000 (GMT)
Subject: master - lv_manip: get_default_region_size return uint32_t
Message-ID: <20200828195911.E31CF394849F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff4827ffb1dbd568b988716c63634c96eb4c1e15
Commit:        ff4827ffb1dbd568b988716c63634c96eb4c1e15
Parent:        93c9055591d8311cb361909f719964cdfa79e209
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 20:07:34 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

lv_manip: get_default_region_size return uint32_t

---
 lib/metadata/lv_manip.c          | 4 ++--
 lib/metadata/metadata-exported.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index bb2ad5beb..c47ec72e2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -829,7 +829,7 @@ static int _round_down_pow2(int r)
 	return r & ~(r >> 1);
 }
 
-int get_default_region_size(struct cmd_context *cmd)
+uint32_t get_default_region_size(struct cmd_context *cmd)
 {
 	int pagesize = lvm_getpagesize();
 	int region_size = _get_default_region_size(cmd);
@@ -846,7 +846,7 @@ int get_default_region_size(struct cmd_context *cmd)
 			    region_size / 2);
 	}
 
-	return region_size;
+	return (uint32_t) region_size;
 }
 
 int add_seg_to_segs_using_this_lv(struct logical_volume *lv,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 06ea757b8..db41ca36c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1152,7 +1152,7 @@ int vg_max_lv_reached(struct volume_group *vg);
 /*
 * Mirroring functions
 */
-int get_default_region_size(struct cmd_context *cmd);  /* in lv_manip.c */
+uint32_t get_default_region_size(struct cmd_context *cmd);  /* in lv_manip.c */
 struct lv_segment *find_mirror_seg(struct lv_segment *seg);
 int lv_add_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t mirrors, uint32_t stripes, uint32_t stripe_size,


