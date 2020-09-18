From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 Sep 2020 15:31:10 +0000 (GMT)
Subject: master - tests: aux better handle invalid table
Message-ID: <20200918153110.12A71395445A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b77595ac8b69fc699c35577e6dbe1322f8c915a0
Commit:        b77595ac8b69fc699c35577e6dbe1322f8c915a0
Parent:        a4137412bf64843578fd116f443d6586a0cffbed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 14:23:20 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 14:23:20 2020 +0200

tests: aux better handle invalid table

In cases where internal functions like zero_dev, delay_dev pass-in
invalid parameter so resulting table can't work, resume at least
previous table line before failing out - so the cleaning process
later on is not stuck waiting on a suspended device.
---
 test/lib/aux.sh | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 364b80a5c..a17bf846c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1078,7 +1078,13 @@ restore_from_devtable() {
 	for dev in "$@"; do
 		local name=${dev##*/}
 		dmsetup load "$name" "$name.devtable"
-		dmsetup resume "$name"
+		if not dmsetup resume "$name" ; then
+			dmsetup clear $name
+			dmsetup resume $name
+			finish_udev_transaction
+			echo "Device $name has unusable table \"$(cat $name.devtable)\""
+			return 1
+		fi
 	done
 	finish_udev_transaction
 }


