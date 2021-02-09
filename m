From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  9 Feb 2021 14:06:47 +0000 (GMT)
Subject: stable-2.02 - thin: check for overprovisioning only once
Message-ID: <20210209140647.B4F36383543D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c99725261a53c6d984fa262980aab0df2ae6d62
Commit:        6c99725261a53c6d984fa262980aab0df2ae6d62
Parent:        cfb9bf13c7073937591fa4dc4a0a93a975016bb1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 00:37:37 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 9 14:45:29 2021 +0100

thin: check for overprovisioning only once

---
 lib/metadata/lv_manip.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 33624148c..c37757e9a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5449,10 +5449,6 @@ static int _lvresize_volume(struct logical_volume *lv,
 			      lp->extents - lv->le_count,
 			      pvh, alloc, lp->approx_alloc))
 		return_0;
-	/* Check for over provisioning only when lv_extend() passed,
-	 * ATM this check does not fail */
-	else if (!pool_check_overprovisioning(lv))
-		return_0;
 
 	if (old_extents == lv->le_count)
 		log_print_unless_silent("Size of logical volume %s unchanged from %s (%" PRIu32 " extents).",
@@ -5705,6 +5701,11 @@ int lv_resize(struct logical_volume *lv,
 
 		backup(vg);
 	}
+
+	/* Check for over provisioning when extended */
+	if ((lp->resize == LV_EXTEND) && lv_is_thin_type(lv))
+		pool_check_overprovisioning(lv);
+
 out:
 	log_print_unless_silent("Logical volume %s successfully resized.",
 				display_lvname(lv));


