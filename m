From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Dec 2007 14:47:25 -0000
Subject: LVM2/scripts fsadm.sh
Message-ID: <20071217144725.7003.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-12-17 14:47:24

Modified files:
	scripts        : fsadm.sh 

Log message:
	tweak usage text

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/scripts/fsadm.sh	2007/12/17 12:31:50	1.1
+++ LVM2/scripts/fsadm.sh	2007/12/17 14:47:22	1.2
@@ -64,24 +64,26 @@
 IFS_OLD=$IFS
 
 tool_usage() {
-	echo "${TOOL}: Utility to resize underlying filesystem"
-	echo "Usage:"
-	echo "  ${TOOL} [options] check|resize device [size]"
-	echo "    -h | --help		  show this help"
-	echo "    -v | --verbose	  be verbose"
-	echo "    -f | --force 	  forces to proceed"
-	echo "    -e | --ext-offline 	  unmount filesystem before Ext2/3 resize"
-	echo "    -n | --dry-run	  print commands rather than running them"
-	echo "    -y | --yes		  answer \"yes\" to automatically proceed"
-	echo "    check		  run fsck"
-	echo "    resize		  resize given device to new size"
-	echo "    size 		  in filesystem blocks"
-	echo " 			  add B to specify Bytes (i.e.: 1000000B)"
-	echo " 			  add K to specify KiloBytes (1024B)"
-	echo " 			  add M to specify MegaBytes (1024KB)"
-	echo " 			  add G to specify GigaBytes (1024MB)"
-	echo " 			  add T to specify TeraBytes (1024GB)"
-	echo " 			  (if unspecified full device is used)"
+	echo "${TOOL}: Utility to resize or check the filesystem on a device"
+	echo
+	echo "  ${TOOL} [options] check device"
+	echo "    - Check the filesystem on device using fsck"
+	echo
+	echo "  ${TOOL} [options] resize device [new_size[BKMGT]]"
+	echo "    - Change the size of the filesystem on device to new_size"
+	echo
+	echo "  Options:"
+	echo "    -h | --help         Show this help message"
+	echo "    -v | --verbose      Be verbose"
+	echo "    -e | --ext-offline  unmount filesystem before Ext2/3 resize"
+	echo "    -f | --force        Bypass sanity checks"
+	echo "    -n | --dry-run      Print commands without running them"
+	echo "    -y | --yes          Answer \"yes\" at any prompts"
+	echo
+	echo "  new_size - Absolute number of filesystem blocks to be in the filesystem,"
+	echo "             or an absolute size using a suffix (in powers of 1024)."
+	echo "             If new_size is not supplied, the whole device is used."
+
 	exit
 }
 


