From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 Nov 2012 14:58:47 +0000 (UTC)
Subject: master - pvscan: exit --cache immediately if locking_type=3 || use_lvmetad=0
Message-ID: <20121109145847.CFC47A0E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc2644ae71a87ea81979f66022b98ec49c692a66
Commit:        fc2644ae71a87ea81979f66022b98ec49c692a66
Parent:        7c7672b3c0916b3cee8aec90f90275a1320acc70
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Nov 9 15:56:57 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Nov 9 15:56:57 2012 +0100

pvscan: exit --cache immediately if locking_type=3 || use_lvmetad=0

---
 WHATS_NEW      |    1 +
 tools/pvscan.c |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a3f8142..fd38a34 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Exit pvscan --cache immediately if cluster locking used or lvmetad not used.
   Don't use lvmetad in lvm2-monitor.service ExecStop to avoid a systemd issue.
   Remove dependency on fedora-storage-init.service in lvm2 systemd units.
   Depend on lvm2-lvmetad.socket in lvm2-monitor.service systemd unit.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 3d5ddef..34ab792 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -119,6 +119,21 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	char *buf;
 	activation_handler handler = NULL;
 
+	/*
+	 * Return here immediately if lvmetad is not used.
+	 * Also return if locking_type=3 (clustered) as we
+	 * dont't support cluster + lvmetad yet.
+	 *
+	 * This is to avoid taking the global lock uselessly
+	 * and to prevent hangs in clustered environment.
+	 */
+	/* TODO: Remove this once lvmetad + cluster supported! */
+	if (find_config_tree_int(cmd, "global/locking_type", 1) == 3 ||
+	    !find_config_tree_int(cmd, "global/use_lvmetad", 0)) {
+		log_debug("_pvscan_lvmetad: immediate return");
+		return ret;
+	}
+
 	if (arg_count(cmd, activate_ARG)) {
 		if (arg_uint_value(cmd, activate_ARG, CHANGE_AAY) != CHANGE_AAY) {
 			log_error("Only --activate ay allowed with pvscan.");


