From: David Teigland <teigland@sourceware.org>
Date: Thu, 24 Oct 2019 11:10:29 -0400
Subject: master - man lvmthin: change wording about mounting xfs
Message-ID: <201910241510.x9OFATgF032643@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ba260e397ba7159eaccee8c0adab8fdb0664be7
Commit:        0ba260e397ba7159eaccee8c0adab8fdb0664be7
Parent:        c8b01f33a675a4f7e35acc78d56b746a81ddec33
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 24 10:09:41 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 24 10:10:18 2019 -0500

man lvmthin: change wording about mounting xfs

---
 man/lvmthin.7_main |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 27bad57..8425614 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -1330,12 +1330,16 @@ dummy transaction, but will require skipping the uuid check:
 
 mount /dev/VG/SnapLV /mnt -o nouuid
 
-Or, the uuid can be changed on disk before mounting:
+After the first mount with the above approach, the UUID can subsequently be
+changed using:
 
 xfs_admin -U generate /dev/VG/SnapLV
 .br
 mount /dev/VG/SnapLV /mnt
 
+Once the UUID has been changed, the mount command will no longer require
+the nouuid option.
+
 If the snapshot LV is readonly, the log recovery and uuid check need to be
 skipped while mounting readonly:
 


