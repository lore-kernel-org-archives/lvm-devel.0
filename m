From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 11 May 2010 08:36:05 -0400
Subject: [PATCH 1/6] Add pvid_from_devname() lvmcache function.
In-Reply-To: <1273581370-13528-1-git-send-email-dwysocha@redhat.com>
References: <1273581370-13528-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1273581370-13528-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add supporting function for mappings from devname -> pvid -> vgname.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c |   19 +++++++++++++++++++
 lib/cache/lvmcache.h |    2 ++
 2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0e31a4e..2a5f2d7 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -747,6 +747,25 @@ struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
 	return NULL;
 }
 
+const char *pvid_from_devname(struct cmd_context *cmd,
+			      const char *devname)
+{
+	struct device *dev;
+	struct label *label;
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


