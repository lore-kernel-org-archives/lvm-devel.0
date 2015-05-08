From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  8 May 2015 16:49:51 +0000 (UTC)
Subject: master - lvmcache: update lvmcache with alternate device
Message-ID: <20150508164951.A66F560F07@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1dfedcc179b6f7caee1069974ab34ddd111ef01d
Commit:        1dfedcc179b6f7caee1069974ab34ddd111ef01d
Parent:        cbdf514bbc3f22453c2c72c913e9161935a22bd8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 5 14:02:43 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 8 11:28:59 2015 -0500

lvmcache: update lvmcache with alternate device

When there are duplicate PVs, and one device
replaces another in lvmcache, use label_read
to update lvmcache for the new device.
---
 lib/cache/lvmetad.c |   32 +++++++++++++++++++-------------
 1 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 470a7b3..00a84b5 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -269,7 +269,8 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 						   struct dm_config_node *cn,
 						   struct format_type *fmt, dev_t fallback)
 {
-	struct device *dev, *dev_alternate;
+	struct device *dev, *dev_alternate, *dev_alternate_cache = NULL;
+	struct label *label;
 	struct id pvid, vgid;
 	char mda_id[32];
 	char da_id[32];
@@ -278,7 +279,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 	struct dm_config_node *alt_devices = dm_config_find_node(cn->child, "devices_alternate");
 	struct dm_config_value *alt_device = NULL;
 	uint64_t offset, size;
-	struct lvmcache_info *info;
+	struct lvmcache_info *info, *info_alternate;
 	const char *pvid_txt = dm_config_find_str(cn->child, "id", NULL),
 		   *vgid_txt = dm_config_find_str(cn->child, "vgid", NULL),
 		   *vgname = dm_config_find_str(cn->child, "vgname", NULL),
@@ -367,23 +368,28 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 	while (alt_device) {
 		dev_alternate = dev_cache_get_by_devt(alt_device->v.i, cmd->filter);
 		if (dev_alternate) {
-			if ((info = lvmcache_add(fmt->labeller, (const char *)&pvid, dev_alternate,
-						 vgname, (const char *)&vgid, 0))) {
-				/*
-				 * FIXME: when lvmcache_add returns non-NULL,
-				 * it means that it has made dev_alternate
-				 * the preferred device in lvmcache.
-				 * I think that means it should be followed
-				 * by the same steps done above?
-				 */
-				log_warn("lvmcache only partially updated for alternate device %s", dev_name(dev));
+			if ((info_alternate = lvmcache_add(fmt->labeller, (const char *)&pvid, dev_alternate,
+							   vgname, (const char *)&vgid, 0))) {
+				dev_alternate_cache = dev_alternate;
+				info = info_alternate;
 			}
-		} else
+		} else {
 			log_warn("Duplicate of PV %s dev %s exists on unknown device %"PRId64 ":%" PRId64,
 				 pvid_txt, dev_name(dev), MAJOR(alt_device->v.i), MINOR(alt_device->v.i));
+		}
 		alt_device = alt_device->next;
 	}
 
+	/*
+	 * Update lvmcache with the info about the alternate device by
+	 * reading its label, which should update lvmcache.
+	 */
+	if (dev_alternate_cache) {
+		if (!label_read(dev_alternate_cache, &label, 0)) {
+			log_warn("No PV label found on duplicate device %s.", dev_name(dev_alternate_cache));
+		}
+	}
+
 	return info;
 }
 


