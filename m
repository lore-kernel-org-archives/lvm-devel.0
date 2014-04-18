From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 18 Apr 2014 01:48:01 +0000 (UTC)
Subject: master - pvscan: Use lvmetad_used().
Message-ID: <20140418014801.A2BF260EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8a3ba18659404b4ebded504a37623eeae8cc830
Commit:        e8a3ba18659404b4ebded504a37623eeae8cc830
Parent:        702180b30c83183722d36500d05da20966759ecf
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 18 02:13:46 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 18 02:13:46 2014 +0100

pvscan: Use lvmetad_used().

Config variables that are processed during setup prior to calling into
particular tools must not be accessed directly afterwards in case the
values already got overridden.

_process_config() already used the tests I'm removing here to call
lvmetad_set_active() and set up lvmetad_used().
---
 WHATS_NEW      |    1 +
 tools/pvscan.c |    5 ++---
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3efba96..53db07b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Use lvmetad_used() in pvscan instead of config_tree.
   Configure --enable-udev-systemd-background-jobs if not disabled explicitly.
   Add lvmdump -s to collect system info and context (currently systemd only).
   Refactor allocation code to make A_POSITIONAL_FILL explicit.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index dff2bb0..4121c7b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -201,9 +201,8 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	 * and to prevent hangs in clustered environment.
 	 */
 	/* TODO: Remove this once lvmetad + cluster supported! */
-	if (find_config_tree_int(cmd, global_locking_type_CFG, NULL) == 3 ||
-	    !find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
-		log_debug_lvmetad("_pvscan_lvmetad: immediate return");
+	if (!lvmetad_used()) {
+		log_verbose("Ignoring pvscan --cache command because lvmetad is not in use.");
 		return ret;
 	}
 


