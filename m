From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 8 Jan 2019 07:16:54 -0500
Subject: master - raid: man regenerated
Message-ID: <201901081216.x08CGscI031916@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81b3b71dae7775c93adebdea60308e11057a4ee8
Commit:        81b3b71dae7775c93adebdea60308e11057a4ee8
Parent:        c0c202e60600b2d7460ce0e7825f2ec89956c68f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 8 13:06:03 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 8 13:13:57 2019 +0100

raid: man regenerated

---
 man/lvs.8_pregen |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 377afc2..9659b70 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -569,8 +569,8 @@ Inconsistencies are detected by initiating a "check" on a RAID logical volume.
 (The scrubbing operations, "check" and "repair", can be performed on a RAID
 logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
 devices in a RAID 1 logical volume that have been marked write-mostly.
-Re(s)haping shows a Raid Logical Volume is undergoing a reshape (ie. striped
- addition/removal, stripe size or RAID algorithm change).
+Re(s)haping signifies a RAID Logical Volume is either undergoing a stripe
+addition/removal, a stripe size or RAID algorithm change.
 (R)emove after reshape signifies freed striped raid images to be removed.
 .IP
 Related to Thin pool Logical Volumes: (F)ailed, out of (D)ata space,


