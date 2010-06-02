From: Danny Rawlins <monster.romster@gmail.com>
Date: Wed, 02 Jun 2010 23:51:56 +1000
Subject: patch: unified diff dmeventd.8 man page
Message-ID: <4C0661FC.8000407@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

diff --git a/man/Makefile.in b/man/Makefile.in
index eef1982..1106117 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -22,6 +22,12 @@ else
 FSADMMAN =
 endif
 
+ifeq ("@DMEVENTD@", "yes")
+DMEVENTDMAN = dmeventd.8
+else
+DMEVENTDMAN =
+endif
+
 MAN5=lvm.conf.5
 MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 lvm.8 \
     lvmchange.8 lvmdiskscan.8 lvmdump.8 \
@@ -30,7 +36,7 @@ MAN8=lvchange.8 lvconvert.8 lvcreate.8 lvdisplay.8
lvextend.8 lvm.8 \
     pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
     vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
     vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8
vgremove.8 \
-    vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
+    vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN) $(DMEVENTDMAN)
 
 ifneq ("@CLVMD@", "none")
   MAN8CLUSTER=clvmd.8
@@ -45,8 +51,8 @@ MAN8DM=dmsetup.8
 MAN5DIR=$(mandir)/man5
 MAN8DIR=$(mandir)/man8
 
-CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(MAN8DM)
-DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8
+CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(DMEVENTDMAN)
$(MAN8DM)
+DISTCLEAN_TARGETS=fsadm.8 clvmd.8 cmirrord.8 dmeventd.8
 
 include $(top_builddir)/make.tmpl
 
diff -u /dev/null dmeventd.8.in
--- /dev/null    2010-06-01 10:26:33.543001381 +1000
+++ dmeventd.8.in    2010-06-02 23:35:11.000000000 +1000
@@ -0,0 +1,32 @@
+.TH CLVMD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.SH NAME
+dmeventd \- dm event LVM daemon
+.SH SYNOPSIS
+.B dmeventd
+[\-V]
+[\-h]
+[\-d|dd|ddd]
+[\-d]
+[\-f]
+.SH DESCRIPTION
+dmeventd is the daemon that monitors active mapped devices.
+This sends messages to syslog when an event occures.
+.br
+For snapshots that reach 80% full with further warnings at 85%, 90% and
95%.
+.br
+For mirrored Logical Volumes it sends messages like flush, sync and
read failures.
+.SH OPTIONS
+.TP
+.I \-V]
+Show version of dmeventd.
+.TP
+.I \-h]
+Show help information.
+.TP
+.I \-d|dd|ddd]
+Log debug messages to syslog (-d, -dd, -ddd). Each extra d adds more
debugging information.
+.TP
+.I \-f]
+Don't fork, run in the foreground.
+.SH SEE ALSO
+.BR lvm (8)


