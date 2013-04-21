From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:37 +0000 (UTC)
Subject: master - thin: lvcreate better support for AAY
Message-ID: <20130421211637.DCD221322@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ca6a4105db63344abe3e62eaa0cbcfcb23c47f9
Commit:        4ca6a4105db63344abe3e62eaa0cbcfcb23c47f9
Parent:        f787b575b52fcbfa8327d083eae4f2baf296b1cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 12 11:51:46 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:06:23 2013 +0200

thin: lvcreate better support for AAY

Test rather for changes which are deactivating.
---
 lib/metadata/lv_manip.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fc316e8..a353932 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4773,9 +4773,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				goto deactivate_and_revert_new_lv;
 			}
 		}
-		if (((lp->activate == CHANGE_AY) ||
-		     (lp->activate == CHANGE_AE) ||
-		     (lp->activate == CHANGE_ALY))) {
+		if ((lp->activate != CHANGE_AN) && (lp->activate != CHANGE_ALN)) {
 			/* At this point send message to kernel thin mda */
 			pool_lv = lv_is_thin_pool(lv) ? lv : first_seg(lv)->pool_lv;
 			if (!update_pool_lv(pool_lv, 1)) {


