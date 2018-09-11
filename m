From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 11 Sep 2018 10:06:21 -0400
Subject: master - tests: bump dm-raid version to 1.14.0
Message-ID: <201809111406.w8BE6LHQ015474@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3832329a6b6a6430c84ea1aaacf17fb122a57b2a
Commit:        3832329a6b6a6430c84ea1aaacf17fb122a57b2a
Parent:        df67b1da4d5ee4cf4514f655dbc5a58193364cbd
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Sep 11 15:58:43 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Sep 11 16:05:48 2018 +0200

tests: bump dm-raid version to 1.14.0

Commit 989626926c98cd00f0236c4fcac883107d76899d
introduced 2 new tests
lvconvert-raid-takeover-linear_to_raid4.sh and
lvconvert-raid-takeover-raid4_to_linear.sh
which involve raid reshaping.

Bump the checked dm-raid target version to 1.14.0
which has reshape kernel fixes to avoid test suite
runs to hang.
---
 .../lvconvert-raid-takeover-linear_to_raid4.sh     |    2 +-
 .../lvconvert-raid-takeover-raid4_to_linear.sh     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh b/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh
index 0360fa0..adaf8d3 100644
--- a/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh
+++ b/test/shell/lvconvert-raid-takeover-linear_to_raid4.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 9 1 || skip
+aux have_raid 1 14 0 || skip
 
 aux prepare_vg 4 32
 
diff --git a/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh b/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh
index e571b82..a581846 100644
--- a/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh
+++ b/test/shell/lvconvert-raid-takeover-raid4_to_linear.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 9 1 || skip
+aux have_raid 1 14 0 || skip
 
 aux prepare_vg 4 32
 


