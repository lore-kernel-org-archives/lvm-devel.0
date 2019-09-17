From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 17 Sep 2019 05:35:09 -0400
Subject: stable-2.02 - tests: pool conversion
Message-ID: <201909170935.x8H9Z9t8020691@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2694f93bb4b670d5afc51ff656f51e1e2945664a
Commit:        2694f93bb4b670d5afc51ff656f51e1e2945664a
Parent:        e147786bac52fea240955329963c9eed0eebfb18
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 17 11:27:13 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 17 11:33:55 2019 +0200

tests: pool conversion

Test conversion of cached LV.
---
 test/shell/lvconvert-cache-thin.sh |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache-thin.sh b/test/shell/lvconvert-cache-thin.sh
index e1d38b8..7dda6e6 100644
--- a/test/shell/lvconvert-cache-thin.sh
+++ b/test/shell/lvconvert-cache-thin.sh
@@ -51,4 +51,20 @@ check lv_field $vg/$lv1 segtype "thin"
 lvconvert --uncache $vg/tpool
 lvs -a $vg
 
+lvremove -f $vg
+
+# Check conversion of cached LV works as thin-pool
+lvcreate -L10 -n $lv $vg
+lvcreate -L10 -n $lv1 $vg
+lvcreate -H -L10 $vg/$lv
+
+# Stack of cache over cache is unsupported ATM
+fail lvconvert --yes --cachepool $vg/$lv
+
+# Thin-pool cannot use cached metaddata LV  (meta should be on FAST device)
+fail lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv
+
+# Thin-pool CAN use cached data LV
+lvconvert --yes --thinpool $vg/$lv
+
 vgremove -f $vg


