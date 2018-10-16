From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Oct 2018 15:57:12 -0400
Subject: master - tests: timing without /usr/bin/time
Message-ID: <201810161957.w9GJvC2N002364@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4db228b9079386b9e24e0389a080f86ac3008e69
Commit:        4db228b9079386b9e24e0389a080f86ac3008e69
Parent:        c15ac326cc29b5d91e726647d584c1b563c8c294
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 20:03:21 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 16 21:56:00 2018 +0200

tests: timing without /usr/bin/time

Use just 'date' so the 'time' package doesn't need to be installed
just for this purpose.
---
 test/shell/thin-many-dmeventd.sh |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/test/shell/thin-many-dmeventd.sh b/test/shell/thin-many-dmeventd.sh
index f73b516..a40c75a 100644
--- a/test/shell/thin-many-dmeventd.sh
+++ b/test/shell/thin-many-dmeventd.sh
@@ -54,10 +54,15 @@ sleep 9
 # new thin-pool registration.
 for i in $(seq 11 15)
 do
-	/usr/bin/time -o TM -f %e lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
-        read -r t < TM
-        test ${t%%.*} -lt 8 || die "Creation of thin pool took more then 8 second! ($t seconds)"
-        # Fill thin-pool to some capacity >50%
+	#/usr/bin/time -o TM -f %e lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
+	#read -r t < TM
+	#test ${t%%.*} -lt 8 || die "Creation of thin pool took more then 8 second! ($t seconds)"
+	START=$(date +%s)
+	lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
+	END=$(date +%s)
+	DIFF=$(( END - START ))
+	test "$DIFF" -lt 8 || die "Creation of thin pool took more then 8 second! ($DIFF seconds)"
+	# Fill thin-pool to some capacity >50%
 	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 conv=fdatasync
 done
 


