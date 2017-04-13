From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Apr 2017 15:22:51 -0400
Subject: master - tests: use raid_region_size 512
Message-ID: <201704131922.v3DJMp9d025470@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ea9a15612e5a5527ca9747b402884a4e864b236
Commit:        0ea9a15612e5a5527ca9747b402884a4e864b236
Parent:        b81b4aad24807d2aa4968aa9fc7d970a65623620
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 13 14:21:34 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 13 14:21:34 2017 -0500

tests: use raid_region_size 512

given the new default from 5ae7a016b8e5796d36cf491345b1cf8e43ec9ea5
---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 214db4e..f12f953 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1127,6 +1127,7 @@ activation/snapshot_autoextend_threshold = 50
 activation/udev_rules = 1
 activation/udev_sync = 1
 activation/verify_udev_operations = $LVM_VERIFY_UDEV
+activation/raid_region_size = 512
 allocation/wipe_signatures_when_zeroing_new_lvs = 0
 backup/archive = 0
 backup/backup = 0


