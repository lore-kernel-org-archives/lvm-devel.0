From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Mar 2013 14:16:18 +0000 (UTC)
Subject: master - thin: cannot use snapshot merge with thinpool
Message-ID: <20130313141618.4056AA0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9cf00666b320c67cf717cbba0ab0758ca4adebd3
Commit:        9cf00666b320c67cf717cbba0ab0758ca4adebd3
Parent:        0191d99906a0ae017b827752232bb7461ccf8f09
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 11 10:44:05 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 13 15:13:54 2013 +0100

thin: cannot use snapshot merge with thinpool

---
 tools/lvconvert.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6a64c2b..9db1093 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -191,9 +191,10 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	if ((arg_count(cmd, snapshot_ARG) || arg_count(cmd, merge_ARG)) &&
 	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG) ||
-	     arg_count(cmd, repair_ARG))) {
+	     arg_count(cmd, repair_ARG) || arg_count(cmd, thinpool_ARG))) {
 		log_error("--snapshot or --merge argument cannot be mixed "
-			  "with --mirrors, --repair or --mirrorlog");
+			  "with --mirrors, --mirrorlog, --repair "
+			  "or --thinpool.");
 		return 0;
 	}
 


