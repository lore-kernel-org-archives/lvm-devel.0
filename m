From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:21:31 -0500
Subject: master - pvck: repair headers and metadata
Message-ID: <64494.119112712212600861@us-mta-281.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3145a855836c4cf50d4b6064b3e6f1ce4a366aad
Commit:        3145a855836c4cf50d4b6064b3e6f1ce4a366aad
Parent:        2e0f2730081554460328b3ac7e28080bd902535c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 29 16:08:43 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:47 2019 -0600

pvck: repair headers and metadata

To write a new/repaired pv_header and label_header:

  pvck --repairtype pv_header --file <file> <device>

This uses the metadata input file to find the PV UUID,
device size, and data offset.

To write new/repaired metadata text and mda_header:

  pvck --repairtype metadata --file <file> <device>

This requires a good pv_header which points to one or two
metadata areas.  Any metadata areas referenced by the
pv_header are updated with the specified metadata and
a new mda_header. "--settings mda_num=1|2" can be used
to select one mda to repair.

To combine all header and metadata repairs:

  pvck --repair --file <file> <device>

It's best to use a raw metadata file as input, that was
extracted from another PV in the same VG (or from another
metadata area on the same PV.)  pvck will also accept a
metadata backup file, but that will produce metadata that
is not identical to other metadata copies on other PVs
and other areas.  So, when using a backup file, consider
using it to update metadata on all PVs/areas.

To get a raw metadata file to use for the repair, see
pvck --dump metadata|metadata_search.

List all instances of metadata from the metadata area:
  pvck --dump metadata_search <device>

Save one instance of metadata at the given offset to
the specified file (this file can be used for repair):

  pvck --dump metadata_search --file <file>
    --settings "metadata_offset=<off>" <device>
---
 man/pvck.8_des            |   87 +++-
 test/shell/pvck-repair.sh |  452 ++++++++++++++
 tools/args.h              |   22 +-
 tools/command-lines.in    |   15 +-
 tools/command.c           |    1 +
 tools/lvmcmdline.c        |    9 +
 tools/pvck.c              | 1461 ++++++++++++++++++++++++++++++++++++++++++---
 tools/tools.h             |    1 +
 tools/vals.h              |    1 +
 9 files changed, 1946 insertions(+), 103 deletions(-)

diff --git a/man/pvck.8_des b/man/pvck.8_des
index fb826d3..2169d73 100644
--- a/man/pvck.8_des
+++ b/man/pvck.8_des
@@ -1,8 +1,83 @@
-pvck checks LVM metadata on PVs.
+pvck checks and repairs LVM metadata on PVs.
 
