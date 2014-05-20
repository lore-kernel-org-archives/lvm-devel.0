From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:53 +0000 (UTC)
Subject: master - cleanup: use print when displaying info
Message-ID: <20140520195353.44A2E60190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1d50d4023d7825fe9d9d3811375e44b90def529
Commit:        d1d50d4023d7825fe9d9d3811375e44b90def529
Parent:        54184f92acea10de5b75ad013f6c8aaf7db03176
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 12:56:49 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:29 2014 +0200

cleanup: use print when displaying info

Use error or warn only when we really have some problem in the code.
---
 tools/lvconvert.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 50771b4..3f1fd46 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1629,7 +1629,7 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	lv_check_transient(lv); /* TODO check this in lib for all commands? */
 
 	if (!(lv->status & PARTIAL_LV)) {
-		log_warn("%s is consistent. Nothing to repair.", lv->name);
+		log_print_unless_silent("%s is consistent. Nothing to repair.", lv->name);
 		return 1;
 	}
 
@@ -1640,15 +1640,15 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 		return_0;
 
 	if (failed_mimages)
-		log_error("Mirror status: %d of %d images failed.",
-			  failed_mimages, original_mimages);
+		log_print_unless_silent("Mirror status: %d of %d images failed.",
+					failed_mimages, original_mimages);
 
 	/*
 	 * Count the failed log devices
 	 */
 	if (failed_logs)
-		log_error("Mirror log status: %d of %d images failed.",
-			  failed_logs, original_logs);
+		log_print_unless_silent("Mirror log status: %d of %d images failed.",
+					failed_logs, original_logs);
 
 	/*
 	 * Find out our policies


