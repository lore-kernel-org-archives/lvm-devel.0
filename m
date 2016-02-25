From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 20:25:19 +0000 (UTC)
Subject: master - Use a common message for a used PV
Message-ID: <20160225202519.7415761086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=172bad0d5679f6152281cdd3a69e2cf0a3288c1e
Commit:        172bad0d5679f6152281cdd3a69e2cf0a3288c1e
Parent:        66e175702af4cfb1ecad9316a8151c001933c190
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 25 14:12:08 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 14:23:41 2016 -0600

Use a common message for a used PV

Change some inconsistent messages and adopt
the new wording "PV %s is used by" in place
of "PV %s is marked as belonging to"
or "PV %s belongs to".
---
 lib/metadata/metadata.c      |    5 ++---
 lib/metadata/pv_manip.c      |    6 ++----
 test/shell/pv-ext-flags.sh   |    2 +-
 test/shell/pvremove-usage.sh |    6 +++---
 tools/pvchange.c             |    2 +-
 tools/toollib.c              |   12 ++++++------
 6 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index acdfdec..6ec0a0e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -201,8 +201,7 @@ static int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 			return_0;
 
 		if (used) {
-			log_error("Physical volume '%s' is marked as belonging to a VG "
-				  "but its metadata is missing.", pv_name);
+			log_error("PV %s is used by a VG but its metadata is missing.", pv_name);
 			return 0;
 		}
 	}
@@ -1585,7 +1584,7 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 			goto_out;
 
 		if (used && pp->force != DONT_PROMPT_OVERRIDE) {
-			log_error("PV '%s' is marked as belonging to a VG but its metadata is missing.", name);
+			log_error("PV %s is used by a VG but its metadata is missing.", name);
 			log_error("Can't initialize PV '%s' without -ff.", name);
 			goto out;
 		}
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index f54111c..48706d1 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -733,8 +733,7 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 			goto_out;
 
 		if (used) {
-			log_warn("WARNING: PV '%s' is marked as belonging to a VG "
-				 "but its metadata is missing.", name);
+			log_warn("WARNING: PV %s is used by a VG but its metadata is missing.", name);
 
 			if (force_count < 2)
 				goto_bad;
@@ -745,8 +744,7 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 				goto_bad;
 		}
 	} else {
-		log_warn("WARNING: PV %s belongs to Volume Group %s "
-			 "(consider using vgreduce).", name, pv_vg_name(pv));
+		log_warn("WARNING: PV %s is used by VG %s (consider using vgreduce).", name, pv_vg_name(pv));
 
 		if (force_count < 2)
 			goto_bad;
diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
index cf2a8a1..d465497 100644
--- a/test/shell/pv-ext-flags.sh
+++ b/test/shell/pv-ext-flags.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_devs 2
 
 # PV_EXT_USED flag
-MARKED_AS_USED_MSG="marked as belonging to a VG but its metadata is missing"
+MARKED_AS_USED_MSG="is used by a VG but its metadata is missing"
 
 ######################################
 ### CHECK PV WITH 0 METADATA AREAS ###
diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index 4fd26d1..e0f51bf 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -56,16 +56,16 @@ for mdacp in 0 1 2; do
 
     # pvremove -f fails when pv in a vg (---metadatacopies $mdacp)
     not pvremove -f "$dev1" 2>&1 | tee out
-    grep "belongs" out
+    grep "is used" out
     pvs "$dev1"
 
     # pvremove -ff fails without confirmation when pv in a vg (---metadatacopies $mdacp)
     not pvremove -ff "$dev1" 2>&1 | tee out
-    grep "belongs" out
+    grep "is used" out
 
     # pvremove -ff succeds with confirmation when pv in a vg (---metadatacopies $mdacp)
     pvremove -ffy "$dev1" 2>&1 | tee out
-    grep "belongs" out
+    grep "is used" out
     not pvs "$dev1"
 
     vgreduce --removemissing $vg
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 3c12c14..86c4ac4 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -60,7 +60,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 			goto_bad;
 
 		if (used && (arg_count(cmd, force_ARG) != DONT_PROMPT_OVERRIDE)) {
-			log_error("PV '%s' is marked as belonging to a VG but its metadata is missing.", pv_name);
+			log_error("PV %s is used by a VG but its metadata is missing.", pv_name);
 			log_error("Can't change PV '%s' without -ff.", pv_name);
 			goto bad;
 		}
diff --git a/tools/toollib.c b/tools/toollib.c
index 3e48139..8029030 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2962,7 +2962,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		pv_name = pv_dev_name(pv);
 
 		if (cmd->system_id && is_orphan(pv) && is_used_pv(pv)) {
-			log_verbose("PV %s is marked as belonging to a VG but its metadata is missing.", pv_name);
+			log_verbose("PV %s is used by a VG but its metadata is missing.", pv_name);
 			log_verbose("Skipping PV %s because it's not possible to decide whether it matches system id.", pv_name);
 			continue;
 		}
@@ -3601,7 +3601,7 @@ static void _check_pvcreate_prompt(struct cmd_context *cmd,
 			prompt->answer = PROMPT_ANSWER_NO;
 
 			if (prompt->vg_name_unknown) {
-				log_error("PV '%s' is marked as belonging to a VG but its metadata is missing.", pvname);
+				log_error("PV %s is used by a VG but its metadata is missing.", pvname);
 				log_error("Can't initialize PV '%s' without -ff.", pvname);
 			} else if (!strcmp(command_name(cmd), "pvcreate")) {
 				log_error("Can't initialize physical volume \"%s\" of volume group \"%s\" without -ff", pvname, vgname);
@@ -3626,15 +3626,15 @@ static void _check_pvcreate_prompt(struct cmd_context *cmd,
 			prompt->answer = PROMPT_ANSWER_NO;
 
 			if (prompt->vg_name_unknown)
-				log_error("PV %s belongs to a VG but its metadata is missing.", pvname);
+				log_error("PV %s is used by a VG but its metadata is missing.", pvname);
 			else
-				log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", pvname, vgname);
+				log_error("PV %s is used by VG %s so please use vgreduce first.", pvname, vgname);
 			log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
 		} else if (pp->yes) {
-			log_warn("WARNING: PV %s belongs to Volume Group %s", pvname, vgname);
+			log_warn("WARNING: PV %s is used by VG %s", pvname, vgname);
 			prompt->answer = PROMPT_ANSWER_YES;
 		} else if (ask) {
-			log_warn("WARNING: PV %s belongs to Volume Group %s", pvname, vgname);
+			log_warn("WARNING: PV %s is used by VG %s", pvname, vgname);
 			if (yes_no_prompt("Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ", pvname, vgname) == 'n') {
 				prompt->answer = PROMPT_ANSWER_NO;
 				log_error("%s: physical volume label not removed", pvname);


