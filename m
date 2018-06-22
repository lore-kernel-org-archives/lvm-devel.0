From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 09:07:59 -0400
Subject: 2018-06-01-stable - pvscan: code reshape
Message-ID: <201806221307.w5MD7xql019652@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=716199334c09b4acf9f536ee6d4ca5e1d52f37db
Commit:        716199334c09b4acf9f536ee6d4ca5e1d52f37db
Parent:        4479228d324fff4863a068ae02c775fd52fb58fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 21:07:15 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 12:31:32 2018 +0200

pvscan: code reshape

---
 tools/pvscan.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 8493eaa..2915db5 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -318,21 +318,22 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	dm_list_init(&found_vgnames);
 	dm_list_init(&pp.changed_vgnames);
 
-	do_activate = arg_is_set(cmd, activate_ARG);
-
-	if (!lvmetad_used() && !do_activate) {
-		log_verbose("Ignoring pvscan --cache because lvmetad is not in use.");
-		return ret;
-	}
-
-	if (do_activate && (arg_uint_value(cmd, activate_ARG, CHANGE_AAY) != CHANGE_AAY)) {
-		log_error("Only --activate ay allowed with pvscan.");
-		return 0;
-	}
+	if ((do_activate = arg_is_set(cmd, activate_ARG))) {
+		if (arg_uint_value(cmd, activate_ARG, 0) != CHANGE_AAY) {
+			log_error("Only --activate ay allowed with pvscan.");
+			return EINVALID_CMD_LINE;
+		}
 
-	if (!lvmetad_used() && do_activate && !find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-		log_verbose("Ignoring pvscan --cache -aay because lvmetad is not in use.");
-		return ret;
+		if (!lvmetad_used() &&
+		    !find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
+			log_verbose("Ignoring pvscan --cache -aay because lvmetad is not in use.");
+			return ret;
+		}
+	} else {
+		if (!lvmetad_used()) {
+			log_verbose("Ignoring pvscan --cache because lvmetad is not in use.");
+			return ret;
+		}
 	}
 
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))


