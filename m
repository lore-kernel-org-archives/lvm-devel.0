From: David Teigland <teigland@sourceware.org>
Date: Tue,  4 Jan 2022 20:57:44 +0000 (GMT)
Subject: main - lvmlockd: cleanup after sanlock_rem_lockspace error
Message-ID: <20220104205744.236513858C2C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=42a16aa6f34d801bfea169b4f6d1fef5d89961f6
Commit:        42a16aa6f34d801bfea169b4f6d1fef5d89961f6
Parent:        04fbffb116eaf5fb1b10785df92966d0083b270f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 4 14:47:31 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 4 14:53:47 2022 -0600

lvmlockd: cleanup after sanlock_rem_lockspace error

When storage is lost under a sanlock VG, and kill_vg/drop_vg
are used, sanlock_rem_lockspace() may return an error, but
the cleanup steps should still be performed.  Without the
cleanup, gl_lsname_sanlock was not cleared.  This caused
future lock requests to fail with ENOLS, but the NO_GL_LS
flag was not set due to gl_lsname_sanlock being set.
This caused lockd_global(sh) in lvm commands to fail when
they could succeed.

Fix from guozhonghua216
---
 daemons/lvmlockd/lvmlockd-sanlock.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index e595eeffd..3f078ea41 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1576,10 +1576,8 @@ int lm_rem_lockspace_sanlock(struct lockspace *ls, int free_vg)
 		goto out;
 
 	rv = sanlock_rem_lockspace(&lms->ss, 0);
-	if (rv < 0) {
+	if (rv < 0)
 		log_error("S %s rem_lockspace_san error %d", ls->name, rv);
-		return rv;
-	}
 
 	if (free_vg) {
 		/*


