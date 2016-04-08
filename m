From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 Apr 2016 18:22:19 +0000 (UTC)
Subject: master - cleanup: avoid gcc warns
Message-ID: <20160408182219.C457160309@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af148a9d7715a8026d3d51a4c4c176bf59d3cc5f
Commit:        af148a9d7715a8026d3d51a4c4c176bf59d3cc5f
Parent:        5cfa6cb347c5b7d8c5e3119b59bc7331388cb47e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 8 11:36:02 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 8 20:20:16 2016 +0200

cleanup: avoid gcc warns

Some older systems may had global declaration to cause gcc warning.
Rename for cases we don't care...
---
 daemons/dmeventd/libdevmapper-event.c |    4 ++--
 daemons/dmeventd/libdevmapper-event.h |    2 +-
 lib/cache/lvmcache.c                  |    2 +-
 lib/cache/lvmcache.h                  |    2 +-
 lib/metadata/metadata-exported.h      |    2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 871c0d6..d395ed3 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -855,9 +855,9 @@ int dm_event_get_version(struct dm_event_fifos *fifos, int *version) {
 	return 1;
 }
 
-void dm_event_log_set(int debug_level, int use_syslog)
+void dm_event_log_set(int debug_log_level, int use_syslog)
 {
-	_debug_level = debug_level;
+	_debug_level = debug_log_level;
 	_use_syslog = use_syslog;
 }
 
diff --git a/daemons/dmeventd/libdevmapper-event.h b/daemons/dmeventd/libdevmapper-event.h
index f9fb442..4c97223 100644
--- a/daemons/dmeventd/libdevmapper-event.h
+++ b/daemons/dmeventd/libdevmapper-event.h
@@ -106,7 +106,7 @@ int dm_event_register_handler(const struct dm_event_handler *dmevh);
 int dm_event_unregister_handler(const struct dm_event_handler *dmevh);
 
 /* Set debug level for logging, and whether to log on stdout/stderr or syslog */
-void dm_event_log_set(int debug_level, int use_syslog);
+void dm_event_log_set(int debug_log_level, int use_syslog);
 
 /* Log messages acroding to current debug level  */
 __attribute__((format(printf, 6, 0)))
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index b1e53e2..394745a 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1133,7 +1133,7 @@ struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct i
 }
 
 const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
-			      const char *devname)
+				       const char *devname)
 {
 	struct device *dev;
 	struct label *label;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 9ca0379..0ebbe07 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -108,7 +108,7 @@ const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgnam
 struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 				unsigned *scan_done_once, uint64_t *label_sector);
 const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
-			      const char *dev_name);
+				       const char *devname);
 char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
 const char *lvmcache_vgname_from_info(struct lvmcache_info *info);
 int lvmcache_vgs_locked(void);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ecca418..fb2ffa3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1061,7 +1061,7 @@ struct lv_segment *get_only_segment_using_this_lv(const struct logical_volume *l
 * Useful functions for managing snapshots.
 */
 int lv_is_origin(const struct logical_volume *lv);
-int lv_is_thin_origin(const struct logical_volume *lv, unsigned *snapshot_count);
+int lv_is_thin_origin(const struct logical_volume *lv, unsigned *snap_count);
 int lv_is_cache_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
 int lv_is_merging_cow(const struct logical_volume *cow);


