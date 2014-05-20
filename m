From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:51 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20140520195351.2F89960190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54184f92acea10de5b75ad013f6c8aaf7db03176
Commit:        54184f92acea10de5b75ad013f6c8aaf7db03176
Parent:        2941cffd2c6bf67ea2b47696e0ad111f07cf921d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 20:10:55 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:28 2014 +0200

cleanup: indent

---
 tools/lvconvert.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 03cd42d..50771b4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1077,15 +1077,13 @@ static void _lvconvert_mirrors_repair_ask(struct cmd_context *cmd,
 		return;
 
 	if (failed_log &&
-	    yes_no_prompt("Attempt to replace failed mirror log? [y/n]: ") == 'n') {
+	    yes_no_prompt("Attempt to replace failed mirror log? [y/n]: ") == 'n')
 		*replace_log = 0;
-	}
 
 	if (failed_mirrors &&
 	    yes_no_prompt("Attempt to replace failed mirror images "
-			  "(requires full device resync)? [y/n]: ") == 'n') {
+			  "(requires full device resync)? [y/n]: ") == 'n')
 		*replace_mirrors = 0;
-	}
 }
 
 /*
@@ -1677,14 +1675,12 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 		if (_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
 					   lp->mirrors, log_count))
 			break;
-		else {
-			if (lp->mirrors > 2)
-				-- lp->mirrors;
-			else if (log_count > 0)
-				-- log_count;
-			else
-				break; /* nowhere to go, anymore... */
-		}
+		if (lp->mirrors > 2)
+			--lp->mirrors;
+		else if (log_count > 0)
+			--log_count;
+		else
+			break; /* nowhere to go, anymore... */
 	}
 
 	if (replace_mimages && lv_mirror_count(lv) != original_mimages)


