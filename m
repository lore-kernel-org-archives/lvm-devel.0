From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:29:36 -0400
Subject: master - tests: get.sh declare and assign separately
Message-ID: <201706292029.v5TKTajc026988@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d90c7fffc3c7e5fa0a02d829909c204fa0d6bfb
Commit:        3d90c7fffc3c7e5fa0a02d829909c204fa0d6bfb
Parent:        834b82b0cd8dfb4867b7eb65e9608e96cf2ba08e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 10:26:28 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: get.sh declare and assign separately

Declare and assign separately to avoid masking return values.

Also comment-out currently unused  orig variable.
---
 test/lib/get.sh |   27 ++++++++++++++++++---------
 1 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/test/lib/get.sh b/test/lib/get.sh
index 0608bc9..88144c1 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -28,32 +28,38 @@ trim_() {
 }
 
 pv_field() {
-	local r=$(pvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	local r
+	r=$(pvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
 	trim_ "$r"
 }
 
 vg_field() {
-	local r=$(vgs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	local r
+	r=$(vgs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
 	trim_ "$r"
 }
 
 lv_field() {
-	local r=$(lvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	local r
+	r=$(lvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
 	trim_ "$r"
 }
 
 lv_first_seg_field() {
-	local r=$(lvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1" | head -1)
+	local r
+	r=$(lvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1" | head -1)
 	trim_ "$r"
 }
 
 lvh_field() {
-	local r=$(lvs -H --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	local r
+	r=$(lvs -H --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
 	trim_ "$r"
 }
 
 lva_field() {
-	local r=$(lvs -a --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	local r
+	r=$(lvs -a --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
 	trim_ "$r"
 }
 
@@ -67,8 +73,10 @@ lv_field_lv_() {
 
 lv_tree_devices_() {
 	local lv="$1/$2"
-	local type=$(lv_field "$lv" segtype -a --unbuffered | head -n 1)
-	local orig=$(lv_field_lv_ "$lv" origin)
+	local type
+	type=$(lv_field "$lv" segtype -a --unbuffered | head -n 1)
+	#local orig
+	#orig=$(lv_field_lv_ "$lv" origin)
 	# FIXME: should we count in also origins ?
 	#test -z "$orig" || lv_tree_devices_ $1 $orig
 	case "$type" in
@@ -76,7 +84,8 @@ lv_tree_devices_() {
 		lv_devices "$lv"
 		;;
 	mirror|raid*)
-		local log=$(lv_field_lv_ "$lv" mirror_log)
+		local log
+		log=$(lv_field_lv_ "$lv" mirror_log)
 		test -z "$log" || lv_tree_devices_ "$1" "$log"
 		for i in $(lv_devices "$lv")
 			do lv_tree_devices_ "$1" "$i"; done


