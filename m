From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 22 Apr 2015 18:24:04 +0000 (UTC)
Subject: master - Improve duplicate PV handling
Message-ID: <20150422182404.97354602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3fc9615d156892efd8bb28b0306c2fe9c14738ff
Commit:        3fc9615d156892efd8bb28b0306c2fe9c14738ff
Parent:        92607ecfe62c2590c7816d53c709d3b96faa2357
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 20 14:13:50 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 22 13:22:14 2015 -0500

Improve duplicate PV handling

Make the processing of duplicate PVs the
same with and without lvmetad.
---
 lib/cache/lvmcache.c |    9 ++++++---
 lib/cache/lvmetad.c  |   28 ++++++++++++++--------------
 2 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6f8c950..c5f78c8 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1610,10 +1610,13 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				 //dm_is_dm_major(MAJOR(dev->dev)))
 				 //
 			else if (!strcmp(pvid_s, existing->dev->pvid)) {
-				log_error("Found duplicate PV %s: using %s not "
-					  "%s", pvid, dev_name(dev),
-					  dev_name(existing->dev));
+				log_error("Found duplicate PV %s: using %s not %s",
+					  pvid_s,
+					  dev_name(existing->dev),
+					  dev_name(dev));
+				strncpy(dev->pvid, pvid_s, sizeof(dev->pvid));
 				_found_duplicate_pvs = 1;
+				return NULL;
 			}
 		}
 		if (strcmp(pvid_s, existing->dev->pvid)) 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 5de571d..600a6cb 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -299,20 +299,6 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 	if (!dev && fallback)
 		dev = dev_cache_get_by_devt(fallback, cmd->filter);
 
-	if (alt_devices)
-		alt_device = alt_devices->v;
-
-	while (alt_device) {
-		dev_alternate = dev_cache_get_by_devt(alt_device->v.i, cmd->filter);
-		if (dev_alternate)
-			log_warn("Found duplicate of PV %s on device %s.",
-				 pvid_txt, dev_name(dev_alternate));
-		else
-			log_warn("Duplicate of PV %s exists on unknown device %"PRId64 ":%" PRId64,
-				 pvid_txt, MAJOR(alt_device->v.i), MINOR(alt_device->v.i));
-		alt_device = alt_device->next;
-	}
-
 	if (!dev) {
 		log_warn("WARNING: Device for PV %s not found or rejected by a filter.", pvid_txt);
 		return NULL;
@@ -375,6 +361,20 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 		++i;
 	} while (da);
 
+	if (alt_devices)
+		alt_device = alt_devices->v;
+
+	while (alt_device) {
+		dev_alternate = dev_cache_get_by_devt(alt_device->v.i, cmd->filter);
+		if (dev_alternate)
+			lvmcache_add(fmt->labeller, (const char *)&pvid, dev_alternate,
+				     vgname, (const char *)&vgid, 0);
+		else
+			log_warn("Duplicate of PV %s dev %s exists on unknown device %"PRId64 ":%" PRId64,
+				 pvid_txt, dev_name(dev), MAJOR(alt_device->v.i), MINOR(alt_device->v.i));
+		alt_device = alt_device->next;
+	}
+
 	return info;
 }
 


