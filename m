From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:35:13 -0400
Subject: master - tests: test striped COW LV
Message-ID: <201803172235.w2HMZDtQ011319@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e7b00a3b9cecd43c7a339ee4ae5fb174179d3dd
Commit:        9e7b00a3b9cecd43c7a339ee4ae5fb174179d3dd
Parent:        c82ab92d04acec41f9a3550e2ee7970d3937566e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 14:26:15 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

tests: test striped COW LV

---
 test/shell/lvconvert-snapshot.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index f751c30..ecf6b3c 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_pvs 1
+aux prepare_pvs 2
 get_devs
 
 vgcreate -s 1k "$vg" "${DEVICES[@]}"
@@ -30,6 +30,7 @@ lvcreate -L1 -s -n $lv3 $vg/$lv2
 lvcreate -l1 -n $lv4 $vg
 lvcreate -L1 -n $lv5 $vg
 lvcreate -L1 -n $lv6 $vg
+lvcreate -L1 -i2 -n $lv7 $vg
 
 not lvconvert -s $vg/$lv1 $vg/not_exist
 
@@ -60,4 +61,7 @@ grep "smaller" err
 lvconvert --yes -s $vg/$lv2 $vg/$lv5
 lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv6
 
+# Striped LV is also supported
+lvconvert --yes --snapshot $vg/$lv2 $vg/$lv7
+
 vgremove -f $vg


