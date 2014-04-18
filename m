From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:54:56 +0000 (UTC)
Subject: master - thin: dmeventd plugins support more minors
Message-ID: <20140418145456.2757660758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b6d6bfb772f8320866e938ecba9894dc2d1cd7e
Commit:        0b6d6bfb772f8320866e938ecba9894dc2d1cd7e
Parent:        47a60369a0473bb5f4f8a9d153c83d1a3f4f187d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 13:26:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:47 2014 +0200

thin: dmeventd plugins support more minors

Kernel supports upto 1M (20bit) minors.
TODO: convert to hash to reduce memory requirements
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 51376d3..6a983a7 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.88 - 
 =================================
+  Increase bitset size for minors for thin dmeventd plugin.
 
 Version 1.02.85 - 10th April 2014
 =================================
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 3126bfa..b700b8d 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -218,7 +218,8 @@ static int _umount_device(char *buffer, unsigned major, unsigned minor,
  */
 static void _umount(struct dm_task *dmt, const char *device)
 {
-	static const size_t MINORS = 4096;
+	/* TODO: Convert to use hash to reduce memory usage */
+	static const size_t MINORS = (1U << 20); /* 20 bit */
 	struct mountinfo_s data = {
 		.device = device,
 	};


