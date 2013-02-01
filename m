From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri,  1 Feb 2013 17:36:25 +0000 (UTC)
Subject: master - RAID: Cache previous results of lv_raid_dev_health for future use
Message-ID: <20130201173625.D5F83A333E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37ffe6a13ad56122abdc808c13af9eeb1adf6731
Commit:        37ffe6a13ad56122abdc808c13af9eeb1adf6731
Parent:        c8242e5cf4895f13e16b598b387c876c6fab7180
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Feb 1 11:32:18 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Feb 1 11:32:18 2013 -0600

RAID:  Cache previous results of lv_raid_dev_health for future use

We can avoid many dev_manager (ioctl) calls by caching the results of
previous calls to lv_raid_dev_health.  Just considering the case where
'lvs -a' is called to get the attributes of a RAID LV and its sub-lvs,
this function would be called many times.  (It would be called at least
7 times for a 3-way RAID1 - once for the health of each sub-LV and once
for the health of the top-level LV.)  This is a good idea because the
sub-LVs are processed in groups along with their parent RAID LV and in
each case, it is the parent LV whose status will be queried.  Therefore,
there only needs to be one trip through dev_manager for each time the
group is processed.
---
 lib/activate/activate.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 602445f..ac19bd2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -786,7 +786,17 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 	int r;
 	struct dev_manager *dm;
 	struct dm_status_raid *status;
+	static char *cached_dev_health = NULL;
+	static const struct logical_volume *cached_lv = NULL;
 
+	if ((lv == cached_lv) && cached_dev_health) {
+		*dev_health = cached_dev_health;
+		log_debug("Using cached raid status for %s/%s: %s",
+			  lv->vg->name, lv->name, *dev_health);
+		return 1;
+	}
+
+	cached_lv = lv;
 	*dev_health = NULL;
 
 	if (!activation())
@@ -806,6 +816,7 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health)
 					   status->dev_health)))
 		stack;
 
+	cached_dev_health = *dev_health;
 	dev_manager_destroy(dm);
 
 	return r;


