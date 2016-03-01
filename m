From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Mar 2016 13:03:14 +0000 (UTC)
Subject: master - coverity: eliminate DEADCODE
Message-ID: <20160301130314.70E0360DAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36d0dcef38ec3ce89f3c13be272efc69f981b207
Commit:        36d0dcef38ec3ce89f3c13be272efc69f981b207
Parent:        8173c2ff9af805a1f8eb79fb4bd223622f79ad0d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 1 13:58:15 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 1 14:02:43 2016 +0100

coverity: eliminate DEADCODE

Coverity notice this cannot be NULL: cur = &dms->regions[*cur_r]
so avoid NULL checking and simplify form.
---
 libdm/libdm-stats.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 82d3fa5..1dce3eb 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -957,15 +957,13 @@ bad:
 static void _stats_walk_next(const struct dm_stats *dms, int region,
 			     uint64_t *cur_r, uint64_t *cur_a)
 {
-	struct dm_stats_region *cur = NULL;
+	struct dm_stats_region *cur;
 	int present;
 
 	if (!dms || !dms->regions)
 		return;
 
-	if (!(cur = &dms->regions[*cur_r]))
-		return;
-
+	cur = dms->regions + *cur_r;
 	present = _stats_region_present(cur);
 
 	if (region && present)


