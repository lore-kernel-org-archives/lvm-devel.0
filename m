From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:46 +0000 (UTC)
Subject: master - lvresize: check for given parameters
Message-ID: <20160211173946.24D4460DC9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f916e8285a8f164927a68082ac6dc759d6720a0
Commit:        3f916e8285a8f164927a68082ac6dc759d6720a0
Parent:        0baf66a992fbac92fa2c30e9bb8e74a5535ff45a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 13:08:13 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:35:06 2016 +0100

lvresize: check for given parameters

Check ac_ value as passed args.
Also drop reseting 'computed' values - since they get
assigned values later.
---
 lib/metadata/lv_manip.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f339d9e..1e1d1b4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4974,11 +4974,9 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			}
 		}
 	} else {  /* If reducing, find stripes, stripesize & size of last segment */
-		if (lp->stripes || lp->stripe_size || lp->mirrors) {
-			lp->stripes = lp->stripe_size = lp->mirrors = 0;
+		if (lp->ac_stripes || lp->ac_stripesize || lp->ac_mirrors)
 			log_print_unless_silent("Ignoring stripes, stripesize and mirrors "
 						"arguments when reducing.");
-		}
 
 		if (lp->sign == SIGN_MINUS)  {
 			if (lp->extents >= existing_extents) {


