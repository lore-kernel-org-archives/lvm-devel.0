From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2010 10:03:07 -0000
Subject: LVM2/scripts fsadm.sh
Message-ID: <20101110100307.3127.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-10 10:03:07

Modified files:
	scripts        : fsadm.sh 

Log message:
	Scan also 'mount' output for mounted filesystem.
	
	As util-linux package seems to give all the time different names,
	try harder to figure out, where is the given lv possible mounted
	and scan /proc/mounts and if not found there, test also 'mount' output.
	
	/dev/dm-xxx
	/dev/mapper/vg-lv
	/dev/vg/lv
	
	All of them could be used different combination in /proc/mount and mount output.
	
	Patch fixes regression for older systems where new detection code failed to
	find valid combination.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/scripts/fsadm.sh	2010/11/01 14:08:52	1.21
+++ LVM2/scripts/fsadm.sh	2010/11/10 10:03:07	1.22
@@ -199,6 +199,10 @@
 	# for empty string try again with real volume name
 	test -z "$MOUNTED" && MOUNTED=$($GREP ^"$RVOLUME" $PROCMOUNTS)
 
+	# for systems with different device names - check also mount output
+	test -z "$MOUNTED" && MOUNTED=$($MOUNT | $GREP ^"$VOLUME")
+	test -z "$MOUNTED" && MOUNTED=$($MOUNT | $GREP ^"$RVOLUME")
+
 	# cut device name prefix and trim everything past mountpoint
 	# echo translates \040 to spaces
 	MOUNTED=${MOUNTED#* }


