From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jan 2014 11:39:59 +0000 (UTC)
Subject: master - thin: fix thin LV flagging for udev to skip scanning
Message-ID: <20140120113959.A9E7D60DA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91b26b63b408b7d7b4f79f0754d190783874e4cc
Commit:        91b26b63b408b7d7b4f79f0754d190783874e4cc
Parent:        79768b2e9c01f6a56d6e2fef7d3bd82f9ce3c2c1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 20 12:38:21 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 20 12:38:21 2014 +0100

thin: fix thin LV flagging for udev to skip scanning

Only flag thin LV for no scanning in udev if this LV is about
to be wiped. This happens only in case the thin LV's pool was not
created with zeroing of the new blocks enabled.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   18 ++++++++++++++----
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6f7abe6..284c92e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Fix thin LV flagging for udev to skip scanning only if the LV is wiped
   Replace use of xfs_check with xfs_reparir in fsadm. 
   Mark lvm1 format metadata as FMT_OBSOLETE. Do not use it with lvmetad.
   Invalidate cached VG struct after a PV in it gets orphaned. (2.02.87)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 62ca245..f45c89f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5634,6 +5634,18 @@ out:
 	return 1;
 }
 
+static int _should_wipe_lv(struct lvcreate_params *lp, struct logical_volume *lv) {
+	int r = lp->zero | lp->wipe_signatures;
+
+	if (!seg_is_thin(lp))
+		return r;
+
+	if (lv_is_thin_volume(lv))
+		return r && !lp->snapshot && !first_seg(first_seg(lv)->pool_lv)->zero_new_blocks;
+
+	return 0;
+}
+
 /* Thin notes:
  * If lp->thin OR lp->activate is AY*, activate the pool if not already active.
  * If lp->thin, create thin LV within the pool - as a snapshot if lp->snapshot.
@@ -6029,7 +6041,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	}
 
 	/* Do not scan this LV until properly zeroed/wiped. */
-	if (lp->zero | lp->wipe_signatures)
+	if (_should_wipe_lv(lp, lv))
 		lv->status |= LV_NOSCAN;
 
 	if (lp->temporary)
@@ -6110,9 +6122,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			log_verbose("Signature wiping on \"%s/%s\" not requested", lv->vg->name, lv->name);
 	}
 
-	if ((!seg_is_thin(lp) ||
-	    (lv_is_thin_volume(lv) && !lp->snapshot &&
-	     !first_seg(first_seg(lv)->pool_lv)->zero_new_blocks))) {
+	if (_should_wipe_lv(lp, lv)) {
 		if (!wipe_lv(lv, (struct wipe_params)
 			     {
 				     .do_zero = lp->zero,


