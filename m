From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 00:24:21 -0400
Subject: [PATCH] Remove LOCK_KEEP and READ_CHECK_EXISTENCE from vgsplit.
In-Reply-To: <1246940664-14890-1-git-send-email-dwysocha@redhat.com>
References: <1246940664-14890-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1246940664-14890-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove LOCK_KEEP and READ_CHECK_EXISTENCE from vgsplit.
These flags are no longer necessary.  We now check for existence
in a differnet function, and it is not necessary to keep the lock.
Removing these flags simplifies the new vg_read() interface.
After this patch, we can fully remove LOCK_KEEP.
READ_CHECK_EXISTENCE needs a bit more work before full removal.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgsplit.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 9cd90b8..0dc5bc4 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -342,11 +342,12 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		existing_vg = 1;
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 					   READ_REQUIRE_RESIZEABLE |
-					   LOCK_NONBLOCKING | LOCK_KEEP |
-					   READ_CHECK_EXISTENCE);
+					   LOCK_NONBLOCKING);
 
-		if (vg_read_error(vg_to))
-			goto_bad;
+		if (vg_read_error(vg_to)) {
+			vg_release(vg_to);
+			goto bad2;
+		}
 
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
@@ -483,7 +484,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	r = ECMD_PROCESSED;
 
 bad:
-	unlock_and_release_vg(cmd, vg_from, vg_name_from);
 	unlock_and_release_vg(cmd, vg_to, vg_name_to);
+bad2:
+	unlock_and_release_vg(cmd, vg_from, vg_name_from);
 	return r;
 }
-- 
1.6.0.6


