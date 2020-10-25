From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Oct 2020 19:37:00 +0000 (GMT)
Subject: stable-2.02 - fsadm: better check for getsize64 support
Message-ID: <20201025193700.4B7183861845@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4dcb35cb03021f1ae450078f3e8bf55c40751a56
Commit:        4dcb35cb03021f1ae450078f3e8bf55c40751a56
Parent:        66ea26131ba1f6206eafe49c9c581a02fab00395
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 20:19:31 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 20:19:31 2020 +0100

fsadm: better check for getsize64 support

Older blockdev tool return failure error code with --help,
and since now the tool abort on command failure, lets
detect missing --getsize64 support directly by running
command and check if it returns something usable.

It's likely very hard to have the system with
such old blockdev tool and newer lvm2 compiled.
---
 scripts/fsadm.sh | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 5bba5ff40..e20401be1 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -377,14 +377,11 @@ detect_mounted() {
 # get the full size of device in bytes
 detect_device_size() {
 	# check if blockdev supports getsize64
-	"$BLOCKDEV" --help 2>&1 | "$GREP" getsize64 >"$NULL"
-	if test $? -eq 0; then
-		DEVSIZE=$("$BLOCKDEV" --getsize64 "$VOLUME")
+	DEVSIZE=$("$BLOCKDEV" --getsize64 "$VOLUME" 2>"$NULL" || true)
+	if test -n "$DEVSIZE" ; then
+		DEVSIZE=$("$BLOCKDEV" --getsize "$VOLUME" || true)
 		test -n "$DEVSIZE" || error "Cannot read size of device \"$VOLUME\"."
-	else
-		DEVSIZE=$("$BLOCKDEV" --getsize "$VOLUME")
-		test -n "$DEVSIZE" || error "Cannot read size of device \"$VOLUME\"."
-		SSSIZE=$("$BLOCKDEV" --getss "$VOLUME")
+		SSSIZE=$("$BLOCKDEV" --getss "$VOLUME" || true)
 		test -n "$SSSIZE" || error "Cannot read sector size of device \"$VOLUME\"."
 		DEVSIZE=$(("$DEVSIZE" * "$SSSIZE"))
 	fi


