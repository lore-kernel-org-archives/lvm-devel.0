From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:16 +0000 (GMT)
Subject: main - vdo: update info about memory
Message-ID: <20220710232216.2444F385737B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f445624c339a5c1436a47d2b51046869f183eb03
Commit:        f445624c339a5c1436a47d2b51046869f183eb03
Parent:        8ca2b1bc213188037ecedfbf76de53de871c7f5b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 4 15:00:26 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

vdo: update info about memory

Add more info about kernel target memory allocation associated with
VDO pool usage.
---
 man/lvmvdo.7_main | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/man/lvmvdo.7_main b/man/lvmvdo.7_main
index 14bd640b5..8c3e3eeaa 100644
--- a/man/lvmvdo.7_main
+++ b/man/lvmvdo.7_main
@@ -12,7 +12,7 @@ for primary storage.
 .P
 Deduplication is a technique for reducing the consumption of storage
 resources by eliminating multiple copies of duplicate blocks. Compression
-takes the individual unique blocks and shrinks them. 
+takes the individual unique blocks and shrinks them.
 These reduced blocks are then efficiently packed together into
 physical blocks. Thin provisioning manages the mapping from logical blocks
 presented by VDO to where the data has actually been physically stored,
@@ -358,8 +358,17 @@ take otherwise as device is already expected to be empty.
 .
 .SS \n+[step]. Memory usage
 .
-The VDO target requires 370 MiB of RAM plus an additional 268 MiB
-per each 1 TiB of physical storage managed by the volume.
+The VDO target requires 38 MiB of RAM and several variable amounts:
+.IP \(bu 2
+1.15 MiB of RAM for each 1 MiB of configured block map cache size.
+The block map cache requires a minimum of 150 MiB RAM.
+.br
+.IP \(bu
+1.6 MiB of RAM for each 1 TiB of logical space.
+.br
+.IP \(bu
+268 MiB of RAM for each 1 TiB of physical storage managed by the volume.
+.br
 .P
 UDS requires a minimum of 250 MiB of RAM,
 which is also the default amount that deduplication uses.

