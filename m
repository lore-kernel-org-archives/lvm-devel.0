From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:35:54 -0500
Subject: master - lvcreate: respecting profile settings
Message-ID: <201703101835.v2AIZsia019186@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f24a1f06b2a9856c2bde0f8ee740bb9c3c695c35
Commit:        f24a1f06b2a9856c2bde0f8ee740bb9c3c695c35
Parent:        36003df7e39bd2b3faf7b9d3f651109ddf30cebb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 10 13:04:30 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

lvcreate: respecting profile settings

---
 lib/metadata/lv_manip.c |    8 --------
 tools/lvcreate.c        |    3 ---
 2 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e78a9ac..5ef9d73 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7402,14 +7402,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		if (seg_is_cache(lp)) {
-			/* validate metadata size */
-			if (!validate_lv_cache_chunk_size(pool_lv, lp->chunk_size))
-				return_0;
-
-			first_seg(pool_lv)->chunk_size = lp->chunk_size;
-		}
-
 		/* Validate volume size to to aling on chunk for small extents */
 		/* Cache chunk size is always set */
 		size = first_seg(pool_lv)->chunk_size;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 80c97b0..01bd4b6 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1156,9 +1156,6 @@ static int _determine_cache_argument(struct volume_group *vg,
 		/* Pool exists, create cache volume */
 		lp->create_pool = 0;
 		lp->origin_name = NULL;
-		/* If cache args not given, use those from cache pool */
-		if (!arg_is_set(cmd, chunksize_ARG))
-			lp->chunk_size = first_seg(lv)->chunk_size;
 	} else if (lv) {
 		/* Origin exists, create cache pool volume */
 		if (!validate_lv_cache_create_origin(lv))


