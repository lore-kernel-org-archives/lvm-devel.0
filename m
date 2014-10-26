From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 17:37:56 +0000 (UTC)
Subject: master - lvcreate: delay check for free extents
Message-ID: <20141026173756.1792860282@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=205e3ff88898848b6e5dcfde74bff829bd27bf83
Commit:        205e3ff88898848b6e5dcfde74bff829bd27bf83
Parent:        c9fbbf48baf9866dc57b336f9ca2b54346fb9827
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 16:18:53 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 18:37:13 2014 +0100

lvcreate: delay check for free extents

As the rounding for cache creation may change the value of extents
postpone check for free extents.
---
 lib/metadata/lv_manip.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1ab47c6..36bc2d8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6636,14 +6636,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return NULL;
 	}
 
-	if (!seg_is_virtual(lp) && !lp->approx_alloc &&
-	    (vg->free_count < lp->extents)) {
-		log_error("Volume group \"%s\" has insufficient free space "
-			  "(%u extents): %u required.",
-			  vg->name, vg->free_count, lp->extents);
-		return NULL;
-	}
-
 	if ((lp->alloc != ALLOC_ANYWHERE) && (lp->stripes > dm_list_size(lp->pvh))) {
 		log_error("Number of stripes (%u) must not exceed "
 			  "number of physical volumes (%d)", lp->stripes,
@@ -6836,6 +6828,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lp->wipe_signatures = 0;
 	}
 
+	if (!seg_is_virtual(lp) && !lp->approx_alloc &&
+	    (vg->free_count < lp->extents)) {
+		log_error("Volume group \"%s\" has insufficient free space "
+			  "(%u extents): %u required.",
+			  vg->name, vg->free_count, lp->extents);
+		return NULL;
+	}
+
 	if (!archive(vg))
 		return_NULL;
 


