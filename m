From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Feb 2016 15:50:24 +0000 (UTC)
Subject: master - man: lvs updates
Message-ID: <20160218155024.EC03D60C98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=485bce1ae398d6764dd238dc2451e4089281284f
Commit:        485bce1ae398d6764dd238dc2451e4089281284f
Parent:        f31d596c0d0fddf69b71b9553f87e780c33c9eb6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 18 14:13:40 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 18 16:49:38 2016 +0100

man: lvs updates

---
 man/lvs.8.in |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/man/lvs.8.in b/man/lvs.8.in
index 51f6f9e..df61497 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -169,6 +169,7 @@ fixed (m)inor
 State: (a)ctive, (s)uspended, (I)nvalid snapshot, invalid (S)uspended snapshot,
 snapshot (m)erge failed, suspended snapshot (M)erge failed,
 mapped (d)evice present without tables, mapped device present with (i)nactive table,
+thin-pool (c)heck needed, suspended thin-pool (C)heck needed,
 (X) unknown
 .IP 6 3
 device (o)pen, (X) unknown
@@ -203,13 +204,19 @@ Inconsistencies are detected by initiating a "check" on a RAID logical volume.
 logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
 devices in a RAID 1 logical volume that have been marked write-mostly.
 .IP
-Related to thin pool Logical Volumes: (F)ailed, out of (D)ata space, (M) read only.
+Related to Thin pool Logical Volumes: (F)ailed, out of (D)ata space,
+(M)etadata read only.
 .br
 (F)ailed is set if thin pool encounters serious failures and hence no further I/O
 is permitted at all. The out of (D)ata space is set if thin pool has run out of
-data space. (M) read only signifies that thin pool encounters certain types of
-failures but it's still possible to do reads at least, but no metadata changes
-are allowed.
+data space. (M)etadata read only signifies that thin pool encounters certain
+types of failures but it's still possible to do reads at least,
+but no metadata changes are allowed.
+.IP
+Related to Thin Logical Volumes: (F)ailed.
+.br
+(F)ailed is set when related thin pool enters Failed state and no further I/O
+is permitted at all.
 .IP 10 3
 s(k)ip activation: this volume is flagged to be skipped during activation.
 .RE


