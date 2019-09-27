From: David Teigland <teigland@sourceware.org>
Date: Fri, 27 Sep 2019 13:52:48 -0400
Subject: master - tests: skip md tests if system not clean
Message-ID: <201909271752.x8RHqmGM018453@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9680fd6d78dc9aede50ed797317ec579e4969522
Commit:        9680fd6d78dc9aede50ed797317ec579e4969522
Parent:        0673d13518ac7d058ca70b04c29fd30f4fedeab6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 27 12:40:42 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 27 12:40:42 2019 -0500

tests: skip md tests if system not clean

---
 test/shell/duplicate-pvs-md0.sh     |    2 +-
 test/shell/duplicate-pvs-md1.sh     |    2 +-
 test/shell/lvm-on-md.sh             |    2 +-
 test/shell/pvcreate-operation-md.sh |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/duplicate-pvs-md0.sh b/test/shell/duplicate-pvs-md0.sh
index d64da4a..d5164ce 100644
--- a/test/shell/duplicate-pvs-md0.sh
+++ b/test/shell/duplicate-pvs-md0.sh
@@ -32,7 +32,7 @@ wipefs -V || skip
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
         modprobe raid0 || skip
-not grep md0 /proc/mdstat
+not grep md0 /proc/mdstat || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
 
diff --git a/test/shell/duplicate-pvs-md1.sh b/test/shell/duplicate-pvs-md1.sh
index d186c0f..626c55c 100644
--- a/test/shell/duplicate-pvs-md1.sh
+++ b/test/shell/duplicate-pvs-md1.sh
@@ -37,7 +37,7 @@ wipefs -V || skip
 
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
         modprobe raid1 || skip
-not grep md0 /proc/mdstat
+not grep md0 /proc/mdstat || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
 
diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 7bcc276..a8df814 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -32,7 +32,7 @@ wipefs -V || skip
 
 test -f /proc/mdstat && grep -q raid1 /proc/mdstat || \
 	modprobe raid1 || skip
-not grep md0 /proc/mdstat
+not grep md0 /proc/mdstat || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
 
diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index 1774d23..6e43e5f 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -22,7 +22,7 @@ wipefs -V || skip
 
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 	modprobe raid0 || skip
-not grep md0 /proc/mdstat
+not grep md0 /proc/mdstat || skip
 
 aux lvmconf 'devices/md_component_detection = 1'
 aux extend_filter_md "a|/dev/md|"


