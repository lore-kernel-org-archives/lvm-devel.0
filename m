From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:36 +0100
Subject: [PATCH 04/23] Remove dead assignment of lock_flags
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <0662c43178e50334f41961cbb83743e9eb7e5e53.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Variable 'lock_flags' is not used.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-command.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 49f1197..95d924b 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -182,7 +182,6 @@ static int lock_vg(struct local_client *client)
     struct clvm_header *header =
 	(struct clvm_header *) client->bits.localsock.cmd;
     unsigned char lock_cmd;
-    unsigned char lock_flags;
     int lock_mode;
     char *args = header->node + strlen(header->node) + 1;
     int lkid;
@@ -204,7 +203,6 @@ static int lock_vg(struct local_client *client)
 
     lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
     lock_mode = ((int)lock_cmd & LCK_TYPE_MASK);
-    lock_flags = args[1];
     lockname = &args[2];
     DEBUGLOG("doing PRE command LOCK_VG '%s' at %x (client=%p)\n", lockname, lock_cmd, client);
 
-- 
1.7.3.4


