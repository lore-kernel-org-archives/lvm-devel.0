From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Aug 2017 08:23:54 -0400
Subject: master - locking: avoid descriptor leak for nonblocking mode
Message-ID: <201708251223.v7PCNs4o005013@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5de944420224f3b629e843f9c190132ed9ff3dca
Commit:        5de944420224f3b629e843f9c190132ed9ff3dca
Parent:        043ff47b0579bffaa63cb023d8850b0e749eb9ce
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 25 11:59:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 25 14:12:55 2017 +0200

locking: avoid descriptor leak for nonblocking mode

When file-locking mode failed on locking, such description was leaked
(typically not an issue since command usually exists afterwards).
So shirt close() at the end of function and use it in all error paths.

Also make sure, when interrrupt is detected, it's really not holding
lock and returns 0.
---
 WHATS_NEW            |    1 +
 lib/misc/lvm-flock.c |   13 ++++++++-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c8f072f..ac69c16 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Fix leaking of file descriptor for non-blocking filebased locking.
   Fix check for 2nd mda at end of disk fits if using pvcreate --restorefile.
   Use maximum metadataarea size that fits with pvcreate --restorefile.
   Always clear cached bootloaderarea when wiping label e.g. in pvcreate.
diff --git a/lib/misc/lvm-flock.c b/lib/misc/lvm-flock.c
index 22eb128..4196313 100644
--- a/lib/misc/lvm-flock.c
+++ b/lib/misc/lvm-flock.c
@@ -116,17 +116,16 @@ static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock
 		old_errno = errno;
 		if (!nonblock) {
 			sigint_restore();
-			if (sigint_caught())
+			if (sigint_caught()) {
 				log_error("Giving up waiting for lock.");
+				break;
+			}
 		}
 
 		if (r) {
 			errno = old_errno;
 			log_sys_error("flock", file);
-			if (close(*fd))
-				log_sys_debug("close", file);
-			*fd = -1;
-			return 0;
+			break;
 		}
 
 		if (!stat(file, &buf1) && !fstat(*fd, &buf2) &&
@@ -134,6 +133,10 @@ static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock
 			return 1;
 	} while (!nonblock);
 
+	if (close(*fd))
+		log_sys_debug("close", file);
+	*fd = -1;
+
 	return_0;
 }
 


