From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:23 -0400
Subject: master - fsadm: make if statement more clear
Message-ID: <201706292025.v5TKPNmV025656@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=95ca7cfdffc5052e360d76c787a601e9aa626bd1
Commit:        95ca7cfdffc5052e360d76c787a601e9aa626bd1
Parent:        c6a5964ce96e869028394fb31060d2e2c44c2ab1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 16:13:29 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

fsadm: make if statement more clear

---
 scripts/fsadm.sh |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 0db24ad..e08862a 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -111,7 +111,7 @@ tool_usage() {
 }
 
 verbose() {
-	test -n "$VERB" && echo "$TOOL:" "$@" || true
+	test -z "$VERB" || echo "$TOOL:" "$@"
 }
 
 # Support multi-line error messages
@@ -423,7 +423,9 @@ try_umount() {
 }
 
 validate_parsing() {
-	test -n "$BLOCKSIZE" && test -n "$BLOCKCOUNT" || error "Cannot parse $1 output."
+	if test -z "$BLOCKSIZE" || test -z "$BLOCKCOUNT" ; then
+		error "Cannot parse $1 output."
+	fi
 }
 ####################################
 # Resize ext2/ext3/ext4 filesystem
@@ -445,7 +447,7 @@ resize_ext() {
 	decode_size "$1" "$BLOCKSIZE"
 	FSFORCE=$FORCE
 
-	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
+	if test "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" || test "$EXTOFF" -eq 1 ; then
 		test "$IS_MOUNTED" -eq 1 && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
 		REMOUNT=$MOUNTED
 		if test -n "$MOUNTED" ; then


