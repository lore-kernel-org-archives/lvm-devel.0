From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Sep 2017 09:15:01 -0400
Subject: master - tests: repair of cachepool
Message-ID: <201709201315.v8KDF11a009506@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a15b7961468682496f9b51d9a07223e3dd6eba3f
Commit:        a15b7961468682496f9b51d9a07223e3dd6eba3f
Parent:        2fd2b197ab5962bc0a1e7eb25bba120d7501032f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 20 12:28:39 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 20 15:14:16 2017 +0200

tests: repair of cachepool

---
 test/shell/lvconvert-repair-cache.sh |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index c68fdbd..5470e3f 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -60,6 +60,24 @@ aux enable_dev "$dev1"
 lvcreate --type cache-pool -L10 $vg/cpool "$dev1"
 lvconvert -H --cachemode writethrough --cachepool $vg/cpool -Zy $lv1
 
+# Check basic --repair of cachepool metadata
+lvchange -an $vg/$lv1
+lvconvert --repair $vg/$lv1
+
+lvs -a $vg
+check lv_exists $vg ${lv1}_meta0
+
+eval $(lvs -S 'name=~_pmspare' -a --config 'report/mark_hidden_devices=0' -o name --noheading --nameprefixes $vg)
+lvremove -f --yes "$vg/$LVM2_LV_NAME"
+
+# check --repair without creation of _pmspare device
+lvconvert --repair --poolmetadataspare n $vg/$lv1
+check lv_exists $vg ${lv1}_meta1
+
+# check no _pmspare has been created in previous --repair
+test "0" = $(lvs -S 'name=~_pmspare' -a -o name --noheading --nameprefixes $vg | wc -l)
+
+
 aux disable_dev "$dev2"
 
 # Deactivate before remove
@@ -71,11 +89,6 @@ not lvconvert --uncache $vg/$lv1
 # --yes to drop when Check its prompting
 lvconvert --yes --uncache $vg/$lv1
 
-#lvconvert --repair $vg/$lv1 -vvvvv
-#/$lv1
-
-#lvchange -ay $vg
-
 aux enable_dev "$dev2"
 
 # FIXME: temporary workaround


