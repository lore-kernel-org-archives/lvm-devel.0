From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Dec 2012 17:02:21 +0000 (UTC)
Subject: master - tests: add error_dev aux
Message-ID: <20121202170221.BC51FA0D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5e2f08cf9134ebf2d377ad050a707c0268d1444
Commit:        c5e2f08cf9134ebf2d377ad050a707c0268d1444
Parent:        0dc6ba8309300b576f56e28dc71fba760b3e52df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 1 17:09:18 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 2 17:55:49 2012 +0100

tests: add error_dev aux

Aux function to replace PV with specifically damaged device.
Usage:

   aux error_dev "$dev1" 8:32 96:8

Replaces from 8 sector 32 error 512b sectors
and from 96 sector next 8 sectors will fail on rw.
Rest of device is preserved.

For testing:
dd if="$dev1" of=x bs=512 count=104 conv=sync,noerror iflag=direct
---
 test/lib/aux.sh |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e3dfdd9..d500b37 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -371,6 +371,53 @@ enable_dev() {
 	finish_udev_transaction
 }
 
+#
+# Convert device to device with errors
+# Takes the list of pairs of error segment from:len
+# Original device table is replace with multiple lines
+# i.e.  error_dev "$dev1" 8:32 96:8
+error_dev() {
+	local dev=$1
+	local name=$(echo "$dev" | sed -e 's,.*/,,')
+	local fromlen
+	local pos
+	local size
+	local type
+	local pvdev
+	local offset
+
+	read pos size type pvdev offset < $name.table
+
+	shift
+	rm -f $name.errtable
+	for fromlen in "$@"; do
+		from=${fromlen%%:*}
+		len=${fromlen##*:}
+		diff=$(($from - $pos))
+		if test $diff -gt 0 ; then
+			echo "$pos $diff $type $pvdev $(($pos + $offset))" >>$name.errtable
+			pos=$(($pos + $diff))
+		elif test $diff -lt 0 ; then
+			die "Position error"
+		fi
+		echo "$from $len error" >>$name.errtable
+		pos=$(($pos + $len))
+	done
+	diff=$(($size - $pos))
+	test $diff -gt 0 && echo "$pos $diff $type $pvdev $(($pos + $offset))" >>$name.errtable
+
+	init_udev_transaction
+	if dmsetup table $name ; then
+		dmsetup load "$name" "$name.errtable"
+	else
+		dmsetup create -u "TEST-$name" "$name" "$name.errtable"
+	fi
+	# using device name (since device path does not exists yet with udev)
+	notify_lvmetad "$dev"
+	dmsetup resume "$name"
+	finish_udev_transaction
+}
+
 backup_dev() {
 	local dev
 


