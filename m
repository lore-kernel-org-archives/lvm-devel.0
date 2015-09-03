From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:48:57 +0000 (UTC)
Subject: master - lockd: check for unlock failure in all cases
Message-ID: <20150903214857.A1531606F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e8b3d4a9825ecca3dc7a71f6379b63a27d6fa8c
Commit:        9e8b3d4a9825ecca3dc7a71f6379b63a27d6fa8c
Parent:        c27015368b590dc42f15ef8d55faa279e912666a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 3 13:47:54 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 3 16:47:54 2015 -0500

lockd: check for unlock failure in all cases

This suppresses an unwanted error message.
---
 lib/locking/lvmlockd.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 983ecc9..a726d87 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1454,6 +1454,10 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 		}
 	}
 
+
+	if (!strcmp(mode, "un"))
+		return 1;
+
 	/*
 	 * ENOLS: no lockspace was found with a global lock.
 	 * The VG with the global lock may not be visible or started yet,
@@ -1473,10 +1477,6 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 	    result == -ESTARTING ||
 	    result == -EVGKILLED ||
 	    result == -ELOCKIO) {
-
-		if (!strcmp(mode, "un"))
-			return 1;
-
 		/*
 		 * If an ex global lock fails, then the command fails.
 		 */


