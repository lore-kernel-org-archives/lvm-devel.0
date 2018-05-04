From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 4 May 2018 10:58:49 -0400
Subject: master - tests: bump raid target version in reshape tests
Message-ID: <201805041458.w44Ewnh7027335@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c9729022bf691a57df25bca43995e9a05c9cf130
Commit:        c9729022bf691a57df25bca43995e9a05c9cf130
Parent:        8bf92875f7f4633d457640af2503c06ffdee7f37
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri May 4 16:56:38 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri May 4 16:58:11 2018 +0200

tests: bump raid target version in reshape tests

Adjust to target version allowing tests to succeed.
---
 test/shell/lvconvert-raid-reshape-load.sh          |    2 +-
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    5 +----
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |    2 +-
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index 23046e5..cd72d09 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -21,7 +21,7 @@ SKIP_WITH_LVMPOLLD=1
 test $(aux total_mem) -gt $((4096*1024)) || skip
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip
+aux have_raid 1 13 2 || skip
 
 mount_dir="mnt"
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index e7066be..88722b0 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -15,16 +15,13 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-# FIXME - skippping until properly kernel is released
-skip
-
 # Test reshaping under io load
 
 # FIXME: This test requires 3GB in /dev/shm!
 test $(aux total_mem) -gt $((4096*1024)) || skip
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip
+aux have_raid 1 13 2 || skip
 
 mount_dir="mnt"
 
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index 2143b4c..1be8d61 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -21,7 +21,7 @@ SKIP_WITH_LVMPOLLD=1
 test $(aux total_mem) -gt $((4096*1024)) || skip
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip
+aux have_raid 1 13 2 || skip
 
 mount_dir="mnt"
 


