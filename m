From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 May 2017 09:13:44 -0400
Subject: master - fsadm: always detect mounted fs with extX
Message-ID: <201705221313.v4MDDiVq030329@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b7ac2bfb3461073486a7b296a76ef26b0d5d733
Commit:        2b7ac2bfb3461073486a7b296a76ef26b0d5d733
Parent:        a29e7843b1b9fe10af0e5bef8304c65a176e394f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 22 14:39:10 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 22 15:10:16 2017 +0200

fsadm: always detect mounted fs with extX

Since we add more validation to 'detect_mounted' function make sure
we always use it even with 'resize' action, so numerous validations
are not skipped.
---
 scripts/fsadm.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 534aac1..831b3ca 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -318,6 +318,9 @@ validate_parsing() {
 # - unmounted for downsize
 ####################################
 resize_ext() {
+	local IS_MOUNTED=0
+	detect_mounted && IS_MOUNTED=1
+
 	verbose "Parsing $TUNE_EXT -l \"$VOLUME\""
 	for i in $(LC_ALL=C "$TUNE_EXT" -l "$VOLUME"); do
 		case "$i" in
@@ -330,7 +333,7 @@ resize_ext() {
 	FSFORCE=$FORCE
 
 	if [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]; then
-		detect_mounted && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
+		test $IS_MOUNTED -eq 1 && verbose "$RESIZE_EXT needs unmounted filesystem" && try_umount
 		REMOUNT=$MOUNTED
 		if test -n "$MOUNTED" ; then
 			# Forced fsck -f for umounted extX filesystem.


