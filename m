From: Milan Broz <mbroz@redhat.com>
Date: Fri, 19 Dec 2008 12:49:03 +0100
Subject: [PATCH] check for maximal device size in set_lv
Message-ID: <494B8A2F.9050305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Do not issue write violating LV size.

pvcreate $DEV
vgcreate -s 1k vg_test $DEV
lvcreate -l 1 -n lv1 vg_test
..
/dev/vg_test/lv1: write failed after 1024 of 4096 at 0: No space left on device

Just check for maximum write size in set_lv.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c	2008-12-19 12:26:26.000000000 +0100
+++ LVM2/lib/metadata/lv_manip.c	2008-12-19 12:37:57.000000000 +0100
@@ -2698,9 +2698,13 @@ int set_lv(struct cmd_context *cmd, stru
 	if (!dev_open_quiet(dev))
 		return_0;
 
-	dev_set(dev, UINT64_C(0),
-		sectors ? (size_t) sectors << SECTOR_SHIFT : (size_t) 4096,
-		value);
+	if (!sectors)
+		sectors = 4096 >> SECTOR_SHIFT;
+
+	if (sectors > lv->size)
+		sectors = lv->size;
+
+	dev_set(dev, UINT64_C(0), (size_t) sectors << SECTOR_SHIFT, value);
 	dev_flush(dev);
 	dev_close_immediate(dev);
 




