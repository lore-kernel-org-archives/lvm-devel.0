From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 May 2016 08:19:41 +0000 (UTC)
Subject: master - coverity: blkdeactivate: separate format and args for printf and declare and assign separately to avoid masking return values
Message-ID: <20160531081941.A1F4460B3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b3a4a95956fe467a2c5fe1cce3925e67366d4fe
Commit:        5b3a4a95956fe467a2c5fe1cce3925e67366d4fe
Parent:        02d67848eb994c19c6ff2050196585fb763c83cb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 31 09:39:06 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 31 09:39:06 2016 +0200

coverity: blkdeactivate: separate format and args for printf and declare and assign separately to avoid masking return values

---
 scripts/blkdeactivate.sh.in |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 39b0f2c..2a48b3e 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -147,7 +147,7 @@ device_umount_one() {
 
 	if test -z "${SKIP_UMOUNT_LIST["$mnt"]}" -a "$DO_UMOUNT" -eq "1"; then
 		echo -n "  [UMOUNT]: unmounting $name ($kname) mounted on $mnt... "
-		if eval $UMOUNT $UMOUNT_OPTS "$(printf $mnt)" $OUT $ERR; then
+		if eval $UMOUNT $UMOUNT_OPTS "$(printf "%s" "$mnt")" $OUT $ERR; then
 			echo "done"
 		else
 			echo "skipping"
@@ -193,7 +193,8 @@ deactivate_holders () {
 }
 
 deactivate_dm () {
-	local name=$(printf $name)
+	local name
+	name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/mapper/$name" || return 0
 	test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
 
@@ -262,7 +263,8 @@ deactivate_lvm () {
 }
 
 deactivate_md () {
-	local name=$(printf $name)
+	local name
+	name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/$name" || return 0
 	test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
 


