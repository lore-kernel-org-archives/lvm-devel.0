From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:33:09 +0000 (UTC)
Subject: master - tests: explicitely use old snapshots
Message-ID: <20141030233309.9EAE760DD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e7c130430a2b232bdf062f8fb3064899b176986b
Commit:        e7c130430a2b232bdf062f8fb3064899b176986b
Parent:        8926230f6e7ac46c5bbed70d3e8efbc43e5b444d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 00:28:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 31 00:28:25 2014 +0100

tests: explicitely use old snapshots

---
 test/shell/snapshot-usage.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index c29d310..a3dd7a6 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -111,7 +111,7 @@ lvs -a $vg1
 lvremove -f $vg1
 
 # Test virtual snapshot over /dev/zero
-lvcreate -V50 -L10 -n $lv1 -s $vg1
+lvcreate --type snapshot -V50 -L10 -n $lv1 -s $vg1
 CHECK_ACTIVE="active"
 test ! -e LOCAL_CLVMD || CHECK_ACTIVE="local exclusive"
 check lv_field $vg1/$lv1 lv_active "$CHECK_ACTIVE"
@@ -228,7 +228,7 @@ lvcreate -s -l100%FREE -n $lv2 $vg1/$lv1
 check lv_field $vg1/$lv2 size "7.50p"
 lvremove -ff $vg1
 
-lvcreate -V15E -l1 -n $lv1 -s $vg1
+lvcreate --type snapshot -V15E -l1 -n $lv1 -s $vg1
 check lv_field $vg1/$lv1 origin_size "15.00e"
 
 vgremove -ff $vg1


