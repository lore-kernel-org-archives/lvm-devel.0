From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  5 Mar 2021 12:01:46 +0000 (GMT)
Subject: main - man: Fix wording in lvmthin(7)
Message-ID: <20210305120146.15AC13870900@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3bea8937334ab9a7852947a30862d6e457f093b6
Commit:        3bea8937334ab9a7852947a30862d6e457f093b6
Parent:        f5fbb1b76fc39fe968d847247b9040ff2acbadcc
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Mar 5 12:49:54 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Mar 5 12:49:54 2021 +0100

man: Fix wording in lvmthin(7)

---
 man/lvmthin.7_main | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 3ce34a5ee..9568eca41 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -443,12 +443,12 @@ If the repair works, the thin pool LV and its thin LVs can be activated.
 User should manually check if repaired thin pool kernel metadata
 has all data for all lvm2 known LVs by individual activation of
 every thin LV. When all works, user should continue with fsck of
-all filesystems present these such volumes.
+all filesystems present on these volumes.
 Once the thin pool is considered fully functional user may remove ThinPoolLV_metaN
 (the LV containing the damaged thin pool metadata) for possible
 space reuse.
 For a better performance it may be useful to pvmove the new repaired metadata LV
-(written to previous pmspare volume) to a better PV (i.e. SSD)
+(written to previous pmspare volume) to a faster PV, e.g. SSD.
 
 If the repair operation fails, the thin pool LV and its thin LVs
 are not accessible and it may be necessary to restore their content


