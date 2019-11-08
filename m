From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Nov 2019 09:15:15 -0500
Subject: stable-2.02 - tests: skip unneeded status check
Message-ID: <201911081415.xA8EFFSf008365@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e3e974bffa4e9842127451072eab1646ac39a1a
Commit:        0e3e974bffa4e9842127451072eab1646ac39a1a
Parent:        bbdcdc12b2240e00f6ab8ff105e954629412b234
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 13:12:31 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 8 15:12:51 2019 +0100

tests: skip unneeded status check

If 'remove' was succesful - we can break loop immediatelly.
---
 test/shell/pvmove-restart.sh |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index dcf4c37..6a5ba58 100644
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


