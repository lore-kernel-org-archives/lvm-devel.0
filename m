From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 12:30:40 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/import-extents.c
Message-ID: <20110330123040.30920.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 12:30:40

Modified files:
	.              : WHATS_NEW 
	lib/format1    : import-extents.c 

Log message:
	Fix reading of unitialized memory
	
	Could be reached via few of our lvm2 test cases:
	
	==11501== Invalid read of size 8
	==11501==    at 0x49B2E0: _area_length (import-extents.c:204)
	==11501==    by 0x49B40C: _read_linear (import-extents.c:222)
	==11501==    by 0x49B952: _build_segments (import-extents.c:323)
	==11501==    by 0x49B9A0: _build_all_segments (import-extents.c:334)
	==11501==    by 0x49BB4C: import_extents (import-extents.c:364)
	==11501==    by 0x497655: _format1_vg_read (format1.c:217)
	==11501==    by 0x47E43E: _vg_read (metadata.c:2901)
	
	cut from t-vgcvgbackup-usage.sh
	--
	pvcreate -M1 $(cat DEVICES)
	vgcreate -M1 -c n $vg $(cat DEVICES)
	lvcreate -l1 -n $lv1 $vg $dev1
	--
	
	Idea of the fix is rather defensive - to allocate one extra element
	to 'map' array which is then used in _area_length() - where the
	loop checks, whether next map entry is continuous.
	
	By placing there always one extra zero entry -
	we fix the read of unallocated memory, and we make sure the data would
	not make a continous block.
	
	FIXME: there could be a problem if some special broken lvm1 data would be imported.
	As the format1 is currently not really used - leave it for future fix
	and use this small hotfix for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1962&r2=1.1963
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-extents.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW	2011/03/29 21:57:56	1.1962
+++ LVM2/WHATS_NEW	2011/03/30 12:30:39	1.1963
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix reading of unallocated memory in lvm1 format import function.
   Replace several strncmp() calls with id_equal().
   Fix lvmcache_info transfer to orphan_vginfo in _lvmcache_update_vgname().
   Fix -Wold-style-definition gcc warnings.
--- LVM2/lib/format1/import-extents.c	2010/04/08 00:28:57	1.39
+++ LVM2/lib/format1/import-extents.c	2011/03/30 12:30:39	1.40
@@ -63,8 +63,12 @@
 			goto_bad;
 
 		lvm->lv = ll->lv;
+		/*
+		 * Alloc 1 extra element, so the loop in _area_length() and
+		 * _check_stripe() finds the last map member as noncontinuous.
+		 */
 		if (!(lvm->map = dm_pool_zalloc(mem, sizeof(*lvm->map)
-					     * ll->lv->le_count)))
+					     * (ll->lv->le_count + 1))))
 			goto_bad;
 
 		if (!dm_hash_insert(maps, ll->lv->name, lvm))


