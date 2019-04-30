From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Apr 2019 15:39:08 -0400
Subject: master - vgcreate: remove the lvmcache locking workaround
Message-ID: <201904301939.x3UJd8c9015823@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7054cd28ae6bb2fad216f8756ab030de3e8e65e
Commit:        d7054cd28ae6bb2fad216f8756ab030de3e8e65e
Parent:        366c1ac15b853fe3efc95472c569efc575f1237f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 30 14:26:16 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 30 14:26:16 2019 -0500

vgcreate: remove the lvmcache locking workaround

Recent cleanups and simplifications to lvmcache and locking
mean that the odd locking to workaround other issues is now
unnecessary.
---
 tools/vgcreate.c |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index d62925f..626cf15 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -91,15 +91,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	/*
-	 * FIXME: we have to unlock/relock the new VG name around the pvcreate
-	 * step because pvcreate needs to destroy lvmcache, which doesn't allow
-	 * any locks to be held.  There shouldn't be any reason to require this
-	 * VG lock to be released, so the lvmcache destroy rule about locks
-	 * seems to be unwarranted here.
-	 */
-	unlock_vg(cmd, NULL, vp_new.vg_name);
-
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
@@ -110,12 +101,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
-	/* Relock the new VG name, see comment above. */
-	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE, NULL)) {
-		destroy_processing_handle(cmd, handle);
-		return_ECMD_FAILED;
-	}
-
 	if (!(vg = vg_create(cmd, vp_new.vg_name)))
 		goto_bad;
 


