From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Feb 2014 08:44:54 +0000 (UTC)
Subject: master - allocation: add default path
Message-ID: <20140225084454.936B861268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7d189baf741d8f27c66cb53ea15f78dcc29efec
Commit:        e7d189baf741d8f27c66cb53ea15f78dcc29efec
Parent:        3e49753e6cf9886472c3e7cd11da456f1bd856d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 25 09:36:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 25 09:36:26 2014 +0100

allocation: add default path

Make it obvious for compiler extents is always defined for
valid code path.
---
 lib/metadata/lv_manip.c |    3 +++
 tools/lvcreate.c        |    5 ++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c4b644c..9dd8f0e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3858,6 +3858,9 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 		case PERCENT_NONE:
 			extents = lp->extents;
 			break;
+		default:
+			log_error(INTERNAL_ERROR "Unsupported percent type %u.", lp->percent);
+			return 0;
 	}
 
 	if (lp->percent != PERCENT_NONE) {
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7d9d22e..7a734f2 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -363,7 +363,7 @@ static int _update_extents_params(struct volume_group *vg,
 	} else
 		lp->pvh = &vg->pvs;
 
-	switch(lcp->percent) {
+	switch (lcp->percent) {
 		case PERCENT_VG:
 			extents = percent_of_extents(lp->extents, vg->extent_count, 0);
 			break;
@@ -397,6 +397,9 @@ static int _update_extents_params(struct volume_group *vg,
 		case PERCENT_NONE:
 			extents = lp->extents;
 			break;
+		default:
+			log_error(INTERNAL_ERROR "Unsupported percent type %u.", lcp->percent);
+			return 0;
 	}
 
 	if (lcp->percent) {


