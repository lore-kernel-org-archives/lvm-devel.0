From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:53 +0000 (UTC)
Subject: master - cleanup: better stack tracing
Message-ID: <20141024144053.8051D60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21798418fc81a232d00e5a93ce4071004e6f0fed
Commit:        21798418fc81a232d00e5a93ce4071004e6f0fed
Parent:        a330640063fed88616379e3c2e4e85b8e2e355b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 22 13:38:47 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

cleanup: better stack tracing

Show proper backtrace on error path.
---
 lib/metadata/lv_manip.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fe0eead..5125412 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7113,16 +7113,20 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 
 		/* A virtual origin must be activated explicitly. */
-		if (lp->voriginsize &&
-		    (!(origin_lv = _create_virtual_origin(cmd, vg, lv->name,
-						    lp->permission,
-						    lp->voriginextents)) ||
-		     !activate_lv_excl(cmd, origin_lv))) {
-			log_error("Couldn't create virtual origin for LV %s",
-				  lv->name);
-			if (origin_lv && !lv_remove(origin_lv))
+		if (lp->voriginsize) {
+			if (!(origin_lv = _create_virtual_origin(cmd, vg, lv->name,
+								 lp->permission,
+								 lp->voriginextents))) {
 				stack;
-			goto deactivate_and_revert_new_lv;
+				goto deactivate_and_revert_new_lv;
+			}
+			if (!activate_lv_excl(cmd, origin_lv)) {
+				log_error("Couldn't get exclusive lock for virtual origin LV %s",
+					  lv->name);
+				if (!lv_remove(origin_lv))
+					stack;
+				goto deactivate_and_revert_new_lv;
+			}
 		}
 
 		/*


