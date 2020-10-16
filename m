From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:14 +0000 (GMT)
Subject: stable-2.02 - tests: add aux delayzero_dev support
Message-ID: <20201016191114.6EA793857824@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ac48c0655c9b0da6846dca30e1250f9a1f78f70
Commit:        5ac48c0655c9b0da6846dca30e1250f9a1f78f70
Parent:        8744d97c7b974a1ad990a0b7e61fa496a9500a52
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 13:50:05 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

tests: add aux delayzero_dev  support

Just like we have 'writeerror_dev' supporting creation of device
which 'readable' segment and segments where write will fail we
have now support for delay zero mappings.

This is useful if we want to 'fake' large writing areas where we do
not really care about the actual 'disk' content - since we test
operation logic and it doesn't matter we read and write zeroes.
With combination with 'delay' target we can create specific mappings
and avoid using large memory areas of ramdisk.
---
 test/lib/aux.sh | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7a8d054e9..3c39151ae 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -565,6 +565,7 @@ teardown() {
 	unset LVM_LOG_FILE_EPOCH
 
 	test ! -f ERR_DEV || should dmsetup remove $(cat ERR_DEV_NAME)
+	test ! -f ZERO_DEV || should dmsetup remove $(cat ZERO_DEV_NAME)
 
 	if test -f TESTNAME ; then
 
@@ -957,6 +958,11 @@ common_dev_() {
 		}
 		shift 2
 		;;
+	delayzero)
+		shift 2
+		# zero delay is just equivalent to 'zero_dev'
+		test "$read_ms" -eq 0 && test "$write_ms" -eq 0 && tgtype="zero"
+		;;
 	# error|zero target does not take read_ms & write_ms only offset list
 	esac
 
@@ -989,6 +995,8 @@ common_dev_() {
 			echo "$from $len delay $pvdev $(( pos + offset )) $read_ms $pvdev $(( pos + offset )) $write_ms" ;;
 		writeerror)
 			echo "$from $len delay $pvdev $(( pos + offset )) 0 $(cat ERR_DEV) 0 0" ;;
+		delayzero)
+			echo "$from $len delay $(cat ZERO_DEV) 0 $read_ms $(cat ZERO_DEV) 0 $write_ms" ;;
 		error|zero)
 			echo "$from $len $tgtype" ;;
 		esac
@@ -1151,6 +1159,29 @@ writeerror_dev() {
 	common_dev_ writeerror "$@"
 }
 
+#
+# Convert device to device with sections of delayed zero read and writes.
+# For this 'delay' dev will use extra new TEST-zerodev (huge zero target)
+# and reroutes reads and writes
+# i.e.  delayzero_dev "$dev1" 8:32
+delayzero_dev() {
+	local name=${PREFIX}-zerodev
+
+	if test ! -e ZERO_DEV; then
+		# delay target is used for error mapping
+		if test ! -f HAVE_DM_DELAY ; then
+			target_at_least dm-delay 1 1 0 || return 0
+			touch HAVE_DM_DELAY
+		fi
+		dmsetup create -u "TEST-$name" "$name" --table "0 4611686018427387904 zero"
+		# Take major:minor of our error device
+		echo "$name" > ZERO_DEV_NAME
+		dmsetup info -c  --noheadings -o major,minor "$name" > ZERO_DEV
+	fi
+
+	common_dev_ delayzero "$@"
+}
+
 #
 # Convert existing device to a device with zero segments
 # Takes the list of pairs of zero segment from:len


