From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:53 +0000 (UTC)
Subject: master - debug: catch invalid request for tree
Message-ID: <20140408090253.80C7F60F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9eab84aa2b4cf97f931f0291b3f690cdceaa1e75
Commit:        9eab84aa2b4cf97f931f0291b3f690cdceaa1e75
Parent:        43f849296e1e4b5450681e275495450bf041a11b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 7 20:33:50 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:15 2014 +0200

debug: catch invalid request for tree

In general for non-toplevel LVs we shouldn't allow any _tree_action.
For now error on request for cache_pool activation which
doesn't even exist in dm-table.
---
 lib/activate/dev_manager.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cde39af..fb9625d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2786,6 +2786,12 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	char *dlid;
 	int r = 0;
 
+	/* Some LV can be used for top level tree */
+	/* TODO: add more.... */
+	if (lv_is_cache_pool(lv)) {
+		log_error(INTERNAL_ERROR "Cannot create tree for %s.", lv->name);
+		return 0;
+	}
 	/* Some targets may build bigger tree for activation */
 	dm->activation = ((action == PRELOAD) || (action == ACTIVATE));
 	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))


