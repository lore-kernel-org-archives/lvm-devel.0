From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 17 Mar 2017 09:22:57 -0400
Subject: master - properties: only thin-pool provides discards
Message-ID: <201703171322.v2HDMvja012196@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a271e7ee720402d3045cd16b04fd7296131bdf5
Commit:        4a271e7ee720402d3045cd16b04fd7296131bdf5
Parent:        d211c98581ee0ce9d1a919d64fd4d0df157c3069
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 17 14:01:18 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 17 14:22:33 2017 +0100

properties: only thin-pool provides discards

Quering non-thin-pool segment for discard property may lead
to intenal error if the segment had set 'out-of-range' value,
so only thin-pool is allowed, for other it returns NULL.
---
 lib/metadata/lv.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e58de66..b24c4aa 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -220,7 +220,12 @@ char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg)
 
 char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	return  dm_pool_strdup(mem, get_pool_discards_name(seg->discards));
+	if (lv_is_thin_pool(seg->lv))
+		return  dm_pool_strdup(mem, get_pool_discards_name(seg->discards));
+
+	log_error("Cannot query non thin-pool segment of LV %s for discards property.",
+		  display_lvname(seg->lv));
+	return NULL;
 }
 
 char *lvseg_kernel_discards_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm)


