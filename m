From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Oct 2016 11:39:23 +0000 (UTC)
Subject: master - lvconvert: fix error value
Message-ID: <20161011113923.CD62E6027B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1186cf2ad4bbfef07ead644dc689745d10709789
Commit:        1186cf2ad4bbfef07ead644dc689745d10709789
Parent:        20e74313cd8abaa691fb4f1015a84b34171aa08a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 11 11:59:43 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 11 13:36:29 2016 +0200

lvconvert: fix error value

Seems some error path where not converted to 'new' ECMD return value.
Fix them to always 'goto out'.
Also drop unneeded   'ret = 0' when ret already is 0.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   12 ++++--------
 2 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b0140be..4138685 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.167 - 
 ======================================
+  Fix a few unconverted return code values for some lvconvert error path.
   Disable lvconvert of thin pool to raid while active.
   Disable systemd service start rate limiting for lvm2-pvscan at .service.
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index daa2af4..a5ef234 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4446,13 +4446,11 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (lv_is_locked(lv)) {
 		log_error("Cannot convert locked LV %s.", display_lvname(lv));
-		ret = 0;
 		goto out;
 	}
 
 	if (lv_is_pvmove(lv)) {
 		log_error("Cannot convert pvmove LV %s.", display_lvname(lv));
-		ret = 0;
 		goto out;
 	}
 
@@ -4471,7 +4469,6 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		    !lv_is_mirrored(lv) &&
 		    !lv_is_raid(lv)) {
 			log_error("Cannot convert internal LV %s.", display_lvname(lv));
-			ret = 0;
 			goto out;
 		}
 	}
@@ -4480,12 +4477,12 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!*lp->type_str)
 		lp->segtype = seg->segtype;
 	else if (!(lp->segtype = get_segtype_from_string(cmd, lp->type_str)))
-		return_0;
+		goto_out;
 
 	if (!strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
 		if (!lp->mirrors_supplied && !seg_is_raid1(seg)) {
 			log_error("Conversions to --type mirror require -m/--mirrors");
-			return 0;
+			goto out;
 		}
 	}
 
@@ -4494,7 +4491,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel.", lp->segtype->name);
-		return 0;
+		goto out;
 	}
 
 	/* Process striping parameters */
@@ -4503,7 +4500,7 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	    _striped_type_requested(lp->type_str) || lp->repair || lp->mirrorlog || lp->corelog) {
 		/* FIXME Handle +/- adjustments too? */
 		if (!get_stripe_params(cmd, lp->segtype, &lp->stripes, &lp->stripe_size, &lp->stripes_supplied, &lp->stripe_size_supplied))
-			return_0;
+			goto_out;
 
 		if (_raid0_type_requested(lp->type_str) || _striped_type_requested(lp->type_str))
 			/* FIXME Shouldn't need to override get_stripe_params which defaults to 1 stripe (i.e. linear)! */
@@ -4569,7 +4566,6 @@ static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 	 * reach here, but this covers anything that was missed.
 	 */
 	log_error("Cannot convert LV %s.", display_lvname(lv));
-	ret = 0;
 
 out:
 	return ret ? ECMD_PROCESSED : ECMD_FAILED;


