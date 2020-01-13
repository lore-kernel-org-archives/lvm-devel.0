From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Jan 2020 11:43:29 -0500
Subject: master - vdo: avoid running initialization of cache pool vars
Message-ID: <75473.120011311432700639@us-mta-188.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ccf3e6f30479331b9b47e0165ed191fbaa38f44
Commit:        5ccf3e6f30479331b9b47e0165ed191fbaa38f44
Parent:        7737ffb11ceba0f4220e1dfb79b8e97f20e7b8e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 6 15:57:08 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 13 17:42:31 2020 +0100

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
index 4a1534c..448f125 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -396,13 +396,15 @@ static int _update_extents_params(struct volume_group *vg,
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



