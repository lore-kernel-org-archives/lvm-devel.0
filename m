From: Milan Broz <mbroz@redhat.com>
Date: Thu, 21 Jan 2010 17:15:28 +0100
Subject: [PATCH] Locking type do not use ignorelockingfailure, fix message.
Message-ID: <1264090528-2960-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/locking/no_locking.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 85374b3..9de143b 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -72,7 +72,7 @@ static int _readonly_lock_resource(struct cmd_context *cmd,
 	    (flags & LCK_SCOPE_MASK) == LCK_VG &&
 	    !(flags & LCK_CACHE) &&
 	    strcmp(resource, VG_GLOBAL)) {
-		log_error("Write locks are prohibited with --ignorelockingfailure.");
+		log_error("Write locks are prohibited with read-only locking.");
 		return 0;
 	}
 
-- 
1.6.6


