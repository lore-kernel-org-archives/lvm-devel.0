From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 04:56:38 -0400
Subject: master - [lvmetad.h] Use static inline functions to stub out functions.
Message-ID: <201804300856.w3U8ucTm018944@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=513e9e3264d6499630ba863ead3fe3701fc8ac29
Commit:        513e9e3264d6499630ba863ead3fe3701fc8ac29
Parent:        475626fb6c8f2d714dcf8b7aea727430756fc571
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Feb 12 13:41:27 2018 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 09:45:13 2018 +0100

[lvmetad.h] Use static inline functions to stub out functions.

The macros were causing warnings because the arguments were percieved as
unused.
---
 lib/cache/lvmetad.h |   76 +++++++++++++++++++++++++++++---------------------
 1 files changed, 44 insertions(+), 32 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index d47ce41..73c2645 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -17,6 +17,8 @@
 
 #include "config-util.h"
 
+#include <stdint.h>
+
 struct volume_group;
 struct cmd_context;
 struct dm_config_tree;
@@ -163,38 +165,48 @@ void lvmetad_clear_disabled(struct cmd_context *cmd);
 
 #  else		/* LVMETAD_SUPPORT */
 
-#    define lvmetad_disconnect()	do { } while (0)
-#    define lvmetad_connect(cmd)	(0)
-#    define lvmetad_make_unused(cmd)	do { } while (0)
-#    define lvmetad_used()		(0)
-#    define lvmetad_set_socket(a)	do { } while (0)
-#    define lvmetad_socket_present()	(0)
-#    define lvmetad_pidfile_present()   (0)
-#    define lvmetad_set_token(a)	do { } while (0)
-#    define lvmetad_release_token()	do { } while (0)
-#    define lvmetad_vg_update(vg)	(1)
-#    define lvmetad_vg_update_pending(vg)	(1)
-#    define lvmetad_vg_update_finish(vg)	(1)
-#    define lvmetad_vg_remove_pending(vg)	(1)
-#    define lvmetad_vg_remove_finish(vg)	(1)
-#    define lvmetad_pv_found(cmd, pvid, dev, fmt, label_sector, vg, found_vgnames, changed_vgnames)	(1)
-#    define lvmetad_pv_gone(devno, pv_name)	(1)
-#    define lvmetad_pv_gone_by_dev(dev)	(1)
-#    define lvmetad_pv_list_to_lvmcache(cmd)	(1)
-#    define lvmetad_pv_lookup(cmd, pvid, found)	(0)
-#    define lvmetad_pv_lookup_by_dev(cmd, dev, found)	(0)
-#    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
-#    define lvmetad_get_vgnameids(cmd, vgnameids)       do { } while (0)
-#    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
-#    define lvmetad_pvscan_single(cmd, dev, found_vgnames, changed_vgnames)	(0)
-#    define lvmetad_pvscan_all_devs(cmd, do_wait)	(0)
-#    define lvmetad_vg_clear_outdated_pvs(vg)           do { } while (0)
-#    define lvmetad_validate_global_cache(cmd, force)	do { } while (0)
-#    define lvmetad_vg_is_foreign(cmd, vgname, vgid) (0)
-#    define lvmetad_token_matches(cmd) (1)
-#    define lvmetad_is_disabled(cmd, reason) (0)
-#    define lvmetad_set_disabled(cmd, reason) do { } while (0)
-#    define lvmetad_clear_disabled(cmd) do { } while (0)
+static inline int lvmetad_connect(struct cmd_context *cmd) {return 0;}
+static inline void lvmetad_disconnect(void) {}
+static inline void lvmetad_make_unused(struct cmd_context *cmd) {}
+static inline int lvmetad_used(void) {return 0;}
+static inline void lvmetad_set_socket(const char *thing) {}
+static inline int lvmetad_socket_present(void) {return 0;}
+static inline int lvmetad_pidfile_present(void) {return 0;}
+static inline void lvmetad_set_token(const struct dm_config_value *filter) {}
+static inline void lvmetad_release_token(void) {}
+static inline int lvmetad_vg_update_pending(struct volume_group *vg) {return 1;}
+static inline int lvmetad_vg_update_finish(struct volume_group *vg) {return 1;}
+static inline int lvmetad_vg_remove_pending(struct volume_group *vg) {return 1;}
+static inline int lvmetad_vg_remove_finish(struct volume_group *vg) {return 1;}
+static inline int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct device *dev,
+		     const struct format_type *fmt, uint64_t label_sector,
+		     struct volume_group *vg,
+		     struct dm_list *found_vgnames,
+		     struct dm_list *changed_vgnames) {return 1;}
+static inline int lvmetad_pv_gone(dev_t devno, const char *pv_name) {return 1;}
+static inline int lvmetad_pv_gone_by_dev(struct device *dev) {return 1;}
+static inline int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd) {return 1;}
+static inline int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found) {return 0;}
+static inline int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *found) {return 0;}
+static inline int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd) {return 1;}
+static inline int lvmetad_get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids) {return 0;}
+static inline struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
+				       const char *vgname, const char *vgid) {return NULL;}
+static inline int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
+			  struct dm_list *found_vgnames,
+			  struct dm_list *changed_vgnames) {return 0;}
+
+static inline int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait) {return 0;}
+
+static inline int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg) {return 0;}
+static inline void lvmetad_validate_global_cache(struct cmd_context *cmd, int force) {}
+static inline int lvmetad_token_matches(struct cmd_context *cmd) {return 1;}
+
+static inline int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid) {return 0;}
+
+static inline int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason) {return 0;}
+static inline void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason) {}
+static inline void lvmetad_clear_disabled(struct cmd_context *cmd) {}
 
 #  endif	/* LVMETAD_SUPPORT */
 


