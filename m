From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:21 +0000 (UTC)
Subject: master - cleanup: reoder lines
Message-ID: <20160310174021.A834560DFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8507db192481b5539d9721c912ce5556049bf050
Commit:        8507db192481b5539d9721c912ce5556049bf050
Parent:        b36cf94318171d9cfe35cee38e4f323ad4c8a0a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 7 10:30:21 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:54 2016 +0100

cleanup: reoder lines

---
 tools/lvconvert.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index dc6cb48..f02a7f9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -395,19 +395,10 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		return 0;
 	}
 
-	if (arg_is_set(cmd, splitsnapshot_ARG)) {
-		if (arg_outside_list_is_set(cmd, "cannot be used with --splitsnapshot",
-					    splitsnapshot_ARG,
-					    force_ARG, noudevsync_ARG, test_ARG,
-					    -1))
-			return_0;
-		lp->splitsnapshot = 1;
-	}
-
 	if (arg_is_set(cmd, split_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --split",
 					    split_ARG,
-                                            name_ARG,
+					    name_ARG,
 					    force_ARG, noudevsync_ARG, test_ARG,
 					    -1))
 			return_0;
@@ -423,6 +414,15 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		lp->splitcache = 1;
 	}
 
+	if (arg_is_set(cmd, splitsnapshot_ARG)) {
+		if (arg_outside_list_is_set(cmd, "cannot be used with --splitsnapshot",
+					    splitsnapshot_ARG,
+					    force_ARG, noudevsync_ARG, test_ARG,
+					    -1))
+			return_0;
+		lp->splitsnapshot = 1;
+	}
+
 	if (arg_is_set(cmd, uncache_ARG)) {
 		if (arg_outside_list_is_set(cmd, "cannot be used with --uncache",
 					    uncache_ARG,


