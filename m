From: Hannes Reinecke <hare@suse.de>
Date: Tue, 18 Mar 2014 09:24:02 +0100
Subject: [PATCH 2/2] Handle duplicate PVs on drbd
In-Reply-To: <1395131042-5015-1-git-send-email-hare@suse.de>
References: <1395131042-5015-1-git-send-email-hare@suse.de>
Message-ID: <1395131042-5015-3-git-send-email-hare@suse.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Xinwei Hu <xwhu@suse.de>

If lvm finds a duplicate PV where one device is a drbd device
it should prefer the drbd device.

Signed-off-by: Xinwei Hu <xwhu@suse.de>
Acked-by: Hannes Reinecke <hare@suse.de>
---
 lib/cache/lvmcache.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d40bdce..ebc619b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1503,6 +1503,14 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 						 dev_subsystem_name(dt, existing->dev),
 						 dev_name(existing->dev));
 				return NULL;
+			} else if (MAJOR(existing->dev->dev) == dt->drbd_major &&
+					MAJOR(dev->dev) != dt->drbd_major) {
+				log_very_verbose("Ignoring duplicate PV %s on "
+						"%s - using drbd %s",
+						pvid, dev_name(dev),
+						dev_name(existing->dev));
+				return NULL;
+
 			} else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
 				   !dm_is_dm_major(MAJOR(dev->dev))) {
 				log_very_verbose("Ignoring duplicate PV %s on "
@@ -1523,6 +1531,12 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 						 "using dm %s", pvid,
 						 dev_name(existing->dev),
 						 dev_name(dev));
+			else if (MAJOR(existing->dev->dev) != dt->drbd_major &&
+					MAJOR(dev->dev) == dt->drbd_major)
+				log_very_verbose("Duplicate PV %s on %s - "
+						"using drbd %s", pvid,
+						dev_name(existing->dev),
+						dev_name(dev));
 			/* FIXME If both dm, check dependencies */
 			//else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
 				 //dm_is_dm_major(MAJOR(dev->dev)))
-- 
1.8.1.4


