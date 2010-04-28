From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 28 Apr 2010 11:55:38 -0400
Subject: [PATCH 1/5] Add pvid_from_devname() lvmcache function.
In-Reply-To: <1272470142-13843-1-git-send-email-dwysocha@redhat.com>
References: <1272470142-13843-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1272470142-13843-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add supporting function for mappings from devname -> pvid -> vgname.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c |   21 +++++++++++++++++++++
 lib/cache/lvmcache.h |    2 ++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 73102ec..f53b4c3 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -747,6 +747,27 @@ struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
 	return NULL;
 }
 
+const char *pvid_from_devname(struct cmd_context *cmd,
+			      const char *devname)
+{
+	struct device *dev;
+	struct label *label;
+	struct lvmcache_info *info;
+
+	if (!(dev = dev_cache_get(devname, cmd->filter))) {
+		log_error("%s: Couldn't find device.  Check your filters?",
+			  devname);
+		return NULL;
+	}
+
+	if (!(label_read(dev, &label, UINT64_C(0))))
+		return NULL;
+
+	info = (struct lvmcache_info *) label->info;
+	return dev->pvid;
+}
+
+
 static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 {
 	struct lvmcache_vginfo *primary_vginfo, *vginfo2;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 8eeb495..5b0ca73 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -95,6 +95,8 @@ struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
 				unsigned *scan_done_once);
+const char *pvid_from_devname(struct cmd_context *cmd,
+			      const char *dev_name);
 int vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 
-- 
1.6.0.6


