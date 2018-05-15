From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 10:59:21 -0400
Subject: master - tests: fix size of COW
Message-ID: <201805151459.w4FExLor030328@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d25c135806593146e70a7c9f7c44535fbeec49f5
Commit:        d25c135806593146e70a7c9f7c44535fbeec49f5
Parent:        0217c53b24db3b0d50d1088ecd7bfc3ad1ba3955
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 16:49:53 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 16:49:53 2018 +0200

tests: fix size of COW

Needs to be changed to match 4K extent_size.
---
 test/shell/snapshot-usage.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 307ab5f..bcfa16a 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -189,7 +189,7 @@ lvremove -f $vg1/snap
 # Undeleted header would trigger attempt to access
 # beyond end of COW device
 # Fails to create when chunk size is different
-lvcreate -s -pr -l12 -n snap $vg1/$lv
+lvcreate -s -pr -l3 -n snap $vg1/$lv
 
 # When header is undelete, fails to read snapshot without read errors
 #dd if="$DM_DEV_DIR/$vg1/snap" of=/dev/null bs=1M count=2


