From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:22 +0000 (UTC)
Subject: master - dumpconfig: check conf tree was created
Message-ID: <20130722104222.829D060DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c394c2a624b24193ca769bff956ca2bd8d1e5c1b
Commit:        c394c2a624b24193ca769bff956ca2bd8d1e5c1b
Parent:        baada4316dd2fcf0383ed7bcfa539c0429e17131
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 19 17:32:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:21 2013 +0200

dumpconfig: check conf tree was created

Missing error path.
---
 tools/dumpconfig.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index da216f5..0887297 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -196,8 +196,11 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	if (cft_check_handle)
 		tree_spec.check_status = cft_check_handle->status;
 
-	if (tree_spec.type != CFG_DEF_TREE_CURRENT)
-		cft = config_def_create_tree(&tree_spec);
+	if ((tree_spec.type != CFG_DEF_TREE_CURRENT) &&
+	    !(cft = config_def_create_tree(&tree_spec))) {
+		r = ECMD_FAILED;
+		goto_out;
+	}
 
 	if (!config_write(cft, arg_count(cmd, withcomments_ARG),
 			  arg_count(cmd, withversions_ARG),


