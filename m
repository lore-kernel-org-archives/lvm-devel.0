From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:31 +0000 (UTC)
Subject: master - debug: drop printing debug trace without labeler
Message-ID: <20140924085731.C95FC60E42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2bfd986ea343244d33181c6b78dc39c8725014cd
Commit:        2bfd986ea343244d33181c6b78dc39c8725014cd
Parent:        4319e06a0fe0b27471ea47687e344b836577f465
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 22 13:34:12 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

debug: drop printing debug trace without labeler

Not having labeller on device is not reason eo generate backtrace in log.
---
 lib/label/label.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 703fef7..ce59da8 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -278,15 +278,12 @@ int label_read(struct device *dev, struct label **result,
 		return r;
 	}
 
-	if (!(l = _find_labeller(dev, buf, &sector, scan_sector)))
-		goto_out;
-
-	if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result) {
-		(*result)->dev = dev;
-		(*result)->sector = sector;
-	}
+	if ((l = _find_labeller(dev, buf, &sector, scan_sector)))
+		if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result) {
+			(*result)->dev = dev;
+			(*result)->sector = sector;
+		}
 
-      out:
 	if (!dev_close(dev))
 		stack;
 


