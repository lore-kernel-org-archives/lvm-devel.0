From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 31 Jul 2015 20:51:58 +0000 (UTC)
Subject: master - lockd: remove ignorelockingfailure checks
Message-ID: <20150731205158.5543B60CFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72f754e2bc571ada133057c5a248162dc349cf93
Commit:        72f754e2bc571ada133057c5a248162dc349cf93
Parent:        439a579aa2aaf13c2e420b6e7888dbd71d7021c0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 31 15:46:51 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 31 15:51:50 2015 -0500

lockd: remove ignorelockingfailure checks

These code paths were effectively unused.  The checks
had been added long ago without any real thought behind
what they should do or be used for.
---
 lib/locking/lvmlockd.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 15abd54..4e85ec1 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1475,11 +1475,7 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 		log_warn("Duplicate sanlock global locks should be corrected");
 
 	if (result < 0) {
-		if (ignorelockingfailure()) {
-			log_debug("Ignore failed locking for global lock");
-			lvmetad_validate_global_cache(cmd, 1);
-			return 1;
-		} else if (result == -EAGAIN) {
+		if (result == -EAGAIN) {
 			/*
 			 * Most of the time, retries should avoid this case.
 			 */
@@ -1770,11 +1766,6 @@ out:
 	if ((lockd_flags & LD_RF_DUP_GL_LS) && strcmp(mode, "un"))
 		log_warn("Duplicate sanlock global lock in VG %s", vg_name);
  
-	if (!ret && ignorelockingfailure()) {
-		log_debug("Ignore failed locking for VG %s", vg_name);
-		return 1;
-	}
- 
 	return ret;
 }
 


