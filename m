From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Jan 2022 16:01:47 +0000 (GMT)
Subject: main - vgsplit: don't reread vg_to
Message-ID: <20220113160147.872013951C05@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e428d22d9647a294eba65852078947df5ade48f
Commit:        5e428d22d9647a294eba65852078947df5ade48f
Parent:        7502f78678db7c7701e543a0a7267e050850ba53
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 12 16:42:01 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 12 16:42:01 2022 -0600

vgsplit: don't reread vg_to

The destination vg is first written with the EXPORTED flag,
then the source vg is written, then the destination vg is
written again without the EXPORTED flag.  Remove an unnecessary
vg_read of the destination vg just before the second write.
---
 tools/vgsplit.c | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index a085ac2ba..5f113b363 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -727,30 +727,6 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		backup(vg_from);
 	}
 
-	/*
-	 * Finally, remove the EXPORTED flag from the new VG and write it out.
-	 * We need to unlock vg_to because vg_read_for_update wants to lock it.
-	 */
-	if (!test_mode()) {
-		unlock_vg(cmd, NULL, vg_name_to);
-		release_vg(vg_to);
-
-		/*
-		 * This command uses the exported vg flag internally, but
-		 * exported VGs are not allowed to be split from the command
-		 * level, so ALLOW_EXPORTED is not set in commands.h.
-		 */
-		cmd->include_exported_vgs = 1;
-
-		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0, 0);
-
-		if (!vg_to) {
-			log_error("Volume group \"%s\" became inconsistent: "
-				  "please fix manually", vg_name_to);
-			goto bad;
-		}
-	}
-
 	vg_to->status &= ~EXPORTED_VG;
 
 	if (!vg_write(vg_to) || !vg_commit(vg_to))


