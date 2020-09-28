From: David Teigland <teigland@sourceware.org>
Date: Mon, 28 Sep 2020 18:29:27 +0000 (GMT)
Subject: master - devices: fix reopen for unopened device
Message-ID: <20200928182927.71827386101B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=890c7ef451809a498978651a1802f65606a7c16b
Commit:        890c7ef451809a498978651a1802f65606a7c16b
Parent:        8952dcbff0c1ca9bfaa2f8fe8b6da78a10319e6b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 25 11:59:49 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 28 13:25:57 2020 -0500

devices: fix reopen for unopened device

If there's a request to reopen rw a device that's not
open, then just call the normal open function.
---
 lib/label/label.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 0090fd0a5..27d06d783 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1460,7 +1460,8 @@ int label_scan_reopen_rw(struct device *dev)
 				  dev_name(dev), dev->bcache_fd, dev->bcache_di);
 			return 0;
 		}
-		goto do_open;
+		dev->flags |= DEV_BCACHE_WRITE;
+		return _scan_dev_open(dev);
 	}
 
 	if ((dev->flags & DEV_BCACHE_WRITE))
@@ -1477,7 +1478,6 @@ int label_scan_reopen_rw(struct device *dev)
 		return 0;
 	}
 
- do_open:
 	flags |= O_DIRECT;
 	flags |= O_NOATIME;
 	flags |= O_RDWR;


