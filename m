From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Jun 2013 11:47:57 +0000 (UTC)
Subject: master - cleanup: use log_print instead of log_error
Message-ID: <20130625114757.4C42561386@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a059f2358d0a339d4d8095fbde08b06409eb131
Commit:        2a059f2358d0a339d4d8095fbde08b06409eb131
Parent:        01174b8b8b140280976182c143e764d525c54939
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 20 14:08:25 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 13:47:39 2013 +0200

cleanup: use log_print instead of log_error

Since reduce the message has informational character and doesn't lead
to exit of the command - reduce the log level to info print as we
use for other similar types.

Reindent next print message.
---
 lib/metadata/lv_manip.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b7c538b..8acca49 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4424,10 +4424,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	}
 
 	if (lp->stripe_size > vg->extent_size) {
-		log_error("Reducing requested stripe size %s to maximum, "
-			  "physical extent size %s",
-			  display_size(cmd, (uint64_t) lp->stripe_size),
-			  display_size(cmd, (uint64_t) vg->extent_size));
+		log_print_unless_silent("Reducing requested stripe size %s to maximum, "
+					"physical extent size %s.",
+					display_size(cmd, (uint64_t) lp->stripe_size),
+					display_size(cmd, (uint64_t) vg->extent_size));
 		lp->stripe_size = vg->extent_size;
 	}
 
@@ -4442,8 +4442,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 
 	if ((size_rest = lp->extents % lp->stripes)) {
 		log_print_unless_silent("Rounding size (%d extents) up to stripe boundary "
-					"size (%d extents)", lp->extents,
-			  lp->extents - size_rest + lp->stripes);
+					"size (%d extents).", lp->extents,
+					lp->extents - size_rest + lp->stripes);
 		lp->extents = lp->extents - size_rest + lp->stripes;
 	}
 


