From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Dec 2013 10:19:31 +0000 (UTC)
Subject: master - cleanup: gcc can't see the code path
Message-ID: <20131205101932.00BD86106B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74878bc2bcd66d60a0b53f409a30271496acd348
Commit:        74878bc2bcd66d60a0b53f409a30271496acd348
Parent:        ac6cd9baa7dac621cae58d545080599dcc281413
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 5 09:41:03 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 5 09:42:50 2013 +0100

cleanup: gcc can't see the code path

This is a bit to hard for gcc to see the condition can't
be triggered, so make it easier and initialize to 0.
---
 tools/lvconvert.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 11ee21a..87eb643 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1803,8 +1803,7 @@ static void _lvconvert_raid_repair_ask(struct cmd_context *cmd, int *replace_dev
 
 static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
-	int replace = 0;
-	int uninitialized_var(image_count);
+	int replace = 0, image_count = 0;
 	struct dm_list *failed_pvs;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);


