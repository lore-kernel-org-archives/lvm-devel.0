From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 29 Jan 2010 16:38:01 -0500
Subject: [PATCH 11/12] Update pvchange, pvs and vgs man pages for metadata disable.
In-Reply-To: <1264801082-28132-11-git-send-email-dwysocha@redhat.com>
References: <1264801082-28132-1-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-2-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-3-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-4-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-5-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-6-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-7-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-8-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-9-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-10-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-11-git-send-email-dwysocha@redhat.com>
Message-ID: <1264801082-28132-12-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Explain --metadatadisable argument to pvchange and new fields to pvs / vgs.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/pvchange.8.in |    6 +++++-
 man/pvs.8.in      |    3 ++-
 man/vgs.8.in      |    2 +-
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/man/pvchange.8.in b/man/pvchange.8.in
index 00c94a6..05190b9 100644
--- a/man/pvchange.8.in
+++ b/man/pvchange.8.in
@@ -6,6 +6,7 @@ pvchange \- change attributes of a physical volume
 [\-\-addtag Tag]
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] 
 [\-\-deltag Tag]
+[\-\-metadatadisable y|n]
 [\-h|\-?|\-\-help]
 [\-t|\-\-test]
 [\-v|\-\-verbose] [\-a|\-\-all] [\-x|\-\-allocatable y|n]
@@ -25,10 +26,13 @@ Generate new random UUID for specified physical volumes.
 .TP
 .I \-x, \-\-allocatable y|n
 Enable or disable allocation of physical extents on this physical volume.
+.TP
+.I \-\-metadatadisable y|n
+Disable or enable metadata areas on this physical volume.
 .SH Example
 "pvchange -x n /dev/sdk1" disallows the allocation of physical extents
 on this physical volume (possibly because of disk errors, or because it will
 be removed after freeing it.
 .SH SEE ALSO
-.BR lvm (8), 
+.BR lvm (8),
 .BR pvcreate (8)
diff --git a/man/pvs.8.in b/man/pvs.8.in
index fe00d2a..f594e59 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -54,7 +54,8 @@ Use \fb-o help\fP to view the full list of columns available.
 .IP
 Column names include: pv_fmt, pv_uuid, dev_size, pv_name, pv_mda_free,
 pv_mda_size, pe_start, pv_size, pv_free, pv_used, pv_attr, pv_pe_count,
-pv_pe_alloc_count, pv_tags, pv_mda_count, pvseg_start, and pvseg_size.
+pv_pe_alloc_count, pv_tags, pv_mda_count, pv_mda_count_disabled,
+pvseg_start, and pvseg_size.
 .IP
 With --segments, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs (8)\fP can also
diff --git a/man/vgs.8.in b/man/vgs.8.in
index b22d08b..040bd69 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -49,7 +49,7 @@ Use \fb-o help\fP to view the full list of columns available.
 Column names include: vg_fmt, vg_uuid, vg_name, vg_attr, vg_size, vg_free,
 vg_sysid, vg_extent_size, vg_extent_count, vg_free_count, max_lv, max_pv,
 pv_count, lv_count, snap_count, vg_seqno, vg_tags, vg_mda_count, vg_mda_free,
-and vg_mda_size.
+and vg_mda_size, vg_mda_count_disabled.
 .IP
 Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs (8)\fP 
 or \fBlvs (8)\fP can also be chosen, but columns cannot be taken from both
-- 
1.6.0.6


