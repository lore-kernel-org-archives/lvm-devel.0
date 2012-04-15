From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Apr 2012 15:40:49 -0000
Subject: LVM2/man Makefile.in lvmetad.8.in
Message-ID: <20120415154049.20645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-04-15 15:40:49

Modified files:
	man            : Makefile.in 
Added files:
	man            : lvmetad.8.in 

Log message:
	Add a rudimentary lvmetad manpage.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmetad.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.43&r2=1.44

/cvs/lvm2/LVM2/man/lvmetad.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/lvmetad.8.in
+++ -	2012-04-15 15:40:49.456002000 +0000
@@ -0,0 +1,42 @@
+.TH LVMETAD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.SH NAME
+lvmetad \- LVM metadata cache daemon
+.SH SYNOPSIS
+.B lvmetad
+.RB [ \-d ]
+.RB [ \-s ]
+.RB [ \-f ]
+.RB [ \-h ]
+.RB [ \-V ]
+.RB [ \-? ]
+.SH DESCRIPTION
+lvmetad is a metadata caching daemon for LVM. The daemon receives notifications
+from udev rules (which must be installed for LVM to work correctly when lvmetad
+is in use). Through these notifications, lvmetad has an up-to-date and
+consistent image of the volume groups available in the system.
+
+By default, lvmetad, even if running, is not used by LVM. See \fBlvm.conf\fP(5).
+.SH OPTIONS
+.TP
+.B \-d
+Repeat from 1 to 3 times (-d, -dd, -ddd) to increase the detail of
+debug messages sent to syslog.
+Each extra d adds more debugging information.
+.TP
+.B \-f
+Don't fork, run in the foreground.
+.TP
+.BR \-h ", " \-?
+Show help information.
+.TP
+.B \-s
+Path to the socket file to use. The option overrides both the built-in default
+(#DEFAULT_RUN_DIR#/lvmetad.socket) and the environment variable
+LVM_LVMETAD_SOCKET.
+.TP
+.B \-V
+Show version of dmeventd.
+
+.SH SEE ALSO
+.BR lvm (8),
+.BR lvm.conf (5)
--- LVM2/man/Makefile.in	2011/09/24 20:50:36	1.43
+++ LVM2/man/Makefile.in	2012/04/15 15:40:48	1.44
@@ -28,6 +28,12 @@
 DMEVENTDMAN =
 endif
 
+ifeq ("@BUILD_LVMETAD@", "yes")
+LVMETAD = lvmetad.8
+else
+LVMETAD =
+endif
+
 MAN5=lvm.conf.5
 MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
 	lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
@@ -36,7 +42,7 @@
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(LVMETAD)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8
@@ -73,7 +79,7 @@
 %: %.in
 	@case "$@" in \
 	  */*) ;; \
-	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;" $< > $@ ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;" $< > $@ ;; \
 	esac
 
 install_man5: $(MAN5)


