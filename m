From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Nov 2006 22:41:57 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm2create_initrd/lvm ...
Message-ID: <20061121224157.24174.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-21 22:41:56

Modified files:
	.              : WHATS_NEW 
	scripts/lvm2create_initrd: lvm2create_initrd 

Log message:
	Update lvm2create_initrd to support gentoo.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.505&r2=1.506
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2create_initrd/lvm2create_initrd.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2006/11/21 17:44:45	1.505
+++ LVM2/WHATS_NEW	2006/11/21 22:41:55	1.506
@@ -1,5 +1,6 @@
 Version 2.02.16 -
 ====================================
+  Update lvm2create_initrd to support gentoo.
 
 Version 2.02.15 - 21st November 2006
 ====================================
--- LVM2/scripts/lvm2create_initrd/lvm2create_initrd	2004/06/07 16:20:05	1.1
+++ LVM2/scripts/lvm2create_initrd/lvm2create_initrd	2006/11/21 22:41:56	1.2
@@ -29,6 +29,8 @@
 #               PATH entries to /sbin/init shell script so chroot works without /usr mounted. Remove
 #               mkdir /initrd so we don't cause problems if root filesystem is corrupted. -- Jeff Layton
 # 15/05/2004	initial support for modules, create lvm.conf from lvm dumpconfig, other cleanups -- Jeff Layton
+# 14/11/2006	Update handling of ldd output to handle hardcoded library links and virtual dll linux-gate.
+#		Add support for Gentoo-style MAKEDEV. Remove hardcoded BINUTILS paths -- Douglas Mayle
 #
 # Copyright Miguel Cabeca, Jeffrey Layton, 2004
 #
@@ -46,13 +48,13 @@
 #    along with this program; if not, write to the Free Software
 #    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 #
-# $Id: lvm2create_initrd,v 1.1 2004/06/07 16:20:05 agk Exp $
+# $Id: lvm2create_initrd,v 1.2 2006/11/21 22:41:56 agk Exp $
 
 TMPMNT=/tmp/mnt.$$
 DEVRAM=/tmp/initrd.$$
 
 # set defaults
-BINFILES=${BINFILES:-"/lib/lvm-200/lvm /bin/bash /bin/busybox /sbin/pivot_root"}
+BINFILES=${BINFILES:-"`which lvm` `which bash` `which busybox` `which pivot_root`"}
 BASICDEVICES=${BASICDEVICES:-"std consoleonly fd"}
 BLOCKDEVICES=${BLOCKDEVICES:-"md hda hdb hdc hdd sda sdb sdc sdd"}
 MAKEDEV=${MAKEDEV:-"debian"}
@@ -269,7 +271,27 @@
 # Figure out which shared libraries we actually need in our initrd
 echo "$cmd -- finding required shared libraries"
 verbose "BINFILES: `echo $BINFILES`"
-LIBFILES=`ldd $BINFILES 2>/dev/null | awk '{if (/=>/) { print $3 }}' | sort -u`
+
+# We need to strip certain lines from ldd output.  This is the full output of an example ldd:
+#lvmhost~ # ldd /sbin/lvm /bin/bash
+#/sbin/lvm:
+#        not a dynamic executable
+#/bin/bash:
+#        linux-gate.so.1 =>  (0xbfffe000)
+#        libncurses.so.5 => /lib/libncurses.so.5 (0xb7ee3000)
+#        libdl.so.2 => /lib/libdl.so.2 (0xb7edf000)
+#        libc.so.6 => /lib/libc.so.6 (0xb7dc1000)
+#        /lib/ld-linux.so.2 (0xb7f28000)
+#
+# 1) Lines with a ":" contain the name of the original binary we're examining, and so are unnecessary.
+#    We need to strip them because they contain "/", and can be confused with links with a hardcoded path.
+# 2) The linux-gate library is a virtual dll that does not exist on disk, but is instead loaded automatically
+#    into the process space, and can't be copied to the ramdisk
+#
+# After these lines have been stripped, we're interested in the lines remaining if they
+# 1) Contain "=>" because they are pathless links, and the value following the token is the path on the disk
+# 2) Contain "/" because it's a link with a hardcoded path, and so we're interested in the link itself.
+LIBFILES=`ldd $BINFILES 2>/dev/null |grep -v -E \(linux-gate\|:\) | awk '{if (/=>/) { print $3 } else if (/\//) { print $1 }}' | sort -u`
 if [ $? -ne 0 ]; then
    echo "$cmd -- ERROR figuring out needed shared libraries"
    exit 1
@@ -356,6 +378,10 @@
     (cd $TMPMNT/dev; /dev/MAKEDEV $OPT_Q -d $TMPMNT/dev -m 2)
     RETCODE=$?
     ;;
+gentoo)
+    (cd $TMPMNT/dev; /usr/sbin/MAKEDEV $OPT_Q $BASICDEVICES $BLOCKDEVICES)
+    RETCODE=$?
+    ;;
 *)
     echo "$cmd -- ERROR: $MAKEDEV is not a known MAKEDEV style."
     RETCODE=1


