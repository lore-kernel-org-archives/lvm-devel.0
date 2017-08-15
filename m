From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Tue, 15 Aug 2017 07:55:13 -0400
Subject: master - pvcreate: fix check for 2nd mda at end of disk fits if using pvcreate --restorefile
Message-ID: <201708151155.v7FBtDE9026659@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3c978f7bcc8c7d7cb473ba718a8e44523a09d02e
Commit:        3c978f7bcc8c7d7cb473ba718a8e44523a09d02e
Parent:        222e1e3acee399b0acf31565f784716d67c465a8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 15 13:23:51 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 15 13:40:25 2017 +0200

pvcreate: fix check for 2nd mda at end of disk fits if using pvcreate --restorefile

Fix code checking that the 2nd mda which is at the end of disk really
fits the available free space and avoid any DA and MDA interleaving when
we already have DA preallocated. This mainly applies when we're restoring
a PV from VG backup using pvcreate --restorefile where we may already have
some DA preallocated - this means the PV was in a VG before with already
allocated space from it (the LVs were created). Hence we need to avoid
stepping into DA - the MDA can never ever be inside in such case!

The code responsible for this calculation was already in
_text_pv_add_metadata_area fn, but it had a bug in the calculation where
we subtracted one more sector by mistake and then the code could still
incorrectly allocate the MDA inside existing DA. The patch also renames
the variable in the code so it doesn't confuse us in future.

Also, if the 2nd mda doesn't fit, don't silently continue with just 1
MDA (at the start of the disk). If 2nd mda was requested and we can't
create that due to unavailable space, error out correctly (the patch
also adds a test to shell/pvcreate-operation.sh for this case).
---
 WHATS_NEW                        |    1 +
 lib/format_text/format-text.c    |   34 +++++++++++++++++-----------------
 test/shell/pvcreate-operation.sh |   28 ++++++++++++++++++++++++----
 3 files changed, 42 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e1294e..c8f072f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Fix check for 2nd mda at end of disk fits if using pvcreate --restorefile.
   Use maximum metadataarea size that fits with pvcreate --restorefile.
   Always clear cached bootloaderarea when wiping label e.g. in pvcreate.
   Disallow --bootloaderareasize with pvcreate --restorefile.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 7db4637..e974f05 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2078,7 +2078,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 {
 	struct format_instance *fid = pv->fid;
 	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
-	uint64_t ba_size, pe_start, pe_end;
+	uint64_t ba_size, pe_start, first_unallocated;
 	uint64_t alignment, alignment_offset;
 	uint64_t disk_size;
 	uint64_t mda_start;
@@ -2213,14 +2213,24 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 		 * if defined or locked. If pe_start is not defined yet, count
 		 * with any existing MDA0. If MDA0 does not exist, just use
 		 * LABEL_SCAN_SIZE.
+		 *
+		 * The first_unallocated here is the first unallocated byte
+		 * beyond existing pe_end if there is any preallocated data area
+		 * reserved already so we can take that as lower limit for our MDA1
+		 * start calculation. If data area is not reserved yet, we set
+		 * first_unallocated to 0, meaning this is not our limiting factor
+		 * and we will look at other limiting factors if they exist.
+		 * Of course, if we have preallocated data area, we also must
+		 * have pe_start assigned too (simply, data area needs its start
+		 * and end specification).
 		 */
-		pe_end = pv->pe_count ? (pv->pe_start +
-					 pv->pe_count * (uint64_t)pv->pe_size - 1) << SECTOR_SHIFT
-				      : 0;
+		first_unallocated = pv->pe_count ? (pv->pe_start + pv->pe_count *
+						    (uint64_t)pv->pe_size) << SECTOR_SHIFT
+						 : 0;
 
 		if (pe_start || pe_start_locked) {
-			limit = pe_end ? pe_end : pe_start;
-			limit_name = pe_end ? "pe_end" : "pe_start";
+			limit = first_unallocated ? first_unallocated : pe_start;
+			limit_name = first_unallocated ? "pe_end" : "pe_start";
 		} else {
 			if ((mda = fid_get_mda_indexed(fid, pvid, ID_LEN, 0)) &&
 				 (mdac = mda->metadata_locn)) {
@@ -2239,7 +2249,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 			}
 		}
 
-		if (limit > disk_size)
+		if (limit >= disk_size)
 			goto bad;
 
 		if (mda_size > disk_size) {
@@ -2265,16 +2275,6 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 				mda_start = disk_size - mda_size;
 			}
 		}
-
-		/*
-		 * If PV's pe_end not set yet, set it to the end of the
-		 * area that precedes the MDA1 we've just calculated.
-		 * FIXME: do we need to set this? Isn't it always set before?
-		 */
-		/*if (!pe_end) {
-			pe_end = mda_start;
-			pv->pe_end = pe_end >> SECTOR_SHIFT;
-		}*/
 	}
 
 	if (limit_applied)
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index ad80375..af1c5a2 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -149,16 +149,36 @@ grep "incompatible with restored pe_start value" err
 # 300k is multiple of 600k so this should pass
 pvcreate --restorefile "$backupfile" --uui "$uuid1" --dataalignment 300k --dataalignmentoffset 32k "$dev1" 2> err
 not grep "incompatible with restored pe_start value" err
-rm -f "$backupfile"
 
 # pvcreate rejects non-existent uuid given with restorefile
-not pvcreate --uuid "$uuid1" --restorefile "$backupfile" "$dev1"
+not pvcreate --uuid "$uuid2" --restorefile "$backupfile" "$dev1" 2> err
+grep "Can't find uuid $uuid2 in backup file $backupfile" err
 
 # pvcreate rejects restorefile without uuid
-not pvcreate --restorefile "$backupfile" "$dev1"
+not pvcreate --restorefile "$backupfile" "$dev1" 2>err
+grep -- "--uuid is required with --restorefile" err
 
 # pvcreate rejects uuid restore with multiple volumes specified
-not pvcreate --uuid "$uuid1" --restorefile "$backupfile" "$dev1" "$dev2"
+not pvcreate --uuid "$uuid1" --restorefile "$backupfile" "$dev1" "$dev2" 2>err
+grep "Can only set uuid on one volume at once" err
+
+# --bootloaderareasize not allowed with pvcreate --restorefile
+not pvcreate --uuid "$uuid1" --restorefile "$backupfile" --bootloaderareasize 1m "$dev1" "$dev2" 2>err
+grep -- "Command does not accept option combination: --bootloaderareasize  with --restorefile" err
+
+rm -f "$backupfile"
+
+pvcreate --norestorefile --uuid $uuid1 "$dev1"
+vgcreate --physicalextentsize 1m $vg1 "$dev1"
+vgcfgbackup -f "$backupfile" "$vg1"
+vgremove -ff "$vg1"
+pvremove -ff "$dev1"
+
+# when 2nd mda requested on pvcreate --restorefile and not enough space for it, pvcreate fails
+not pvcreate --restorefile "$backupfile" --uuid $uuid1 --metadatacopies 2 "$dev1" 2>err
+grep "Not enough space available for metadata area with index 1 on PV $dev1" err
+
+rm -f "$backupfile"
 
 # pvcreate wipes swap signature when forced
 dd if=/dev/zero of="$dev1" bs=1024 count=64


