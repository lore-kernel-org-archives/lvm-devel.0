From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Oct 2020 14:21:23 +0000 (GMT)
Subject: master - fsadm: better check for getsize64 support
Message-ID: <20201026142123.4FEC0385703B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0333841352b76ce13464b82cb1876ea82b80351
Commit:        b0333841352b76ce13464b82cb1876ea82b80351
Parent:        2183af62e56ff68e77eb29c7da9fcf2445b30eba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 20:19:31 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 13:06:52 2020 +0100

fsadm: better check for getsize64 support

Older blockdev tool return failure error code with --help,
and since now the tool abort on command failure, lets
detect missing --getsize64 support directly by running
command and check if it returns something usable.

It's likely very hard to have the system with
such old blockdev tool and newer lvm2 compiled.
---
 scripts/fsadm.sh | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 5bba5ff40..9b95d318d 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -377,16 +377,13 @@ detect_mounted() {
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
-		DEVSIZE=$(("$DEVSIZE" * "$SSSIZE"))
+		DEVSIZE=$(( $DEVSIZE * $SSSIZE ))
 	fi
 }
 


