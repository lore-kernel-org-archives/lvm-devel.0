From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 12 Mar 2012 08:59:55 -0000
Subject: LVM2/udev 69-dm-lvm-metad.rules
Message-ID: <20120312085955.12874.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-12 08:59:55

Modified files:
	udev           : 69-dm-lvm-metad.rules 

Log message:
	Detect the lvm binary path in lvmetad udev rules.
	
	We can't use 'DM_SBIN_PATH'. This one is set only for DM devices but not
	for all block devices - the pvscan is run on all relevant block devices!
	
	This LVM_SBIN_PATH (as well as DM_SBIN_PATH) detection should be removed
	eventually but for upstream solution, we still have to do that as there are
	known cases where the binaries are put either in /sbin or /usr/sbin
	(some installation systems, initrd systems etc.).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/69-dm-lvm-metad.rules.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/udev/69-dm-lvm-metad.rules	2012/03/06 02:30:50	1.3
+++ LVM2/udev/69-dm-lvm-metad.rules	2012/03/12 08:59:55	1.4
@@ -19,7 +19,12 @@
 # Device-mapper devices are processed only on change event or on supported synthesized event.
 KERNEL=="dm-[0-9]*", ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
 
+# Set proper sbin path, /sbin has higher priority than /usr/sbin.
+ENV{LVM_SBIN_PATH}="/sbin"
+TEST!="$env{LVM_SBIN_PATH}/lvm", ENV{LVM_SBIN_PATH}="/usr/sbin"
+TEST!="$env{LVM_SBIN_PATH}/lvm", GOTO="lvm_end"
+
 # Only process devices already marked as a PV - this requires blkid to be called before.
-ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="$env{DM_SBIN_PATH}/pvscan --cache --major $major --minor $minor"
+ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="$env{LVM_SBIN_PATH}/lvm pvscan --cache --major $major --minor $minor"
 
 LABEL="lvm_end"


