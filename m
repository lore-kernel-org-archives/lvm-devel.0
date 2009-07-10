From: Milan Broz <mbroz@redhat.com>
Date: Fri, 10 Jul 2009 16:10:40 +0200
Subject: [PATCH] Do not count VG_GLOBAL to lock_count.
Message-ID: <4A574BE0.70704@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not count VG_GLOBAL to lock_count.

Otherwise all read-only scanning will open devices RW.
because of
	flags = vg_write_lock_held() ? O_RDWR : O_RDONLY;

(And trigger udev rule because of IN_CLOSE_WRITE monitoring).

Anyway, there are many other situations when lvm opens
device RW unnecessarily...

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/locking/locking.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 5c04b4f..482cdf0 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -189,12 +189,16 @@ void reset_locking(void)
 		_unblock_signals();
 }
 
-static void _update_vg_lock_count(uint32_t flags)
+static void _update_vg_lock_count(const char *resource, uint32_t flags)
 {
 	if ((flags & LCK_SCOPE_MASK) != LCK_VG ||
 	    (flags & LCK_CACHE))
 		return;
 
+	/* Ignore global locks */
+	if (!strcmp(resource, VG_GLOBAL))
+		return;
+
 	if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
 		_vg_lock_count--;
 	else
@@ -356,7 +360,7 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t fla
 								== LCK_READ);
 		}
 
-		_update_vg_lock_count(flags);
+		_update_vg_lock_count(resource, flags);
 	}
 
 	_unlock_memory(flags);



