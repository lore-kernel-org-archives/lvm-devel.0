From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 10 Feb 2014 08:05:32 +0000 (UTC)
Subject: master - cleanup: missing parentheses in a condition
Message-ID: <20140210080532.4FE6E60D64@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56358160948554e1eb8dc7c5a86dbad4216376fd
Commit:        56358160948554e1eb8dc7c5a86dbad4216376fd
Parent:        290e58b0b6f001b2f3563304fd17d606eff51ba2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 10 09:03:08 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 10 09:05:17 2014 +0100

cleanup: missing parentheses in a condition

gcc reports:
  metadata/merge.c:229:58: warning: suggest parentheses around '&&' within '||' [-Wparentheses]
  metadata/merge.c:232:58: warning: suggest parentheses around '&&' within '||' [-Wparentheses]
---
 lib/metadata/merge.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index e636580..f6a14a8 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -227,11 +227,11 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				}
 
 				if ((seg_is_thin_pool(seg) &&
-				     (seg->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
-				     (seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) ||
+				     ((seg->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
+				     (seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE))) ||
 				    (seg_is_cache_pool(seg) &&
-				     (seg->chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
-				     (seg->chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE)))
+				     ((seg->chunk_size < DM_CACHE_MIN_DATA_BLOCK_SIZE) ||
+				     (seg->chunk_size > DM_CACHE_MAX_DATA_BLOCK_SIZE))))
 {
 					log_error("LV %s: %spool segment %u has chunk size %u out of range.",
 						  lv->name,


