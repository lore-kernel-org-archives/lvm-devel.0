From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:30 -0500
Subject: master - tests: skip unneeded status check
Message-ID: <18266.119111116462601343@us-mta-292.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba313ac84a7bc27ce69d225dec1bfc80bcb20988
Commit:        ba313ac84a7bc27ce69d225dec1bfc80bcb20988
Parent:        1cc13335998558b84750fc2ba25c8b9f7b053746
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 13:12:31 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:25 2019 +0100

tests: skip unneeded status check

If 'remove' was succesful - we can break loop immediatelly.
---
 test/shell/pvmove-restart.sh |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 115ce14..1669187 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -51,12 +51,11 @@ wait
 # First take down $lv1 then it's pvmove0
 j=0
 for i in $lv1 pvmove0 pvmove0_mimage_0 pvmove0_mimage_1 ; do
-	while dmsetup status "$vg-$i"; do
-		dmsetup remove "$vg-$i" || {
-			j=$(( j + 1 ))
-			test $j -le 100 || die "Cannot take down devices."
-			sleep .1;
-		}
+	while dmsetup status "$vg-$i" ; do
+		dmsetup remove "$vg-$i" && break
+		j=$(( j + 1 ))
+		test $j -le 100 || die "Cannot take down devices."
+		sleep .1;
 	done
 done
 dmsetup table | grep $PREFIX



