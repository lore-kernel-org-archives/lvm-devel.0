From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:24 +0000 (UTC)
Subject: master - lv_manip: improve should_wipe reporting
Message-ID: <20141024144024.5090761079@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be3f666ef3ad25f2af598ecfa305ab9c2f7de3f4
Commit:        be3f666ef3ad25f2af598ecfa305ab9c2f7de3f4
Parent:        2fc403b0fc5c7fffec4d7864433d0db3c139995c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 22 13:29:25 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

lv_manip: improve should_wipe reporting

We want to print smarter warning message only when
the zeroing was not provided on the first zeroable segment
of newly created LV.

Put warning within _should_wipe_lv function to avoid reevaluation
of same conditions twice.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   40 +++++++++++++++++++++++++---------------
 2 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e2372e5..70b41bc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Improve _should_wipe_lv() to warn with message.
   Inform about temporarily created volumes only in verbose mode.
   Better support for --test mode with pool creation.
   Query lock holding LV when replacing and converting raid volumes.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 61620e5..3c84a5c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6530,14 +6530,31 @@ int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
 	return 1;
 }
 
-static int _should_wipe_lv(struct lvcreate_params *lp, struct logical_volume *lv) {
-	int r = lp->zero | lp->wipe_signatures;
+static int _should_wipe_lv(struct lvcreate_params *lp,
+			   struct logical_volume *lv, int warn)
+{
+	/* Unzeroable segment */
+	if (first_seg(lv)->segtype->flags & SEG_CANNOT_BE_ZEROED)
+		return 0;
 
-	if (!seg_is_thin(lp) && !seg_is_cache_pool(lp))
-		return r;
+	/* Thin snapshot need not to be zeroed */
+	/* Thin pool with zeroing doesn't need zeroing or wiping */
+	if (lv_is_thin_volume(lv) &&
+	    (first_seg(lv)->origin ||
+	     first_seg(first_seg(lv)->pool_lv)->zero_new_blocks))
+		return 0;
 
-	if (lv_is_thin_volume(lv))
-		return r && !lp->snapshot && !first_seg(first_seg(lv)->pool_lv)->zero_new_blocks;
+	/* Cannot zero read-only volume */
+	if ((lv->status & LVM_WRITE) &&
+	    (lp->zero || lp->wipe_signatures))
+		return 1;
+
+	if (warn && (!lp->zero || !(lv->status & LVM_WRITE)))
+		log_warn("WARNING: Logical volume %s not zeroed.",
+			 display_lvname(lv));
+	if (warn && (!lp->wipe_signatures || !(lv->status & LVM_WRITE)))
+		log_verbose("Signature wiping on logical volume %s not requested.",
+			    display_lvname(lv));
 
 	return 0;
 }
@@ -7017,7 +7034,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	}
 
 	/* Do not scan this LV until properly zeroed/wiped. */
-	if (_should_wipe_lv(lp, lv))
+	if (_should_wipe_lv(lp, lv, 0))
 		lv->status |= LV_NOSCAN;
 
 	if (lp->temporary)
@@ -7073,14 +7090,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return NULL;
 	}
 
-	if (!seg_is_thin(lp) && !lp->snapshot) {
-		if (!lp->zero)
-			log_warn("WARNING: \"%s/%s\" not zeroed", lv->vg->name, lv->name);
-		if (!lp->wipe_signatures)
-			log_verbose("Signature wiping on \"%s/%s\" not requested", lv->vg->name, lv->name);
-	}
-
-	if (_should_wipe_lv(lp, lv)) {
+	if (_should_wipe_lv(lp, lv, 1)) {
 		if (!wipe_lv(lv, (struct wipe_params)
 			     {
 				     .do_zero = lp->zero,


