From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:37:35 -0400
Subject: master - tests: improve loop
Message-ID: <201707101237.v6ACbZfh023449@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4ed3f1bee3fca0b27ace8bfe593aa6aee15a3a19
Commit:        4ed3f1bee3fca0b27ace8bfe593aa6aee15a3a19
Parent:        e68d986cd5374edc5b6884fc1c3dcc197c954b46
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 10:10:36 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: improve loop

---
 test/shell/lvconvert-raid-takeover.sh |   24 +++++++++++-------------
 1 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index c9b45e9..2fb0e5a 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -28,19 +28,17 @@ detect_error_leak_()
 {
 	local err
 
-	dmsetup info -c -o name --noheadings | tee out
-	if grep $vg out ; then
-		for i in $(grep $vg out) ; do
-			if dmsetup table $i | grep "error "; then
-				err="$err $i"
-			fi
-		done
-		test -z "$err" || {
-			dmsetup table | grep $vg
-			dmsetup ls --tree
-			die "Device(s) $err should not be here."
-		}
-	fi
+	for i in $(dmsetup info -c -o name --noheadings) ; do
+		case "$i" in
+		"$vg*") (dmsetup table "$i" | grep "error ") && err="$err $i" ;;
+		esac
+	done
+
+	test -z "$err" || {
+		dmsetup table | grep $vg
+		dmsetup ls --tree
+		die "Device(s) $err should not be here."
+	}
 }
 
 function _lvcreate


