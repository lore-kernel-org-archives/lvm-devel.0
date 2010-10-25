From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:24 +0200
Subject: [PATCH 17/30] Use const pvid for device_from_pvid()
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <6d6e018d2a3a09b8dfb9059df78a5e416eb0cd60.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update interface for device_from_pvid and use const pvid.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c |    2 +-
 lib/cache/lvmcache.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 35d6f76..83ac1a5 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -733,7 +733,7 @@ struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
 	return pvids;
 }
 
-struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
+struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 				unsigned *scan_done_once)
 {
 	struct label *label;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 4966a5c..28f8541 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -94,7 +94,7 @@ struct lvmcache_vginfo *vginfo_from_vgname(const char *vgname,
 struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
 struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
-struct device *device_from_pvid(struct cmd_context *cmd, struct id *pvid,
+struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 				unsigned *scan_done_once);
 const char *pvid_from_devname(struct cmd_context *cmd,
 			      const char *dev_name);
-- 
1.7.3.1


