From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Nov 2018 07:18:22 -0500
Subject: master - tests: skip part of test
Message-ID: <201811191218.wAJCIMit012474@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d2609a2324988027795a757c1b387dd2ec3214b
Commit:        6d2609a2324988027795a757c1b387dd2ec3214b
Parent:        0747a6d0de8ccbf1586d392de29f4ab3b0fa7dbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 18 22:01:27 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 18 22:03:50 2018 +0100

tests: skip part of test

On kernel 4.8 this test piece oopses machine (fc23).
---
 test/shell/lvconvert-raid.sh |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 3b7af97..6aaaf36 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -244,9 +244,16 @@ lvremove -ff $vg
 ###########################################
 aux delay_dev "$dev2" 0 100
 lvcreate --type raid1 -m 2 -aey -l 2 -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+case "$(uname -r)" in
+4.8.14*)
+echo "Skippen test that kills this kernel"
+;;
+*)
 lvconvert --yes -m 1 $vg/$lv1 "$dev3"
 lvconvert --yes -m 0 $vg/$lv1 "$dev1"
 aux enable_dev "$dev2"
+;;
+esac
 lvremove -ff $vg
 
 ###########################################


