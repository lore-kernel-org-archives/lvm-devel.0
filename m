From: Milan Broz <mbroz@redhat.com>
Date: Tue,  8 Dec 2009 16:39:05 +0100
Subject: [PATCH 02/10] Get rid of hardcoded 0xffdf cluster lock flag.
In-Reply-To: <cover.1260284754.git.mbroz@redhat.com>
References: <cover.1260284754.git.mbroz@redhat.com>
Message-ID: <0fc994ad580d6e479a89c904d88d23a296240bcc.1260284754.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There is hidded change - the upper flags (0xffff0000)
and now not cleared, but there are unused anyway.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/locking/cluster_locking.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index eb09241..b031f12 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -415,7 +415,7 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 		clvmd_cmd = CLVMD_CMD_LOCK_LV;
 		strcpy(lockname, resource);
 		lock_scope = "LV";
-		flags &= 0xffdf;	/* Mask off HOLD flag */
+		flags &= ~LCK_HOLD;	/* Mask off HOLD flag */
 		break;
 
 	default:
-- 
1.6.5.4


