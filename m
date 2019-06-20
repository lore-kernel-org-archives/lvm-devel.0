From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jun 2019 05:22:45 -0400
Subject: stable-2.02 - tests: check for installed time command
Message-ID: <201906200922.x5K9MjYB009017@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02a5921cdb90c15c93486ef8b8bd42486f6829b6
Commit:        02a5921cdb90c15c93486ef8b8bd42486f6829b6
Parent:        b61c89b52b524b59a515123a9d659066cc4e183e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 20 11:04:23 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 20 11:21:08 2019 +0200

tests: check for installed time command

If the /usr/bin/time command is not installed, skip test
(do not want to use shells' built-in).
---
 test/shell/thin-many-dmeventd.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/thin-many-dmeventd.sh b/test/shell/thin-many-dmeventd.sh
index f73b516..2a1fe74 100644
--- a/test/shell/thin-many-dmeventd.sh
+++ b/test/shell/thin-many-dmeventd.sh
@@ -22,6 +22,7 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 #
 # Main
 #
+TIME=$(which time) || skip "Missing 'time' command"
 aux have_thin 1 0 0 || skip
 
 aux prepare_dmeventd
@@ -54,7 +55,7 @@ sleep 9
 # new thin-pool registration.
 for i in $(seq 11 15)
 do
-	/usr/bin/time -o TM -f %e lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
+	"$TIME" -o TM -f %e lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
         read -r t < TM
         test ${t%%.*} -lt 8 || die "Creation of thin pool took more then 8 second! ($t seconds)"
         # Fill thin-pool to some capacity >50%


