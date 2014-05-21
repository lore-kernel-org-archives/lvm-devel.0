From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 09:43:35 +0000 (UTC)
Subject: master - tests: notify lvmetad after udev transation
Message-ID: <20140521094335.1E339603A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cbdb8fa58925f64cf1da9de9ec00e878fe83c2d0
Commit:        cbdb8fa58925f64cf1da9de9ec00e878fe83c2d0
Parent:        97c91b020e234d40a43ccde9edc2e8f9a4c3bb2b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 11:40:34 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 11:43:24 2014 +0200

tests: notify lvmetad after udev transation

Delay udev notification after the point udev transaction
is finished - since otherwise some device may still
be found missing until udev transaction is finished.
---
 test/lib/aux.sh |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0832f24..400a49d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -413,9 +413,12 @@ disable_dev() {
 		min=$(($(stat -L --printf=0x%T "$dev")))
 		echo "Disabling device $dev ($maj:$min)"
 		dmsetup remove -f "$dev" 2>/dev/null || true
-		notify_lvmetad --major "$maj" --minor "$min"
 	done
 	finish_udev_transaction
+
+	for dev in "$@"; do
+		notify_lvmetad --major "$maj" --minor "$min"
+	done
 }
 
 enable_dev() {
@@ -429,9 +432,12 @@ enable_dev() {
 			dmsetup load "$name" "$name.table"
 		# using device name (since device path does not exists yes with udev)
 		dmsetup resume "$name"
-		notify_lvmetad "$dev"
 	done
 	finish_udev_transaction
+
+	for dev in "$@"; do
+		notify_lvmetad "$dev"
+	done
 }
 
 #
@@ -477,8 +483,8 @@ error_dev() {
 	fi
 	# using device name (since device path does not exists yet with udev)
 	dmsetup resume "$name"
-	notify_lvmetad "$dev"
 	finish_udev_transaction
+	notify_lvmetad "$dev"
 }
 
 backup_dev() {


