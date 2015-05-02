From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  2 May 2015 22:43:53 +0000 (UTC)
Subject: master - tests: use 800ms write delay
Message-ID: <20150502224353.98A8460CFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31f1375d23fcc23a35e67bd8780d1ba82db4be56
Commit:        31f1375d23fcc23a35e67bd8780d1ba82db4be56
Parent:        4f6660db7df704d8ba5d855b369b6dfdff4eed1c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 2 22:03:19 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 3 00:43:15 2015 +0200

tests: use 800ms write delay

Since this value magically worked for  pvmove-abort*
use it here as well.

Also prepate_lvmetad has better kill&reload mechanism.
---
 test/shell/pvmove-restart.sh |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 011e6ee..db87d52 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -21,7 +21,7 @@ vgextend $vg "$dev3"
 
 # Slowdown writes
 # (FIXME: generates interesting race when not used)
-aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
+aux delay_dev "$dev3" 0 800 $(get first_extent_sector "$dev3"):
 
 for mode in "--atomic" ""
 do
@@ -44,7 +44,7 @@ wait
 
 # First take down $lv1 then it's pvmove0
 j=0
-for i in $lv1 pvmove0 pvmove0_mimage_1 pvmove0_mimage_0 ; do
+for i in $lv1 pvmove0 pvmove0_mimage_0 pvmove0_mimage_1 ; do
 	while dmsetup status "$vg-$i"; do
 		dmsetup remove "$vg-$i" || {
 			j=$(($j + 1))
@@ -76,8 +76,7 @@ if test -e LOCAL_CLVMD ; then
 fi
 
 if test -e LOCAL_LVMETAD ; then
-	# Restart lvmetad
-	kill $(< LOCAL_LVMETAD)
+	# Restart lvmetad (kill is built-in)
 	aux prepare_lvmetad
 fi
 
@@ -92,8 +91,6 @@ dmsetup table
 
 pvmove --abort
 
-pvmove --abort
-
 lvs -a -o+devices $vg
 
 lvremove -ff $vg


