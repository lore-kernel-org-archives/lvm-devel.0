From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 12 Dec 2017 13:04:34 -0500
Subject: master - device: Fix an unpaired device close.
Message-ID: <201712121804.vBCI4Yj9027301@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e932c5da50a22e585a3cd08edb3d849e7715e244
Commit:        e932c5da50a22e585a3cd08edb3d849e7715e244
Parent:        b96862ee11e0291cc1101ff4e17e54f9fe8da666
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 12 17:56:58 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 12 17:56:58 2017 +0000

device: Fix an unpaired device close.

dev_open_flags contains an unpaired dev_close_immediate so increment
open_count before calling it.
---
 lib/device/dev-io.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index dc9ad13..c321e61 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -491,11 +491,12 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 			return 1;
 		}
 
-		if (dev->open_count && !need_excl) {
+		if (dev->open_count && !need_excl)
 			log_debug_devs("%s: Already opened read-only. Upgrading "
 				       "to read-write.", dev_name(dev));
-			dev->open_count++;
-		}
+
+		/* dev_close_immediate will decrement this */
+		dev->open_count++;
 
 		dev_close_immediate(dev);
 		// FIXME: dev with DEV_ALLOCED is released


