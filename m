From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:03:08 -0400
Subject: master - pvscan: code reshape
Message-ID: <201806142003.w5EK38Gm003677@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=752c39d91db55ae637fef3b8066e1a78f894609d
Commit:        752c39d91db55ae637fef3b8066e1a78f894609d
Parent:        33703995ae264c7abdc6d566283d94d8587a85f1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 21:07:15 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

pvscan: code reshape

---
 tools/pvscan.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 61626e6..508f283 100644
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


