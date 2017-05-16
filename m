From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 16 May 2017 04:52:42 -0400
Subject: master - test: Update condition for changing RAID regionsize
Message-ID: <201705160852.v4G8qgpK023125@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cdb49216c5b00a4d73dab3f56be76bde8d128186
Commit:        cdb49216c5b00a4d73dab3f56be76bde8d128186
Parent:        5406191cb9112dea6d8a618ae1da815f816291f6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue May 16 10:43:34 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue May 16 10:44:52 2017 +0200

test: Update condition for changing RAID regionsize

The test is failing on F23 and F25 with 1.9.1
---
 test/shell/lvconvert-raid-regionsize.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-regionsize.sh b/test/shell/lvconvert-raid-regionsize.sh
index 9884c1b..2cea86e 100644
--- a/test/shell/lvconvert-raid-regionsize.sh
+++ b/test/shell/lvconvert-raid-regionsize.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 9 0 || skip
+aux have_raid 1 11 0 || skip
 
 aux prepare_vg 6
 


