From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Feb 2010 23:53:17 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20100215235317.10821.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-02-15 23:53:16

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	lib/format_text: format-text.c 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.225&r2=1.226
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1432&r2=1.1433
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.344&r2=1.345
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/VERSION	2010/02/02 14:03:50	1.225
+++ LVM2/VERSION	2010/02/15 23:53:15	1.226
@@ -1 +1 @@
-2.02.61(1)-cvs (2010-02-02)
+2.02.61(1)-cvs (2010-02-15)
--- LVM2/VERSION_DM	2010/02/02 14:03:50	1.37
+++ LVM2/VERSION_DM	2010/02/15 23:53:15	1.38
@@ -1 +1 @@
-1.02.44-cvs (2010-02-02)
+1.02.44-cvs (2010-02-15)
--- LVM2/WHATS_NEW	2010/02/15 20:32:27	1.1432
+++ LVM2/WHATS_NEW	2010/02/15 23:53:15	1.1433
@@ -1,31 +1,32 @@
-Version 2.02.61 - 
-===================================
-  Add LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES env. var. to suppress error and warning mesages.
-  Remove hard-coded rule to skip _mimage devices in 11-dm-lvm.rules.
-  Use udev transactions in testsuite.
-  Don't use LVM_UDEV_DISABLE_CHECKING env. var. anymore and set the state automatically.
-  Add lvm2app exports lvm_pv_get_size(), lvm_pv_get_free(), and lvm_pv_get_dev_size().
-  Fix off by 512 sizes for lvm2app.
-  Add 'fail_if_percent_unsupported' arg to _percent() and _percent_run().
-  Remove false "failed to find tree node for" error when activating merging origin.
-  Make lvconvert --repair --use-policies exit with success when no action is needed.
-  Add multiple snapshot lv 'lvconvert --merge @tag' support via process_each_lv().
-  Fix inappropriate second resync when adding mimage to core-logged mirror.
-  Exclude internal VG names and uuids in lists returned via liblvm interface.
-  Add %ORIGIN support to lv{create,extend,reduce,resize} --extents option.
-  Add copy constructor for metadata_area.
+Version 2.02.61 - 15th February 2010
+====================================
+  Fix some consts and floating point gcc warnings.
+  Fix dm_report_field_uint64 function to accept 64-bit ints.
+  Change readhead display to use 32-bit -1 const instead of 64-bit.
+  Add LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES environment variable.
+  Remove hard-coding that skipped _mimage devices from 11-dm-lvm.rules.
+  Use udev transactions in test suite.
+  Set udev state automatically instead of using LVM_UDEV_DISABLE_CHECKING.
+  Add lvm_pv_get_size, lvm_pv_get_free and lvm_pv_get_dev_size to lvm2app.
+  Change lvm2app to return all sizes in bytes as documented (not sectors).
+  Add 'fail_if_percent_unsupported' arg to _percent and _percent_run.
+  Remove false "failed to find tree node" error when activating merging origin.
+  Exit with success when lvconvert --repair --use-policies performs no action.
+  Accept a list of LVs with 'lvconvert --merge @tag' using process_each_lv.
+  Avoid unnecessary second resync when adding mimage to core-logged mirror.
+  Exclude internal VG names and uuids from lists returned through liblvm.
+  Add %ORIGIN support to lv{create,extend,reduce,resize} --extents.
+  Add _mda_copy to clone a struct metadata_area.
   Remove pointless versioned symlinks to dmeventd plugin libraries.
   Fix dmeventd snapshot plugin build dependency.
-  Make clvmd -V return zero status.
-  Fix lvconvert issue with cluster mirrors due to un'_safe' list processing
-  Fix pvmove abort workaround to be cluster-aware when temporary mirror activation fails.
-  Always query device by using uuid only and not name in clvmd.
-  Add missing metadata reverts in pvmove error path.
-  Unlock shared lock in clvmd if activation calls failed.
-  Fix return code of info call for query by uuid.
-  Fix some constness and floating point gcc warnings.
-  Fix dm_report_field_uint64 function.
-  Fix display of lv_kernel_read_ahead -1, broken by fix of dm_report_field_uint64().
+  Make clvmd -V return status zero.
+  Remove unnecessary 'dmsetup resume' following 'dmsetup create' in tests.
+  Fix cmirrord segfault in clog_cpg list processing when converting mirror log.
+  Deactivate temporary pvmove mirror cluster-wide when activating it fails.
+  Always query device by uuid and not name in clvmd.
+  Add missing metadata vg_reverts in pvmove error paths.
+  Unlock shared lock in clvmd if activation calls fail.
+  Return success from dev_manager_info with non-existent uuid if ioctl succeeds.
 
 Version 2.02.60 - 23rd January 2010
 ===================================
--- LVM2/WHATS_NEW_DM	2010/02/15 16:21:33	1.344
+++ LVM2/WHATS_NEW_DM	2010/02/15 23:53:15	1.345
@@ -1,9 +1,9 @@
-Version 1.02.44 - 
-===================================
+Version 1.02.44 - 15th February 2010
+====================================
   Add DM_UDEV_DISABLE_LIBRARY_FALLBACK udev flag to rely on udev only.
   Export dm_udev_create_cookie function to create new cookies on demand.
-  Add --udevcookie, udevcreatecookie and udevreleasecookie for dmsetup.
-  Don't use DM_UDEV_DISABLE_CHECKING env. var. anymore and set the state automatically.
+  Add --udevcookie, udevcreatecookie and udevreleasecookie to dmsetup.
+  Set udev state automatically instead of using DM_UDEV_DISABLE_CHECKING.
 
 Version 1.02.43 - 21st January 2010
 ===================================
--- LVM2/lib/format_text/format-text.c	2010/02/02 16:26:34	1.118
+++ LVM2/lib/format_text/format-text.c	2010/02/15 23:53:15	1.119
@@ -1571,6 +1571,9 @@
 	memcpy(mda_new, mda, sizeof(*mda));
 	memcpy(mdac_new, mdac, sizeof(*mdac));
 	mda_new->metadata_locn = mdac_new;
+
+	/* FIXME mda 'list' left invalid here */
+
 	return mda_new;
 }
 


