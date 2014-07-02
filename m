From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:48:35 +0000 (UTC)
Subject: master - raid: don't skip prompt with force
Message-ID: <20140702084835.C1BA361054@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b872ce870b753d034da919814c13703606af188
Commit:        0b872ce870b753d034da919814c13703606af188
Parent:        c460f35cdadc853fc5bb7b796dbc0ead6968b82c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 1 09:55:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:36:32 2014 +0200

raid: don't skip prompt with force

Yes is meant to be used to skip all new prompts.
(--force just adds more prompts).
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   22 +++++++---------------
 2 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2259976..846983f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Require --yes to skip raid repair prompt.
   Change makefile %.d generation to handle filename changes without make clean.
   Fix use of buildir in make pofile.
   Enhance private volumes UUIDs with suffixed for easier detection.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3e00e17..d80fa60 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1797,12 +1797,11 @@ static int _is_valid_raid_conversion(const struct segment_type *from_segtype,
 	return 1;
 }
 
-static void _lvconvert_raid_repair_ask(struct cmd_context *cmd, int *replace_dev)
+static void _lvconvert_raid_repair_ask(struct cmd_context *cmd,
+				       struct lvconvert_params *lp,
+				       int *replace_dev)
 {
-	const char *dev_policy = NULL;
-
-	int force = arg_count(cmd, force_ARG);
-	int yes = arg_count(cmd, yes_ARG);
+	const char *dev_policy;
 
 	*replace_dev = 1;
 
@@ -1818,15 +1817,8 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd, int *replace_dev
 		return;
 	}
 
-	if (force != PROMPT) {
-		*replace_dev = 0;
-		return;
-	}
-
-	if (yes)
-		return;
-
-	if (yes_no_prompt("Attempt to replace failed RAID images "
+	if (!lp->yes &&
+	    yes_no_prompt("Attempt to replace failed RAID images "
 			  "(requires full device resync)? [y/n]: ") == 'n') {
 		*replace_dev = 0;
 	}
@@ -1926,7 +1918,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 			init_mirror_in_sync(1);
 		}
 
-		_lvconvert_raid_repair_ask(cmd, &replace);
+		_lvconvert_raid_repair_ask(cmd, lp, &replace);
 
 		if (replace) {
 			if (!(failed_pvs = _failed_pv_list(lv->vg)))


