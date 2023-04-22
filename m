From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 22 Apr 2023 09:26:25 +0000 (GMT)
Subject: main - aux: don't use to new dd options
Message-ID: <20230422092625.53C8B3857BB2@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0f26a135b34f212f59818ea6cc85ce83ecb28bc
Commit:        b0f26a135b34f212f59818ea6cc85ce83ecb28bc
Parent:        8bcf46a0acfa500b4fb586cba254ca3930389d3d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 21 22:01:40 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 21 22:01:40 2023 +0200

aux: don't use to new dd options

Actually  oseek comes only with rawhide's version,
just use the standard option name.
---
 test/lib/aux.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 62635ce84..d6689e3b8 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -923,7 +923,7 @@ cleanup_idm_context() {
 # TODO: add support for parametrized [OPTION] usage (Not usable ATM)
 # TODO: -bs  blocksize  (defaults 512K)
 # TODO: -count  count/length  (defaults to whole device, otherwise in BS units)
-# TODO: -seek  offset/oseek  (defaults 0, begining of zeroing area in BS unit)
+# TODO: -seek  offset/seek  (defaults 0, begining of zeroing area in BS unit)
 clear_devs() {
 	local bs=
 	local count=
@@ -968,7 +968,7 @@ corrupt_dev() {
 	test -n "${a[0]-}" || return 0
 
 	# Seek for the sequence and replace it with corruption pattern
-	echo -n "${a[1]/$2/$3}" | dd of="$1" bs=1 oseek="${a[0]}" conv=fdatasync
+	echo -n "${a[1]/$2/$3}" | dd of="$1" bs=1 seek="${a[0]}" conv=fdatasync
 }
 
 prepare_backing_dev() {

