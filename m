From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Mar 2018 07:09:50 -0400
Subject: master - cleanup: typo fix
Message-ID: <201803191109.w2JB9o1G016323@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e0c0417ce1af29ae5253bca7f1277e13e3c3ee6
Commit:        4e0c0417ce1af29ae5253bca7f1277e13e3c3ee6
Parent:        8d7ece126b96337326d026ab4edebe2db4333459
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 19 12:05:36 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 19 12:05:57 2018 +0100

cleanup: typo fix

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 32c737c..a7947d8 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2109,7 +2109,7 @@ static int _pool_callback(struct dm_tree_node *node,
 	if (!(ret = exec_cmd(pool_lv->vg->cmd, (const char * const *)argv,
 			     &status, 0))) {
 		if (status == ENOENT) {
-			log_warn("WARNING: Check is skipped, please install recomended missing binary %s!",
+			log_warn("WARNING: Check is skipped, please install recommended missing binary %s!",
 				 argv[0]);
 			return 1;
 		}


