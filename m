From: Milan Broz <mbroz@redhat.com>
Date: Mon, 11 Jan 2010 18:52:21 +0100
Subject: [PATCH] Fix clvmd automatic target module load to not segfault.
Message-ID: <1263232341-5960-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/locking/locking.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index e1881af..4d1d845 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -186,7 +186,9 @@ void reset_locking(void)
 	_vg_lock_count = 0;
 	_vg_write_lock_held = 0;
 
-	_locking.reset_locking();
+	/* FIXME: clvmd/exec_cmd calls that without locking set */
+	if (_locking.reset_locking)
+		_locking.reset_locking();
 
 	if (was_locked)
 		_unblock_signals();
-- 
1.6.6


