From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Jul 2015 11:10:59 +0000 (UTC)
Subject: master - cleanup: drop duplicated seg test
Message-ID: <20150715111059.BD565609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7101e7bfb1b8f5f792974a3b5f39fa4fcdb5656
Commit:        a7101e7bfb1b8f5f792974a3b5f39fa4fcdb5656
Parent:        beb65056cf450ac14c2354f87a981cd5a379560c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 10 13:51:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 15 13:10:22 2015 +0200

cleanup: drop duplicated seg test

Test is already in seg_is_pool() if branch.
and one minor indent fix.
---
 lib/metadata/merge.c |    3 +--
 tools/lvcreate.c     |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 530b4e4..e38cb53 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -237,8 +237,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 					inc_error_count;
 				}
 
-				if (seg_is_pool(seg) &&
-				    !validate_pool_chunk_size(lv->vg->cmd, seg->segtype, seg->chunk_size)) {
+				if (!validate_pool_chunk_size(lv->vg->cmd, seg->segtype, seg->chunk_size)) {
 					log_error("LV %s: %s segment %u has invalid chunk size %u.",
 						  lv->name, seg->segtype->name, seg_count, seg->chunk_size);
 					inc_error_count;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2595130..12b5166 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -587,7 +587,7 @@ static int _read_cache_params(struct cmd_context *cmd,
 }
 
 static int _read_activation_params(struct cmd_context *cmd,
-                                   struct volume_group *vg,
+				   struct volume_group *vg,
 				   struct lvcreate_params *lp)
 {
 	unsigned pagesize = lvm_getpagesize() >> SECTOR_SHIFT;


