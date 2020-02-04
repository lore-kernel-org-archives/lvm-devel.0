From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:23:25 -0500
Subject: master - generate: remake
Message-ID: <15254.120020411231500149@us-mta-294.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa7642a44441c63dd71184b70f5c3955696a5ad4
Commit:        aa7642a44441c63dd71184b70f5c3955696a5ad4
Parent:        336361b2f25c09c7aad4d21aca272a11c6c9352a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 4 15:40:33 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

generate: remake

Regen man page.
---
 man/pvck.8_pregen | 109 ++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 82 insertions(+), 27 deletions(-)

diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index ea9d17d..1800714 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -25,7 +25,7 @@ pvck - Check metadata on physical volumes
 .ad b
 .br
 .ad l
-    \fB--dump\fP \fIString\fP
+    \fB--dump\fP \fBheaders\fP|\fBmetadata\fP|\fBmetadata_all\fP|\fBmetadata_search\fP
 .ad b
 .br
 .ad l
@@ -94,44 +94,50 @@ pvck - Check metadata on physical volumes
 .SH DESCRIPTION
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
@@ -149,14 +155,15 @@ VG, it is important for the user to determine the correct PV UUID and
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
@@ -175,6 +182,53 @@ correct (having been undamaged or already repaired).
 Repairs label_header fields, leaving the pv_header (in the same sector)
 unchanged.  (repairtype pv_header should usually be used instead.)
 
+.SS Settings
+
+The --settings option controls or overrides certain dump or repair
+behaviors.  All offset and size values in settings are in bytes (units are
+not recognized.)  These settings are subject to change.
+
+.B mda_num=1|2
+.br
+Select which metadata area should be used.  By default the first metadata
+area (1) is used.  mda1 is always located at offset 4096.  mda2, at the
+end of the device, often does not exist (it's not created by default.) If
+mda1 is erased, mda2, if it exists, will often still have metadata.
+
+\fBmetadata_offset=\fP\fIbytes\fP
+.br
+Select metadata text at this offset.  Use with metadata_search to
+print/save one instance of metadata text.
+
+\fBmda_offset=\fP\fIbytes\fP \fBmda_size=\fP\fIbytes\fP
+.br
+Refers to a metadata area (mda) location and size.  An mda includes an
+mda_header and circular metadata text buffer.  Setting this forces
+metadata_search look for metadata in the given area instead of the
+standard locations.  When set to zero with repair, it indicates no
+metadata areas should exist.
+
+\fBmda2_offset=\fP\fIbytes\fP \fBmda2_size=\fP\fIbytes\fP
+.br
+When repairing a pv_header, this forces a specific offset and size for
+mda2 that should be recorded in the pv_header.
+
+\fBpv_uuid=\fP\fIuuid\fP
+.br
+Specify the PV UUID of the device being repaired.  When not specified,
+repair will attempt to determine the correct PV UUID by matching a device
+name in the metadata.
+
+\fBdevice_size=\fP\fIbytes\fP
+.br
+\fBdata_offset=\fP\fIbytes\fP
+.br
+When repairing a pv_header, the device_size, data_offset, and pvid can all
+be specified directly, in which case these values are not taken from a
+metadata file (where they usually come from), and the metadata file can be
+omitted.  data_offset is the starting location of the first physical
+extent (data), which follows the first metadata area.
+
 .SH USAGE
 Check for metadata on a device
 .br
@@ -190,7 +244,7 @@ Check for metadata on a device
 Check and print LVM headers and metadata on a device
 .br
 .P
-\fBpvck\fP \fB--dump\fP \fIString\fP \fIPV\fP
+\fBpvck\fP \fB--dump\fP \fBheaders\fP|\fBmetadata\fP|\fBmetadata_all\fP|\fBmetadata_search\fP \fIPV\fP
 .br
 .RS 4
 .ad l
@@ -344,7 +398,7 @@ For testing and debugging.
 .ad b
 .HP
 .ad l
-\fB--dump\fP \fIString\fP
+\fB--dump\fP \fBheaders\fP|\fBmetadata\fP|\fBmetadata_all\fP|\fBmetadata_search\fP
 .br
 Dump headers and metadata from a PV for debugging and repair.
 Option values include: \fBheaders\fP to print and check LVM headers,
@@ -437,7 +491,8 @@ Repair headers and metadata on a PV. See command description.
 \fB--settings\fP \fIString\fP
 .br
 Specifies command specific settings in "Key = Value" form.
-Repeat this option to specify multiple values.
+Combine multiple settings in quotes, or repeat the settings
+option for each.
 .ad b
 .HP
 .ad l



