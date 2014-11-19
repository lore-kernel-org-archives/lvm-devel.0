From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Nov 2014 00:14:03 +0000 (UTC)
Subject: master - locking: rename LCK_CONVERT
Message-ID: <20141119001403.C544C6033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01760967b45a68f1645b797e69b28403a7823ee2
Commit:        01760967b45a68f1645b797e69b28403a7823ee2
Parent:        aaa6205d5ad4beb8a54d56f9285cafb5dbd5c7b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 18 09:04:30 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 18 16:50:49 2014 +0100

locking: rename LCK_CONVERT

All 'MODE' bits are using _MODE suffix so rename to LCK_CONVERT_MODE
(part of rhbz 735445).
No functional change.
---
 daemons/clvmd/lvm-functions.c |    4 ++--
 lib/locking/locking.h         |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 4ebd059..dafffcc 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -136,7 +136,7 @@ static const char *decode_flags(unsigned char flags)
 		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR|" : "",
 		flags & LCK_ORIGIN_ONLY_MODE ? "ORIGIN_ONLY|" : "",
 		flags & LCK_TEST_MODE ? "TEST|" : "",
-		flags & LCK_CONVERT ? "CONVERT|" : "",
+		flags & LCK_CONVERT_MODE ? "CONVERT|" : "",
 		flags & LCK_DMEVENTD_MONITOR_IGNORE ? "DMEVENTD_MONITOR_IGNORE|" : "",
 		flags & LCK_REVERT_MODE ? "REVERT|" : "");
 
@@ -375,7 +375,7 @@ static int do_activate_lv(char *resource, unsigned char command, unsigned char l
 	 * of exclusive lock to shared one during activation.
 	 */
 	if (!test_mode() && command & LCK_CLUSTER_VG) {
-		status = hold_lock(resource, mode, LCKF_NOQUEUE | (lock_flags & LCK_CONVERT ? LCKF_CONVERT:0));
+		status = hold_lock(resource, mode, LCKF_NOQUEUE | ((lock_flags & LCK_CONVERT_MODE) ? LCKF_CONVERT:0));
 		if (status) {
 			/* Return an LVM-sensible error for this.
 			 * Forcing EIO makes the upper level return this text
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index c1affb4..644e07c 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -114,7 +114,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_DMEVENTD_MONITOR_MODE	0x04	/* Register with dmeventd */
 
 /* Not yet used. */
-#define LCK_CONVERT			0x08	/* Convert existing lock */
+#define LCK_CONVERT_MODE		0x08	/* Convert existing lock */
 
 #define LCK_TEST_MODE			0x10    /* Test mode: No activation */
 #define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */


