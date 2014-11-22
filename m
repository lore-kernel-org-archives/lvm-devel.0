From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 17:52:06 +0000 (UTC)
Subject: master - tests: use old virt snaps in the test
Message-ID: <20141122175206.9AFDC601B9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4607cbcb0d785a8b112c32ee2487c5f9ee59cdc4
Commit:        4607cbcb0d785a8b112c32ee2487c5f9ee59cdc4
Parent:        fc935495c813b7577ac8237459a2cc65ea291ac2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 22 18:14:45 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 22 18:51:02 2014 +0100

tests: use old virt snaps in the test

Don't use thin with its thin requirements for the test.
---
 test/shell/lvcreate-large-raid.sh   |   10 +++++-----
 test/shell/lvcreate-large-raid10.sh |   10 +++++-----
 test/shell/lvcreate-large.sh        |    2 +-
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 286b068..182b267 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -20,11 +20,11 @@ aux have_raid 1 3 0 || skip
 
 aux prepare_vg 5
 
-lvcreate -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 
 #FIXME this should be 1024T
 #check lv_field $vg/$lv size "128.00m"
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 3c6ddcf..de1cc02 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -20,11 +20,11 @@ aux have_raid 1 3 0 || skip
 
 aux prepare_vg 5
 
-lvcreate -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
-lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv1 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv2 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv3 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv4 $vg --virtualsize 256T
+lvcreate --type snapshot -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 
 aux extend_filter_LVMTEST
 
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index 24fccb1..29bdd33 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -18,7 +18,7 @@ aux can_use_16T || skip
 
 aux prepare_vg 4
 
-lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
+lvcreate --type snapshot -s -l 100%FREE -n $lv $vg --virtualsize 1024T
 
 #FIXME this should be 1024T
 #check lv_field $vg/$lv size "128.00m"


