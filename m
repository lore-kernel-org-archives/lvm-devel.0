From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 28 Jul 2016 15:35:42 +0000 (UTC)
Subject: master - man: lvcreate correction on --stripes explanation and examples with respect to the changed, configurable default behaviour introduced with commit 7eb79091937d.
Message-ID: <20160728153542.3136C6090A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d959b6c75a6cc98691413ec4eab5b01e992d6c1
Commit:        8d959b6c75a6cc98691413ec4eab5b01e992d6c1
Parent:        02ddd48c1148052175ac2178f3f762ca0629d6e9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 28 17:34:42 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jul 28 17:34:42 2016 +0200

man: lvcreate correction on --stripes explanation and examples      with respect to the changed, configurable default behaviour      introduced with commit 7eb79091937d.

     E.g. raid default of 2 stripes rather than number of PVs in the VG
     or on the command line minus one.
---
 man/lvcreate.8.in |   29 +++++++++++++++++++++--------
 1 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 1cce0b6..34b6523 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -603,14 +603,24 @@ for online conversion to thin volumes with external origin.
 .br
 Gives the number of stripes.
 This is equal to the number of physical volumes to scatter
-the logical volume.  When creating a RAID 4/5/6 logical volume,
+the logical volume data.  When creating a RAID 4/5/6 logical volume,
 the extra devices which are necessary for parity are
 internally accounted for.  Specifying \fB\-i 3\fP
-would use 3 devices for striped logical volumes,
-4 devices for RAID 4/5, and 5 devices for RAID 6.  Alternatively,
-RAID 4/5/6 will stripe across all PVs in the volume group or
-all of the PVs specified if the \fB\-i\fP
-argument is omitted.
+would cause 3 devices for striped and RAID 0 logical volumes,
+4 devices for RAID 4/5, 5 devices for RAID 6 and 6 devices for RAID 10.
+Alternatively, RAID 0 will stripe across 2 devices,
+RAID 4/5 across 3 PVs, RAID 6 across 5 PVs and RAID 10 across
+4 PVs in the volume group if the \fB\-i\fP argument is omitted.
+In order to stripe across all PVs of the VG if the \fB\-i\fP argument is
+omitted, set raid_stripe_all_devices=1 in the allocation
+section of \fBlvm.conf (5)\fP or add
+.br
+\fB\-\-config allocation/raid_stripe_all_devices=1\fP
+.br
+to the command.
+.br
+Note the current limitation of 8 stripes total in any RaidLV including parity devices.
+
 Two implementations of basic striping are available in the kernel.
 The original device-mapper implementation is the default and should
 normally be used.  The alternative implementation using MD, available
@@ -801,9 +811,12 @@ a parity drive for a total of 4 devices) and a stripesize of 64KiB:
 .B lvcreate \-\-type raid5 \-L 5G \-i 3 \-I 64 \-n my_lv vg00
 
 Creates a RAID5 logical volume "vg00/my_lv", using all of the free
-space in the VG and spanning all the PVs in the VG:
+space in the VG and spanning all the PVs in the VG (note that the command
+will fail if there's more than 8 PVs in the VG in which case \fB\-i 7\fP
+has to be used to get to the currently possible maximum of
+8 devices including parity for RaidLVs):
 .sp
-.B lvcreate \-\-type raid5 \-l 100%FREE \-n my_lv vg00
+.B lvcreate \-\-config allocation/raid_stripe_all_devices=1 \-\-type raid5 \-l 100%FREE \-n my_lv vg00
 
 Creates a 5GiB RAID10 logical volume "vg00/my_lv", with 2 stripes on
 2 2-way mirrors.  Note that the \fB-i\fP and \fB-m\fP arguments behave


