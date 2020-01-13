From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Jan 2020 11:42:04 -0500
Subject: stable-2.02 - vdo: avoid running initialization of cache pool vars
Message-ID: <08824.120011311420100115@us-mta-42.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c575c1c9ff71d95b6af0ec75798dd597491ca0b8
Commit:        c575c1c9ff71d95b6af0ec75798dd597491ca0b8
Parent:        36210c2b491424d7a0ab27d0a65effd6fc6ecc4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 6 15:57:08 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 13 17:41:22 2020 +0100

vdo: avoid running initialization of cache pool vars

Since VDO is also pool, the old if() case missed to know about this,
and executed unnecesserily initialization of cache pool variables.
This was usually harmless when using 'smaller' sizes of VDO pools,
but for big VDO pool size, we were reporting senseless messages
about big cache chunk sizes.
---
 tools/lvcreate.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index c27b798..4be8e03 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -395,13 +395,15 @@ static int _update_extents_params(struct volume_group *vg,
 						     &lp->discards,
 						     &lp->zero_new_blocks))
 				return_0;
-		} else if (!update_cache_pool_params(vg->cmd, vg->profile, vg->extent_size,
-						     lp->segtype, lp->target_attr,
-						     lp->extents,
-						     &lp->pool_metadata_extents,
-						     &lp->thin_chunk_size_calc_policy,
-						     &lp->chunk_size))
-			return_0;
+		} else if (segtype_is_cache_pool(lp->segtype) || segtype_is_cache(lp->segtype)) {
+			if (!update_cache_pool_params(vg->cmd, vg->profile, vg->extent_size,
+						      lp->segtype, lp->target_attr,
+						      lp->extents,
+						      &lp->pool_metadata_extents,
+						      &lp->thin_chunk_size_calc_policy,
+						      &lp->chunk_size))
+				return_0;
+		}
 
 		if (lcp->percent == PERCENT_FREE || lcp->percent == PERCENT_PVS) {
 			if (lp->extents <= (2 * lp->pool_metadata_extents)) {



