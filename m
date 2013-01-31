From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 31 Jan 2013 16:52:57 -0600
Subject: [PATCH 2 of 3] Cached lv_raid_dev_health results
Message-ID: <1359672777.13305.13.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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

Index: lvm2/lib/activate/activate.c
===================================================================
--- lvm2.orig/lib/activate/activate.c
+++ lvm2/lib/activate/activate.c
@@ -783,7 +783,17 @@ int lv_raid_dev_health(const struct logi
 	struct dev_manager *dm;
 	struct lvinfo info;
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
@@ -806,6 +816,7 @@ int lv_raid_dev_health(const struct logi
 					   status->dev_health)))
 		stack;
 
+	cached_dev_health = *dev_health;
 	dev_manager_destroy(dm);
 
 	return r;