-Use the --dump option to extract metadata from PVs for debugging.
-With dump, set --pvmetadatacopies 2 to extract metadata from a
-second metadata area at the end of the device. Use the --file
-option to save the raw metadata to a specified file. (The raw
-metadata is not usable with vgcfgbackup and vgcfgrestore.)
+.SS Dump
+
+.B headers
+.br
+Print header values and warn if any values are incorrect.  Checks the
+label_header, pv_header, mda_header(s), and metadata text.
+
+.B metadata
+.br
+Print or save the current metadata text, using headers to locate the
+metadata.  If headers are damaged, the metadata may not be found.  Use
+--settings "mda_num=2" to look in mda2 (the second mda at the end of the
+device (if used).  The metadata text is printed to stdout.  With --file,
+the metadata text is saved to a file.
+
+.B metadata_all
+.br
+List or save all versions of metadata found in the metadata area, using
+headers to locate the metadata.  If headers are damaged, the metadata may
+not be found.  Use --settings "mda_num=2" as above.  All metadata versions
+are listed (add -v to include descriptions and dates in the listing.)
+With -file, all versions are written to a file.
+
+.B metadata_search
+.br
+Search for all versions of metadata in the common locations.  This does
+not use headers, so it can find metadata even when headers are damaged.
+Use --settings "mda_num=2" as above.  All metadata versions are listed
+(add -v to include descriptions and dates in the listing.)  With --file,
+all versions are written to a file.  To save one copy of metadata, use
+--settings "metadata_offset=<offset>", where the offset is taken from the
+dump listing.
+
+.B metadata_area
+.br
+Save the entire text metadata area to a file without processing.
+
+.SS Repair
+
+.B --repair
+.br
+Repair headers and metadata on a PV.  This uses a metadata input file that
+was extracted by --dump, or a backup file (from /etc/lvm/backup).  When
+possible, use metadata saved by --dump from another PV in the same VG (or
+from a second metadata area on the PV).
+
+There are cases where the PV UUID needs to be specified for the PV being
+repaired.  It is specified using --settings "pv_uuid=<UUID>".  In
+particular, if the device name for the PV being repaired does not match
+the previous device name of the PV, then LVM may not be able to determine
+the correct PV UUID.  When headers are damaged on more than one PV in a
+VG, it is important for the user to determine the correct PV UUID and
+specify it in --settings.  Otherwise, the wrong PV UUID could be used if
+device names have been swapped since the metadata was last written.
+
+If a PV had no metadata areas and the pv_header is damaged, then the
+repair will not know to create no metadata areas during repair.  It will
+by default repair metadata in mda1.  To repair with no metadata areas, use
+--settings "mda_offset=0 mda_size=0".
+
+There are cases where repair should be run on all PVs in the VG (using the
+same metadata file):  if all PVs in the VG are damaged, if using an old
+metadata version, or if a backup file is used instead of raw metadata.
+
+Using --repair is equivalent to running --repairtype pv_header followed by
+--repairtype metadata.
+
+.B --repairtype pv_header
+.br
+Repairs the header sector, containing the pv_header and label_header.
+
+.B --repairtype metadata
+.br
+Repairs the mda_header and metadata text.  It requires the headers to be
+correct (having been undamaged or already repaired).
+
+.B --repairtype label_header
+.br
+Repairs label_header fields, leaving the pv_header (in the same sector)
+unchanged.  (repairtype pv_header should usually be used instead.)
 
diff --git a/test/shell/pvck-repair.sh b/test/shell/pvck-repair.sh
new file mode 100644
index 0000000..0e83848
--- /dev/null
+++ b/test/shell/pvck-repair.sh
@@ -0,0 +1,452 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2008-2013,2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+. lib/inittest
+
+aux prepare_devs 2
+get_devs
+
+# One PV, one mda, pv_header zeroed
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate $vg "$dev1"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+pvck --dump headers "$dev1" || true
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, one mda, mda_header zeroed
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate $vg "$dev1"
+dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, one mda, pv_header and mda_header zeroed
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate $vg "$dev1"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, one mda, metadata zeroed, use backup
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate $vg "$dev1"
+vgcfgbackup
+dd if=/dev/zero of="$dev1" bs=512 count=2 seek=9
+pvck --dump headers "$dev1" || true
+pvck --dump metadata "$dev1" || true
+pvck --dump metadata_search "$dev1" || true
+pvck --repair -y -f etc/backup/$vg "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, one mda, mda_header and metadata zeroed, use backup
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate $vg "$dev1"
+vgcfgbackup
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump metadata "$dev1" || true
+pvck --dump metadata_search "$dev1" || true
+pvck --repair -y -f etc/backup/$vg "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, one mda, pv_header, mda_header and metadata zeroed, use backup
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate $vg "$dev1"
+vgcfgbackup
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump metadata "$dev1" || true
+pvck --dump metadata_search "$dev1" || true
+pvck --repair -y -f etc/backup/$vg "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, two mdas, pv_header zeroed
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate --pvmetadatacopies 2 $vg "$dev1"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+pvck --dump headers "$dev1" || true
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, two mdas, mda_header1 zeroed
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate --pvmetadatacopies 2 $vg "$dev1"
+pvck --dump headers "$dev1" || true
+dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump metadata_search --settings mda_num=1 "$dev1" || true
+pvck --dump metadata_search --settings mda_num=2 "$dev1" || true
+pvck --dump metadata --settings mda_num=1 "$dev1" || true
+pvck --dump metadata --settings mda_num=2 "$dev1" || true
+pvck --dump metadata --settings mda_num=2 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, two mdas, pv_header and mda_header1 zeroed
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate --pvmetadatacopies 2 $vg "$dev1"
+pvck --dump headers "$dev1" || true
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump metadata "$dev1" || true
+pvck --dump metadata --settings mda_num=2 "$dev1" || true
+pvck --dump metadata_search "$dev1" || true
+pvck --dump metadata_search --settings mda_num=2 "$dev1" || true
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, two mdas, metadata1 zeroed, use mda2
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate --pvmetadatacopies 2 $vg "$dev1"
+pvck --dump headers "$dev1" || true
+dd if=/dev/zero of="$dev1" bs=512 count=2 seek=9
+pvck --dump headers "$dev1" || true
+pvck --dump metadata "$dev1" || true
+pvck --dump metadata --settings mda_num=2 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, two mdas, mda_header1 and metadata1 zeroed, use mda2
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate --pvmetadatacopies 2 $vg "$dev1"
+pvck --dump headers "$dev1" || true
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump metadata "$dev1" || true
+pvck --dump metadata --settings mda_num=2 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, two mdas, pv_header, mda_header1 and metadata1 zeroed, use mda2
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate --pvmetadatacopies 2 $vg "$dev1"
+pvck --dump headers "$dev1" || true
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump metadata "$dev1" || true
+pvck --dump metadata --settings mda_num=2 "$dev1" || true
+pvck --dump metadata_search "$dev1" || true
+pvck --dump metadata_search --settings mda_num=2 "$dev1" || true
+pvck --dump metadata_search --settings "mda_num=2 seqno=1" -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, two mdas, pv_header, both mda_header, and both metadata zeroed, use backup
+# only writes mda1 since there's no evidence that mda2 existed
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate --pvmetadatacopies 2 $vg "$dev1"
+pvck --dump headers "$dev1" || true
+vgcfgbackup
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=67584
+pvck --dump headers "$dev1" || true
+pvck --dump metadata "$dev1" || true
+pvck --dump metadata --settings mda_num=2 "$dev1" || true
+pvck --dump metadata_search "$dev1" || true
+pvck --dump metadata_search --settings mda_num=2 "$dev1" || true
+pvck --repair -y -f etc/backup/$vg "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, two mdas, pv_header, both mda_header, and both metadata zeroed, use backup
+# writes mda1 and also mda2 because of the mda2 settings passed to repair
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+vgcreate --pvmetadatacopies 2 $vg "$dev1"
+pvck --dump headers "$dev1" || true
+vgcfgbackup
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=67584
+pvck --dump headers "$dev1" || true
+pvck --dump metadata "$dev1" || true
+pvck --dump metadata --settings mda_num=2 "$dev1" || true
+pvck --dump metadata_search "$dev1" || true
+pvck --dump metadata_search --settings mda_num=2 "$dev1" || true
+pvck --repair --settings "mda2_offset=34603008 mda2_size=1048576" -y -f etc/backup/$vg "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda each, pv_header and mda_header zeroed on each
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+vgcreate $vg "$dev1" "$dev2"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev2" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
+dd if=/dev/zero of="$dev2" bs=512 count=1 seek=8
+pvck --dump headers "$dev1"
+pvck --dump headers "$dev2"
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --repair -y -f meta "$dev2"
+pvck --dump headers "$dev1"
+pvck --dump headers "$dev2"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda each, metadata zeroed on each, use backup
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+vgcreate $vg "$dev1" "$dev2"
+vgcfgbackup
+dd if=/dev/zero of="$dev1" bs=512 count=2 seek=9
+dd if=/dev/zero of="$dev2" bs=512 count=2 seek=9
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+pvck --repair -y -f etc/backup/$vg "$dev1"
+pvck --repair -y -f etc/backup/$vg "$dev2"
+pvck --dump headers "$dev1"
+pvck --dump headers "$dev2"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda each, pv_header, mda_header and metadata zeroed on each, use backup
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+vgcreate $vg "$dev1" "$dev2"
+vgcfgbackup
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev2" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
+dd if=/dev/zero of="$dev2" bs=512 count=3 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+pvck --repair -y -f etc/backup/$vg "$dev1"
+pvck --repair -y -f etc/backup/$vg "$dev2"
+pvck --dump headers "$dev1"
+pvck --dump headers "$dev2"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda each, pv_header and mda_header zeroed on first
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+vgcreate $vg "$dev1" "$dev2"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+pvck --dump metadata -f meta "$dev2"
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda each, metadata zeroed on first
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+vgcreate $vg "$dev1" "$dev2"
+dd if=/dev/zero of="$dev1" bs=512 count=2 seek=9
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+pvck --dump metadata -f meta "$dev2"
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda each, pv_header, mda_header and metadata zeroed on first
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+vgcreate $vg "$dev1" "$dev2"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+pvck --dump metadata -f meta "$dev2"
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda on first, no mda on second, zero header on first
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+pvcreate "$dev1"
+pvcreate --pvmetadatacopies 0 "$dev2"
+vgcreate $vg "$dev1" "$dev2"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --dump headers "$dev1"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda on first, no mda on second, zero headers on both
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+pvcreate "$dev1"
+pvcreate --pvmetadatacopies 0 "$dev2"
+vgcreate $vg "$dev1" "$dev2"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev2" bs=512 count=2
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+pvck --repair -y --settings "mda_offset=0 mda_size=0" -f meta "$dev2"
+pvck --dump headers "$dev1"
+pvck --dump headers "$dev2"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda on first, no mda on second, zero all on first
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+pvcreate "$dev1"
+pvcreate --pvmetadatacopies 0 "$dev2"
+vgcreate $vg "$dev1" "$dev2"
+vgcfgbackup
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+pvck --repair -y -f etc/backup/$vg "$dev1"
+pvck --repair -y --settings "mda_offset=0 mda_size=0" -f etc/backup/$vg "$dev2"
+pvck --dump headers "$dev1"
+pvck --dump headers "$dev2"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, two mda on each, pv_header and mda_header1 zeroed on both
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+pvcreate --pvmetadatacopies 2 "$dev1"
+pvcreate --pvmetadatacopies 2 "$dev2"
+vgcreate $vg "$dev1" "$dev2"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev2" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
+dd if=/dev/zero of="$dev2" bs=512 count=1 seek=8
+pvck --dump headers "$dev1"
+pvck --dump headers "$dev2"
+pvck --dump metadata_search --settings "mda_num=2 seqno=1" -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+rm meta
+pvck --dump metadata_search --settings "mda_num=2 seqno=1" -f meta "$dev2" || true
+pvck --repair -y -f meta "$dev2"
+rm meta
+pvck --dump headers "$dev1"
+pvck --dump headers "$dev2"
+vgs $vg
+lvcreate -l1 -an $vg
+
+# Two PV, one mda each, pv_header and mda_header zeroed on each,
+# non-standard data_offset/mda_size on first
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+pvcreate --metadatasize 2048k --dataalignment 128k "$dev1"
+pvcreate "$dev2"
+vgcreate $vg "$dev1" "$dev2"
+dd if=/dev/zero of="$dev1" bs=512 count=2
+dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
+dd if=/dev/zero of="$dev2" bs=512 count=2
+dd if=/dev/zero of="$dev2" bs=512 count=1 seek=8
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+pvck --repair -y -f meta "$dev1"
+rm meta
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev2" || true
+pvck --repair -y -f meta "$dev2"
+rm meta
+pvck --dump headers "$dev1" || true
+pvck --dump headers "$dev2" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
+# One PV, one mda, pv_header zeroed, unmatching dev name requires specified uuid
+rm meta || true
+dd if=/dev/zero of="$dev1" || true
+dd if=/dev/zero of="$dev2" || true
+vgcreate $vg "$dev1"
+pvck --dump headers "$dev1" || true
+UUID1=`pvck --dump headers "$dev1" | grep pv_header.pv_uuid | awk '{print $2}'`
+echo $UUID1
+dd if=/dev/zero of="$dev1" bs=512 count=2
+pvck --dump headers "$dev1" || true
+pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
+sed 's/\/dev\/mapper\/LVMTEST/\/dev\/mapper\/BADTEST/' meta > meta.bad
+grep device meta
+grep device meta.bad
+not pvck --repair -y -f meta.bad "$dev1"
+pvck --repair -y -f meta.bad --settings pv_uuid=$UUID1 "$dev1"
+pvck --dump headers "$dev1" || true
+vgs $vg
+lvcreate -l1 -an $vg
+
diff --git a/tools/args.h b/tools/args.h
index 2f84d2c..533cc54 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -214,11 +214,13 @@ arg(driverloaded_ARG, '\0', "driverloaded", bool_VAL, 0, 0,
     "For testing and debugging.\n")
 
 arg(dump_ARG, '\0', "dump", string_VAL, 0, 0,
-    "Dump metadata from a PV. Option values include \\fBmetadata\\fP\n"
-    "to print or save the current text metadata, \\fBmetadata_area\\fP\n"
-    "to save the entire text metadata area to a file, \\fBmetadata_all\\fP\n"
-    "to save the current and any previous complete versions of metadata\n"
-    "to a file, and \\fBheaders\\fP to print and check LVM headers.\n")
+    "Dump headers and metadata from a PV for debugging and repair.\n"
+    "Option values include: \\fBheaders\\fP to print and check LVM headers,\n"
+    "\\fBmetadata\\fP to print or save the current text metadata,\n"
+    "\\fBmetadata_all\\fP to list or save all versions of metadata,\n"
+    "\\fBmetadata_search\\fP to list or save all versions of metadata,\n"
+    "searching standard locations in case of damaged headers,\n"
+    "\\fBmetadata_area\\fP to save an entire text metadata area to a file.\n")
 
 arg(errorwhenfull_ARG, '\0', "errorwhenfull", bool_VAL, 0, 0,
     "Specifies thin pool behavior when data space is exhausted.\n"
@@ -544,9 +546,15 @@ arg(rebuild_ARG, '\0', "rebuild", pv_VAL, ARG_GROUPABLE, 0,
     "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(repair_ARG, '\0', "repair", 0, 0, 0,
+    "#lvconvert\n"
     "Replace failed PVs in a raid or mirror LV, or run a repair\n"
     "utility on a thin pool. See \\fBlvmraid\\fP(7) and \\fBlvmthin\\fP(7)\n"
-    "for more information.\n")
+    "for more information.\n"
+    "#pvck\n"
+    "Repair headers and metadata on a PV.\n")
+
+arg(repairtype_ARG, '\0', "repairtype", repairtype_VAL, 0, 0,
+    "Repair headers and metadata on a PV. See command description.\n")
 
 arg(replace_ARG, '\0', "replace", pv_VAL, ARG_GROUPABLE, 0,
     "Replace a specific PV in a raid LV with another PV.\n"
@@ -1001,6 +1009,8 @@ arg(exported_ARG, 'e', "exported", 0, 0, 0,
 arg(physicalextent_ARG, 'E', "physicalextent", 0, 0, 0, NULL)
 
 arg(file_ARG, 'f', "file", string_VAL, 0, 0,
+    "#pvck\n"
+    "Metadata file to read or write.\n"
     "#lvmconfig\n"
     "#dumpconfig\n"
     "#config\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index cbd64a8..10165ea 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1437,9 +1437,20 @@ ID: pvck_general
 DESC: Check for metadata on a device
 
 pvck --dump String PV
-OO: --settings String, --file String, --pvmetadatacopies MetadataCopiesPV, --labelsector Number
+OO: --settings String, --file String,
+--pvmetadatacopies MetadataCopiesPV, --labelsector Number
 ID: pvck_dump
-DESC: Print metadata from a device
+DESC: Check and print LVM headers and metadata on a device
+
+pvck --repairtype RepairType PV
+OO: --settings String, --file String, --labelsector Number
+ID: pvck_repair_type
+DESC: Repair LVM headers or metadata on a device
+
+pvck --repair --file String PV
+OO: --settings String, --labelsector Number
+ID: pvck_repair
+DESC: Repair LVM headers and metadata on a device
 
 ---
 
diff --git a/tools/command.c b/tools/command.c
index 2e69eff..7bad98d 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -122,6 +122,7 @@ static inline int syncaction_arg(struct cmd_context *cmd __attribute__((unused))
 static inline int reportformat_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int configreport_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+static inline int repairtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 
 /* needed to include commands.h when building man page generator */
 #define CACHE_VGMETADATA        0x00000001
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 860e6de..3d79e97 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1077,6 +1077,15 @@ int configtype_arg(struct cmd_context *cmd, struct arg_values *av)
 	return 0;
 }
 
+int repairtype_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!strcmp(av->value, "pv_header") ||
+	    !strcmp(av->value, "metadata") ||
+	    !strcmp(av->value, "label_header"))
+		return 1;
+	return 0;
+}
+
 /*
  * FIXME: there's been a confusing mixup among:
  * resizeable, resizable, allocatable, allocation.
diff --git a/tools/pvck.c b/tools/pvck.c
index 8588906..cc23d9b 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -23,14 +23,45 @@
 #define PRINT_CURRENT 1
 #define PRINT_ALL 2
 
+#define ID_STR_SIZE 40 /* uuid formatted with dashes is 38 chars */
+
+/*
+ * command line input from --settings
+ */
 struct settings {
-	uint64_t metadata_offset;  /* start of text metadata, from start of disk */
-	uint64_t mda_offset;       /* start of mda_header, from start of disk */
-	uint64_t mda_size;         /* size of metadata area (mda_header + text area) */
+	uint64_t metadata_offset;  /* bytes, start of text metadata (from start of disk) */
+	uint64_t mda_offset;       /* bytes, start of mda_header (from start of disk) */
+	uint64_t mda_size;         /* bytes, size of metadata area (mda_header + text area) */
+	uint64_t mda2_offset;      /* bytes */
+	uint64_t mda2_size;        /* bytes */
+	uint64_t device_size;      /* bytes */
+	uint64_t data_offset;      /* bytes, start of data (pe_start) */
+	uint32_t seqno;
+	struct id pvid;
+
+	int mda_num;               /* 1 or 2 for first or second mda */
+	char *backup_file;
 
 	unsigned metadata_offset_set:1;
 	unsigned mda_offset_set:1;
 	unsigned mda_size_set:1;
+	unsigned mda2_offset_set;
+	unsigned mda2_size_set;
+	unsigned device_size_set:1;
+	unsigned data_offset_set:1;
+	unsigned seqno_set:1;
+	unsigned pvid_set:1;
+};
+
+/*
+ * command line input from --file
+ */
+struct metadata_file {
+	const char *filename;
+	char *text_buf;
+	uint64_t text_size; /* bytes */
+	uint32_t text_crc;
+	char vgid_str[ID_STR_SIZE];
 };
 
 static char *_chars_to_str(void *in, void *out, int num, int max, const char *field)
@@ -136,6 +167,8 @@ static int _check_vgname_start(char *buf, int *len)
 	return 0;
 }
 
