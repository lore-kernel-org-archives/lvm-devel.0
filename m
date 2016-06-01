From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  1 Jun 2016 15:42:20 +0000 (UTC)
Subject: master - tests: extend prepare_loop
Message-ID: <20160601154220.7B04960613@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d73a83e8cf508b6d97ee937a01ebd24a678dfabc
Commit:        d73a83e8cf508b6d97ee937a01ebd24a678dfabc
Parent:        d37a26b680f6c7ca9ec0bb1ce0cca189d19b525f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 1 17:25:06 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 1 17:37:52 2016 +0200

tests: extend prepare_loop

Treat args after size  as 'extra' params for losetup.
---
 test/lib/aux.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3bb469b..d51a65c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -553,6 +553,7 @@ teardown() {
 
 prepare_loop() {
 	local size=${1=32}
+	local losetup_params=${@:2}
 	local i
 	local slash
 
@@ -577,9 +578,9 @@ prepare_loop() {
 	local LOOPFILE="$PWD/test.img"
 	rm -f "$LOOPFILE"
 	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size + 1)) 2> /dev/null
-	if LOOP=$(losetup -s -f "$LOOPFILE" 2>/dev/null); then
+	if LOOP=$(losetup ${losetup_params} -s -f "$LOOPFILE" 2>/dev/null); then
 		:
-	elif LOOP=$(losetup -f) && losetup "$LOOP" "$LOOPFILE"; then
+	elif LOOP=$(losetup -f) && losetup ${losetup_params} "$LOOP" "$LOOPFILE"; then
 		# no -s support
 		:
 	else
@@ -590,7 +591,7 @@ prepare_loop() {
 				local dev="$DM_DEV_DIR/loop$slash$i"
 				! losetup "$dev" >/dev/null 2>&1 || continue
 				# got a free
-				losetup "$dev" "$LOOPFILE"
+				losetup ${losetup_params} "$dev" "$LOOPFILE"
 				LOOP=$dev
 				break
 			done


