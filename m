From: David Teigland <teigland@sourceware.org>
Date: Fri, 6 Dec 2019 17:25:04 -0500
Subject: master - man pvck: describe settings
Message-ID: <67566.119120617245901387@us-mta-355.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=338f4df54ba19244c4cf51c9ad6461ef5613ed5f
Commit:        338f4df54ba19244c4cf51c9ad6461ef5613ed5f
Parent:        3f381784f2726edda1ebfe806ba7d0b0dee33cdb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 6 16:21:48 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Dec 6 16:24:27 2019 -0600

man pvck: describe settings

---
 man/pvck.8_des |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/man/pvck.8_des b/man/pvck.8_des
index 2169d73..8e81493 100644
--- a/man/pvck.8_des
+++ b/man/pvck.8_des
@@ -81,3 +81,49 @@ correct (having been undamaged or already repaired).
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
+mda_header and circular text buffer.  Setting this forces metadata_search
+look for metadata in the given area instead of the normal locations.  When
+set to zero with repair, it indicates no metadata areas should exist.
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



