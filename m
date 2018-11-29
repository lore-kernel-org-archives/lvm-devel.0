From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:13:08 -0500
Subject: master - tests: use select with dmsetup
Message-ID: <201811292213.wATMD840016664@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f87ba68d409dc8da02aa8d9c58798eb5f2d4477
Commit:        5f87ba68d409dc8da02aa8d9c58798eb5f2d4477
Parent:        74731a5277eb02347902801c4ec5b087deecc580
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 23 20:08:08 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:10:09 2018 +0100

tests: use select with dmsetup

Use 'dmsetup -S' to greatly simplify such loops.
---
 .../lvconvert-raid-takeover-linear_to_raid4.sh     |   15 ++-------------
 .../lvconvert-raid-takeover-raid4_to_linear.sh     |   15 ++-------------
 test/shell/lvconvert-raid-takeover.sh              |   15 ++-------------
 3 files changed, 6 insertions(+), 39 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh b/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh
index adaf8d3..6b28cad 100644
--- a/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh
+++ b/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh
@@ -23,19 +23,8 @@ aux prepare_vg 4 32
 # FIXME: lvconvert leaks  'error' devices
 detect_error_leak_()
 {
-	local err=""
-
-	for i in $(dmsetup info -c -o name --noheadings) ; do
-		case "$i" in
-		"$vg*") (dmsetup table "$i" | grep "error ") && err="$err $i" ;;
-		esac
-	done
-
-	test -z "$err" || {
-		dmsetup table | grep $vg
-		dmsetup ls --tree
-		die "Device(s) $err should not be here."
-	}
+	dmsetup table -S "name=~^$vg-" | not grep "error" || \
+		die "Device(s) with error target should not be here."
 }
 
 # Create linear LV
diff --git a/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh b/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh
index a581846..6201af4 100644
--- a/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh
+++ b/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh
@@ -23,19 +23,8 @@ aux prepare_vg 4 32
 # FIXME: lvconvert leaks  'error' devices
 detect_error_leak_()
 {
-	local err=""
-
-	for i in $(dmsetup info -c -o name --noheadings) ; do
-		case "$i" in
-		"$vg*") (dmsetup table "$i" | grep "error ") && err="$err $i" ;;
-		esac
-	done
-
-	test -z "$err" || {
-		dmsetup table | grep $vg
-		dmsetup ls --tree
-		die "Device(s) $err should not be here."
-	}
+	dmsetup table -S "name=~^$vg-" | not grep "error" || \
+		die "Device(s) with error target should not be here."
 }
 
 # Create 3-way striped raid4 (4 legs total)
diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index d22c11b..b57cbe9 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -26,19 +26,8 @@ aux prepare_vg 8
 # FIXME: lvconvert leaks  'error' devices
 detect_error_leak_()
 {
-	local err=""
-
-	for i in $(dmsetup info -c -o name --noheadings) ; do
-		case "$i" in
-		"$vg*") (dmsetup table "$i" | grep "error ") && err="$err $i" ;;
-		esac
-	done
-
-	test -z "$err" || {
-		dmsetup table | grep $vg
-		dmsetup ls --tree
-		die "Device(s) $err should not be here."
-	}
+	dmsetup table -S "name=~^$vg-" | not grep "error" || \
+		die "Device(s) with error target should not be here."
 }
 
 function _lvcreate


