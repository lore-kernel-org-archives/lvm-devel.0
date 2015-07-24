From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 24 Jul 2015 15:56:41 +0000 (UTC)
Subject: master - lockd: remove an unreachable global lock condition
Message-ID: <20150724155641.767B860D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1f5ac3eca1ebccc08fdc3f9304e3d85fa115146
Commit:        c1f5ac3eca1ebccc08fdc3f9304e3d85fa115146
Parent:        bcb875dcb19323ab62f2f3b409c4bda4ce8267d1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 23 11:00:03 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 24 10:56:08 2015 -0500

lockd: remove an unreachable global lock condition

There is no longer an "enable" option for the global lock,
so remove the bit of code that was checking for it.  It
was an optional variation anyway, and not one that was likely
to be used.

Also update the corresponding comment describing global lock
creation.
---
 lib/locking/lvmlockd.c |   63 ++++++++++++-----------------------------------
 1 files changed, 16 insertions(+), 47 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index ac8c155..e9d7882 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1169,55 +1169,24 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 			return 1;
 
 		/*
-		 * This is the explicit sanlock bootstrap condition for
-		 * proceding without the global lock: a chicken/egg case
-		 * for the first sanlock VG that is created.
+		 * This is the sanlock bootstrap condition for proceding
+		 * without the global lock: a chicken/egg case for the first
+		 * sanlock VG that is created.  When creating the first
+		 * sanlock VG, there is no global lock to acquire because
+		 * the gl will exist in the VG being created.  So, we
+		 * skip acquiring the global lock when creating this initial
+		 * VG, and enable the global lock in this VG.
 		 *
-		 * When creating the first sanlock VG, there is no global
-		 * lock to acquire because the gl will exist in the VG
-		 * being created.  The "enable" option makes explicit that
-		 * this is expected:
+		 * Here we assume that this is an initial bootstrap condition
+		 * based on the fact that lvmlockd has seen no lockd VGs.
+		 * (A commmand line option could be added to allow the user
+		 * to make this initial bootstrap condition explicit.)
 		 *
-		 * vgcreate --lock-type sanlock --lock-gl enable
-		 *
-		 * There are three indications that this is the unique
-		 * first-sanlock-vg bootstrap case:
-		 *
-		 * - result from lvmlockd is -ENOLS because lvmlockd found
-		 *   no lockspace for this VG; expected because it's being
-		 *   created here.
-		 *
-		 * - result flag LD_RF_NO_GL_LS from lvmlockd means that
-		 *   lvmlockd has seen no other lockspace with a global lock.
-		 *   This implies that this is probably the first sanlock vg
-		 *   to be created.  If other sanlock vgs exist, the global
-		 *   lock should be available from one of them.
-		 *
-		 * - command line lock-gl arg is "enable" which means the
-		 *   user expects this to be the first sanlock vg, and the
-		 *   global lock should be enabled in it.
-		 */
-
-		if ((lockd_flags & LD_RF_NO_GL_LS) &&
-		    !strcmp(vg_lock_type, "sanlock") &&
-		    !strcmp(mode, "enable")) {
-			log_print_unless_silent("Enabling sanlock global lock");
-			lvmetad_validate_global_cache(cmd, 1);
-			return 1;
-		}
-
-		/*
-		 * This is an implicit sanlock bootstrap condition for
-		 * proceeding without the global lock.  The command line does
-		 * not indicate explicitly that this is a bootstrap situation
-		 * (via "enable"), but it seems likely to be because lvmlockd
-		 * has seen no lockd-type vgs.  It is possible that a global
-		 * lock does exist in a vg that has not yet been seen.  If that
-		 * vg appears after this creates a new vg with a new enabled
-		 * gl, then there will be two enabled global locks, and one
-		 * will need to be disabled.  (We could instead return an error
-		 * here and insist with an error message that the --lock-gl
-		 * enable option be used to exercise the explicit case above.)
+		 * That assumption might be wrong.  It is possible that a global
+		 * lock does exist in a VG that has not yet been seen.  If that
+		 * VG appears after this creates a new VG with a new enabled
+		 * global lock, then there will be two VGs containing enabled
+		 * global locks, and one will need to be disabled by the user.
 		 */
 
 		if ((lockd_flags & LD_RF_NO_GL_LS) &&


