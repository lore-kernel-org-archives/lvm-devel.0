From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:00 +0000 (GMT)
Subject: main - thin: check for overprovisioning only once
Message-ID: <20210208224500.6A169389681C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eed060f0408738eb8191ee6bcef4fa93b9b87511
Commit:        eed060f0408738eb8191ee6bcef4fa93b9b87511
Parent:        99e168162aeac82d8ed4634add4bdd05cf208315
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 00:37:37 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:18:44 2021 +0100

thin: check for overprovisioning only once

---
 lib/metadata/lv_manip.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1ab9627dc..5c528a50b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5830,10 +5830,6 @@ static int _lvresize_volume(struct logical_volume *lv,
 			      lp->extents - lv->le_count,
 			      pvh, alloc, lp->approx_alloc))
 		return_0;
-	/* Check for over provisioning only when lv_extend() passed,
-	 * ATM this check does not fail */
-	else if (!pool_check_overprovisioning(lv))
-		return_0;
 
 	if (old_extents == lv->le_count)
 		log_print_unless_silent("Size of logical volume %s unchanged from %s (%" PRIu32 " extents).",
@@ -6126,6 +6122,11 @@ int lv_resize(struct logical_volume *lv,
 
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


