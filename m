From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:49:51 +0000 (UTC)
Subject: master - lvscan: Implement a --cache mode.
Message-ID: <20140722204951.6924B6110F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9ea014e5152b806f57f6099311b64a2c03ca482
Commit:        a9ea014e5152b806f57f6099311b64a2c03ca482
Parent:        653fd7bee3d9f765fdf81743331f2d9e91ea28bf
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 21 03:55:46 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jul 22 22:48:21 2014 +0200

lvscan: Implement a --cache mode.

---
 tools/commands.h |    3 ++-
 tools/lvscan.c   |   27 ++++++++++++++++++++++++++-
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 1f9d03c..6e115d9 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -581,6 +581,7 @@ xx(lvscan,
    "lvscan " "\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice] " "\n"
+   "\t[--cache]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|-?|--help] " "\n"
@@ -591,7 +592,7 @@ xx(lvscan,
    "\t[--version]\n",
 
    all_ARG, blockdevice_ARG, ignorelockingfailure_ARG, partial_ARG,
-   readonly_ARG)
+   readonly_ARG, cache_ARG)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 2641054..df8a12e 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -15,6 +15,28 @@
 
 #include "tools.h"
 
+static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	struct pv_list *pvl;
+	struct dm_list pvs;
+
+	if (!lvmetad_used()) {
+		log_verbose("Ignoring lvscan --cache because lvmetad is not in use.");
+		return ECMD_PROCESSED;
+	}
+
+	dm_list_init(&pvs);
+
+	if (!get_pv_list_for_lv(lv->vg->vgmem, lv, &pvs))
+		return ECMD_FAILED;
+
+	dm_list_iterate_items(pvl, &pvs)
+		if (!lvmetad_pvscan_single(cmd, pvl->pv->dev, NULL))
+			return ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
 static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 			 void *handle __attribute__((unused)))
 {
@@ -24,6 +46,9 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	const char *active_str, *snapshot_str;
 
+	if (arg_count(cmd, cache_ARG))
+		return _lvscan_single_lvmetad(cmd, lv);
+
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
@@ -58,7 +83,7 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 int lvscan(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (argc) {
+	if (argc && !arg_count(cmd, cache_ARG)) {
 		log_error("No additional command line arguments allowed");
 		return EINVALID_CMD_LINE;
 	}


