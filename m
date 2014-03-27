From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 12:15:23 +0000 (UTC)
Subject: master - cleanup: indent change
Message-ID: <20140327121523.D77B760D90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc8185601d09d7a9725f3519f9acf5f43e40f844
Commit:        fc8185601d09d7a9725f3519f9acf5f43e40f844
Parent:        5076456a735163243a8593870fed44fb0cc1c20e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 26 21:01:47 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 27 13:13:09 2014 +0100

cleanup: indent change

---
 lib/metadata/merge.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index f6a14a8..146034f 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -231,8 +231,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				     (seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE))) ||
 				    (seg_is_cache_pool(seg) &&
 				     ((seg->chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
-				     (seg->chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE))))
-{
+				     (seg->chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE)))) {
 					log_error("LV %s: %spool segment %u has chunk size %u out of range.",
 						  lv->name,
 						  seg_is_thin_pool(seg) ?