+/* all sizes and offsets in bytes */
+
 static void _copy_out_metadata(char *buf, uint32_t start, uint32_t first_start, uint64_t mda_size, char **meta_buf, uint64_t *meta_size, int *bad_end)
 {
 	char *new_buf;
@@ -213,10 +246,14 @@ static void _copy_out_metadata(char *buf, uint32_t start, uint32_t first_start,
 	*meta_size = new_len;
 }
 
-static int _text_buf_parsable(char *text_buf, uint64_t text_size)
+/* all sizes and offsets in bytes */
+
+static int _text_buf_parse(char *text_buf, uint64_t text_size, struct dm_config_tree **cft_out)
 {
 	struct dm_config_tree *cft;
 
+	*cft_out = NULL;
+
 	if (!(cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0))) {
 		return 0;
 	}
@@ -226,27 +263,41 @@ static int _text_buf_parsable(char *text_buf, uint64_t text_size)
 		return 0;
 	}
 
+	*cft_out = cft;
+	return 1;
+}
+
+/* all sizes and offsets in bytes */
+
+static int _text_buf_parsable(char *text_buf, uint64_t text_size)
+{
+	struct dm_config_tree *cft = NULL;
+
+	if (!_text_buf_parse(text_buf, text_size, &cft))
+		return 0;
+
 	config_destroy(cft);
 	return 1;
 }
 
 #define MAX_LINE_CHECK 128
-#define ID_STR_SIZE 48
 
-static void _copy_line(char *in, char *out, int *len)
+static void _copy_line(char *in, char *out, int *len, int linesize)
 {
 	int i;
 
 	*len = 0;
 
-	for (i = 0; i < MAX_LINE_CHECK; i++) {
+	for (i = 0; i < linesize; i++) {
+		out[i] = in[i];
 		if ((in[i] == '\n') || (in[i] == '\0'))
 			break;
-		out[i] = in[i];
 	}
 	*len = i+1;
 }
 
+/* all sizes and offsets in bytes */
+
 static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const char *tofile, struct device *dev,
 			  int mda_num, uint64_t mda_offset, uint64_t mda_size, char *buf)
 {
@@ -255,19 +306,16 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 	char vgname[NAME_LEN+1];
 	char id_str[ID_STR_SIZE];
 	char id_first[ID_STR_SIZE];
-	char latest_vgname[NAME_LEN+1];
-	char latest_id_str[ID_STR_SIZE];
 	char *text_buf;
 	char *p;
-	uint32_t buf_off; /* offset with buf which begins with mda_header */
+	uint32_t buf_off; /* offset with buf which begins with mda_header, bytes */
 	uint32_t buf_off_first = 0;
 	uint32_t seqno;
-	uint32_t latest_seqno;
 	uint32_t crc;
-	uint64_t text_size;
-	uint64_t meta_size;
-	uint64_t latest_offset;
-	int metadata_offset_found = 0;
+	uint64_t text_size; /* bytes */
+	uint64_t meta_size; /* bytes */
+	int print_count = 0;
+	int one_found = 0;
 	int multiple_vgs = 0;
 	int bad_end;
 	int vgnamelen;
@@ -281,11 +329,6 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		}
 	}
 
-	memset(latest_vgname, 0, sizeof(latest_vgname));
-	memset(latest_id_str, 0, sizeof(latest_id_str));
-	latest_offset = 0;
-	latest_seqno = 0;
-
 	/*
 	 * If metadata has not wrapped, and the metadata area beginning
 	 * has not been damaged, the text area will begin with vgname {.
@@ -324,6 +367,9 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		text_size = 0;
 		bad_end = 0;
 
+		if (one_found)
+			break;
+
 		/*
 		 * Check for a new metadata copy at each 512 offset
 		 * (after skipping 512 bytes for mda_header@the
@@ -346,17 +392,14 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 			count++;
 			continue;
 		}
-		if (set->metadata_offset_set) {
-			if (metadata_offset_found)
-				break;
-			metadata_offset_found = 1;
-		}
+		if (set->metadata_offset_set)
+			one_found = 1;
 
 		/*
 		 * copy line of possible metadata to check for vgname
 		 */
 		memset(line, 0, sizeof(line));
