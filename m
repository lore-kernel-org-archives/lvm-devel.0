From: Ondrej Kozina <okozina@sourceware.org>
Date: Tue, 10 Oct 2017 09:52:03 -0400
Subject: master - test: fsadm-crypt.sh fixes
Message-ID: <201710101352.v9ADq3Mj014876@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e61313843f835284303141bd514fcbcb08fb2463
Commit:        e61313843f835284303141bd514fcbcb08fb2463
Parent:        59145715f12c65bca68d28bd7e04e660752d6760
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 10 15:45:15 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 10 15:47:04 2017 +0200

test: fsadm-crypt.sh fixes

use conservative 'luksOpen' command instead
fix reiserfs tests on plain crypt devices
---
 test/shell/fsadm-crypt.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/fsadm-crypt.sh b/test/shell/fsadm-crypt.sh
index 7f7f3a1..348b0ce 100644
--- a/test/shell/fsadm-crypt.sh
+++ b/test/shell/fsadm-crypt.sh
@@ -130,7 +130,7 @@ crypt_format() {
 # $3 name
 crypt_open() {
 	local kname=
-	echo "$2" | cryptsetup open "$1" "$3"
+	echo "$2" | cryptsetup luksOpen "$1" "$3"
 	test -L "$DM_DEV_DIR/mapper/$3" || {
 		kname=$(get_crypt_kname $3)
 		ln -s "$DM_DEV_DIR/$kname" "$3"
@@ -144,7 +144,7 @@ crypt_open() {
 # $4 header
 crypt_open_detached() {
 	local kname=
-	echo "$2" | cryptsetup open --header "$4" "$1" "$3"
+	echo "$2" | cryptsetup luksOpen --header "$4" "$1" "$3"
 	test -L "$DM_DEV_DIR/mapper/$3" || {
 		kname=$(get_crypt_kname $3)
 		ln -s "$DM_DEV_DIR/$kname" "$3"
@@ -402,8 +402,8 @@ test_reiserfs_plain() {
 	not lvreduce -L-10M -r $1
 	fscheck_reiserfs "$3"
 
-	fsadm --cryptresize resize $3 30M
-	fsadm --cryptresize resize $3 35M
+	fsadm -y --cryptresize resize $3 30M
+	fsadm -y --cryptresize resize $3 35M
 	fscheck_reiserfs "$3"
 
 	crypt_close "$4"


