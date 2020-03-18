From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 18 Mar 2020 13:36:21 +0000 (GMT)
Subject: master - test: Can not attach writecache to active volume
Message-ID: <20200318133621.9F05B393FC2D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc32787c1b7f867008f30444a20ba154e0cdc39c
Commit:        fc32787c1b7f867008f30444a20ba154e0cdc39c
Parent:        957904933b2b0f94eddc6204ca2fa61e2df741a0
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 18 14:30:09 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 18 14:35:58 2020 +0100

test: Can not attach writecache to active volume

---
 test/shell/writecache.sh | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index 0a7f694bb..a7a2d9564 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -139,8 +139,10 @@ mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
 cp pattern1 $mount_dir/pattern1
 ls -l $mount_dir
 
-lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
+# TODO BZ 1808012 - can not convert active volume to writecache:
+not lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
 
+if false; then
 check lv_field $vg/$lv1 segtype writecache
 
 lvs -a $vg/${lv2}_cvol --noheadings -o segtype >out
@@ -162,6 +164,7 @@ diff pattern1 $mount_dir/pattern1.after
 umount $mount_dir
 lvchange -an $vg/$lv1
 lvremove $vg/$lv1
+fi
 
 vgremove -ff $vg
 



