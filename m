From: Milan Broz <mbroz@redhat.com>
Date: Mon, 06 Apr 2009 13:26:44 +0200
Subject: [PATCH] Enable use of cached metadata for pvs & pvdisplay
Message-ID: <49D9E6F4.90205@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Enable use of cached metadata for pvs & pvdisplay.

Currently PV commands, which performs full device scan, repeatly
re-reads PVs and scans for all devices.

Without vg private mempool this behaviour leads to OOM for large VG.

This patch allows using internal metadata cache for pvs & pvdisplay,
so the commands scan the PVs only once.
(We have to use VG_GLOBAL otherwise cache is invalidated on every
VG unlock in process_single PV call.)

(this is kind of temporary solution...)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/commands.h  |    4 ++--
 tools/pvdisplay.c |   13 ++++++++++++-
 tools/reporter.c  |    2 +-
 tools/toollib.c   |   33 ++++++++++++++++++++++++---------
 4 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index da202c0..cd83d5e 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -497,7 +497,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   0,
+   CACHE_VGMETADATA,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[-d|--debug]\n"
@@ -571,7 +571,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   0,
+   CACHE_VGMETADATA,
    "pvs" "\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 406e631..086a2da 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -91,6 +91,8 @@ out:
 
 int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 {
+	int r;
+
 	if (arg_count(cmd, columns_ARG)) {
 		if (arg_count(cmd, colon_ARG) || arg_count(cmd, maps_ARG) ||
 		    arg_count(cmd, short_ARG)) {
@@ -113,6 +115,15 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ, 0, NULL,
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
+		log_error("Unable to obtain global lock.");
+		return ECMD_FAILED;
+	}
+
+	r = process_each_pv(cmd, argc, argv, NULL, LCK_VG_READ, 0, NULL,
 			       _pvdisplay_single);
+
+	unlock_vg(cmd, VG_GLOBAL);
+
+	return r;
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index 9d03f58..aa15af6 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -435,5 +435,5 @@ int pvs(struct cmd_context *cmd, int argc, char **argv)
 	else
 		type = LABEL;
 
-	return _report(cmd, argc, argv, type);
+	return  _report(cmd, argc, argv, type);
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index 72d08ca..fef0761 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -611,15 +611,16 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
-	if (!scan_vgs_for_pvs(cmd)) {
-		stack;
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
+		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
 	}
 
-	if (!(iter = dev_iter_create(cmd->filter, 1))) {
-		log_error("dev_iter creation failed");
-		return ECMD_FAILED;
-	}
+	if (!scan_vgs_for_pvs(cmd))
+		goto_bad;
+
+	if (!(iter = dev_iter_create(cmd->filter, 1)))
+		goto_bad;
 
 	while ((dev = dev_iter_get(iter))) {
 		if (!(pv = pv_read(cmd, dev_name(dev), NULL, NULL, 0, 0))) {
@@ -638,8 +639,12 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 	}
 
 	dev_iter_destroy(iter);
-
+	
+	unlock_vg(cmd, VG_GLOBAL);
 	return ret_max;
+bad:
+	unlock_vg(cmd, VG_GLOBAL);
+	return ECMD_FAILED;
 }
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
@@ -791,17 +796,27 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				return ret_max;
 		} else {
 			log_verbose("Scanning for physical volume names");
-			if (!(pvslist = get_pvs(cmd)))
+			if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ)) {
+				log_error("Unable to obtain global lock.");
 				return ECMD_FAILED;
+			}
+
+			if (!(pvslist = get_pvs(cmd))) {
+				unlock_vg(cmd, VG_GLOBAL);
+				return ECMD_FAILED;
+			}
 
 			dm_list_iterate_items(pvl, pvslist) {
 				ret = process_single(cmd, NULL, pvl->pv,
 						     handle);
 				if (ret > ret_max)
 					ret_max = ret;
-				if (sigint_caught())
+				if (sigint_caught()) {
+					unlock_vg(cmd, VG_GLOBAL);
 					return ret_max;
+				}
 			}
+			unlock_vg(cmd, VG_GLOBAL);
 		}
 	}
 



