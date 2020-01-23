From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Jan 2020 04:32:51 -0500
Subject: master - tests: writeerror_dev
Message-ID: <01436.120012304324400321@us-mta-189.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ecb77e9db31c88ed1a53e3194366e642f9b04e5a
Commit:        ecb77e9db31c88ed1a53e3194366e642f9b04e5a
Parent:        cf844941d4f0939a78a9e0d0e0ef932172e55bfb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 20 13:15:46 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 23 10:32:15 2020 +0100

tests: writeerror_dev

Intruduce aux function for easy simulation of disk areas,
that are 'normally' readable, but will fail on write.
---
 test/lib/aux.sh | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ea126de..a9d1fe4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -516,6 +516,8 @@ teardown() {
 	echo -n "## teardown..."
 	unset LVM_LOG_FILE_EPOCH
 
+	test ! -f ERR_DEV || should dmsetup remove $(cat ERR_DEV_NAME)
+
 	if test -f TESTNAME ; then
 
 	if test ! -f SKIP_THIS_TEST ; then
@@ -954,6 +956,8 @@ common_dev_() {
 		case "$tgtype" in
 		delay)
 			echo "$from $len delay $pvdev $(( pos + offset )) $read_ms $pvdev $(( pos + offset )) $write_ms" ;;
+		writeerror)
+			echo "$from $len delay $pvdev $(( pos + offset )) 0 $(cat ERR_DEV) 0 0" ;;
 		error|zero)
 			echo "$from $len $tgtype" ;;
 		esac
@@ -1082,6 +1086,29 @@ error_dev() {
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
+		# delay target is used for error mapping
+		if test ! -f HAVE_DM_DELAY ; then
+			target_at_least dm-delay 1 1 0 || return 0
+			touch HAVE_DM_DELAY
+		fi
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



