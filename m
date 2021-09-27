From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:51 +0000 (GMT)
Subject: main - make: opened can be needed for either defines case
Message-ID: <20210927165751.072C73858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df70dca995e5593e27e13cf00311d961b4def0e2
Commit:        df70dca995e5593e27e13cf00311d961b4def0e2
Parent:        9971459d19e93ff652eeaff165da72e51b256299
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 17:46:09 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

make: opened can be needed for either defines case

Reported-by: adamboardman of gemian
---
 lib/device/dev-io.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 17993d82c..b4f1930b1 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -380,8 +380,10 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 		return 0;
 	}
 
-#ifdef O_DIRECT_SUPPORT
+#if defined(O_NOATIME) || defined(O_DIRECT_SUPPORT)
       opened:
+#endif
+#ifdef O_DIRECT_SUPPORT
 	if (direct)
 		dev->flags |= DEV_O_DIRECT_TESTED;
 #endif


