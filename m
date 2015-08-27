From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 27 Aug 2015 21:37:16 +0000 (UTC)
Subject: master - lvmlockd: VG lock can be used when changing lock type
Message-ID: <20150827213716.DA90F6026B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5d99cb9e685ba167f10413694e5d9d34fe90bb0
Commit:        e5d99cb9e685ba167f10413694e5d9d34fe90bb0
Parent:        3c1924c9c0d45cbce67aa3c1dad70737a6956cc3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 27 16:34:51 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 27 16:34:51 2015 -0500

lvmlockd: VG lock can be used when changing lock type

This bit was missed from commit de4db6a that added
changing lock_type.
---
 tools/vgchange.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index f57fa15..6d86051 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1048,15 +1048,6 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 		cmd->lockd_vg_disable = 1;
 
 	/*
-	 * In most cases, lockd_vg does not apply when changing lock type.
-	 * (We don't generally allow changing *from* lockd type yet.)
-	 * lockd_vg could be called within _vgchange_locktype as needed.
-	 */
-
-	if (arg_is_set(cmd, locktype_ARG))
-		cmd->lockd_vg_disable = 1;
-
-	/*
 	 * Changing system_id or lock_type must only be done on explicitly
 	 * named vgs.
 	 */


