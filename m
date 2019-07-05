From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 5 Jul 2019 19:26:36 -0400
Subject: stable-2.02 - tests: fsadm-crypt.sh update mkfs parameter
Message-ID: <201907052326.x65NQaW9009779@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cff9bff0afc21d9593dd6585bbd375384fdf47be
Commit:        cff9bff0afc21d9593dd6585bbd375384fdf47be
Parent:        143aca25daa2303a9494bace28262e64bd77698d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 14:46:01 2019 -0500
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jul 6 01:24:28 2019 +0200

tests: fsadm-crypt.sh update mkfs parameter

mkfs.xfs was rejecting previously working value
---
 test/shell/fsadm-crypt.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 68fed95..9377e89 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -268,7 +268,7 @@ test_ext3_small_shrink() {
 }
 
 test_xfs_resize() {
-	mkfs.xfs -l internal,size=1000b -f "$3"
+	mkfs.xfs -l internal,size=1536b -f "$3"
 
 	fsadm --lvresize resize $1 30M
 	# Fails - not enough space for 4M fs
@@ -283,7 +283,7 @@ test_xfs_resize() {
 }
 
 test_xfs_small_shrink() {
-	mkfs.xfs -l internal,size=1000b -f "$3"
+	mkfs.xfs -l internal,size=1536b -f "$3"
 
 	not lvresize -L-1 -r $1
 	fscheck_xfs "$3"
@@ -347,7 +347,7 @@ test_ext3_inactive() {
 
 test_xfs_inactive() {
 	crypt_open "$2" $PWD2 "$4"
-	mkfs.xfs -l internal,size=1000b -f "$3"
+	mkfs.xfs -l internal,size=1536b -f "$3"
 	crypt_close "$4"
 
 	not fsadm --lvresize resize $1 30M
@@ -428,7 +428,7 @@ test_ext3_plain() {
 }
 
 test_xfs_plain() {
-	mkfs.xfs -l internal,size=1000b -f "$3"
+	mkfs.xfs -l internal,size=1536b -f "$3"
 
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M -r $1
@@ -494,7 +494,7 @@ test_ext3_detached() {
 }
 
 test_xfs_detached() {
-	mkfs.xfs -l internal,size=1000b -f "$3"
+	mkfs.xfs -l internal,size=1536b -f "$3"
 
 	not fsadm --lvresize resize $1 30M
 	not lvresize -L+10M -r $1


