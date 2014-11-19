From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Nov 2014 22:25:27 +0000 (UTC)
Subject: master - tests: use snapshot targets
Message-ID: <20141119222527.5387F60392@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d8c1b66241bea0b6b67bde7ebd04b9db10d3208
Commit:        8d8c1b66241bea0b6b67bde7ebd04b9db10d3208
Parent:        c75548300d63452b4fa615d71cb40cb10382aa33
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 19 23:24:18 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 19 23:24:18 2014 +0100

tests: use snapshot targets

---
 test/shell/lvconvert-snapshot.sh |    2 +-
 test/shell/snapshot-usage.sh     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index 3d81573..55fcb1a 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -18,7 +18,7 @@ aux prepare_pvs 1
 
 vgcreate -s 1k $vg $(cat DEVICES)
 
-lvcreate -V50 -L1 -n $lv1 -s $vg
+lvcreate --type snapshot -V50 -L1 -n $lv1 -s $vg
 
 lvcreate -aey -L1 -n $lv2 $vg
 lvcreate -L1 -s -n $lv3 $vg/$lv2
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index a3dd7a6..74f54de 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -78,7 +78,7 @@ lvremove -f $vg
 
 
 # Automatically activates exclusively in cluster
-lvcreate -s -l 100%FREE -n $lv $vg --virtualsize $TSIZE
+lvcreate --type snapshot -s -l 100%FREE -n $lv $vg --virtualsize $TSIZE
 
 aux extend_filter_LVMTEST
 aux lvmconf "activation/snapshot_autoextend_percent = 20" \


