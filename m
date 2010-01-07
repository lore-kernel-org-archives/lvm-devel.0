From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 7 Jan 2010 20:01:57 -0000
Subject: LVM2 ./WHATS_NEW udev/11-dm-lvm.rules
Message-ID: <20100107200157.3276.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-01-07 20:01:56

Modified files:
	.              : WHATS_NEW 
	udev           : 11-dm-lvm.rules 

Log message:
	Always set environment variables for an LVM2 device in 11-dm-lvm.rules.
	
	This way we can still use DM_LV_NAME, DM_VG_NAME and DM_LV_LAYER in all
	the other rules.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1371&r2=1.1372
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/11-dm-lvm.rules.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2010/01/07 19:54:21	1.1371
+++ LVM2/WHATS_NEW	2010/01/07 20:01:55	1.1372
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Always set environment variables for an LVM2 device in 11-dm-lvm.rules.
   Add activation/udev_rules config option in lvm.conf.
   Add macro outfc() and export out_text_with_comment().
   Add macros outsize() and outhint().
--- LVM2/udev/11-dm-lvm.rules	2009/11/01 18:01:31	1.4
+++ LVM2/udev/11-dm-lvm.rules	2010/01/07 20:01:55	1.5
@@ -16,11 +16,12 @@
 ACTION!="add|change", GOTO="lvm_end"
 ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
 ENV{DM_UUID}!="LVM-?*", GOTO="lvm_end"
-ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
 
 # Use DM name and split it up into its VG/LV/layer constituents.
 IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup splitname --nameprefixes --noheadings --rows $env{DM_NAME}"
 
+ENV{DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG}=="1", GOTO="lvm_end"
+
 # Do not create symlinks for inappropriate subdevices.
 ENV{DM_LV_NAME}=="?*_mimage_[0-9]*|pvmove?*|?*_vorigin", GOTO="lvm_disable"
 ENV{DM_LV_LAYER}=="?*", GOTO="lvm_disable"


