From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 26 Nov 2019 04:08:13 -0500
Subject: master - tests: Find md name using lsblk
Message-ID: <67349.119112604080800561@us-mta-281.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6902585187e9a7e29fb57d8415743db1bf80dab
Commit:        b6902585187e9a7e29fb57d8415743db1bf80dab
Parent:        4757ce4c2a4d67ca7170fd25a5dc6e160fb7a788
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Nov 26 09:11:05 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Nov 26 09:13:17 2019 +0100

tests: Find md name using lsblk

After stopping MD device and rescanning the leg, it is created with
different name.
---
 test/shell/duplicate-pvs-md0.sh |    6 ++----
 test/shell/duplicate-pvs-md1.sh |    9 +++------
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/test/shell/duplicate-pvs-md0.sh b/test/shell/duplicate-pvs-md0.sh
index 036f570..6ff9ba2 100644
--- a/test/shell/duplicate-pvs-md0.sh
+++ b/test/shell/duplicate-pvs-md0.sh
@@ -368,8 +368,7 @@ aux enable_dev "$dev2"
 aux aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
-mdadm --stop "$mddev" || true
-mdadm --stop --scan
+mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true
@@ -434,8 +433,7 @@ aux enable_dev "$dev2"
 aux aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
-mdadm --stop "$mddev" || true
-mdadm --stop --scan
+mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index 64d9b98..0e1b83c 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -415,8 +415,7 @@ aux enable_dev "$dev2"
 aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
-mdadm --stop "$mddev" || true
-mdadm --stop --scan
+mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true
@@ -480,8 +479,7 @@ aux enable_dev "$dev2"
 aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
-mdadm --stop "$mddev" || true
-mdadm --stop --scan
+mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true
@@ -619,8 +617,7 @@ aux enable_dev "$dev4"
 aux udev_wait
 cat /proc/mdstat
 # for some reason enabling dev2 starts an odd md dev
-mdadm --stop "$mddev" || true
-mdadm --stop --scan
+mdadm --stop $(lsblk -al -o NAME --noheadings "$dev2" | grep '^md') || true
 cat /proc/mdstat
 aux wipefs_a "$dev1" || true
 aux wipefs_a "$dev2" || true



