From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Dec 2012 08:54:38 +0000 (UTC)
Subject: master - lvconvert: do not ignore -f in lvconvert --repair -y -f
Message-ID: <20121211085439.0DBADA0D86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f942ae4a7af0f9b93c6a6aacb1793ee22f87ed13
Commit:        f942ae4a7af0f9b93c6a6aacb1793ee22f87ed13
Parent:        1ec6a59dcf2c1c2788d12bd4374c6dbb5cfb8e36
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 11 09:52:54 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 11 09:52:54 2012 +0100

lvconvert: do not ignore -f in lvconvert --repair -y -f

---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   24 +++++++++++++-----------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b5b774f..2fa5e56 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Do not ignore -f in lvconvert --repair -y -f for mirror and raid volumes.
   Disallow pvmove on RAID LVs until they are addressed properly
   Allow empty activation/{auto_activation|read_only|}_volume_list config option.
   Add lvm.conf option global/thin_disabled_features.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d0429d8..2d51069 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -806,14 +806,14 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 		return;
 	}
 
-	if (yes)
-		return;
-
 	if (force != PROMPT) {
 		*replace_log = *replace_mirrors = 0;
 		return;
 	}
 
+	if (yes)
+		return;
+
 	if (failed_log &&
 	    yes_no_prompt("Attempt to replace failed mirror log? [y/n]: ") == 'n') {
 		*replace_log = 0;
@@ -1523,29 +1523,31 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd, int *replace_dev
 	int force = arg_count(cmd, force_ARG);
 	int yes = arg_count(cmd, yes_ARG);
 
-	*replace_dev = 0;
+	*replace_dev = 1;
 
 	if (arg_count(cmd, use_policies_ARG)) {
 		dev_policy = find_config_tree_str(cmd, "activation/raid_fault_policy", DEFAULT_RAID_FAULT_POLICY);
 
 		if (!strcmp(dev_policy, "allocate") ||
 		    !strcmp(dev_policy, "replace"))
-			*replace_dev = 1;
-		/* else if (!strcmp(dev_policy, "anything_else")) -- ignore */
+			return;
+
+		/* else if (!strcmp(dev_policy, "anything_else")) -- no replace */
+		*replace_dev = 0;
 		return;
 	}
 
-	if (yes) {
-		*replace_dev = 1;
+	if (force != PROMPT) {
+		*replace_dev = 0;
 		return;
 	}
 
-	if (force != PROMPT)
+	if (yes)
 		return;
 
 	if (yes_no_prompt("Attempt to replace failed RAID images "
-			  "(requires full device resync)? [y/n]: ") == 'y') {
-		*replace_dev = 1;
+			  "(requires full device resync)? [y/n]: ") == 'n') {
+		*replace_dev = 0;
 	}
 }
 


