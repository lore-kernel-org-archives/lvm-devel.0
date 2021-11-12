From: David Teigland <teigland@sourceware.org>
Date: Fri, 12 Nov 2021 18:27:06 +0000 (GMT)
Subject: main - tests: udev-pvscan-vgchange clear services
Message-ID: <20211112182706.BB6953858410@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4926061d32f855ffe7a38034b2fe2917e63409a0
Commit:        4926061d32f855ffe7a38034b2fe2917e63409a0
Parent:        66f0fe57c3b376672696e3e7f4fe9e691a06d482
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 12 12:10:26 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 12 12:10:26 2021 -0600

tests: udev-pvscan-vgchange clear services

---
 test/shell/udev-pvscan-vgchange.sh | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/test/shell/udev-pvscan-vgchange.sh b/test/shell/udev-pvscan-vgchange.sh
index fcd8e961b..a82bf8876 100644
--- a/test/shell/udev-pvscan-vgchange.sh
+++ b/test/shell/udev-pvscan-vgchange.sh
@@ -400,3 +400,13 @@ mdadm --stop "$mddev"
 aux udev_wait
 wipe_all
 
+systemctl stop lvm-activate-$vg1
+systemctl stop lvm-activate-$vg2
+systemctl stop lvm-activate-$vg3
+systemctl stop lvm-activate-$vg4
+systemctl stop lvm-activate-$vg5
+systemctl stop lvm-activate-$vg6
+systemctl stop lvm-activate-$vg7
+systemctl stop lvm-activate-$vg8
+systemctl stop lvm-activate-$vg9
+


