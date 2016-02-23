From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 11:26:00 +0000 (UTC)
Subject: master - thin: fix read size compare
Message-ID: <20160223112600.5001560D10@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f501f083bf1ea9f60a8b18aa9b5d59f3459ee4a6
Commit:        f501f083bf1ea9f60a8b18aa9b5d59f3459ee4a6
Parent:        05eb87ca2defb6e7e7bd9759bab566de7cb6e3f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 12:11:15 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 12:22:18 2016 +0100

thin: fix read size compare

Fix the compare with 'unsigned' sizeof() and error read -1 result.
So the read error is correctly recognized.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f15d885..355712c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.144 - 
 =====================================
+  Fir read error detection when checking for uninitialized thin-pool header.
   Fix error path for internal error in lvmetad vg lookup code.
 
 Version 2.02.143 - 21st February 2016
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2826218..15d6bb9 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1841,7 +1841,7 @@ static int _pool_callback(struct dm_tree_node *node,
 			return 0;
 		}
 		/* let's assume there is no problem to read 64 bytes */
-		if (read(fd, buf, sizeof(buf)) < sizeof(buf)) {
+		if (read(fd, buf, sizeof(buf)) < (int)sizeof(buf)) {
 			log_sys_error("read", argv[args]);
 			if (close(fd))
 				log_sys_error("close", argv[args]);


