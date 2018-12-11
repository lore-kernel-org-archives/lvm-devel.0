From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 11 Dec 2018 10:54:31 -0500
Subject: master - man: document 's' RAID attribute bit
Message-ID: <201812111554.wBBFsVAD011753@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=627f0e2bd84753a7bfbda517f22c54a929e3a458
Commit:        627f0e2bd84753a7bfbda517f22c54a929e3a458
Parent:        dd5716ddf258c4a44819fa90d3356833ccf767b4
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Dec 11 16:54:17 2018 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Dec 11 16:54:17 2018 +0100

man: document 's' RAID attribute bit

---
 man/lvs.8_end    |    2 ++
 man/lvs.8_pregen |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/man/lvs.8_end b/man/lvs.8_end
index f24ffe9..4f83516 100644
--- a/man/lvs.8_end
+++ b/man/lvs.8_end
@@ -56,6 +56,8 @@ Inconsistencies are detected by initiating a "check" on a RAID logical volume.
 (The scrubbing operations, "check" and "repair", can be performed on a RAID
 logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
 devices in a RAID 1 logical volume that have been marked write-mostly.
+Re(s)haping signifies a RAID Logical Volume is either undergoing a stripe
+addition/removal, a stripe size or RAID algorithm change.
 (R)emove after reshape signifies freed striped raid images to be removed.
 .IP
 Related to Thin pool Logical Volumes: (F)ailed, out of (D)ata space,
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index cbc0ed8..377afc2 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -569,6 +569,8 @@ Inconsistencies are detected by initiating a "check" on a RAID logical volume.
 (The scrubbing operations, "check" and "repair", can be performed on a RAID
 logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
 devices in a RAID 1 logical volume that have been marked write-mostly.
+Re(s)haping shows a Raid Logical Volume is undergoing a reshape (ie. striped
+ addition/removal, stripe size or RAID algorithm change).
 (R)emove after reshape signifies freed striped raid images to be removed.
 .IP
 Related to Thin pool Logical Volumes: (F)ailed, out of (D)ata space,


