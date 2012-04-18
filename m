From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 18 Apr 2012 15:26:03 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvmdump.sh
Message-ID: <20120418152603.13666.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-04-18 15:26:02

Modified files:
	.              : WHATS_NEW 
	scripts        : lvmdump.sh 

Log message:
	Add udev info and context to lvmdump.
	--------------------------------------------------------------------

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2384&r2=1.2385
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmdump.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2012/04/12 03:16:37	1.2384
+++ LVM2/WHATS_NEW	2012/04/18 15:26:02	1.2385
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Add udev info and context to lvmdump.
   Fix RAID device replacement code so that it works under snapshot.
   Fix inability to split RAID1 image while specifying a particular PV.
   Update man pages to give them same look&feel.
--- LVM2/scripts/lvmdump.sh	2011/06/02 09:08:16	1.18
+++ LVM2/scripts/lvmdump.sh	2012/04/18 15:26:02	1.19
@@ -30,6 +30,7 @@
 CUT=cut
 DATE=date
 BASENAME=basename
+UDEVADM=udevadm
 UNAME=uname
 
 # user may override lvm and dmsetup location by setting LVM_BINARY
@@ -54,6 +55,7 @@
 	echo "    -m gather LVM metadata from the PVs"
 	echo "    -d <directory> dump into a directory instead of tarball"
 	echo "    -c if running clvmd, gather cluster data as well"
+	echo "    -u gather udev info and context"
 	echo ""
 
 	exit 1
@@ -62,7 +64,8 @@
 advanced=0
 clustered=0
 metadata=0
-while getopts :acd:hm opt; do
+udev=0
+while getopts :acd:hmu opt; do
 	case $opt in 
 		s)      sysreport=1 ;;
 		a)	advanced=1 ;;
@@ -70,6 +73,7 @@
 		d)	userdir=$OPTARG ;;
 		h)	usage ;;
 		m)	metadata=1 ;;
+		u)	udev=1 ;;
 		:)	echo "$0: $OPTARG requires a value:"; usage ;;
 		\?)     echo "$0: unknown option $OPTARG"; usage ;;
 		*)	usage ;;
@@ -221,6 +225,20 @@
 	done
 fi
 
+if (( $udev )); then
+	myecho "Gathering udev info..."
+
+	udev_dir="$dir/udev"
+
+	log "$MKDIR -p \"$udev_dir\""
+	log "$UDEVADM info --version >> \"$udev_dir/version\" 2>> \"$log\""
+	log "$UDEVADM info --export-db >> \"$udev_dir/db\" 2>> \"$log\""
+	log "$CP -a /etc/udev/udev.conf \"$udev_dir/conf\" 2>> \"$log\""
+	log "$LS -la /lib/udev >> \"$udev_dir/lib_dir\" 2>> \"$log\""
+	log "$CP -aR /etc/udev/rules.d \"$udev_dir/rules_etc\" 2>> \"$log\""
+	log "$CP -aR /lib/udev/rules.d \"$udev_dir/rules_lib\" 2>> \"$log\""
+fi
+
 if test -z "$userdir"; then
 	lvm_dump="$dirbase.tgz"
 	myecho "Creating report tarball in $HOME/$lvm_dump..."


