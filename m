From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:31:01 +0100
Subject: [PATCH 15/16] Remove dead assignment of lock_flags
In-Reply-To: <cover.1297419991.git.zkabelac@redhat.com>
References: <cover.1297419991.git.zkabelac@redhat.com>
Message-ID: <6d85ce67bfba8d8c155700a255ad8368c40f6c5c.1297419991.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Variable 'lock_flags' is not used - so put into a comment.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 6d0dee4..0c0a6cb 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -185,7 +185,6 @@ static int lock_vg(struct local_client *client)
     struct clvm_header *header =
 	(struct clvm_header *) client->bits.localsock.cmd;
     unsigned char lock_cmd;
-    unsigned char lock_flags;
     int lock_mode;
     char *args = header->node + strlen(header->node) + 1;
     int lkid;
@@ -207,7 +206,7 @@ static int lock_vg(struct local_client *client)
 
     lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
     lock_mode = ((int)lock_cmd & LCK_TYPE_MASK);
-    lock_flags = args[1];
+    /* lock_flags = args[1]; */
     lockname = &args[2];
     DEBUGLOG("doing PRE command LOCK_VG '%s' at %x (client=%p)\n", lockname, lock_cmd, client);
 
-- 
1.7.4


