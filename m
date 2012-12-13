From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 13 Dec 2012 10:20:02 +0000 (UTC)
Subject: master - lvconvert: also allow --type with --stripes
Message-ID: <20121213102002.BB88423D4@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8025aa67a05af046878f52dfb45fca30ed70084
Commit:        e8025aa67a05af046878f52dfb45fca30ed70084
Parent:        c089029b70d64e4f7d2851336d463ce40f1b7023
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 13 11:15:37 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 13 11:19:11 2012 +0100

lvconvert: also allow --type with --stripes

We can also use this for conversion between different mirror segment
types. Each new segment type converter then needs to check itself
whether the --stripes is applicable.
---
 tools/lvconvert.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9c947d7..fa3b1ec 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -169,9 +169,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 
 	if ((arg_count(cmd, stripes_long_ARG) || arg_count(cmd, stripesize_ARG)) &&
 	    !(arg_count(cmd, mirrors_ARG) || arg_count(cmd, repair_ARG) ||
-	      arg_count(cmd, thinpool_ARG))) {
+	      arg_count(cmd, thinpool_ARG) || arg_count(cmd, type_ARG))) {
 		log_error("--stripes or --stripesize argument is only valid "
-			  "with --mirrors, --repair or --thinpool");
+			  "with --mirrors, --repair, --thinpool or --type");
 		return 0;
 	}
 


