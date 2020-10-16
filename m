From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:40 +0000 (GMT)
Subject: stable-2.02 - tests: aux better handle invalid table
Message-ID: <20201016191140.98960396EC89@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=276e22e263645138d315c1057c85233ad32f0c11
Commit:        276e22e263645138d315c1057c85233ad32f0c11
Parent:        f9327d040c4a9b525117b40adea796a8072a25c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 14:23:20 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

tests: aux better handle invalid table

In cases where internal functions like zero_dev, delay_dev pass-in
invalid parameter so resulting table can't work, resume at least
previous table line before failing out - so the cleaning process
later on is not stuck waiting on a suspended device.
---
 test/lib/aux.sh | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 75dcbc41d..8758dc01d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1117,7 +1117,13 @@ restore_from_devtable() {
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
 


