From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 17 Sep 2019 07:18:50 -0400
Subject: master - tests: pool conversion
Message-ID: <201909171118.x8HBIo3u025596@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee6b9b78ece389813895e3ecf79e5bbcbafee871
Commit:        ee6b9b78ece389813895e3ecf79e5bbcbafee871
Parent:        7612c21f5511c58bac81fc46e304bd9f4cd2cd75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 17 11:27:13 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 17 13:13:49 2019 +0200

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


