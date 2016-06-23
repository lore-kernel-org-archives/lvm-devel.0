From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:35 +0000 (UTC)
Subject: master - lvresize: move and extend resizefs ignoring check
Message-ID: <20160623130135.15EAA60612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58d414f7f5d998e32234e7a6c2d6c9d0ad38f996
Commit:        58d414f7f5d998e32234e7a6c2d6c9d0ad38f996
Parent:        fa69ed0bc845df3d2c7ae68d03cdd4a3dec339d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 20 13:16:53 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:08 2016 +0200

lvresize: move and extend resizefs ignoring check

Move check for 'ignoring' --resizefs option and extend check
for some more types.
---
 lib/metadata/lv_manip.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a908e1e..a628683 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4709,6 +4709,17 @@ static int _lvresize_check_lv(struct logical_volume *lv,
 	if (lp->ac_stripesize && !_validate_stripesize(vg, lp))
 		return_0;
 
+	if (lp->resizefs &&
+	    (lv_is_thin_pool(lv) ||
+	     lv_is_thin_pool_data(lv) ||
+	     lv_is_thin_pool_metadata(lv) ||
+	     lv_is_pool_metadata_spare(lv) ||
+	     lv_is_lockd_sanlock_lv(lv))) {
+		log_print_unless_silent("Ignoring --resizefs as volume %s does not have a filesystem.",
+					display_lvname(lv));
+		lp->resizefs = 0;
+	}
+
 	if (lp->ac_stripes) {
 		if (!(vg->fid->fmt->features & FMT_SEGMENTS))
 			log_print_unless_silent("Varied striping not supported. Ignoring.");
@@ -5212,10 +5223,6 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 	alloc_policy_t alloc;
 
 	if (lv_is_thin_pool(lv)) {
-		if (lp->resizefs) {
-			log_print_unless_silent("Ignoring --resizefs as thin pool volumes do not have filesystem.");
-			lp->resizefs = 0;
-		}
 		lock_lv = lv;
 		seg = first_seg(lv);
 		/* Switch to layered LV resizing */


