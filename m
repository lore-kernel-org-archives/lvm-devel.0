From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Jan 2020 09:22:34 -0500
Subject: stable-2.02 - tests: writeerror_dev
Message-ID: <62498.120012009223000174@us-mta-430.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b41118b9c8fed755eaabb1b0833f2518ddf1c36
Commit:        9b41118b9c8fed755eaabb1b0833f2518ddf1c36
Parent:        440ced192a5ae6d5fa7c191981abcdf59926e90b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 20 13:15:46 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 20 15:21:38 2020 +0100

tests: writeerror_dev

Intruduce aux function for easy simulation of disk areas,
that are 'normally' readable, but will fail on write.
---
 test/lib/aux.sh | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ec0699f..b90063d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -564,6 +564,8 @@ teardown() {
 	echo -n "## teardown..."
 	unset LVM_LOG_FILE_EPOCH
 
+	test ! -f ERR_DEV || should dmsetup remove $(cat ERR_DEV_NAME)
+
 	if test -f TESTNAME ; then
 
 	if test ! -f SKIP_THIS_TEST ; then
@@ -985,6 +987,8 @@ common_dev_() {
 		case "$tgtype" in
 		delay)
 			echo "$from $len delay $pvdev $(( pos + offset )) $read_ms $pvdev $(( pos + offset )) $write_ms" ;;
+		writeerror)
+			echo "$from $len delay $pvdev $(( pos + offset )) 0 $(cat ERR_DEV) 0 0" ;;
 		error|zero)
 			echo "$from $len $tgtype" ;;
 		esac
@@ -1125,6 +1129,24 @@ error_dev() {
 }
 
 #
+# Convert device to device with write errors but normal reads.
+# For this 'delay' dev is used and reroutes 'reads' back to original device
+# and for writes it will use extra new TEST-errordev (huge error target)
+# i.e.  writeerror_dev "$dev1" 8:32
+writeerror_dev() {
+	local name=${PREFIX}-errordev
+
+	if test ! -e ERR_DEV; then
+		dmsetup create -u "TEST-$name" "$name" --table "0 4611686018427387904 error"
+		# Take major:minor of our error device
+		echo "$name" > ERR_DEV_NAME
+		dmsetup info -c  --noheadings -o major,minor "$name" > ERR_DEV
+	fi
+
+	common_dev_ writeerror "$@"
+}
+
+#
 # Convert existing device to a device with zero segments
 # Takes the list of pairs of zero segment from:len
 # Combination with error or delay is unsupported



