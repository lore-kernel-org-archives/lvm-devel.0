From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Feb 2013 14:18:25 +0000 (UTC)
Subject: master - man: update pvcreate/pvs/vgconvert man page to cover embedding area support
Message-ID: <20130226141825.75BFBA0C57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28a5f6bc3833ad2f84e6d00745fc103d508708a6
Commit:        28a5f6bc3833ad2f84e6d00745fc103d508708a6
Parent:        ea69cda4b089f96b89c178bcef3ed44df86cf825
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 26 14:10:11 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 26 14:46:42 2013 +0100

man: update pvcreate/pvs/vgconvert man page to cover embedding area support

---
 man/pvcreate.8.in  |   13 +++++++++++++
 man/pvs.8.in       |    6 +++---
 man/vgconvert.8.in |    2 ++
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index 3fec8dc..1fda0ad 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -12,6 +12,8 @@ pvcreate \- initialize a disk or partition for use by LVM
 .RB [ \-\-force ]]
 .RB [ \-y | \-\-yes ]
 .RB [ \-\-labelsector ]
+.RB [ \-\-embeddingareasize
+.IR size ]
 .RB [ \-M | \-\-metadatatype
 .IR type ]
 .RB [ \-\- [ pv ] metadatacopies
@@ -163,6 +165,17 @@ sector (sector 1).  This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source).  Use with care.
 .TP
+.B \-\-embeddingareasize \fIsize
+Create a separate embedding area of specified size besides PV's data
+area. The embedding area is an area of reserved space on the PV from
+which LVM2 will not allocate any extents and it's kept untouched for
+use with external tools to embed their own data or metadata. The start
+of the embedding area is always aligned, see also \fB--dataalignment\fP
+and \fB--dataalignmentoffset\fP. The embedding area size may eventually
+end up increased due to the alignment, but it's never less than the
+size that is requested. To see the embedding area start and size of
+an existing Physical Volume use \fBpvs -o +ea_start,ea_size\fP.
+.TP
 .B \-\-setphysicalvolumesize \fIsize
 Overrides the automatically-detected size of the PV.  Use with care.
 .SH Examples
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 4bdfa12..7fff4fd 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -63,9 +63,9 @@ and \fB-o pvseg_all\fP to select all Physical Volume segment columns.
 Use \fB-o help\fP to view the full list of columns available.
 .IP
 Column names include: pv_fmt, pv_uuid, dev_size, pv_name, pv_mda_free,
-pv_mda_size, pe_start, pv_size, pv_free, pv_used, pv_attr, pv_pe_count,
-pv_pe_alloc_count, pv_tags, pv_mda_count, pv_mda_used_count,
-pvseg_start, and pvseg_size.
+pv_mda_size, ea_start, ea_size, pe_start, pv_size, pv_free, pv_used,
+pv_attr, pv_pe_count, pv_pe_alloc_count, pv_tags, pv_mda_count,
+pv_mda_used_count, pvseg_start, and pvseg_size
 .IP
 With \fB\-\-segments\fP, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs\fP(8) can also
diff --git a/man/vgconvert.8.in b/man/vgconvert.8.in
index 95ea41c..6567a9e 100644
--- a/man/vgconvert.8.in
+++ b/man/vgconvert.8.in
@@ -8,6 +8,8 @@ vgconvert \- convert volume group metadata format
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-labelsector ]
+.RB [ \-\-embeddingareasize
+.IR size ]
 .RB [ \-M | \-\-metadatatype
 .IR type ]
 .RB [ \-\-pvmetadatacopies


