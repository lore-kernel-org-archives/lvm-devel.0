From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Jun 2020 13:02:46 +0000 (GMT)
Subject: master - cov: avoid double call of free_hints() on error path
Message-ID: <20200624130246.14B8E3939C28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cca2a652d1ac2fa67677e3dca50141efa8e2c1a9
Commit:        cca2a652d1ac2fa67677e3dca50141efa8e2c1a9
Parent:        eb06832b37d6d1e3d1c5fba69c5829d76d5d27a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 22 11:07:34 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:01:03 2020 +0200

cov: avoid double call of free_hints() on error path

Since we 'free_hints()' on return error path from call of
_read_hint_file(), avoid calling it twice in the middle of
error path process.
---
 lib/label/hints.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 9546f4880..efa02f7c5 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -801,10 +801,8 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	if (fclose(fp))
 		stack;
 
-	if (!ret) {
-		free_hints(hints);
+	if (!ret)
 		return 0;
-	}
 
 	if (!found)
 		return 1;


