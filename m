From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:40 +0000 (UTC)
Subject: master - cleanup: postpone confirmation prompt for snapshot
Message-ID: <20140815130740.063D761229@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6872adc0ff7e6c72cc94fd15ed5dd910b958386e
Commit:        6872adc0ff7e6c72cc94fd15ed5dd910b958386e
Parent:        ba7796e0550dcc8fcc114bc8eadc6815c34c3f4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 15 13:31:53 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:44 2014 +0200

cleanup: postpone confirmation prompt for snapshot

Prompt user for confimation after more checks are done.
(So we avoid case prompting and failing after prompt)
---
 tools/lvchange.c |   39 +++++++++++++++++++--------------------
 1 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 992efde..f3bef8b 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -964,26 +964,6 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin = origin_from_cow(lv)) &&
-	    arg_count(cmd, activate_ARG)) {
-		if (origin->origin_count < 2)
-			snaps_msg[0] = '\0';
-		else if (dm_snprintf(snaps_msg, sizeof(snaps_msg),
-				     " and %u other snapshot(s)",
-				     origin->origin_count - 1) < 0) {
-			log_error("Failed to prepare message.");
-			return ECMD_FAILED;
-		}
-
-		if (!arg_count(cmd, yes_ARG) &&
-		    (yes_no_prompt("Change of snapshot %s will also change its"
-				   " origin %s%s. Proceed? [y/n]: ", lv->name,
-				   origin->name, snaps_msg) == 'n')) {
-			log_error("Logical volume %s not changed.", lv->name);
-			return ECMD_FAILED;
-		}
-	}
-
 	if (lv->status & PVMOVE) {
 		log_error("Unable to change pvmove LV %s", lv->name);
 		if (arg_count(cmd, activate_ARG))
@@ -1019,6 +999,25 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_FAILED;
 	}
 
+	if (lv_is_cow(lv) && arg_count(cmd, activate_ARG)) {
+		if (origin->origin_count < 2)
+			snaps_msg[0] = '\0';
+		else if (dm_snprintf(snaps_msg, sizeof(snaps_msg),
+				     " and %u other snapshot(s)",
+				     origin->origin_count - 1) < 0) {
+			log_error("Failed to prepare message.");
+			return ECMD_FAILED;
+		}
+
+		if (!arg_count(cmd, yes_ARG) &&
+		    (yes_no_prompt("Change of snapshot %s will also change its "
+				   "origin %s%s. Proceed? [y/n]: ", lv->name,
+				   origin->name, snaps_msg) == 'n')) {
+			log_error("Logical volume %s not changed.", lv->name);
+			return ECMD_FAILED;
+		}
+	}
+
 	/*
 	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
 	 * If --poll is explicitly provided use it; otherwise polling


