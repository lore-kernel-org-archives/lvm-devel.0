From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 18 Sep 2013 04:07:00 +0000 (UTC)
Subject: master - man: lvs man page was not accurate on the volume health bit of lv_attr
Message-ID: <20130918040700.95FE2606B5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2dd0a832a8f06471f86e8244884c4dc902cc9f7
Commit:        c2dd0a832a8f06471f86e8244884c4dc902cc9f7
Parent:        68f841fcda29ee0af177b0299b52842afcf1bae2
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 17 23:03:57 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 17 23:03:57 2013 -0500

man: lvs man page was not accurate on the volume health bit of lv_attr

The 'm'ismatches flag only shows after a "check" scrubbing operation -
not after a "check" or "repair" as indicated by the man page.
---
 man/lvs.8.in |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/man/lvs.8.in b/man/lvs.8.in
index 8f97dc2..32cb788 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -173,12 +173,11 @@ more of the Physical Volumes this RAID Logical Volume uses had suffered a
 write error.  The write error could be due to a temporary failure of that
 Physical Volume or an indication that it is failing.  The device should be
 refreshed or replaced.  (m)ismatches signifies that the RAID logical volume
-has portions of the array that are not coherent or that the array has
-recently repaired inconsistencies.  An additional "check" after a "repair"
-of a RAID logical volume will clear this flag if no additional discrepancies
-are found.  ("check" and "repair" of a RAID Logical Volume can be done via
-the 'lvchange' command.)  (w)ritemostly signifies the devices in a RAID 1
-logical volume that have been marked write-mostly.
+has portions of the array that are not coherent.  Inconsistencies are
+detected by initiating a "check" on a RAID logical volume.  (The scrubbing
+operations, "check" and "repair", can be performed on a RAID logical
+volume via the 'lvchange' command.)  (w)ritemostly signifies the devices in
+a RAID 1 logical volume that have been marked write-mostly.
 .IP 10 3
 s(k)ip activation: this volume is flagged to be skipped during activation.
 .RE


