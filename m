From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Jul 2016 15:39:59 +0000 (UTC)
Subject: master - lvconvert: enable work with partial LVs
Message-ID: <20160719153959.5C42360BBA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6dc4d035088c74693e3920961ec7814e4ecf0793
Commit:        6dc4d035088c74693e3920961ec7814e4ecf0793
Parent:        f8872578e9f40c9259d8a116aa48a794055290bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 19 17:11:57 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 19 17:39:41 2016 +0200

lvconvert: enable work with partial LVs

Fix printed message and enable handling of missing PVs.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ba1a58b..79c4317 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.162 - 
 =================================
+  Enabled lvconvert --uncache to work with partial VG.
 
 Version 2.02.161 - 15th July 2016
 =================================
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0368e84..2e84348 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2122,15 +2122,17 @@ static int _lvconvert_uncache(struct cmd_context *cmd,
 				return 0;
 			}
 			log_warn("WARNING: Uncaching of partially missing writethrough cache volume %s might destroy your data.",
-				 display_lvname(first_seg(seg->pool_lv)->metadata_lv));
+				 display_lvname(lv));
 		}
 
 		if (!lp->yes &&
-		    yes_no_prompt("Do you really want to uncache %s? with missing LVs [y/n]: ",
+		    yes_no_prompt("Do you really want to uncache %s with missing LVs? [y/n]: ",
 				  display_lvname(lv)) == 'n') {
 			log_error("Conversion aborted.");
 			return 0;
 		}
+		cmd->handles_missing_pvs = 1;
+		cmd->partial_activation = 1;
 	}
 
 	if (lvremove_single(cmd, remove_lv, NULL) != ECMD_PROCESSED)


