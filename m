From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Jan 2013 23:48:33 +0000 (UTC)
Subject: master - lvmetad: rename device vars and move _token_update
Message-ID: <20130104234833.16275231A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=41e7f45258555bf28871a8243487a12751932842
Commit:        41e7f45258555bf28871a8243487a12751932842
Parent:        981962b339123338335da5a3cda822117808c591
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 4 23:45:22 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 4 23:45:22 2013 +0000

lvmetad: rename device vars and move _token_update

Move _token_update() to avoid the need for _lvmetad_send prototype.

Use 'dev' consistently for a struct device * variable.
Use 'devno' for a dev_t.
---
 lib/cache/lvmetad.c |   49 +++++++++++++++++++++++--------------------------
 lib/cache/lvmetad.h |    4 ++--
 2 files changed, 25 insertions(+), 28 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 0862f0a..0999fbd 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -118,22 +118,6 @@ void lvmetad_set_socket(const char *sock)
 	_lvmetad_socket = sock;
 }
 
-static daemon_reply _lvmetad_send(const char *id, ...);
-
-static int _token_update(void)
-{
-	daemon_reply repl = _lvmetad_send("token_update", NULL);
-
-	if (repl.error || strcmp(daemon_reply_str(repl, "response", ""), "OK")) {
-		daemon_reply_destroy(repl);
-		return 0;
-	}
-
-	daemon_reply_destroy(repl);
-	return 1;
-}
-
-
 static daemon_reply _lvmetad_send(const char *id, ...)
 {
 	va_list ap;
@@ -167,6 +151,19 @@ retry:
 	return repl;
 }
 
+static int _token_update(void)
+{
+	daemon_reply repl = _lvmetad_send("token_update", NULL);
+
+	if (repl.error || strcmp(daemon_reply_str(repl, "response", ""), "OK")) {
+		daemon_reply_destroy(repl);
+		return 0;
+	}
+
+	daemon_reply_destroy(repl);
+	return 1;
+}
+
 /*
  * Helper; evaluate the reply from lvmetad, check for errors, print diagnostics
  * and return a summary success/failure exit code.
@@ -222,7 +219,7 @@ static int _read_mda(struct lvmcache_info *info,
 static struct lvmcache_info *_pv_populate_lvmcache(
 	struct cmd_context *cmd, struct dm_config_node *cn, dev_t fallback)
 {
-	struct device *device;
+	struct device *dev;
 	struct id pvid, vgid;
 	char mda_id[32];
 	char da_id[32];
@@ -246,11 +243,11 @@ static struct lvmcache_info *_pv_populate_lvmcache(
 		return NULL;
 	}
 
-	device = dev_cache_get_by_devt(devt, cmd->filter);
-	if (!device && fallback)
-		device = dev_cache_get_by_devt(fallback, cmd->filter);
+	dev = dev_cache_get_by_devt(devt, cmd->filter);
+	if (!dev && fallback)
+		dev = dev_cache_get_by_devt(fallback, cmd->filter);
 
-	if (!device) {
+	if (!dev) {
 		log_error("No device found for PV %s.", pvid_txt);
 		return NULL;
 	}
@@ -269,7 +266,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(
 	if (!vgname)
 		vgname = fmt->orphan_vg_name;
 
-	if (!(info = lvmcache_add(fmt->labeller, (const char *)&pvid, device,
+	if (!(info = lvmcache_add(fmt->labeller, (const char *)&pvid, dev,
 				  vgname, (const char *)&vgid, 0)))
 		return_NULL;
 
@@ -680,7 +677,7 @@ static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
 	return 1;
 }
 
-int lvmetad_pv_found(const struct id *pvid, struct device *device, const struct format_type *fmt,
+int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct format_type *fmt,
 		     uint64_t label_sector, struct volume_group *vg, activation_handler handler)
 {
 	char uuid[64];
@@ -708,7 +705,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *device, const struct
 	}
 
 	if (!config_make_nodes(pvmeta, pvmeta->root, NULL,
-			       "device = %"PRId64, (int64_t) device->dev,
+			       "device = %"PRId64, (int64_t) dev->dev,
 			       "dev_size = %"PRId64, (int64_t) (info ? lvmcache_device_size(info) : 0),
 			       "format = %s", fmt->name,
 			       "label_sector = %"PRId64, (int64_t) label_sector,
@@ -768,7 +765,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *device, const struct
 	return result;
 }
 
-int lvmetad_pv_gone(dev_t device, const char *pv_name, activation_handler handler)
+int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler)
 {
 	daemon_reply reply;
 	int result;
@@ -784,7 +781,7 @@ int lvmetad_pv_gone(dev_t device, const char *pv_name, activation_handler handle
          *        the whole stack from top to bottom (not yet upstream).
          */
 
-	reply = _lvmetad_send("pv_gone", "device = %" PRId64, (int64_t) device, NULL);
+	reply = _lvmetad_send("pv_gone", "device = %" PRId64, (int64_t) devno, NULL);
 
 	result = _lvmetad_handle_reply(reply, "drop PV", pv_name, &found);
 	/* We don't care whether or not the daemon had the PV cached. */
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 7886965..e985387 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -97,7 +97,7 @@ int lvmetad_vg_remove(struct volume_group *vg);
  * number on the cached and on the discovered PV match but the metadata content
  * does not.
  */
-int lvmetad_pv_found(const struct id *pvid, struct device *device,
+int lvmetad_pv_found(const struct id *pvid, struct device *dev,
 		     const struct format_type *fmt, uint64_t label_sector,
 		     struct volume_group *vg, activation_handler handler);
 
@@ -154,7 +154,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 #    define lvmetad_release_token()	do { } while (0)
 #    define lvmetad_vg_update(vg)	(1)
 #    define lvmetad_vg_remove(vg)	(1)
-#    define lvmetad_pv_found(pvid, device, fmt, label_sector, vg, handler)	(1)
+#    define lvmetad_pv_found(pvid, dev, fmt, label_sector, vg, handler)	(1)
 #    define lvmetad_pv_gone(devno, pv_name, handler)	(1)
 #    define lvmetad_pv_gone_by_dev(dev, handler)	(1)
 #    define lvmetad_pv_list_to_lvmcache(cmd)	(1)


