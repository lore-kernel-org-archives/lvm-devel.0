From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 10 Mar 2015 19:00:42 +0000 (UTC)
Subject: master - reporting: should not fail with foreign option if lvm1 pvs exist
Message-ID: <20150310190042.3C052607AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=760cebf47dde020b42e44b35a0ad81204b6047e5
Commit:        760cebf47dde020b42e44b35a0ad81204b6047e5
Parent:        c7290759b059c65e2dbd56e498186b4b8acc8315
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 10 13:56:25 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 10 13:56:25 2015 -0500

reporting: should not fail with foreign option if lvm1 pvs exist

When lvm1 PVs are visible, and lvmetad is used, and the foreign
option was included in the reporting command, the reporting
command would fail after the 'pvscan all devs' function saw
the lvm1 PVs.  There is no reason the command should fail
because of the lvm1 PVs; they should just be ignored.
---
 lib/cache/lvmetad.c |   30 +++++++++++++++++++++++-------
 lib/cache/lvmetad.h |    4 ++--
 tools/lvscan.c      |    2 +-
 tools/pvscan.c      |    4 ++--
 4 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index aad4423..08c58d2 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -136,6 +136,9 @@ void lvmetad_set_socket(const char *sock)
 	_lvmetad_socket = sock;
 }
 
+static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler,
+				    int ignore_obsolete);
+
 static daemon_reply _lvmetad_send(const char *id, ...)
 {
 	va_list ap;
@@ -183,7 +186,7 @@ retry:
 				max_remaining_sleep_times--;	/* Sleep once before rescanning the first time, then 5 times each time after that. */
 		} else {
 			/* If the re-scan fails here, we try again later. */
-			(void) lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL);
+			(void) _lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL, 0);
 			num_rescans++;
 			max_remaining_sleep_times = 5;
 		}
@@ -904,7 +907,7 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 }
 
 int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
-			  activation_handler handler)
+			  activation_handler handler, int ignore_obsolete)
 {
 	struct label *label;
 	struct lvmcache_info *info;
@@ -933,9 +936,16 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 		goto_bad;
 
 	if (baton.fid->fmt->features & FMT_OBSOLETE) {
-		log_error("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
-			  baton.fid->fmt->name, dev_name(dev));
+		if (ignore_obsolete)
+			log_warn("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
+				  baton.fid->fmt->name, dev_name(dev));
+		else
+			log_error("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
+				  baton.fid->fmt->name, dev_name(dev));
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+
+		if (ignore_obsolete)
+			return 1;
 		return 0;
 	}
 
@@ -974,7 +984,8 @@ bad:
 	return 0;
 }
 
-int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
+static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler,
+				    int ignore_obsolete)
 {
 	struct dev_iter *iter;
 	struct device *dev;
@@ -1016,7 +1027,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 			stack;
 			break;
 		}
-		if (!lvmetad_pvscan_single(cmd, dev, handler))
+		if (!lvmetad_pvscan_single(cmd, dev, handler, ignore_obsolete))
 			r = 0;
 	}
 
@@ -1031,11 +1042,16 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 	return r;
 }
 
+int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
+{
+	return _lvmetad_pvscan_all_devs(cmd, handler, 0);
+}
+
 /* 
  * FIXME Implement this function, skipping PVs known to belong to local or clustered,
  * non-exported VGs.
  */
 int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler)
 {
-	return lvmetad_pvscan_all_devs(cmd, handler);
+	return _lvmetad_pvscan_all_devs(cmd, handler, 1);
 }
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 4d6f107..b5bac69 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -153,7 +153,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
  * Scan a single device and update lvmetad with the result(s).
  */
 int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
-			  activation_handler handler);
+			  activation_handler handler, int ignore_obsolete);
 
 int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler);
 int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler);
@@ -180,7 +180,7 @@ int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handl
 #    define lvmetad_pv_lookup_by_dev(cmd, dev, found)	(0)
 #    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
-#    define lvmetad_pvscan_single(cmd, dev, handler)	(0)
+#    define lvmetad_pvscan_single(cmd, dev, handler, ignore_obsolete)	(0)
 #    define lvmetad_pvscan_all_devs(cmd, handler)	(0)
 #    define lvmetad_pvscan_foreign_vgs(cmd, handler)	(0)
 
diff --git a/tools/lvscan.c b/tools/lvscan.c
index fa9d976..e98c73d 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -40,7 +40,7 @@ static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume
 					 pvid_s);
 			continue;
 		}
-		if (!lvmetad_pvscan_single(cmd, pvl->pv->dev, NULL))
+		if (!lvmetad_pvscan_single(cmd, pvl->pv->dev, NULL, 0))
 			return ECMD_FAILED;
 	}
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 5709172..307187d 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -277,7 +277,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 			stack;
 			break;
 		}
-		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
+		if (!lvmetad_pvscan_single(cmd, dev, handler, 0)) {
 			ret = ECMD_FAILED;
 			stack;
 			break;
@@ -310,7 +310,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 			stack;
 			break;
 		}
-		if (!lvmetad_pvscan_single(cmd, dev, handler)) {
+		if (!lvmetad_pvscan_single(cmd, dev, handler, 0)) {
 			ret = ECMD_FAILED;
 			stack;
 			break;


