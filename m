From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Oct 2014 08:20:37 +0000 (UTC)
Subject: master - tests: typos
Message-ID: <20141007082037.C7198602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62802ddae052e9af996a4366bdcd5a9f2ec713d1
Commit:        62802ddae052e9af996a4366bdcd5a9f2ec713d1
Parent:        236db9fc0df9784d559fbce49a9fcb5e642e6445
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 23:25:49 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 7 10:19:33 2014 +0200

tests: typos

---
 test/shell/lvcreate-cache.sh |    2 +-
 test/shell/lvcreate-thin.sh  |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 3bc8f40..17b8c09 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -66,7 +66,7 @@ check lv_field $vg/pool7 segtype "cache-pool"
 
 lvremove -f $vg
 
-# Validate ambiguos pool name is detected
+# Validate ambiguous pool name is detected
 invalid lvcreate -l 1 --type cache-pool --cachepool pool1 $vg/pool2
 invalid lvcreate -l 1 --type cache-pool --name pool3 --cachepool pool4 $vg
 invalid lvcreate -l 1 --type cache-pool --name pool6 --cachepool pool6 $vg/pool7
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 42ea635..16eb1e7 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -51,7 +51,7 @@ check vg_field $vg lv_count 0
 
 
 # Let's pretend pool is like normal LV when using --type thin-pool support --name
-# Reject ambigous thin pool names
+# Reject ambiguous thin pool names
 invalid lvcreate --type thin-pool -l1 --name pool1 $vg/pool2
 invalid lvcreate --type thin-pool -l1 --name pool3 --thinpool pool4 $vg
 invalid lvcreate --type thin-pool -l1 --name pool5 --thinpool pool6 $vg/pool7
@@ -60,7 +60,7 @@ check vg_field $vg lv_count 0
 
 lvcreate --type thin-pool -l1 --name pool1 $vg
 lvcreate --type thin-pool -l1 --name $vg/pool2
-# If the thin pool name is unambigous let it proceed
+# If the thin pool name is unambiguous let it proceed
 lvcreate --type thin-pool -l1 --name pool3 $vg/pool3
 lvcreate --type thin-pool -l1 --name pool4 --thinpool $vg/pool4
 lvcreate --type thin-pool -l1 --name pool5 --thinpool $vg/pool5 $vg/pool5


