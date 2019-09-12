From: David Teigland <teigland@sourceware.org>
Date: Thu, 12 Sep 2019 12:23:51 -0400
Subject: master - tests: skip some without wipefs
Message-ID: <201909121623.x8CGNpuQ023693@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=585db872749a08dd42139cbf4234cbcd50a19683
Commit:        585db872749a08dd42139cbf4234cbcd50a19683
Parent:        82b887a4cfa12f32781cc0dc89c51d89658179a1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 12 11:23:30 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 12 11:23:30 2019 -0500

tests: skip some without wipefs

---
 test/shell/allow-mixed-block-sizes.sh |    1 +
 test/shell/duplicate-pvs-md0.sh       |    2 ++
 test/shell/duplicate-pvs-md1.sh       |    2 ++
 test/shell/lvm-on-md.sh               |    2 ++
 test/shell/pvcreate-operation-md.sh   |    2 ++
 5 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
index 2f0b3a0..ec60bc6 100644
--- a/test/shell/allow-mixed-block-sizes.sh
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -15,6 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 losetup -h | grep sector-size || skip
+wipefs -V || skip
 
 dd if=/dev/zero of=loopa bs=$((1024*1024)) count=2 2> /dev/null
 dd if=/dev/zero of=loopb bs=$((1024*1024)) count=2 2> /dev/null
diff --git a/test/shell/duplicate-pvs-md0.sh b/test/shell/duplicate-pvs-md0.sh
index 4c7863d..d64da4a 100644
--- a/test/shell/duplicate-pvs-md0.sh
+++ b/test/shell/duplicate-pvs-md0.sh
@@ -28,6 +28,8 @@ _clear_online_files() {
 
 . lib/inittest
 
+wipefs -V || skip
+
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
         modprobe raid0 || skip
 not grep md0 /proc/mdstat
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index d242e03..d186c0f 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -33,6 +33,8 @@ _clear_online_files() {
 
 . lib/inittest
 
+wipefs -V || skip
+
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
         modprobe raid1 || skip
 not grep md0 /proc/mdstat
diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 6862101..7bcc276 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -28,6 +28,8 @@ _clear_online_files() {
 
 . lib/inittest
 
+wipefs -V || skip
+
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
 	modprobe raid1 || skip
 not grep md0 /proc/mdstat
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 12cf891..1774d23 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -18,6 +18,8 @@ SKIP_WITH_LVMPOLLD=1
 # skip this test if mdadm or sfdisk (or others) aren't available
 which sfdisk || skip
 
+wipefs -V || skip
+
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
 not grep md0 /proc/mdstat


