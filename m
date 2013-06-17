From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 17 Jun 2013 18:13:31 +0000 (UTC)
Subject: master - RAID: Remove optimization using static vars in lv_raid_dev_health
Message-ID: <20130617181331.5343861126@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1acad23d68b6b82a297fb4106f016ae7a15fcf1a
Commit:        1acad23d68b6b82a297fb4106f016ae7a15fcf1a
Parent:        8ac9791c362dd150abb80749fbb72c4a336fc61b
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jun 17 13:03:15 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jun 17 13:03:15 2013 -0500

RAID: Remove optimization using static vars in lv_raid_dev_health

Revert commit 37ffe6a.  If static variables are to be used then we
will put them elsewhere and limit the optimization to reporting
code, rather that have it be used in the general case.
---
 lib/activate/activate.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 342a474..2cdda49 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -797,18 +797,7 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 	int r;
 	struct dev_manager *dm;
 	struct dm_status_raid *status;
-	/* FIXME: find a better way for this, it is fragile */
-	static char *cached_dev_health = NULL;
-	static const struct logical_volume *cached_lv = NULL;
-
-	if ((lv == cached_lv) && cached_dev_health) {
-		*dev_health = cached_dev_health;
-		log_debug("Using cached raid status for %s/%s: %s",
-			  lv->vg->name, lv->name, *dev_health);
-		return 1;
-	}
 
-	cached_lv = lv;
 	*dev_health = NULL;
 
 	if (!activation())
@@ -830,7 +819,6 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 		return_0;
 	}
 
-	cached_dev_health = *dev_health;
 	dev_manager_destroy(dm);
 
 	return r;


