From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 14:26:31 +0000 (GMT)
Subject: main - gcc: avoid warns on missing braces with older version
Message-ID: <20210920142631.75DE33858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e990d1fec93126017124d3db754aeed5b6c7dc3
Commit:        2e990d1fec93126017124d3db754aeed5b6c7dc3
Parent:        1a8a33ae9b39567e2a2cc399f13cebecb5fa2dea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 16:11:49 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 16:11:49 2021 +0200

gcc: avoid warns on missing braces with older version

---
 libdm/libdm-stats.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 6cfa23384..62b28b69d 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4519,7 +4519,7 @@ static int _stats_unmap_regions(struct dm_stats *dms, uint64_t group_id,
 	struct dm_stats_region *region = NULL;
 	struct dm_stats_group *group = NULL;
 	uint64_t nr_kept, nr_old;
-	struct _extent ext = { 0 };
+	struct _extent ext = { .id = 0 };
 	int64_t i;
 
 	group = &dms->groups[group_id];


