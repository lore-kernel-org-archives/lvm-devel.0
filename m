From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:49 +0000 (UTC)
Subject: master - thin: dmeventd fix memleak on error path
Message-ID: <20121215162549.E0CDBA0C59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f9e26f5c0d0bbcd0eeedcda1de3daa92188bd22
Commit:        6f9e26f5c0d0bbcd0eeedcda1de3daa92188bd22
Parent:        401c9aba4a1d37d2bb05467e8860876929db9a8c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 13 20:19:38 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:27 2012 +0100

thin: dmeventd fix memleak on error path

Some error paths on _umount have leaked bitset.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 75bd1b3..ce342cf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Fix resource leak in error path of dmeventd's umount of thin volume.
   Automatically deactivate failed preloaded dm tree node.
   Add DM_DISABLE_UDEV environment variable to manage dev nodes by libdm only.
   Fix dm_task_set_cookie to properly process udev flags if udev_sync disabled.
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index a1af4c0..ba72c4a 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -291,8 +291,9 @@ static void _umount(struct dm_task *dmt, const char *device)
 	if (fclose(minfo))
 		syslog(LOG_ERR, "Failed to close %s\n", mountinfo);
 
-	dm_bitset_destroy(minors);
 out:
+	if (minors)
+		dm_bitset_destroy(minors);
 	dmeventd_lvm2_lock();
 }
 


