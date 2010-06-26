From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:45 -0400
Subject: [PATCH 14/38] Update pvchange, pvs and vgs man pages for metadata ignore.
In-Reply-To: <1277520789-6808-14-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-15-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Explain --metadataignore argument to pvchange, add new fields to pvs / vgs.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/pvchange.8.in |   10 +++++++++-
 man/pvs.8.in      |    3 ++-
 man/vgs.8.in      |    2 +-
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/man/pvchange.8.in b/man/pvchange.8.in
index 00c94a6..7585306 100644
--- a/man/pvchange.8.in
+++ b/man/pvchange.8.in
@@ -6,6 +6,7 @@ pvchange \- change attributes of a physical volume
 [\-\-addtag Tag]
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] 
 [\-\-deltag Tag]
+[\-\-metadataignore y|n]
 [\-h|\-?|\-\-help]
 [\-t|\-\-test]
 [\-v|\-\-verbose] [\-a|\-\-all] [\-x|\-\-allocatable y|n]
@@ -25,10 +26,17 @@ Generate new random UUID for specified physical volumes.
 .TP
 .I \-x, \-\-allocatable y|n
 Enable or disable allocation of physical extents on this physical volume.
+.TP
+.I \-\-metadataignore y|n
+Ingore or un-ignore metadata areas on this physical volume.  If metadata
+areas on a physical volume are ignored, LVM will treat the physical volume
+as though it has been created with \fB\-\-pvmetadatacopies\fP of 0.  LVM
+operations that would normally result in reading or writing of metadata
+will skip over any ignored metadata areas on physical volumes.
 .SH Example
 "pvchange -x n /dev/sdk1" disallows the allocation of physical extents
 on this physical volume (possibly because of disk errors, or because it will
 be removed after freeing it.
 .SH SEE ALSO
-.BR lvm (8), 
+.BR lvm (8),
 .BR pvcreate (8)
diff --git a/man/pvs.8.in b/man/pvs.8.in
index fe00d2a..55892cc 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -54,7 +54,8 @@ Use \fb-o help\fP to view the full list of columns available.
 .IP
 Column names include: pv_fmt, pv_uuid, dev_size, pv_name, pv_mda_free,
 pv_mda_size, pe_start, pv_size, pv_free, pv_used, pv_attr, pv_pe_count,
-pv_pe_alloc_count, pv_tags, pv_mda_count, pvseg_start, and pvseg_size.
+pv_pe_alloc_count, pv_tags, pv_mda_count, pv_mda_count_ignored,
+pvseg_start, and pvseg_size.
 .IP
 With --segments, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs (8)\fP can also
diff --git a/man/vgs.8.in b/man/vgs.8.in
index b22d08b..7475f77 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -49,7 +49,7 @@ Use \fb-o help\fP to view the full list of columns available.
 Column names include: vg_fmt, vg_uuid, vg_name, vg_attr, vg_size, vg_free,
 vg_sysid, vg_extent_size, vg_extent_count, vg_free_count, max_lv, max_pv,
 pv_count, lv_count, snap_count, vg_seqno, vg_tags, vg_mda_count, vg_mda_free,
-and vg_mda_size.
+and vg_mda_size, vg_mda_count_ignored.
 .IP
 Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs (8)\fP 
 or \fBlvs (8)\fP can also be chosen, but columns cannot be taken from both
-- 
1.6.0.6


