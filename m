From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 14 Apr 2015 20:22:11 +0000 (UTC)
Subject: master - lvmetad: Issue warnings about duplicate PV UUIDs (client-side).
Message-ID: <20150414202211.8540C602FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=24352aff2b30ad23aebd444c752d8b6dd02c9f03
Commit:        24352aff2b30ad23aebd444c752d8b6dd02c9f03
Parent:        a1dd61459cf40eae21ed407115f652cabdba1ad4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Mar 31 18:47:02 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Apr 14 20:18:27 2015 +0200

lvmetad: Issue warnings about duplicate PV UUIDs (client-side).

---
 lib/cache/lvmetad.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 7bb6701..5de571d 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -269,13 +269,14 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 						   struct dm_config_node *cn,
 						   struct format_type *fmt, dev_t fallback)
 {
-	struct device *dev;
+	struct device *dev, *dev_alternate;
 	struct id pvid, vgid;
 	char mda_id[32];
 	char da_id[32];
 	int i = 0;
-	struct dm_config_node *mda = NULL;
-	struct dm_config_node *da = NULL;
+	struct dm_config_node *mda, *da;
+	struct dm_config_node *alt_devices = dm_config_find_node(cn->child, "devices_alternate");
+	struct dm_config_value *alt_device = NULL;
 	uint64_t offset, size;
 	struct lvmcache_info *info;
 	const char *pvid_txt = dm_config_find_str(cn->child, "id", NULL),
@@ -298,6 +299,20 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 	if (!dev && fallback)
 		dev = dev_cache_get_by_devt(fallback, cmd->filter);
 
+	if (alt_devices)
+		alt_device = alt_devices->v;
+
+	while (alt_device) {
+		dev_alternate = dev_cache_get_by_devt(alt_device->v.i, cmd->filter);
+		if (dev_alternate)
+			log_warn("Found duplicate of PV %s on device %s.",
+				 pvid_txt, dev_name(dev_alternate));
+		else
+			log_warn("Duplicate of PV %s exists on unknown device %"PRId64 ":%" PRId64,
+				 pvid_txt, MAJOR(alt_device->v.i), MINOR(alt_device->v.i));
+		alt_device = alt_device->next;
+	}
+
 	if (!dev) {
 		log_warn("WARNING: Device for PV %s not found or rejected by a filter.", pvid_txt);
 		return NULL;


