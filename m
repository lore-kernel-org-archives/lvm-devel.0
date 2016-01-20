From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jan 2016 12:53:50 +0000 (UTC)
Subject: master - cleanup: use log_print
Message-ID: <20160120125350.737B260D1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c99ca6f430eb3650115882b5b6a8f9dde6212b12
Commit:        c99ca6f430eb3650115882b5b6a8f9dde6212b12
Parent:        2da7525c8371a94ee8fe700ff021e3b14dd2fd34
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 15 10:35:10 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 20 13:44:47 2016 +0100

cleanup: use log_print

Using log_print for ignoring message instead of log_warn.
Add some missing '.'.
---
 lib/metadata/lv_manip.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7ba52f9..e0312e3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4269,17 +4269,17 @@ static int _validate_stripesize(struct cmd_context *cmd,
 				struct lvresize_params *lp)
 {
 
-	if ( lp->ac_stripesize_value > STRIPE_SIZE_LIMIT * 2) {
-		log_error("Stripe size cannot be larger than %s",
+	if (lp->ac_stripesize_value > (STRIPE_SIZE_LIMIT * 2)) {
+		log_error("Stripe size cannot be larger than %s.",
 			  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 		return 0;
 	}
 
 	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
-		log_warn("Varied stripesize not supported. Ignoring.");
+		log_print_unless_silent("Varied stripesize not supported. Ignoring.");
 	else if (lp->ac_stripesize_value > vg->extent_size) {
 		log_print_unless_silent("Reducing stripe size %s to maximum, "
-					"physical extent size %s",
+					"physical extent size %s.",
 					display_size(cmd, lp->ac_stripesize_value),
 					display_size(cmd, vg->extent_size));
 		lp->stripe_size = vg->extent_size;
@@ -4287,7 +4287,7 @@ static int _validate_stripesize(struct cmd_context *cmd,
 		lp->stripe_size = lp->ac_stripesize_value;
 
 	if (lp->stripe_size & (lp->stripe_size - 1)) {
-		log_error("Stripe size must be power of 2");
+		log_error("Stripe size must be power of 2.");
 		return 0;
 	}
 


