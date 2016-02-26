From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 26 Feb 2016 15:56:03 +0000 (UTC)
Subject: master - report: Shift (u)sed pv_attr under (a)llocatable.
Message-ID: <20160226155603.58CD2610A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=98981265963f5c2572687cc7c8b49aa7cb6f85ec
Commit:        98981265963f5c2572687cc7c8b49aa7cb6f85ec
Parent:        183bd8ca0342f6f72630afcb42b453b88ee90ac6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Feb 26 15:46:37 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Feb 26 15:46:37 2016 +0000

report: Shift (u)sed pv_attr under (a)llocatable.

Showing 'u' in the pv_attr reporting field is mostly unnecessary because
most PVs are allocatable, and being allocatable implies it is (u)sed,
and this is already obvious from other fields in the default 'pvs'
output like the VG name.

So move the new (u)sed pv_attr from character position 4 to 1, and only
show it in those rare cases when the PV is not (a)llocatable or the
relevant metadata is missing.

(Scripts should not be using pv_attr, but rather pv_allocatable,
pv_exported, pv_missing, pv_in_use etc.)
---
 WHATS_NEW                    |    1 +
 lib/metadata/pv.c            |    8 +++++---
 man/pvs.8.in                 |    2 +-
 test/shell/pvchange-usage.sh |   10 +++++-----
 4 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f91b3d0..610ea43 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.144 - 
 =====================================
+  Only show (u)sed pv_attr char when PV is not (a)llocatable. (2.02.143)
   Update makefile to generate lcov output also for lvmpolld and lvmlockd.
   Fix SystemdService lvm2-lvmdbusd.service name.
   Improve support for env LVM_VG_NAME for reference VG name in lvconvert.
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 1d68045..7ea993f 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -237,15 +237,17 @@ char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
 	char *repstr;
 	int used = is_used_pv(pv);
 
-	if (!(repstr = dm_pool_zalloc(mem, 5))) {
+	if (!(repstr = dm_pool_zalloc(mem, 4))) {
 		log_error("dm_pool_alloc failed");
 		return NULL;
 	}
 
-	repstr[0] = (pv->status & ALLOCATABLE_PV) ? 'a' : '-';
+	/*
+	 * An allocatable PV is always used, so we don't need to show 'u'.
+	 */
+	repstr[0] = (pv->status & ALLOCATABLE_PV) ? 'a' : (used > 0) ? 'u' : '-';
 	repstr[1] = (pv->status & EXPORTED_VG) ? 'x' : '-';
 	repstr[2] = (pv->status & MISSING_PV) ? 'm' : '-';
-	repstr[3] = used <= 0 ? '-' : 'u';
 
 	return repstr;
 }
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 4bc042b..0e0ad92 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -86,7 +86,7 @@ pv_mda_used_count, pvseg_start, and pvseg_size
 With \fB\-\-segments\fP, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs\fP(8) can also
 be chosen. The pv_attr bits are: @llocatable, e(x)ported, (m)issing and
-(u)sed.
+(u)sed (but not allocatable).
 .TP
 .B \-\-segments
 Produces one line of output for each contiguous allocation of space on each
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index efffe18..df7893e 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -24,11 +24,11 @@ aux prepare_pvs 4
 
 # check 'allocatable' pv attribute
 pvcreate "$dev1"
-check pv_field "$dev1" pv_attr ----
+check pv_field "$dev1" pv_attr ---
 vgcreate $vg1 "$dev1"
-check pv_field "$dev1" pv_attr a--u
+check pv_field "$dev1" pv_attr a--
 pvchange --allocatable n "$dev1"
-check pv_field "$dev1" pv_attr ---u
+check pv_field "$dev1" pv_attr u--
 vgremove -ff $vg1
 not pvchange --allocatable y "$dev1"
 pvremove -ff "$dev1"
@@ -51,10 +51,10 @@ do
 # "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
 	pvchange "$dev1" -x n
 	pvchange "$dev1" -x n   # already disabled
-	check pv_field "$dev1" pv_attr  ---u
+	check pv_field "$dev1" pv_attr  u--
 	pvchange "$dev1" -x y
 	pvchange "$dev1" -x y   # already enabled
-	check pv_field "$dev1" pv_attr  a--u
+	check pv_field "$dev1" pv_attr  a--
 
 # check we are able to change number of managed metadata areas
 	if test $mda -gt 0 ; then


