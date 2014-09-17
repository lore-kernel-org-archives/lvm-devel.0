From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 17 Sep 2014 14:52:18 +0000 (UTC)
Subject: master - cleanup: Remove metadata.h from tools dir.
Message-ID: <20140917145218.B033F6133F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b4f5be76a3b8c9c89719e5d8699033a79c993b6f
Commit:        b4f5be76a3b8c9c89719e5d8699033a79c993b6f
Parent:        98414ca7dd2682b64fec141ae58b4c8ed4367fc7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 17 15:50:24 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 17 15:50:24 2014 +0100

cleanup: Remove metadata.h from tools dir.

metadata.h is meant to be internal to the library.
metadata-exported.h contains the things needed by tools.
---
 lib/metadata/metadata-exported.h |    5 +++++
 lib/metadata/metadata.h          |    5 -----
 tools/pvmove.c                   |    1 -
 tools/pvremove.c                 |    1 -
 tools/vgsplit.c                  |    1 -
 5 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 01b04ff..0a307ab 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -615,6 +615,10 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  unsigned metadataignore,
 				  struct pvcreate_restorable_params *rp);
 
+int pvremove_single(struct cmd_context *cmd, const char *pv_name,
+		    void *handle __attribute__((unused)), unsigned force_count,
+		    unsigned prompt);
+
 int pv_resize_single(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     struct physical_volume *pv,
@@ -927,6 +931,7 @@ int get_pv_list_for_lv(struct dm_pool *mem,
 /* Find LV segment containing given LE */
 struct lv_segment *first_seg(const struct logical_volume *lv);
 struct lv_segment *last_seg(const struct logical_volume *lv);
+struct lv_segment *get_only_segment_using_this_lv(const struct logical_volume *lv);
 
 /*
 * Useful functions for managing snapshots.
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 518dd21..439f6b7 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -341,10 +341,6 @@ unsigned long set_pe_align_offset(struct physical_volume *pv,
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
 
-int pvremove_single(struct cmd_context *cmd, const char *pv_name,
-			   void *handle __attribute__((unused)), unsigned force_count,
-			   unsigned prompt);
-
 struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_name,
                                      struct pvcreate_params *pp, int write_now);
 
@@ -428,7 +424,6 @@ int lv_split_segment(struct logical_volume *lv, uint32_t le);
  */
 int add_seg_to_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
 int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
-struct lv_segment *get_only_segment_using_this_lv(const struct logical_volume *lv);
 
 int for_each_sub_lv(struct logical_volume *lv,
                     int (*fn)(struct logical_volume *lv, void *data),
diff --git a/tools/pvmove.c b/tools/pvmove.c
index a9d750d..3072584 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -16,7 +16,6 @@
 #include "tools.h"
 #include "polldaemon.h"
 #include "display.h"
-#include "metadata.h"  /* for 'get_only_segment_using_this_lv' */
 
 #define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
 #define PVMOVE_EXCLUSIVE    0x00000002      /* Require exclusive LV */
diff --git a/tools/pvremove.c b/tools/pvremove.c
index dfd6007..035d4fd 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "metadata.h"
 
 int pvremove(struct cmd_context *cmd, int argc, char **argv)
 {
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index ad2eb48..362f854 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "metadata.h"  /* for 'get_only_segment_using_this_lv' */
 
 static int _lv_is_in_vg(struct volume_group *vg, struct logical_volume *lv)
 {


