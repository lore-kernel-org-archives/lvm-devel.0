From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:39 +0000 (UTC)
Subject: master - activate: lv_check_not_in_use no check of closed
Message-ID: <20140924085639.66D696109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f2adcc9efc8621fa5cf3a1871f2294fa7da7f1f
Commit:        0f2adcc9efc8621fa5cf3a1871f2294fa7da7f1f
Parent:        392bb6f46eb73dcf725566fbdf006a4e02ae7502
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 23:07:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:47:00 2014 +0200

activate: lv_check_not_in_use no check of closed

Don't perform expensive sysfs tests when the device is closed.
(having open_count == 0).
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c5ba9fa..b4ee934 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Do not scan sysfs in lv_check_not_in_use() when device is closed.
   Backup final metadata after resync of mirror/raid.
   Unify handling of --persistent option for lvcreate and lvchange.
   Validate major and minor numbers stored in metadata.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2091fa1..7f3a711 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -700,7 +700,7 @@ int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	unsigned int open_count_check_retries;
 
-	if (!info->exists)
+	if (!info->exists || !info->open_count)
 		return 1;
 
 	/* If sysfs is not used, use open_count information only. */


