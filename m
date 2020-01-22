From: David Teigland <teigland@sourceware.org>
Date: Wed, 22 Jan 2020 16:01:58 -0500
Subject: master - man: pvck dump description improvements
Message-ID: <24800.120012216015300967@us-mta-206.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7078dd01e86b176aa5bcb964f57db4ba108eeb4e
Commit:        7078dd01e86b176aa5bcb964f57db4ba108eeb4e
Parent:        d53bfae273677975bd805bfaa3d7e7cd995aaa52
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 22 15:01:00 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 22 15:01:00 2020 -0600

man: pvck dump description improvements

---
 man/pvck.8_des | 60 +++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 34 insertions(+), 26 deletions(-)

diff --git a/man/pvck.8_des b/man/pvck.8_des
index 8e81493..b87345e 100644
--- a/man/pvck.8_des
+++ b/man/pvck.8_des
@@ -1,43 +1,49 @@
 pvck checks and repairs LVM metadata on PVs.
 
-.SS Dump
+.SS Dump options 
 
 .B headers
 .br
-Print header values and warn if any values are incorrect.  Checks the
-label_header, pv_header, mda_header(s), and metadata text.
+Print LVM on-disk headers and structures: label_header, pv_header,
+mda_header(s), and metadata text.  Warnings are printed if any values are
+incorrect.  The label_header and pv_header both exist in a 512 byte
+sector, usually the second sector of the device.  An mda_header exists in
+a 512 byte sector at offset 4096 bytes.  A second mda_header can
+optionally exist near the end of the device.  The metadata text exists in
+an area (about 1MiB by default) immediately following the mda_header
+sector.  The metadata text is checked but not printed (see other options).
 
 .B metadata
 .br
-Print or save the current metadata text, using headers to locate the
-metadata.  If headers are damaged, the metadata may not be found.  Use
---settings "mda_num=2" to look in mda2 (the second mda at the end of the
-device (if used).  The metadata text is printed to stdout.  With --file,
-the metadata text is saved to a file.
+Print the current LVM VG metadata text (or save to a file), using headers
+to locate the latest copy of metadata.  If headers are damaged, metadata
+may not be found (see metadata_search).  Use --settings "mda_num=2" to
+look in mda2 (the second mda at the end of the device, if used).  The
+metadata text is printed to stdout or saved to a file with --file.
 
 .B metadata_all
 .br
-List or save all versions of metadata found in the metadata area, using
-headers to locate the metadata.  If headers are damaged, the metadata may
-not be found.  Use --settings "mda_num=2" as above.  All metadata versions
-are listed (add -v to include descriptions and dates in the listing.)
-With -file, all versions are written to a file.
+List all versions of VG metadata found in the metadata area, using headers
+to locate metadata.  Full copies of all metadata are saved to a file with
+the --file option.  If headers are damaged, metadata may not be found (see
+metadata_search).  Use --settings "mda_num=2" as above.  Use -v to include
+descriptions and dates when listing metadata versions.
 
 .B metadata_search
 .br
-Search for all versions of metadata in the common locations.  This does
-not use headers, so it can find metadata even when headers are damaged.
-Use --settings "mda_num=2" as above.  All metadata versions are listed
-(add -v to include descriptions and dates in the listing.)  With --file,
-all versions are written to a file.  To save one copy of metadata, use
---settings "metadata_offset=<offset>", where the offset is taken from the
-dump listing.
+List all versions of VG metadata found in the metadata area, searching
+common locations so metadata can be found if headers are damaged.  Full
+copies of all metadata are saved to a file with the --file option.  To
+save one specific version of metadata, use --settings
+"metadata_offset=<offset>", where the offset is taken from the list of
+versions found.  Use -v to include descriptions and dates when listing
+metadata versions.
 
 .B metadata_area
 .br
 Save the entire text metadata area to a file without processing.
 
-.SS Repair
+.SS Repair options
 
 .B --repair
 .br
@@ -55,14 +61,15 @@ VG, it is important for the user to determine the correct PV UUID and
 specify it in --settings.  Otherwise, the wrong PV UUID could be used if
 device names have been swapped since the metadata was last written.
 
-If a PV had no metadata areas and the pv_header is damaged, then the
+If a PV has no metadata areas and the pv_header is damaged, then the
 repair will not know to create no metadata areas during repair.  It will
 by default repair metadata in mda1.  To repair with no metadata areas, use
 --settings "mda_offset=0 mda_size=0".
 
 There are cases where repair should be run on all PVs in the VG (using the
 same metadata file):  if all PVs in the VG are damaged, if using an old
-metadata version, or if a backup file is used instead of raw metadata.
+metadata version, or if a backup file is used instead of raw metadata
+(taken from pvck dump.)
 
 Using --repair is equivalent to running --repairtype pv_header followed by
 --repairtype metadata.
@@ -102,9 +109,10 @@ print/save one instance of metadata text.
 \fBmda_offset=\fP\fIbytes\fP \fBmda_size=\fP\fIbytes\fP
 .br
 Refers to a metadata area (mda) location and size.  An mda includes an
-mda_header and circular text buffer.  Setting this forces metadata_search
-look for metadata in the given area instead of the normal locations.  When
-set to zero with repair, it indicates no metadata areas should exist.
+mda_header and circular metadata text buffer.  Setting this forces
+metadata_search look for metadata in the given area instead of the
+standard locations.  When set to zero with repair, it indicates no
+metadata areas should exist.
 
 \fBmda2_offset=\fP\fIbytes\fP \fBmda2_size=\fP\fIbytes\fP
 .br