-		_copy_line(p, line, &len);
+		_copy_line(p, line, &len, sizeof(line));
 		p += len;
 
 		if (!_check_vgname_start(line, &vgnamelen)) {
@@ -370,7 +413,7 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		 * copy next line of metadata, which should contain id
 		 */
 		memset(line, 0, sizeof(line));
-		_copy_line(p, line, &len);
+		_copy_line(p, line, &len, sizeof(line));
 		p += len;
 
 		if (strncmp(line, "id = ", 5)) {
@@ -384,15 +427,29 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		 * copy next line of metadata, which should contain seqno
 		 */
 		memset(line, 0, sizeof(line));
-		_copy_line(p, line, &len);
+		_copy_line(p, line, &len, sizeof(line));
 		p += len;
 
 		if (strncmp(line, "seqno = ", 8)) {
 			count++;
 			continue;
 		}
+		if (sscanf(line, "seqno = %u", &seqno) != 1) {
+			count++;
+			continue;
+		}
 
-		sscanf(line, "seqno = %u", &seqno);
+		/*
+		 * user specified metadata with one seqno
+		 * (this is not good practice since multiple old copies of metadata
+		 * can have the same seqno; this is mostly to simplify testing)
+		 */
+		if (set->seqno_set && (set->seqno != seqno)) {
+			count++;
+			continue;
+		}
+		if (set->seqno_set)
+			one_found = 1;
 
 		/*
 		 * The first three lines look like metadata with
@@ -428,13 +485,6 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 			  (unsigned long long)text_size,
 			  crc, vgname, seqno, id_str);
 
-		if (!latest_seqno || (seqno > latest_seqno)) {
-			latest_seqno = seqno;
-			latest_offset = mda_offset + buf_off;
-			memcpy(latest_vgname, vgname, NAME_LEN);
-			memcpy(latest_id_str, id_str, ID_STR_SIZE);
-		}
-
 		/*
 		 * save the location of the first metadata we've found so
 		 * we know where to stop after wrapping buf.
@@ -449,26 +499,30 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 		if (!_text_buf_parsable(text_buf, text_size))
 			log_warn("WARNING: parse error for metadata at %llu", (unsigned long long)(mda_offset + buf_off));
 		if (bad_end)
-			log_warn("WARNING: bad terminating bytes for metadata at %llu", (unsigned long long)(mda_offset + buf_off));
+			log_warn("WARNING: unexpected terminating bytes for metadata at %llu", (unsigned long long)(mda_offset + buf_off));
 
 		if (arg_is_set(cmd, verbose_ARG)) {
 			char *str1, *str2;
 			if ((str1 = strstr(text_buf, "description = "))) {
 				memset(line, 0, sizeof(line));
-				_copy_line(str1, line, &len);
+				_copy_line(str1, line, &len, sizeof(line));
+				if ((p = strchr(line, '\n')))
+					*p = '\0';
 				log_print("%s", line);
 			}
 			if (str1 && (str2 = strstr(str1, "creation_time = "))) {
 				memset(line, 0, sizeof(line));
-				_copy_line(str2, line, &len);
+				_copy_line(str2, line, &len, sizeof(line));
+				if ((p = strchr(line, '\n')))
+					*p = '\0';
 				log_print("%s\n", line);
 			}
 		}
 
 		if (fp) {
-			fprintf(fp, "%s", text_buf);
-			if (!set->metadata_offset_set)
+			if (print_count++)
 				fprintf(fp, "\n--\n");
+			fprintf(fp, "%s", text_buf);
 		}
 
 		free(text_buf);
@@ -485,12 +539,6 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 	if (multiple_vgs)
 		log_warn("WARNING: metadata from multiple VGs was found.");
 
-	if (!set->metadata_offset_set)
-		log_print("Most recent metadata found at %llu seqno %u for vg %s id %s",
-			  (unsigned long long)latest_offset, latest_seqno,
-			  latest_vgname, latest_id_str);
-
-
 	if (fp) {
 		if (fflush(fp))
 			stack;
@@ -501,6 +549,8 @@ static int _dump_all_text(struct cmd_context *cmd, struct settings *set, const c
 	return 1;
 }
 
+/* all sizes and offsets in bytes */
+
 static int _check_label_header(struct label_header *lh, uint64_t labelsector,
 			       int *found_label)
 {
@@ -521,7 +571,7 @@ static int _check_label_header(struct label_header *lh, uint64_t labelsector,
 
 	crc = calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl,
 		       LABEL_SIZE - ((uint8_t *) &lh->offset_xl - (uint8_t *) lh));
-		
+
 	if (crc != xlate32(lh->crc_xl)) {
 		log_print("CHECK: label_header.crc expected 0x%x", crc);
 		bad++;
@@ -563,6 +613,8 @@ static int _check_pv_header(struct pv_header *ph)
 }
 
 /*
+ * all sizes and offsets in bytes
+ *
  * mda_offset/mda_size are from the pv_header/disk_locn and could
  * be incorrect.
  */
@@ -612,6 +664,7 @@ static int _check_mda_header(struct mda_header *mh, int mda_num, uint64_t mda_of
 }
 
 /*
+ * all sizes and offsets in bytes
  *
  * mda_offset, mda_size are from pv_header.disk_locn
  * (the location of the metadata area.)
@@ -706,16 +759,20 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	if (!dev_read_bytes(dev, mda_offset, mda_size, meta_buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",
 			  (unsigned long long)mda_offset, (unsigned long long)mda_size);
+		free(meta_buf);
 		return 0;
 	}
 
 	if (!(fp = fopen(tofile, "wx"))) {
 		log_error("Failed to create file %s", tofile);
+		free(meta_buf);
 		return 0;
 	}
 
 	fwrite(meta_buf, mda_size - 512, 1, fp);
 
+	free(meta_buf);
+
 	if (fflush(fp))
 		stack;
 	if (fclose(fp))
@@ -723,6 +780,8 @@ static int _dump_meta_area(struct device *dev, const char *tofile,
 	return 1;
 }
 
+/* all sizes and offsets in bytes */
+
 static int _dump_current_text(struct device *dev,
 			      int print_fields, int print_metadata, const char *tofile,
 			      int mda_num, int rlocn_index,
@@ -739,12 +798,11 @@ static int _dump_current_text(struct device *dev,
 	int ri = rlocn_index; /* 0 or 1 */
 	int bad = 0;
 
-	if (!(meta_buf = malloc(meta_size))) {
+	if (!(meta_buf = zalloc(meta_size))) {
 		log_print("CHECK: mda_header_%d.raw_locn[%d] no mem for metadata text size %llu", mn, ri,
 			  (unsigned long long)meta_size);
 		return 0;
 	}
-	memset(meta_buf, 0, meta_size);
 
 	/*
 	 * Read the metadata text specified by the raw_locn so we can
@@ -755,7 +813,7 @@ static int _dump_current_text(struct device *dev,
 	 * mda_offset + meta_offset.
 	 */
 	if (meta_offset + meta_size > mda_size) {
-	 	/* text metadata wraps to start of text metadata area */
+		/* text metadata wraps to start of text metadata area */
 		uint32_t wrap = (uint32_t) ((meta_offset + meta_size) - mda_size);
 		off_t offset_a = mda_offset + meta_offset;
 		uint32_t size_a = meta_size - wrap;
@@ -766,6 +824,7 @@ static int _dump_current_text(struct device *dev,
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu part_a %llu %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size,
 				  (unsigned long long)offset_a, (unsigned long long)size_a);
+			free(meta_buf);
 			return 0;
 		}
 
@@ -773,12 +832,14 @@ static int _dump_current_text(struct device *dev,
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu part_b %llu %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size,
 				  (unsigned long long)offset_b, (unsigned long long)size_b);
+			free(meta_buf);
 			return 0;
 		}
 	} else {
 		if (!dev_read_bytes(dev, mda_offset + meta_offset, meta_size, meta_buf)) {
 			log_print("CHECK: failed to read metadata text at mda_header_%d.raw_locn[%d].offset %llu size %llu", mn, ri,
 				  (unsigned long long)meta_offset, (unsigned long long)meta_size);
+			free(meta_buf);
 			return 0;
 		}
 	}
@@ -836,11 +897,14 @@ static int _dump_current_text(struct device *dev,
 	}
 
  out:
+	free(meta_buf);
 	if (bad)
 		return 0;
 	return 1;
 }
 
+/* all sizes and offsets in bytes */
+
 static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsector, struct device *dev,
 				     int print_fields,
 				     int *found_label,
@@ -848,16 +912,16 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 				     uint64_t *mda2_offset, uint64_t *mda2_size,
 				     int *mda_count_out)
 {
+	char buf[512];
 	char str[256];
 	struct label_header *lh;
 	struct pv_header *pvh;
 	struct pv_header_extension *pvhe;
 	struct disk_locn *dlocn;
-	uint64_t lh_offset;
-	uint64_t pvh_offset;
-	uint64_t pvhe_offset;
-	uint64_t dlocn_offset;
-	char *buf;
+	uint64_t lh_offset;     /* bytes */
+	uint64_t pvh_offset;    /* bytes */
+	uint64_t pvhe_offset;   /* bytes */
+	uint64_t dlocn_offset;  /* bytes */
 	uint64_t tmp;
 	int mda_count = 0;
 	int bad = 0;
@@ -865,9 +929,6 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 
 	lh_offset = labelsector * 512; /* from start of disk */
 
-	if (!(buf = zalloc(512)))
-		return_0;
-
 	if (!dev_read_bytes(dev, lh_offset, 512, buf)) {
 		log_print("CHECK: failed to read label_header at %llu",
 			  (unsigned long long)lh_offset);
@@ -1071,6 +1132,8 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 }
 
 /*
+ * all sizes and offsets in bytes
+ *
  * mda_offset and mda_size are the location/size of the metadata area,
  * which starts with the mda_header and continues through the circular
  * buffer of text.
@@ -1091,22 +1154,20 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 			    uint32_t *checksum0_ret,
 			    int *found_header)
 {
+	char buf[512];
 	char str[256];
-	char *buf;
+	char *mda_buf;
 	struct mda_header *mh;
 	struct raw_locn *rlocn0, *rlocn1;
 	uint64_t rlocn0_offset, rlocn1_offset;
-	uint64_t meta_offset = 0;
-	uint64_t meta_size = 0;
+	uint64_t meta_offset = 0; /* bytes */
+	uint64_t meta_size = 0;   /* bytes */
 	uint32_t meta_checksum = 0;
 	int mda_num = (mda_offset == 4096) ? 1 : 2;
 	int bad = 0;
 
 	*checksum0_ret = 0; /* checksum from raw_locn[0] */
 
-	if (!(buf = zalloc(512)))
-		return_0;
-
 	/*
 	 * The first mda_header is 4096 bytes from the start
 	 * of the device.  Each mda_header is 512 bytes.
@@ -1192,35 +1253,34 @@ static int _dump_mda_header(struct cmd_context *cmd, struct settings *set,
 	 * looking at all copies of the metadata in the area
 	 */
 	if (print_metadata == PRINT_ALL) {
-		free(buf);
-
-		if (!(buf = malloc(mda_size)))
+		if (!(mda_buf = zalloc(mda_size)))
 			goto_out;
-		memset(buf, 0, mda_size);
 
-		if (!dev_read_bytes(dev, mda_offset, mda_size, buf)) {
+		if (!dev_read_bytes(dev, mda_offset, mda_size, mda_buf)) {
 			log_print("CHECK: failed to read metadata area at offset %llu size %llu",
 				  (unsigned long long)mda_offset, (unsigned long long)mda_size);
 			bad++;
+			free(mda_buf);
 			goto out;
 		}
 
-		_dump_all_text(cmd, set, tofile, dev, mda_num, mda_offset, mda_size, buf);
+		_dump_all_text(cmd, set, tofile, dev, mda_num, mda_offset, mda_size, mda_buf);
+		free(mda_buf);
 	}
 
 	/* Should we also check text metadata if it exists in rlocn1? */
  out:
-	if (buf)
-		free(buf);
 	if (bad)
 		return 0;
 	return 1;
 }
 
+/* all sizes and offsets in bytes */
+
 static int _dump_headers(struct cmd_context *cmd, const char *dump, struct settings *set,
 			 uint64_t labelsector, struct device *dev)
 {
-	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
+	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
 	uint32_t mda1_checksum, mda2_checksum;
 	int mda_count = 0;
 	int bad = 0;
@@ -1256,12 +1316,14 @@ static int _dump_headers(struct cmd_context *cmd, const char *dump, struct setti
 	return 1;
 }
 
+/* all sizes and offsets in bytes */
+
 static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct settings *set,
 			 uint64_t labelsector, struct device *dev,
 			 int print_metadata, int print_area)
 {
 	const char *tofile = NULL;
-	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
+	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
 	uint32_t mda1_checksum, mda2_checksum;
 	int mda_count = 0;
 	int mda_num = 1;
@@ -1309,9 +1371,11 @@ static int _dump_metadata(struct cmd_context *cmd, const char *dump, struct sett
 	return 1;
 }
 
+/* all sizes and offsets in bytes */
+
 static int _dump_found(struct cmd_context *cmd, struct settings *set, uint64_t labelsector, struct device *dev)
 {
-	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
+	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
 	uint32_t mda1_checksum = 0, mda2_checksum = 0;
 	int found_label = 0, found_header1 = 0, found_header2 = 0;
 	int mda_count = 0;
@@ -1357,6 +1421,8 @@ static int _dump_found(struct cmd_context *cmd, struct settings *set, uint64_t l
 #define ONE_MB_IN_BYTES 1048576
 
 /*
+ * all sizes and offsets in bytes (except dev_sectors from dev_get_size)
+ *
  * Look for metadata text in common locations, without using any headers
  * (pv_header/mda_header) to find the location, since the headers may be
  * zeroed/damaged.
@@ -1367,8 +1433,8 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 {
 	const char *tofile = NULL;
 	char *buf;
-	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
-	uint64_t mda_offset, mda_size;
+	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
+	uint64_t mda_offset, mda_size; /* bytes */
 	int mda_count = 0;
 	int mda_num = 1;
 
@@ -1414,7 +1480,8 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 		uint64_t dev_bytes;
 		uint64_t extra_bytes;
 
-		dev_get_size(dev, &dev_sectors);
+		if (dev_get_size(dev, &dev_sectors))
+			stack;
 
 		dev_bytes = dev_sectors * 512;
 		extra_bytes = dev_bytes % ONE_MB_IN_BYTES;
@@ -1441,9 +1508,8 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 	log_print("Searching for metadata at offset %llu size %llu",
 		  (unsigned long long)mda_offset, (unsigned long long)mda_size);
 
-	if (!(buf = malloc(mda_size)))
+	if (!(buf = zalloc(mda_size)))
 		return_0;
-	memset(buf, 0, mda_size);
 
 	if (!dev_read_bytes(dev, mda_offset, mda_size, buf)) {
 		log_print("CHECK: failed to read metadata area at offset %llu size %llu",
@@ -1458,6 +1524,8 @@ static int _dump_search(struct cmd_context *cmd, const char *dump, struct settin
 	return 1;
 }
 
+/* all sizes and offsets in bytes */
+
 static int _get_one_setting(struct cmd_context *cmd, struct settings *set, char *key, char *val)
 {
 	if (!strncmp(key, "metadata_offset", strlen("metadata_offset"))) {
@@ -1467,6 +1535,19 @@ static int _get_one_setting(struct cmd_context *cmd, struct settings *set, char
 		return 1;
 	}
 
+	if (!strncmp(key, "seqno", strlen("seqno"))) {
+		if (sscanf(val, "%u", &set->seqno) != 1)
+			goto_bad;
+		set->seqno_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "backup_file", strlen("backup_file"))) {
+		if ((set->backup_file = strdup(val)))
+			return 1;
+		return 0;
+	}
+
 	if (!strncmp(key, "mda_offset", strlen("mda_offset"))) {
 		if (sscanf(val, "%llu", (unsigned long long *)&set->mda_offset) != 1)
 			goto_bad;
@@ -1480,6 +1561,54 @@ static int _get_one_setting(struct cmd_context *cmd, struct settings *set, char
 		set->mda_size_set = 1;
 		return 1;
 	}
+
+	if (!strncmp(key, "mda2_offset", strlen("mda2_offset"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&set->mda2_offset) != 1)
+			goto_bad;
+		set->mda2_offset_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "mda2_size", strlen("mda2_size"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&set->mda2_size) != 1)
+			goto_bad;
+		set->mda2_size_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "device_size", strlen("device_size"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&set->device_size) != 1)
+			goto_bad;
+		set->device_size_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "data_offset", strlen("data_offset"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&set->data_offset) != 1)
+			goto_bad;
+		set->data_offset_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "pv_uuid", strlen("pv_uuid"))) {
+		if (strchr(val, '-') && (strlen(val) == 32)) {
+			memcpy(&set->pvid, val, 32);
+			set->pvid_set = 1;
+			return 1;
+		} else if (id_read_format_try(&set->pvid, val)) {
+			set->pvid_set = 1;
+			return 1;
+		} else {
+			log_error("Failed to parse UUID from pv_uuid setting.");
+			goto bad;
+		}
+	}
+
+	if (!strncmp(key, "mda_num", strlen("mda_num"))) {
+		if (sscanf(val, "%u", (int *)&set->mda_num) != 1)
+			goto_bad;
+		return 1;
+	}
 bad:
 	log_error("Invalid setting: %s", key);
 	return 0;
@@ -1494,8 +1623,6 @@ static int _get_settings(struct cmd_context *cmd, struct settings *set)
 	int num;
 	int pos;
 
-	memset(set, 0, sizeof(struct settings));
-
 	/*
 	 * "grouped" means that multiple --settings options can be used.
 	 * Each option is also allowed to contain multiple key = val pairs.
@@ -1531,16 +1658,1127 @@ static int _get_settings(struct cmd_context *cmd, struct settings *set)
 	return 1;
 }
 
+/*
+ * pvck --repairtype label_header
+ *
+ * Writes new label_header without changing pv_header fields.
+ * All constant values except for recalculated crc.
+ *
+ * all sizes and offsets in bytes
+ */
+
+static int _repair_label_header(struct cmd_context *cmd, const char *repair,
+			        struct settings *set, uint64_t labelsector, struct device *dev)
+{
+	char buf[512];
+	struct label_header *lh;
+	struct pv_header *pvh;
+	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
+	uint64_t lh_offset;  /* bytes */
+	uint64_t pvh_offset; /* bytes */
+	uint32_t crc;
+	int mda_count;
+	int found_label = 0;
+
+	lh_offset = labelsector * 512; /* from start of disk */
+
+	_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
+			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
+
+	if (!found_label) {
+		log_warn("WARNING: No LVM label found on %s.  It may not be an LVM device.", dev_name(dev));
+		if (!arg_count(cmd, yes_ARG) &&
+		    yes_no_prompt("Write LVM header to device? ") == 'n')
+			return 0;
+	}
+
+	if (!dev_read_bytes(dev, lh_offset, 512, buf)) {
+	        log_error("Failed to read label_header at %llu", (unsigned long long)lh_offset);
+	        return 0;
+	}
+
+	lh = (struct label_header *)buf;
+	pvh = (struct pv_header *)(buf + 32);
+	pvh_offset = lh_offset + 32; /* from start of disk */
+
+	/* sanity check */
+	if ((void *)pvh != (void *)(buf + pvh_offset - lh_offset)) {
+	        log_error("Problem with pv_header offset calculation");
+	        return 0;
+	}
+
+	memcpy(lh->id, LABEL_ID, sizeof(lh->id));
+	memcpy(lh->type, LVM2_LABEL, sizeof(lh->type));
+	lh->sector_xl =  xlate64(labelsector);
+	lh->offset_xl = xlate32(32);
+
+	crc = calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl,
+	               LABEL_SIZE - ((uint8_t *) &lh->offset_xl - (uint8_t *) lh));
+
+	lh->crc_xl = xlate32(crc);
+       
+	log_print("Writing label_header.crc 0x%08x", crc);
+
+	if (arg_is_set(cmd, test_ARG)) {
+		log_warn("Skip writing in test mode.");
+		return 1;
+	}
+
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Write new LVM header to %s? ", dev_name(dev)) == 'n')
+		return 0;
+
+	if (!dev_write_bytes(dev, lh_offset, 512, buf)) {
+	        log_error("Failed to write new header");
+	        return 0;
+	}
+	return 1;
+}
+
+static int _get_pv_info_from_metadata(struct cmd_context *cmd, struct settings *set,
+				     struct device *dev,
+				     struct pv_header *pvh, int found_label,
+				     char *text_buf, uint64_t text_size,
+				     char *pvid,
+				     uint64_t *device_size_sectors,
+				     uint64_t *pe_start_sectors)
+{
+	int8_t pvid_cur[ID_LEN+1];  /* found in existing pv_header */
+	int8_t pvid_set[ID_LEN+1];  /* set by user in --settings */
+	int8_t pvid_use[ID_LEN+1];  /* the pvid chosen to use */
+	int pvid_cur_valid = 0;     /* pvid_cur is valid */
+	int pvid_use_valid = 0;     /* pvid_use is valid */
+	struct dm_config_tree *cft = NULL;
+	struct volume_group *vg = NULL;
+	struct pv_list *pvl;
+
+	memset(pvid_cur, 0, sizeof(pvid_cur));
+	memset(pvid_set, 0, sizeof(pvid_set));
+	memset(pvid_use, 0, sizeof(pvid_use));
+
+	/*
+	 * Check if there's a valid existing PV UUID at the expected location.
+	 */
+	if (!id_read_format_try((struct id *)&pvid_cur, (char *)&pvh->pv_uuid))
+		memset(&pvid_cur, 0, ID_LEN);
+	else {
+		memcpy(&pvid_use, &pvid_cur, ID_LEN);
+		pvid_use_valid = 1;
+		pvid_cur_valid = 1;
+	}
+
+	if (set->pvid_set) {
+		memcpy(&pvid_set, &set->pvid, ID_LEN);
+		memcpy(&pvid_use, &pvid_set, ID_LEN);
+		pvid_use_valid = 1;
+	}
+
+	if (pvid_cur_valid && set->pvid_set && memcmp(&pvid_cur, &pvid_set, ID_LEN)) {
+		log_warn("WARNING: existing PV UUID %s does not match pv_uuid setting %s.",
+			 (char *)&pvid_cur, (char *)&pvid_set);
+
+		memcpy(&pvid_use, &pvid_set, ID_LEN);
+		pvid_use_valid = 1;
+	}
+
+	if (!_text_buf_parse(text_buf, text_size, &cft)) {
+		log_error("Invalid metadata file.");
+		return 0;
+	}
+
+	if (!(vg = vg_from_config_tree(cmd, cft))) {
+		config_destroy(cft);
+		log_error("Invalid metadata file.");
+		return 0;
+	}
+
+	config_destroy(cft);
+
+	/*
+	 * If pvid_use is set, look for metadata PV section with matching PV UUID.
+	 * Otherwise, look for metadata PV section with device name matching dev.
+	 *
+	 * pvid_use will be empty if there's no valid UUID in the existing
+	 * pv_header, and the user did not specify a UUID in --settings.
+	 *
+	 * Choosing the PV UUID based only on a matching device name is somewhat
+	 * weak since device names are dynamic, but we do scan devs to verify the
+	 * chosen PV UUID is not in use elsewhere, which should avoid most of the
+	 * risk of picking a wrong UUID.
+	 */
+	if (!pvid_use_valid) {
+		dm_list_iterate_items(pvl, &vg->pvs) {
+			if (!strcmp(pvl->pv->device_hint, dev_name(dev)))
+				goto copy_pv;
+		}
+	} else {
+		dm_list_iterate_items(pvl, &vg->pvs) {
+			if (id_equal(&pvl->pv->id, (struct id *)&pvid_use))
+				goto copy_pv;
+		}
+	}
+
+	release_vg(vg);
+
+	/*
+	 * Don't know what PV UUID to use, possibly:
+	 * . the user set a PV UUID that does not exist in the metadata file
+	 * . the UUID in the existing pv_header does not exist in the metadata file
+	 * . the metadata has no PV with a device name hint matching this device
+	 */
+	if (set->pvid_set)
+		log_error("PV UUID %s not found in metadata file.", (char *)&pvid_set);
+	else if (pvid_cur_valid)
+		log_error("PV UUID %s in existing pv_header not found in metadata file.", (char *)&pvid_cur);
+	else if (!pvid_use_valid)
+		log_error("PV name %s not found in metadata file.", dev_name(dev));
+
+	log_error("No valid PV UUID, specify a PV UUID from metadata in --settings.");
+	return 0;
+
+ copy_pv:
+	*device_size_sectors = pvl->pv->size;
+	*pe_start_sectors = pvl->pv->pe_start;
+	memcpy(pvid, &pvl->pv->id, ID_LEN);
+
+	release_vg(vg);
+	return 1;
+}
+
+/*
+ * Checking for mda1 is simple because it's always at the same location,
+ * and when a PV is set to use zero metadata areas, this space is just
+ * unused.  We could look for any surviving metadata text in mda1
+ * containing the VG UUID to confirm that this PV has been used for
+ * metadata, but if the start of the disk has been zeroed, then we
+ * may not find any.
+ */
+static int _check_for_mda1(struct cmd_context *cmd, struct device *dev)
+{
+	char buf[512];
+	struct mda_header *mh;
+
+	if (!dev_read_bytes(dev, 4096, 512, buf))
+		return_0;
+
+	mh = (struct mda_header *)buf;
+
+	if (!memcmp(mh->magic, FMTT_MAGIC, sizeof(mh->magic)))
+		return 1;
+	return 0;
+}
+
+/*
+ * Checking for mda2 is more complicated.  Very often PVs will not use
+ * a second mda2, and the location is not quite as predictable.  Also,
+ * if we mistakenly conclude that an mda2 belongs on the PV, we'd end
+ * up writing into the data area.
+ *
+ * all sizes and offsets in bytes
+ */
+static int _check_for_mda2(struct cmd_context *cmd, struct device *dev,
+			   uint64_t device_size, struct metadata_file *mf,
+			   uint64_t *mda2_offset, uint64_t *mda2_size)
+{
+	struct mda_header *mh;
+	char buf2[256];
+	char *buf;
+	uint64_t mda_offset, mda_size, extra_bytes; /* bytes */
+	int i, found = 0;
+
+	if (device_size < (2 * ONE_MB_IN_BYTES))
+		return_0;
+
+	extra_bytes = device_size % ONE_MB_IN_BYTES;
+	mda_offset = device_size - extra_bytes - ONE_MB_IN_BYTES;
+	mda_size = device_size - mda_offset;
+
+	if (!(buf = malloc(mda_size)))
+		return_0;
+
+	if (!dev_read_bytes(dev, mda_offset, mda_size, buf))
+		goto fail;
+
+	mh = (struct mda_header *)buf;
+
+	/*
+	 * To be certain this is really an mda_header before writing it,
+	 * require that magic, version and start are all correct.
+	 */
+
+	if (memcmp(mh->magic, FMTT_MAGIC, sizeof(mh->magic)))
+		goto fail;
+
+	if (xlate32(mh->version) != FMTT_VERSION) {
+		log_print("Skipping mda2 (wrong mda_header.version)");
+		goto fail;
+	}
+
+	if (xlate64(mh->start) != mda_offset) {
+		log_print("Skipping mda2 (wrong mda_header.start)");
+		goto fail;
+	}
+
+	/*
+	 * Search text area for an instance of current metadata before enabling
+	 * mda2, in case this mda_header is from a previous generation PV and
+	 * is not actually used by the current PV.  An mda_header and metadata
+	 * area from a previous PV (in a previous VG) that used mda2 might
+	 * still exist, while the current PV does not use an mda2.
+	 *
+	 * Search for the vgid in the first 256 bytes at each 512 byte boundary
+	 * in the first half of the metadata area.
+	 */
+	for (i = 0; i < (mda_size / 1024); i++) {
+		memcpy(buf2, buf + 512 + (i * 512), sizeof(buf2));
+
+		if (strstr(buf2, mf->vgid_str)) {
+			log_print("Found mda2 header at offset %llu size %llu",
+				  (unsigned long long)mda_offset, (unsigned long long)mda_size);
+			*mda2_offset = mda_offset;
+			*mda2_size = mda_size;
+			found = 1;
+			break;
+		}
+	}
+	if (!found) {
+		log_print("Skipping mda2 (no matching VG UUID in metadata area)");
+		goto fail;
+	}
+
+	free(buf);
+	return 1;
+
+ fail:
+	free(buf);
+	*mda2_offset = 0;
+	*mda2_size = 0;
+	return 0;
+}
+
+/*
+ * pvck --repairtype pv_header --file input --settings
+ *
+ * Writes new pv_header and label_header.
+ *
+ * pv_header.pv_uuid
+ * If a uuid is given in --settings, that is used.
+ * Else if existing pv_header has a valid uuid, that is used.
+ * Else if the metadata file has a matching device name, that uuid is used.
+ *
+ * pv_header.device_size
+ * Use device size from metadata file.
+ *
+ * pv_header.disk_locn[0].offset (data area start)
+ * Use pe_start from metadata file.
+ *
+ * pv_header.disk_locn[2].offset/size (first metadata area)
+ * offset always 4096.  size is pe_start - offset.
+ *
+ * pv_header.disk_locn[3].offset/size (second metadata area)
+ * Look for existing mda_header at expected offset, and if
+ * found use that value.  Otherwise second mda is not used.
+ *
+ * The size/offset variables in sectors have a _sectors suffix,
+ * any other size/offset variables in bytes.
+ */
+
+static int _repair_pv_header(struct cmd_context *cmd, const char *repair,
+			     struct settings *set, struct metadata_file *mf,
+			     uint64_t labelsector, struct device *dev)
+{
+	char head_buf[512];
+	int8_t pvid[ID_LEN+1];
+	struct device *dev_with_pvid = NULL;
+	struct label_header *lh;
+	struct pv_header *pvh;
+	struct pv_header_extension *pvhe;
+	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
+	uint64_t lh_offset;               /* in bytes, from start of disk */
+	uint64_t device_size = 0;         /* in bytes, as stored in pv_header */
+	uint64_t device_size_sectors = 0; /* in sectors, as stored in metadata */
+	uint64_t get_size_sectors = 0;    /* in sectors, as dev_get_size returns */
+	uint64_t get_size = 0;            /* in bytes */
+	uint64_t pe_start_sectors;        /* in sectors, as stored in metadata */
+	uint64_t data_offset;             /* in bytes, as stored in pv_header */
+	uint32_t head_crc;
+	int mda_count;
+	int found_label = 0;
+	int di;
+
+	memset(&pvid, 0, ID_LEN+1);
+
+	lh_offset = labelsector * 512; /* from start of disk */
+
+	if (!dev_get_size(dev, &get_size_sectors))
+		log_warn("WARNING: Cannot get device size.");
+	get_size = get_size_sectors << SECTOR_SHIFT;
+
+	_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
+			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
+
+	/*
+	 * The header sector may have been zeroed, or the user may have
+	 * accidentally given the wrong device.
+	 */
+	if (!found_label)
+		log_warn("WARNING: No LVM label found on %s.  It may not be an LVM device.", dev_name(dev));
+
+	/*
+	 * The PV may have had no metadata areas, or one, or two.
+	 *
+	 * Try to avoid writing new metadata areas where they didn't exist
+	 * before.  Writing mda1 when it didn't exist previously would not be
+	 * terrible since the space is unused anyway, but wrongly writing mda2
+	 * could end up in the data area.
+	 *
+	 * When the pv_header has no mda1 or mda2 locations, check for evidence
+	 * of prior mda headers for mda1 and mda2.
+	 *
+	 * When the pv_header has an mda1 location and no mda2 location, just
+	 * use mda1 and don't look for mda2 (unless requested by user setting)
+	 * since it probably did not exist.  (It's very unlikely that only the
+	 * mda2 location was zeroed in the pv_header.)
+	 */
+	if (!mda_count && !mda1_offset && !mda2_offset) {
+		if (_check_for_mda1(cmd, dev))
+			mda_count = 1;
+
+		if (_check_for_mda2(cmd, dev, get_size, mf, &mda2_offset, &mda2_size))
+			mda_count = 2;
+	}
+
+	/*
+	 * The PV may have had zero metadata areas (not common), or the
+	 * pv_header and the mda1 header@4096 may have been zeroed
+	 * (more likely).  Ask the user if metadata in mda1 should be
+	 * included; it would usually be yes.  To repair a PV and use
+	 * zero metadata areas, require the user to specify
+	 * --settings "mda_offset=0 mda_size=0".
+	 *
+	 * NOTE: mda1 is not written by repair pv_header, this will only
+	 * include a pointer to mda1 in the pv_header so that a subsequent
+	 * repair metadata will use that to write an mda_header and metadata.
+	 */
+	if (!mda_count && set->mda_offset_set && set->mda_size_set &&
+	    !set->mda_offset && !set->mda_size) {
+		log_warn("WARNING: PV will have no metadata with zero metadata areas.");
+
+	} else if (!mda_count) {
+		log_warn("WARNING: no previous metadata areas found on device.");
+
+		if (arg_count(cmd, yes_ARG) ||
+		    yes_no_prompt("Should a metadata area be included? ") == 'y') {
+			/* mda1_offset/mda1_size are set below */
+			mda_count = 1;
+		} else {
+			log_error("To repair with zero metadata areas, use --settings \"mda_offset=0 mda_size=0\".");
+			goto fail;
+		}
+	}
+
+	/*
+	 * The user has provided offset or size for mda2.  This would
+	 * usually be done when these values do not exist on disk,
+	 * but if mda2 *is* found on disk, ensure it agrees with the
+	 * user's setting.
+	 */
+	if (mda_count && (set->mda2_offset_set || set->mda2_size_set)) {
+		if (mda2_offset && (mda2_offset != set->mda2_offset)) {
+			log_error("mda2_offset setting %llu does not match mda2_offset found on disk %llu.",
+				 (unsigned long long)set->mda2_offset, (unsigned long long)mda2_offset);
+			goto fail;
+		}
+		if (mda2_size && (mda2_size != set->mda2_size)) {
+			log_error("mda2_size setting %llu does not match mda2_size found on disk %llu.",
+				 (unsigned long long)set->mda2_size, (unsigned long long)mda2_size);
+			goto fail;
+		}
+		mda2_offset = set->mda2_offset;
+		mda2_size = set->mda2_size;
+		mda_count = 2;
+	}
+
+	/*
+	 * The header sector is read into this buffer.
+	 * This same buffer is modified and written back.
+	 */
+	if (!dev_read_bytes(dev, lh_offset, 512, head_buf)) {
+	        log_error("Failed to read label_header at %llu", (unsigned long long)lh_offset);
+		goto fail;
+	}
+
+	lh = (struct label_header *)head_buf;
+	pvh = (struct pv_header *)(head_buf + 32);
+
+	/*
+	 * Metadata file is not needed if user provides pvid/device_size/data_offset.
+	 * All values in settings are in bytes.
+	 */
+	if (set->device_size_set && set->pvid_set && set->data_offset_set && !mf->filename) {
+		device_size = set->device_size;
+		pe_start_sectors = set->data_offset >> SECTOR_SHIFT;
+		memcpy(&pvid, &set->pvid, ID_LEN);
+
+		if (get_size && (get_size != device_size)) {
+			log_warn("WARNING: device_size setting %llu bytes does not match device size %llu bytes.",
+				 (unsigned long long)set->device_size, (unsigned long long)get_size);
+		}
+		goto scan;
+	}
+
+	if (!mf->filename) {
+		log_error("Metadata input file is needed for pv_header info.");
+		log_error("See pvck --dump to locate and create a metadata file.");
+		goto fail;
+	}
+
+	/*
+	 * Look in the provided copy of VG metadata for info that determines
+	 * pv_header fields.
+	 *
+	 * pv<N> {
+	 * 	id = <uuid>
+	 * 	device = <path>  # device path hint, set when metadata was last written
+	 * 	...
+	 * 	dev_size = <num> # in 512 sectors
+	 * 	pe_start = <num> # in 512 sectors
+	 * }
+	 *
+	 * Select the right pv entry by matching an existing pv uuid, or the
+	 * current device name to the device path hint.  Take the pv uuid,
+	 * dev_size and pe_start from the metadata to use in the pv_header.
+	 */
+	if (!_get_pv_info_from_metadata(cmd, set, dev, pvh, found_label,
+					mf->text_buf, mf->text_size, (char *)&pvid,
+					&device_size_sectors, &pe_start_sectors))
+		goto fail;
+
+	/*
+	 * In pv_header, device_size is bytes, but in metadata dev_size is in sectors.
+	 */
+	device_size = device_size_sectors << SECTOR_SHIFT;
+
+ scan:
+	/*
+	 * Read all devs to verify the pvid that will be written does not exist
+	 * on another device.
+	 */
+	if (!label_scan_for_pvid(cmd, (char *)&pvid, &dev_with_pvid)) {
+		log_error("Failed to scan devices to check PV UUID.");
+		goto fail;
+	}
+
+	if (dev_with_pvid && (dev_with_pvid != dev)) {
+		log_error("Cannot use PV UUID %s which exists on %s", (char *)&pvid, dev_name(dev_with_pvid));
+		goto fail;
+	}
+
+	/*
+	 * Set new label_header and pv_header fields.
+	 */
+
+	/* set label_header (except crc) */
+	memcpy(lh->id, LABEL_ID, sizeof(lh->id));
+	memcpy(lh->type, LVM2_LABEL, sizeof(lh->type));
+	lh->sector_xl =  xlate64(labelsector);
+	lh->offset_xl = xlate32(32);
+
+	/* set pv_header */
+	memcpy(pvh->pv_uuid, &pvid, ID_LEN);
+	pvh->device_size_xl = xlate64(device_size);
+
+	/* set data area location */
+	data_offset = (pe_start_sectors << SECTOR_SHIFT);
+	pvh->disk_areas_xl[0].offset = xlate64(data_offset);
+	pvh->disk_areas_xl[0].size = 0;
+
+	/* set end of data areas */
+	pvh->disk_areas_xl[1].offset = 0;
+	pvh->disk_areas_xl[1].size = 0;
+
+	di = 2;
+
+	/* set first metadata area location */
+	if (mda_count > 0) {
+		mda1_offset = 4096;
+		mda1_size = (pe_start_sectors << SECTOR_SHIFT) - 4096;
+		pvh->disk_areas_xl[di].offset = xlate64(mda1_offset);
+		pvh->disk_areas_xl[di].size = xlate64(mda1_size);
+		di++;
+	}
+
+	/* set second metadata area location */
+	if (mda_count > 1) {
+		pvh->disk_areas_xl[di].offset = xlate64(mda2_offset);
+		pvh->disk_areas_xl[di].size = xlate64(mda2_size);
+		di++;
+	}
+
+	/* set end of metadata areas */
+	pvh->disk_areas_xl[di].offset = 0;
+	pvh->disk_areas_xl[di].size = 0;
+	di++;
+
+	/* set pv_header_extension */
+	pvhe = (struct pv_header_extension *)((char *)pvh + sizeof(struct pv_header) + (di * sizeof(struct disk_locn)));
+	pvhe->version = xlate32(PV_HEADER_EXTENSION_VSN);
+	pvhe->flags = xlate32(PV_EXT_USED);
+	pvhe->bootloader_areas_xl[0].offset = 0;
+	pvhe->bootloader_areas_xl[0].size = 0;
+
+	head_crc = calc_crc(INITIAL_CRC, (uint8_t *)&lh->offset_xl,
+			    LABEL_SIZE - ((uint8_t *) &lh->offset_xl - (uint8_t *) lh));
+
+	/* set label_header crc (last) */
+	lh->crc_xl = xlate32(head_crc);
+
+	/*
+	 * Write the updated header sector.
+	 */
+
+	log_print("Writing label_header.crc 0x%08x pv_header uuid %s device_size %llu",
+		  head_crc, (char *)&pvid, (unsigned long long)device_size);
+
+	log_print("Writing data_offset %llu mda1_offset %llu mda1_size %llu mda2_offset %llu mda2_size %llu",
+		  (unsigned long long)data_offset,
+		  (unsigned long long)mda1_offset,
+		  (unsigned long long)mda1_size,
+		  (unsigned long long)mda2_offset,
+		  (unsigned long long)mda2_size);
+
+	if (arg_is_set(cmd, test_ARG)) {
+		log_warn("Skip writing in test mode.");
+		return 1;
+	}
+
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Write new LVM header to %s? ", dev_name(dev)) == 'n')
+		goto fail;
+
+	if (!dev_write_bytes(dev, lh_offset, 512, head_buf)) {
+	        log_error("Failed to write new header");
+		goto fail;
+	}
+
+	return 1;
+fail:
+	return 0;
+}
+
+/* all sizes and offsets in bytes */
+
+static int _update_mda(struct cmd_context *cmd, struct metadata_file *mf, struct device *dev,
+		       int mda_num, uint64_t mda_offset, uint64_t mda_size)
+{
+	char *buf[512];
+	struct mda_header *mh;
+	struct raw_locn *rlocn0, *rlocn1;
+	uint64_t max_size;
+	uint64_t text_offset;
+	uint32_t crc;
+
+	max_size = ((mda_size - 512) / 2) - 512;
+	if (mf->text_size > mda_size) {
+		log_error("Metadata text %llu too large for mda_size %llu max %llu",
+			  (unsigned long long)mf->text_size,
+			  (unsigned long long)mda_size,
+			  (unsigned long long)max_size);
+		goto fail;
+	}
+
+	if (!dev_read_bytes(dev, mda_offset, 512, buf)) {
+		log_print("CHECK: failed to read mda_header_%d at %llu",
+			  mda_num, (unsigned long long)mda_offset);
+		goto fail;
+	}
+
+	text_offset = mda_offset + 512;
+
+	mh = (struct mda_header *)buf;
+	memcpy(mh->magic, FMTT_MAGIC, sizeof(mh->magic));
+	mh->version = xlate32(FMTT_VERSION);
+	mh->start = xlate64(mda_offset);
+	mh->size = xlate64(mda_size);
+
+	rlocn0 = mh->raw_locns;
+	rlocn0->flags = 0;
+	rlocn0->offset = xlate64(512); /* text begins 512 from start of mda_header */
+	rlocn0->size = xlate64(mf->text_size);
+	rlocn0->checksum = xlate32(mf->text_crc);
+
+	rlocn1 = (struct raw_locn *)((char *)mh->raw_locns + 24);
+	rlocn1->flags = 0;
+	rlocn1->offset = 0;
+	rlocn1->size = 0;
+	rlocn1->checksum = 0;
+
+	crc = calc_crc(INITIAL_CRC, (uint8_t *)mh->magic,
+		       MDA_HEADER_SIZE - sizeof(mh->checksum_xl));
+	mh->checksum_xl = xlate32(crc);
+
+	log_print("Writing metadata at %llu length %llu crc 0x%08x mda%d",
+		  (unsigned long long)(mda_offset + 512),
+		  (unsigned long long)mf->text_size, mf->text_crc, mda_num);
+
+	log_print("Writing mda_header at %llu mda%d",
+		  (unsigned long long)mda_offset, mda_num);
+
+	if (arg_is_set(cmd, test_ARG)) {
+		log_warn("Skip writing in test mode.");
+		return 1;
+	}
+
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Write new LVM metadata to %s? ", dev_name(dev)) == 'n')
+		goto fail;
+
+	if (!dev_write_bytes(dev, text_offset, mf->text_size, mf->text_buf)) {
+		log_error("Failed to write new mda text");
+		goto fail;
+	}
+
+	if (!dev_write_bytes(dev, mda_offset, 512, buf)) {
+		log_error("Failed to write new mda header");
+		goto fail;
+	}
+
+	return 1;
+ fail:
+	return 0;
+}
+
+/*
+ * pvck --repairtype metadata --file input --settings
+ *
+ * Writes new metadata into the text area and writes new
+ * mda_header for it.  Requires valid mda locations in pv_header.
+ * Metadata is written immediately after mda_header.
+ *
+ * all sizes and offsets in bytes
+ */
+
+static int _repair_metadata(struct cmd_context *cmd, const char *repair,
+			    struct settings *set, struct metadata_file *mf,
+			    uint64_t labelsector, struct device *dev)
+{
+	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0; /* bytes */
+	int found_label = 0;
+	int mda_count = 0;
+	int mda_num;
+	int bad = 0;
+
+	mda_num = set->mda_num;
+
+	if (!mf->filename) {
+		log_error("Metadata input file is required.");
+		return 0;
+	}
+
+	_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
+			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
+
+	if (!found_label) {
+		log_error("No lvm label found on device.");
+		log_error("See --repairtype pv_header to repair headers.");
+		return 0;
+	}
+
+	if (!mda_count && set->mda_offset_set && set->mda_size_set &&
+	    !set->mda_offset && !set->mda_size) {
+		log_print("No metadata areas on device to repair.");
+		return 1;
+	}
+
+	if (!mda_count) {
+		log_error("No metadata areas found on device.");
+		log_error("See --repairtype pv_header to repair headers.");
+		return 0;
+	}
+
+	if ((mda_num == 1) && !mda1_offset) {
+		log_error("No mda1 offset found.");
+		log_error("See --repairtype pv_header to repair headers.");
+		return 0;
+	}
+
+	if ((mda_num == 2) && !mda2_offset) {
+		log_error("No mda2 offset found.");
+		log_error("See --repairtype pv_header to repair headers.");
+		return 0;
+	}
+
+	if ((!mda_num || mda_num == 1) && mda1_offset) {
+		if (!_update_mda(cmd, mf, dev, 1, mda1_offset, mda1_size))
+			bad++;
+	}
+
+	if ((!mda_num || mda_num == 2) && mda2_offset) {
+		if (!_update_mda(cmd, mf, dev, 2, mda2_offset, mda2_size))
+			bad++;
+	}
+
+	if (bad)
+		return 0;
+
+	return 1;
+}
+
+static void _strip_backup_line(char *line1, int len1, char *line2, int *len2)
+{
+	int copying = 0;
+	int i, j = 0;
+
+	for (i = 0; i < len1; i++) {
+		if (line1[i] == '\0')
+			break;
+
+		if (line1[i] == '\n')
+			break;
+
+		/* omit tabs at start of line */
+		if (!copying && (line1[i] == '\t'))
+			continue;
+
+		/* omit tabs and comment@end of line (can tabs occur without comment?) */
+		if (copying && (line1[i] == '\t') && strchr(line1 + i, '#'))
+			break;
+
+		copying = 1;
+
+		line2[j++] = line1[i];
+	}
+
+	line2[j++] = '\n';
+	*len2 = j;
+}
+
+#define MAX_META_LINE 4096
+
+/* all sizes and offsets in bytes */
+
+static int _backup_file_to_raw_metadata(char *back_buf, uint64_t back_size,
+					char **text_buf_out, uint64_t *text_size_out)
+{
+	char line[MAX_META_LINE];
+	char line2[MAX_META_LINE];
+	char *p, *text_buf;
+	uint32_t text_pos, pre_len, back_pos, text_max;
+	int len, len2, vgnamelen;
+
+	text_max = back_size * 2;
+
+	if (!(text_buf = malloc(text_max)))
+		return_0;
+	memset(text_buf, 0, text_max);
+
+	p = back_buf;
+	text_pos = 0;
+	back_pos = 0;
+
+	while (1) {
+		if (back_pos >= back_size)
+			break;
+
+		memset(line, 0, sizeof(line));
+		len = 0;
+
+		_copy_line(p, line, &len, sizeof(line));
+		p += len;
+		back_pos += len;
+
+		if (len < 3)
+			continue;
+
+		if (_check_vgname_start(line, &vgnamelen)) {
+			/* vg name is first line of text_buf */
+			memcpy(text_buf, line, len);
+			text_pos = len;
+
+			pre_len = back_pos - len;
+			break;
+		}
+	}
+
+	while (1) {
+		if (back_pos >= back_size)
+			break;
+
+		memset(line, 0, sizeof(line));
+		memset(line2, 0, sizeof(line2));
+		len = 0;
+		len2 = 0;
+
+		_copy_line(p, line, &len, sizeof(line));
+
+		if (line[0] == '\0')
+			break;
+
+		p += len;
+		back_pos += len;
+
+		/* shouldn't happen */
+		if (text_pos + len > text_max)
+			return_0;
+
+		if (len == 1) {
+			text_buf[text_pos++] = '\n';
+			continue;
+		}
+
+		_strip_backup_line(line, len, line2, &len2);
+
+		memcpy(text_buf + text_pos, line2, len2);
+		text_pos += len2;
+	}
+
+	/* shouldn't happen */
+	if (text_pos + pre_len + 3 > text_max)
+		return_0;
+
+	/* copy first pre_len bytes of back_buf into text_buf */
+	memcpy(text_buf + text_pos, back_buf, pre_len);
+	text_pos += pre_len;
+
+	text_pos++; /* null termination */
+
+	*text_size_out = text_pos;
+	*text_buf_out = text_buf;
+
+	return 1;
+}
+
+static int _is_backup_file(struct cmd_context *cmd, char *text_buf, uint64_t text_size)
+{
+	if ((text_buf[0] == '#') && !strncmp(text_buf, "# Generated", 11))
+		return 1;
+	return 0;
+}
+
+/* all sizes and offsets in bytes */
+
+static int _dump_backup_to_raw(struct cmd_context *cmd, struct settings *set)
+{
+	const char *input = set->backup_file;
+	const char *tofile = NULL;
+	struct stat sb;
+	char *back_buf, *text_buf;
+	uint64_t back_size, text_size;
+	int fd, rv;
+
+	if (arg_is_set(cmd, file_ARG)) {
+		if (!(tofile = arg_str_value(cmd, file_ARG, NULL)))
+			return_0;
+	}
+
+	if (!input) {
+		log_error("Set backup file in --settings backup_file=path");
+		return 0;
+	}
+
+	if (!(fd = open(input, O_RDONLY))) {
+		log_error("Cannot open file: %s", input);
+		return 0;
+	}
+
+	if (fstat(fd, &sb)) {
+		log_error("Cannot access file: %s", input);
+		close(fd);
+		return 0;
+	}
+
+	if (!(back_size = (uint64_t)sb.st_size)) {
+		log_error("Empty file: %s", input);
+		close(fd);
+		return 0;
+	}
+
+	if (!(back_buf = zalloc(back_size))) {
+		close(fd);
+		return 0;
+	}
+
+	rv = read(fd, back_buf, back_size);
+	if (rv != back_size) {
+		log_error("Cannot read file: %s", input);
+		close(fd);
+		free(back_buf);
+		return 0;
+	}
+
+	close(fd);
+
+	if (!_is_backup_file(cmd, back_buf, back_size)) {
+		log_error("File does not appear to contain a metadata backup.");
+		free(back_buf);
+		return 0;
+	}
+
+	if (!_backup_file_to_raw_metadata(back_buf, back_size, &text_buf, &text_size)) {
+		free(back_buf);
+		return_0;
+	}
+
+	free(back_buf);
+
+	if (!tofile) {
+		log_print("---");
+		printf("%s\n", text_buf);
+		log_print("---");
+	} else {
+		FILE *fp;
+		if (!(fp = fopen(tofile, "wx"))) {
+			log_error("Failed to create file %s", tofile);
+			return 0;
+		}
+
+		fprintf(fp, "%s", text_buf);
+
+		if (fflush(fp))
+			stack;
+		if (fclose(fp))
+			stack;
+	}
+
+	return 1;
+}
+
+/* all sizes and offsets in bytes */
+
+static int _check_metadata_file(struct cmd_context *cmd, struct metadata_file *mf,
+				char *text_buf, int text_size)
+{
+	char *vgid;
+	int namelen;
+
+	if (text_size < NAME_LEN+1) {
+		log_error("Invalid raw text metadata in file.  File size is too small.");
+		return 0;
+	}
+
+	/*
+	 * Using pvck --dump metadata output redirected to file may be a common
+	 * mistake, so check and warn about that specifically.
+	 */
+	if (isspace(text_buf[0]) && isspace(text_buf[1]) && strstr(text_buf, "---")) {
+		log_error("Invalid raw text metadata in file.");
+		log_error("(pvck stdout is not valid input, see pvck -f.)");
+		return 0;
+	}
+
+	/*
+	 * Using a metadata backup file may be another common mistake.
+	 */
+	if ((text_buf[0] == '#') && !strncmp(text_buf, "# Generated", 11)) {
+		log_error("Invalid raw text metadata in file.");
+		log_error("(metadata backup file is not valid input.)");
+		return 0;
+	}
+
+	if (text_buf[text_size-1] != '\0' ||
+	    text_buf[text_size-2] != '\n' ||
+	    text_buf[text_size-3] != '\n')
+		log_warn("WARNING: unexpected final bytes of raw metadata, expected \\n\\n\\0.");
+
+	if (_check_vgname_start(text_buf, &namelen)) {
+		if (!(vgid = strstr(text_buf, "id = "))) {
+			log_error("Invalid raw text metadata in file.  (No VG UUID found.)");
+			return 0;
+		}
+		memcpy(mf->vgid_str, vgid + 6, 38);
+		return 1;
+	}
+
+	log_warn("WARNING: file data does not begin with a VG name and may be invalid.");
+
+	if (!arg_count(cmd, yes_ARG) &&
+	    yes_no_prompt("Write input file data to disk?") == 'n') {
+		log_error("Invalid raw text metadata in file.");
+		return 0;
+	}
+
+	return 1;
+}
+
+/* all sizes and offsets in bytes */
+
+static int _read_metadata_file(struct cmd_context *cmd, struct metadata_file *mf)
+{
+	struct stat sb;
+	char *text_buf;
+	uint64_t text_size;
+	uint32_t text_crc;
+	int fd, rv;
+
+	if (!(fd = open(mf->filename, O_RDONLY))) {
+		log_error("Cannot open file: %s", mf->filename);
+		return 0;
+	}
+
+	if (fstat(fd, &sb)) {
+		log_error("Cannot access file: %s", mf->filename);
+		close(fd);
+		return 0;
+	}
+
+	if (!(text_size = (uint64_t)sb.st_size)) {
+		log_error("Empty file: %s", mf->filename);
+		close(fd);
+		return 0;
+	}
+
+	if (!(text_buf = zalloc(text_size + 1))) {
+		close(fd);
+		return 0;
+	}
+
+	rv = read(fd, text_buf, text_size);
+	if (rv != text_size) {
+		log_error("Cannot read file: %s", mf->filename);
+		close(fd);
+		free(text_buf);
+		return 0;
+	}
+
+	text_size += 1; /* null terminating byte */
+
+	close(fd);
+
+	if (_is_backup_file(cmd, text_buf, text_size)) {
+		char *back_buf = text_buf;
+		uint64_t back_size = text_size;
+		text_buf = NULL;
+		text_size = 0;
+		if (!_backup_file_to_raw_metadata(back_buf, back_size, &text_buf, &text_size))
+			return_0;
+	}
+
+	if (!_check_metadata_file(cmd, mf, text_buf, text_size))
+		return_0;
+
+	text_crc = calc_crc(INITIAL_CRC, (uint8_t *)text_buf, text_size);
+
+	mf->text_size = text_size;
+	mf->text_buf = text_buf;
+	mf->text_crc = text_crc;
+	return 1;
+}
+
 int pvck(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct settings set;
+	struct metadata_file mf;
 	struct device *dev;
-	const char *dump;
+	const char *dump, *repair;
 	const char *pv_name;
 	uint64_t labelsector = 1;
 	int bad = 0;
+	int ret = 0;
 	int i;
 
+	memset(&set, 0, sizeof(set));
+	memset(&mf, 0, sizeof(mf));
+
 	/*
 	 * By default LVM skips the first sector (sector 0), and writes
 	 * the label_header in the second sector (sector 1).
@@ -1549,7 +2787,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, labelsector_ARG))
 		labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
 
-	if (arg_is_set(cmd, dump_ARG)) {
+	if (arg_is_set(cmd, dump_ARG) || arg_is_set(cmd, repairtype_ARG) || arg_is_set(cmd, repair_ARG)) {
 		pv_name = argv[0];
 
 		if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
@@ -1561,6 +2799,14 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	if (!_get_settings(cmd, &set))
 		return ECMD_FAILED;
 
+	if (arg_is_set(cmd, file_ARG) && (arg_is_set(cmd, repairtype_ARG) || arg_is_set(cmd, repair_ARG))) {
+		if (!(mf.filename = arg_str_value(cmd, file_ARG, NULL)))
+			return ECMD_FAILED;
+
+		if (!_read_metadata_file(cmd, &mf))
+			return ECMD_FAILED;
+	}
+
 	label_scan_setup_bcache();
 
 	if (arg_is_set(cmd, dump_ARG)) {
@@ -1582,16 +2828,53 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 
 		else if (!strcmp(dump, "headers"))
 			ret = _dump_headers(cmd, dump, &set, labelsector, dev);
-		else {
+
+		else if (!strcmp(dump, "backup_to_raw")) {
+			ret = _dump_backup_to_raw(cmd, &set);
+
+		} else
 			log_error("Unknown dump value.");
-			ret = 0;
-		}
 
 		if (!ret)
 			return ECMD_FAILED;
 		return ECMD_PROCESSED;
 	}
 
+	if (arg_is_set(cmd, repairtype_ARG)) {
+		cmd->use_hints = 0;
+
+		repair = arg_str_value(cmd, repairtype_ARG, NULL);
+
+		if (!strcmp(repair, "label_header"))
+			ret = _repair_label_header(cmd, repair, &set, labelsector, dev);
+
+		else if (!strcmp(repair, "pv_header"))
+			ret = _repair_pv_header(cmd, repair, &set, &mf, labelsector, dev);
+
+		else if (!strcmp(repair, "metadata"))
+			ret = _repair_metadata(cmd, repair, &set, &mf, labelsector, dev);
+		else
+			log_error("Unknown repair value.");
+
+		if (!ret)
+			return ECMD_FAILED;
+		return ECMD_PROCESSED;
+	}
+
+	if (arg_is_set(cmd, repair_ARG)) {
+		cmd->use_hints = 0;
+
+		/* repair is a combination of repairtype pv_header+metadata */
+
+		if (!_repair_pv_header(cmd, "pv_header", &set, &mf, labelsector, dev))
+			return ECMD_FAILED;
+
+		if (!_repair_metadata(cmd, "metadata", &set, &mf, labelsector, dev))
+			return ECMD_FAILED;
+
+		return ECMD_PROCESSED;
+	}
+
 	/*
 	 * The old/original form of pvck, which did not do much,
 	 * but this is here to preserve the historical output.
diff --git a/tools/tools.h b/tools/tools.h
index b78c471..a2baaa5 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -184,6 +184,7 @@ int syncaction_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_v
 int reportformat_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int configreport_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int configtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int repairtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
diff --git a/tools/vals.h b/tools/vals.h
index db8bae9..317e498 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -141,6 +141,7 @@ val(syncaction_VAL, syncaction_arg, "SyncAction", "check|repair")
 val(reportformat_VAL, reportformat_arg, "ReportFmt", "basic|json")
 val(configreport_VAL, configreport_arg, "ConfigReport", "log|vg|lv|pv|pvseg|seg")
 val(configtype_VAL, configtype_arg, "ConfigType", "current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata")
+val(repairtype_VAL, repairtype_arg, "RepairType", "pv_header|metadata|label_header")
 
 /* this should always be last */
 val(VAL_COUNT, NULL, NULL, NULL)



