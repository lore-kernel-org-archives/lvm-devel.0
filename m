From: Christoph Anton Mitterer <calestyo@scientia.net>
Date: Fri, 20 Aug 2010 01:46:58 +0200
Subject: patch: lvdisplay, pvdisplay, vgdisplay manpages
Message-ID: <1282261618.3337.67.camel@fermat.scientia.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(2nd try ;) )

Hi.

In order to solve
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=404058
I've provided some patches for [pv|lv|vg]display.

What they'd do:
- align the wording style used by all three
- replace the numbers in vgcreate with "*" as used in lvcreate and
pvcreate
- for all, removed "logical volume", "physical volume" and "volume
group"
in the description, if it's clear as it's the respective manpage (e.g.
in
the lvdisplay manpage "logical volume size" -> "size")
- improved the explanation in some cases (e.g. actual/current LV of the
VG)
- Sometimes the unit seemed to be wrong (e.g. fixed kilobytes or
sectors,
where actually MiB was used)... wrote "human-readable format" in that
cases.

Be warned:
- I removed all lines, which were not there when I tried the commands,
but
this could just result because I do not have some options set or do not
use
lvm1. So _REALLY_ double check if I did not remove something which is
actually not obsolete.


Again,.. please check whether everything is correct what I've changed.


Cheers,
Chris.



--- lvdisplay.8 2010-06-24 01:05:17.488777000 +0200
+++ lvdisplay.8 2010-06-25 11:32:13.260323003 +0200
@@ -58,19 +58,18 @@
 
 The values are:
 
-* logical volume name
-* volume group name
-* logical volume access
-* logical volume status
-* internal logical volume number
-* open count of logical volume
-* logical volume size in sectors
-* current logical extents associated to logical volume
-* allocated logical extents of logical volume
-* allocation policy of logical volume
-* read ahead sectors of logical volume
-* major device number of logical volume
-* minor device number of logical volume
+* name (device file pathname)
+* name of the volume group the logical volume belongs to
+* UUID
+* access permission (r|rw)
+* status
+* open count
+* size in human-readable format
+* current number of associated logical extents
+* number of segments
+* allocation policy
+* read ahead sectors
+* major and minor device number
 
 .fi
 .TP




--- pvdisplay.8 2010-06-25 11:32:30.187572000 +0200
+++ pvdisplay.8 2010-06-25 11:35:17.741325151 +0200
@@ -49,17 +49,15 @@
 
 The values are:
 
-* physical volume device name
-* volume group name
-* physical volume size in kilobytes
-* internal physical volume number (obsolete)
-* physical volume status
-* physical volume (not) allocatable
-* current number of logical volumes on this physical volume
-* physical extent size in kilobytes
+* name (device file pathname)
+* name of the volume group the physical volume belongs to
+* usable and non-usable space sizes in human-readable format
+* status (allocatable or not)
+* physical extent size in human-readable format
 * total number of physical extents
-* free number of physical extents
-* allocated number of physical extents
+* number of free physical extents
+* number of allocated physical extents
+* UUID
 
 .fi
 .TP




--- vgdisplay.8 2010-06-24 01:05:11.711784000 +0200
+++ vgdisplay.8 2010-06-25 11:46:32.165379302 +0200
@@ -51,23 +51,25 @@
 
 The values are:
 
-1  volume group name
-2  volume group access
-3  volume group status
-4  internal volume group number
-5  maximum number of logical volumes
-6  current number of logical volumes
-7  open count of all logical volumes in this volume group
-8  maximum logical volume size
-9  maximum number of physical volumes
-10 current number of physical volumes
-11 actual number of physical volumes
-12 size of volume group in kilobytes
-13 physical extent size
-14 total number of physical extents for this volume group
-15 allocated number of physical extents for this volume group
-16 free number of physical extents for this volume group
-17 uuid of volume group
+* name
+* system ID
+* format
+* number of metadata areas
+* metadate sequence number
+* access permission (r|rw)
+* status
+* maximum number of logical volumes
+* current number of logical volumes
+* open count of all logical volumes
+* maximum number of physical volumes
+* current number of physical volumes (including missing phyiscal
volumes)
+* actual number of physical volumes (not including missing physical
volumes)
+* size in human-readable format
+* physical extent size
+* total number of physical extents
+* number of allocated physical extents
+* number of free physical extents
+* UUID
 
 .fi
 .TP



