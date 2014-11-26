From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Nov 2014 10:51:55 +0000 (UTC)
Subject: master - coverity: fix possible NULL dereference
Message-ID: <20141126105155.B774760E2F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=193f9b26a0a87b2f5ce9a308ea0d957fadfe4aeb
Commit:        193f9b26a0a87b2f5ce9a308ea0d957fadfe4aeb
Parent:        86ae68a5f7e396a6584b8003667b44a433d914fd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 26 11:46:13 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 26 11:46:13 2014 +0100

coverity: fix possible NULL dereference

The call to dm_config_destroy can derefence result->mem
while result is still NULL:

struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
{
	...
	int ok = 0;
	...
	if (!(result = dm_config_flatten(current)))
		goto_out;
	...
	ok = 1;
out:
	 if (!ok) {
		dm_config_destroy(result)
		...
	}
	...
}
---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index ddf2dcf..71eb9a8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1175,7 +1175,7 @@ struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
 	ok = 1;
 
 out:
-	if (!ok) {
+	if (!ok && result) {
 		dm_config_destroy(result);
 		result = NULL;
 	}


