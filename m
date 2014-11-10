From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:21 +0000 (UTC)
Subject: master - report: for cache LV report chunksize
Message-ID: <20141110210621.55375608F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d7340b7a191376b94c45503f9c5cbee5f337e85
Commit:        8d7340b7a191376b94c45503f9c5cbee5f337e85
Parent:        6a41286c012e8a15a41f0d807c0cb62de7f515b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 10 21:29:32 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

report: for cache LV report chunksize

Cache LV reports chunksize via cache-pool.
---
 lib/metadata/lv.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index bdf98f8..016f299 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -177,6 +177,8 @@ uint64_t lvseg_chunksize(const struct lv_segment *seg)
 		size = (uint64_t) find_snapshot(seg->lv)->chunk_size;
 	else if (seg_is_pool(seg))
 		size = (uint64_t) seg->chunk_size;
+	else if (seg_is_cache(seg))
+		return lvseg_chunksize(first_seg(seg->pool_lv));
 	else
 		size = UINT64_C(0);
 


