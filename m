From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:59 +0000 (UTC)
Subject: master - cleanup: init of lcp
Message-ID: <20141103132359.76F7460243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0f7d6e36a27a3fc38307ae726583cc2e4c2a105
Commit:        a0f7d6e36a27a3fc38307ae726583cc2e4c2a105
Parent:        d6c5445bea45de548bb16378030cd4f381bf4c04
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 10:25:05 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

cleanup: init of lcp

Use struct initializer instead of memset().
---
 tools/lvcreate.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 2cbfbe5..f6786a8 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -346,7 +346,7 @@ static int _update_extents_params(struct volume_group *vg,
 	    (vg->free_count < lp->extents - size_rest + (lp->stripes * stripesize_extents))) {
 		log_print_unless_silent("Rounding size (%d extents) down to stripe boundary "
 					"size (%d extents)", lp->extents,
-			  lp->extents - size_rest);
+					lp->extents - size_rest);
 		lp->extents = lp->extents - size_rest;
 	}
 
@@ -625,7 +625,6 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	int only_linear = 0;
 	int mirror_default_cfg;
 
-	memset(lcp, 0, sizeof(*lcp));
 	dm_list_init(&lp->tags);
 	lp->target_attr = ~0;
 	lp->yes = arg_count(cmd, yes_ARG);
@@ -1413,7 +1412,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		.major = -1,
 		.minor = -1,
 	};
-	struct lvcreate_cmdline_params lcp;
+	struct lvcreate_cmdline_params lcp = { 0 };
 	struct volume_group *vg;
 
 	if (!_lvcreate_params(cmd, argc, argv, &lp, &lcp)) {


