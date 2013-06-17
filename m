From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 17 Jun 2013 17:41:16 +0000 (UTC)
Subject: master - TEST: Fix 'dd' overrunning device size and causing test failure
Message-ID: <20130617174116.75113614AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a4fdc19022e578c6003b6bdbd9e5edfa753a827
Commit:        7a4fdc19022e578c6003b6bdbd9e5edfa753a827
Parent:        21f1062ef883adeed2bad85bb61ad652b32029c7
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jun 17 12:38:09 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jun 17 12:38:09 2013 -0500

TEST: Fix 'dd' overrunning device size and causing test failure

Assumed size of 4M was too large and the test was failing because
'dd' was failing to perform its write.

Calculate the size we need to write with 'dd' instead, so we
don't overrun the device.
---
 test/shell/lvchange-raid.sh |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index b331961..da9c76e 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -177,11 +177,16 @@ run_syncaction_check() {
 # run_refresh_check <VG> <LV>
 #   Assumes "$dev2" is in the array
 run_refresh_check() {
+	local size
+
 	aux wait_for_sync $1 $2
 
+	size=`lvs -a --noheadings -o size --units 1k $1/$2 | sed s/\.00k//`
+	size=$(sed s/^[[:space:]]*// <<< "$size")
+
 	# Disable dev2 and do some I/O to make the kernel notice
 	aux disable_dev "$dev2"
-	dd if=/dev/urandom of=/dev/$1/$2 bs=4M count=1
+	dd if=/dev/urandom of=/dev/$1/$2 bs=1k count=$size
 
 	# Check for 'p'artial flag
 	lvs --noheadings -o lv_attr $1/$2 | grep '.*p$'


