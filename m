From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Nov 2021 22:59:20 +0000 (GMT)
Subject: main - tests: udev-pvscan-vgchange fix wait
Message-ID: <20211111225920.75509385840E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=20c550ab10e50d25249ed0b0553ff8a33ed3348f
Commit:        20c550ab10e50d25249ed0b0553ff8a33ed3348f
Parent:        0e0faf30e01f78828b7e240f57217755b62650bb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 11 16:04:24 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 11 16:04:24 2021 -0600

tests: udev-pvscan-vgchange fix wait

the service now remains after completion
---
 test/shell/udev-pvscan-vgchange.sh | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/test/shell/udev-pvscan-vgchange.sh b/test/shell/udev-pvscan-vgchange.sh
index f0d637562..fcd8e961b 100644
--- a/test/shell/udev-pvscan-vgchange.sh
+++ b/test/shell/udev-pvscan-vgchange.sh
@@ -71,15 +71,11 @@ wipe_all() {
 	done
 }
 
-# udevadm trigger runs udev rule which runs systemd-run --no-wait vgchange -aay
-# Because of --no-wait, we need to wait for the transient systemd
-# service to be gone before checking the effects of the vgchange.
-
 wait_lvm_activate() {
 	local vgw=$1
 	local wait=0
 
-	while systemctl status lvm-activate-$vgw > /dev/null && test "$wait" -le 30; do
+	while systemctl status lvm-activate-$vgw | grep "active (running)" && test "$wait" -le 30; do
 		sleep .2
 		wait=$(( wait + 1 ))
 	done


