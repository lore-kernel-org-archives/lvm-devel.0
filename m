From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  8 Jan 2016 14:47:20 +0000 (UTC)
Subject: master - man: lvs: document F, D and M thin pool health status chars for lv_attr in lvs man page
Message-ID: <20160108144720.7CAFA602DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d11468ab20f5aec25eabab214ca9d3107e9685b
Commit:        8d11468ab20f5aec25eabab214ca9d3107e9685b
Parent:        4304a95dfdb4791e23dbd4b0280c667eba5cb664
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 8 15:47:01 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 8 15:47:01 2016 +0100

man: lvs: document F,D and M thin pool health status chars for lv_attr in lvs man page

---
 WHATS_NEW    |    1 +
 man/lvs.8.in |   38 ++++++++++++++++++++++++++------------
 2 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aa61f0a..137ad18 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.139 - 
 =====================================
+  Document F,D and M thin pool health status chars for lv_attr in lvs man page.
   Also add lvm2-activation{-early,-net}.service systemd status for lvmdump -s.
 
 Version 2.02.138 - 14th December 2015
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 952b6ec..51f6f9e 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -183,19 +183,33 @@ snapshots of thin volumes using the new thin provisioning driver appear as (t).
 .IP 8 3
 Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
 .IP 9 3
-Volume Health: (p)artial, (r)efresh needed, (m)ismatches exist, (w)ritemostly,
-(X) unknown.
+Volume Health, where there are currently three groups of attributes identified:
+.IP
+Common ones for all Logical Volumes: (p)artial, (X) unknown.
+.br
 (p)artial signifies that one or more of the Physical Volumes this Logical
-Volume uses is missing from the system.  (r)efresh signifies that one or
-more of the Physical Volumes this RAID Logical Volume uses had suffered a
-write error.  The write error could be due to a temporary failure of that
-Physical Volume or an indication that it is failing.  The device should be
-refreshed or replaced.  (m)ismatches signifies that the RAID logical volume
-has portions of the array that are not coherent.  Inconsistencies are
-detected by initiating a "check" on a RAID logical volume.  (The scrubbing
-operations, "check" and "repair", can be performed on a RAID logical
-volume via the 'lvchange' command.)  (w)ritemostly signifies the devices in
-a RAID 1 logical volume that have been marked write-mostly.
+Volume uses is missing from the system. (X) unknown signifies the status
+is unknown.
+.IP
+Related to RAID Logical Volumes: (r)efresh needed, (m)ismatches exist, (w)ritemostly.
+.br
+(r)efresh signifies that one or more of the Physical Volumes this RAID Logical
+Volume uses had suffered a write error. The write error could be due to a
+temporary failure of that Physical Volume or an indication that it is failing.
+The device should be refreshed or replaced. (m)ismatches signifies that the
+RAID logical volume has portions of the array that are not coherent.
+Inconsistencies are detected by initiating a "check" on a RAID logical volume.
+(The scrubbing operations, "check" and "repair", can be performed on a RAID
+logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
+devices in a RAID 1 logical volume that have been marked write-mostly.
+.IP
+Related to thin pool Logical Volumes: (F)ailed, out of (D)ata space, (M) read only.
+.br
+(F)ailed is set if thin pool encounters serious failures and hence no further I/O
+is permitted at all. The out of (D)ata space is set if thin pool has run out of
+data space. (M) read only signifies that thin pool encounters certain types of
+failures but it's still possible to do reads at least, but no metadata changes
+are allowed.
 .IP 10 3
 s(k)ip activation: this volume is flagged to be skipped during activation.
 .RE


