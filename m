From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Feb 2017 14:41:15 +0000 (UTC)
Subject: master - tests: support zero_dev
Message-ID: <20170222144115.136AD60E67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa72caca5a19c67caffefc3f967af630b93ee2f0
Commit:        aa72caca5a19c67caffefc3f967af630b93ee2f0
Parent:        f44e69f9fc2dc56d1fec02f6303b2a1101cdf47e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 22 15:16:20 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 22 15:40:59 2017 +0100

tests: support zero_dev

When the test would need to try to write some large amount of data
we can give it 'zero' segments - for obvious reason such written data
can't be verified but in some test cases it doesn't really matter.

Usage follows  'error_dev' style.

For now test suite is not supporting any combination of
error/delay/zero segments so only 1 type could be used per PV.
---
 test/lib/aux.sh |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 5108a52..9779358 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -866,7 +866,7 @@ common_dev_() {
 		else
 			test -z "${offsets[@]}" && offsets="0:"
 		fi ;;
-	error)  offsets=${@:3}
+	error|zero)  offsets=${@:3}
 		test -z "${offsets[@]}" && offsets="0:" ;;
 	esac
 
@@ -893,8 +893,8 @@ common_dev_() {
 		case "$tgtype" in
 		delay)
 			echo "$from $len delay $pvdev $(($pos + $offset)) $read_ms $pvdev $(($pos + $offset)) $write_ms" ;;
-		error)
-			echo "$from $len error" ;;
+		error|zero)
+			echo "$from $len $tgtype" ;;
 		esac
 		pos=$(($pos + $len))
 	done > "$name.devtable"
@@ -1013,12 +1013,23 @@ restore_from_devtable() {
 #
 # Convert device to device with errors
 # Takes the list of pairs of error segment from:len
-# Original device table is replace with multiple lines
+# Combination with zero or delay is unsupported
+# Original device table is replaced with multiple lines
 # i.e.  error_dev "$dev1" 8:32 96:8
 error_dev() {
 	common_dev_ error "$@"
 }
 
+#
+# Convert existing device to a device with zero segments
+# Takes the list of pairs of zero segment from:len
+# Combination with error or delay is unsupported
+# Original device table is replaced with multiple lines
+# i.e.  zero_dev "$dev1" 8:32 96:8
+zero_dev() {
+	common_dev_ zero "$@"
+}
+
 backup_dev() {
 	local dev
 


