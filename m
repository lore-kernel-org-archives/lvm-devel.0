From: Milan Broz <mbroz@redhat.com>
Date: Wed, 31 Mar 2010 16:05:08 +0200
Subject: [PATCH] Always use blocking lock for VGs and orphan locks.
Message-ID: <1270044308-30885-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Because we have now strong rule for lock ordering:
 - VG locks must be taken in alphabetical order
 - ORPHAN locks must be the last
vgs_locked() is now not needed.

This fixes problem with orphan locking, e.g.
vgremove VG1    |    vgremove VG2
lock(VG1)       |    lock(VG2)
lock(ORPHAN)    |    lock(ORPHAN) -> fail, non-blocking

https://bugzilla.redhat.com/show_bug.cgi?id=578413

(More similar places in code.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/locking/locking.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 76dbda5..cf0d3ae 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -420,11 +420,9 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
 		/*
-		 * Automatically set LCK_NONBLOCK if one or more VGs locked.
-		 * This will enforce correctness and prevent deadlocks rather
-		 * than relying on the caller to set the flag properly.
+		 * VG locks alphabetical, ORPHAN lock last
 		 */
-		if (!_blocking_supported || vgs_locked())
+		if (!_blocking_supported)
 			flags |= LCK_NONBLOCK;
 
 		if (vol[0] != '#' &&
-- 
1.7.0.3


