From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:11:02 +0000 (UTC)
Subject: master - generate man pages
Message-ID: <20170213181102.B760860CD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=698abdde165a3e747b81f18cf3405f2d4abb5bae
Commit:        698abdde165a3e747b81f18cf3405f2d4abb5bae
Parent:        13a6368522894e9d32544d8fb3d6360bbe9018d1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 10 16:20:19 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 10:31:23 2017 -0600

generate man pages

---
 configure.in             |    2 +
 doc/license.txt          |   14 +
 man/Makefile.in          |   39 +-
 man/clvmd.8.in           |   26 +
 man/lvchange.8.des       |    2 +
 man/lvchange.8.end       |    6 +
 man/lvchange.8.in        |  491 -------------------
 man/lvconvert.8.des      |   32 ++
 man/lvconvert.8.end      |   95 ++++
 man/lvconvert.8.in       | 1199 ----------------------------------------------
 man/lvcreate.8.des       |   28 ++
 man/lvcreate.8.end       |   98 ++++
 man/lvcreate.8.in        |  914 -----------------------------------
 man/lvdisplay.8.des      |    5 +
 man/lvdisplay.8.in       |  134 -----
 man/lvextend.8.des       |    5 +
 man/lvextend.8.end       |   16 +
 man/lvextend.8.in        |  134 -----
 man/lvm-config.8.des     |    5 +
 man/lvm-config.8.in      |    1 -
 man/lvm-dumpconfig.8.des |    5 +
 man/lvm-dumpconfig.8.in  |    1 -
 man/lvm-fullreport.8.des |    6 +
 man/lvm-fullreport.8.in  |  145 ------
 man/lvm-lvpoll.8.des     |    4 +
 man/lvm-lvpoll.8.end     |   33 ++
 man/lvm-lvpoll.8.in      |   89 ----
 man/lvmchange.8.in       |   10 -
 man/lvmconfig.8.des      |    3 +
 man/lvmconfig.8.in       |  225 ---------
 man/lvmdiskscan.8.des    |    7 +
 man/lvmdiskscan.8.in     |   27 -
 man/lvmlockd.8.in        |   42 +-
 man/lvmsadc.8.des        |    3 +
 man/lvmsadc.8.in         |   16 -
 man/lvmsar.8.des         |    3 +
 man/lvmsar.8.in          |   16 -
 man/lvreduce.8.des       |   14 +
 man/lvreduce.8.end       |    5 +
 man/lvreduce.8.in        |  110 -----
 man/lvremove.8.des       |   22 +
 man/lvremove.8.end       |   11 +
 man/lvremove.8.in        |   80 ---
 man/lvrename.8.des       |    2 +
 man/lvrename.8.end       |   10 +
 man/lvrename.8.in        |   51 --
 man/lvresize.8.des       |    2 +
 man/lvresize.8.end       |    6 +
 man/lvresize.8.in        |  124 -----
 man/lvs.8.des            |    1 +
 man/lvs.8.end            |   75 +++
 man/lvs.8.in             |  290 -----------
 man/lvscan.8.des         |    5 +
 man/lvscan.8.in          |   52 --
 man/pvchange.8.des       |    1 +
 man/pvchange.8.end       |    6 +
 man/pvchange.8.in        |   59 ---
 man/pvck.8.des           |    1 +
 man/pvck.8.end           |    8 +
 man/pvck.8.in            |   37 --
 man/pvcreate.8.des       |   18 +
 man/pvcreate.8.end       |   13 +
 man/pvcreate.8.in        |  210 --------
 man/pvdisplay.8.des      |    5 +
 man/pvdisplay.8.in       |  109 -----
 man/pvmove.8.des         |   61 +++
 man/pvmove.8.end         |   46 ++
 man/pvmove.8.in          |  187 -------
 man/pvremove.8.des       |    2 +
 man/pvremove.8.in        |   37 --
 man/pvresize.8.des       |    2 +
 man/pvresize.8.end       |   16 +
 man/pvresize.8.in        |   56 ---
 man/pvs.8.des            |    1 +
 man/pvs.8.end            |   11 +
 man/pvs.8.in             |  153 ------
 man/pvscan.8.des         |  105 ++++
 man/pvscan.8.in          |  178 -------
 man/see_also.end         |   67 +++
 man/vgcfgbackup.8.des    |   16 +
 man/vgcfgbackup.8.in     |   36 --
 man/vgcfgrestore.8.des   |    8 +
 man/vgcfgrestore.8.end   |    9 +
 man/vgcfgrestore.8.in    |   58 ---
 man/vgchange.8.des       |    2 +
 man/vgchange.8.end       |   16 +
 man/vgchange.8.in        |  346 -------------
 man/vgck.8.des           |    1 +
 man/vgck.8.in            |   22 -
 man/vgconvert.8.des      |    7 +
 man/vgconvert.8.in       |   48 --
 man/vgcreate.8.des       |    4 +
 man/vgcreate.8.end       |    6 +
 man/vgcreate.8.in        |  187 -------
 man/vgdisplay.8.des      |    4 +
 man/vgdisplay.8.in       |  123 -----
 man/vgexport.8.des       |    8 +
 man/vgexport.8.in        |   37 --
 man/vgextend.8.des       |   11 +
 man/vgextend.8.end       |    6 +
 man/vgextend.8.in        |   71 ---
 man/vgimport.8.des       |    5 +
 man/vgimport.8.in        |   38 --
 man/vgimportclone.8.des  |    6 +
 man/vgimportclone.8.end  |    9 +
 man/vgimportclone.8.in   |   46 --
 man/vgmerge.8.des        |    3 +
 man/vgmerge.8.end        |    7 +
 man/vgmerge.8.in         |   41 --
 man/vgmknodes.8.des      |    5 +
 man/vgmknodes.8.in       |   30 --
 man/vgreduce.8.des       |    1 +
 man/vgreduce.8.in        |   49 --
 man/vgremove.8.des       |    6 +
 man/vgremove.8.in        |   46 --
 man/vgrename.8.des       |    9 +
 man/vgrename.8.end       |   10 +
 man/vgrename.8.in        |   58 ---
 man/vgs.8.des            |    1 +
 man/vgs.8.end            |   17 +
 man/vgs.8.in             |  161 -------
 man/vgscan.8.des         |    1 +
 man/vgscan.8.in          |   43 --
 man/vgsplit.8.des        |   13 +
 man/vgsplit.8.in         |   80 ---
 tools/Makefile.in        |    1 -
 126 files changed, 1159 insertions(+), 6683 deletions(-)

diff --git a/configure.in b/configure.in
index 8ec65c8..55bc0be 100644
--- a/configure.in
+++ b/configure.in
@@ -86,6 +86,8 @@ AC_PROG_RANLIB
 AC_PATH_TOOL(CFLOW_CMD, cflow)
 AC_PATH_TOOL(CSCOPE_CMD, cscope)
 AC_PATH_TOOL(CHMOD, chmod)
+AC_PATH_TOOL(WC, wc)
+AC_PATH_TOOL(SORT, sort)
 
 ################################################################################
 dnl -- Check for header files.
diff --git a/doc/license.txt b/doc/license.txt
new file mode 100644
index 0000000..5ba3e66
--- /dev/null
+++ b/doc/license.txt
@@ -0,0 +1,14 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
diff --git a/man/Makefile.in b/man/Makefile.in
index 471cac3..ca2249c 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -31,18 +31,20 @@ LVMRAIDMAN = lvmraid.7
 
 MAN5=lvm.conf.5
 MAN7=lvmsystemid.7 lvmreport.7 
-MAN8=lvm-config.8 lvm-dumpconfig.8 lvm-fullreport.8 lvm-lvpoll.8 \
-	lvchange.8 lvmconfig.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 \
-	lvm.8 lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
+MAN8=lvm.8 lvmconf.8 lvmdump.8
+MAN8DM=dmsetup.8 dmstats.8
+MAN8CLUSTER=
+MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
+
+MAN8GEN=lvm-config.8 lvm-dumpconfig.8 lvm-fullreport.8 lvm-lvpoll.8 \
+	lvcreate.8 lvchange.8 lvmconfig.8 lvconvert.8 lvdisplay.8 lvextend.8 \
 	lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
 	lvscan.8 pvchange.8 pvck.8 pvcreate.8 pvdisplay.8 pvmove.8 pvremove.8 \
 	pvresize.8 pvs.8 pvscan.8 vgcfgbackup.8 vgcfgrestore.8 vgchange.8 \
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
-	vgrename.8 vgs.8 vgscan.8 vgsplit.8
-MAN8DM=dmsetup.8 dmstats.8
-MAN8CLUSTER=
-MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
+	vgrename.8 vgs.8 vgscan.8 vgsplit.8 \
+	lvmsar.8 lvmsadc.8 lvmdiskscan.8 lvmchange.8
 
 ifeq ($(MAKECMDGOALS),all_man)
   MAN_ALL="yes"
@@ -113,8 +115,8 @@ MAN8DIR=$(mandir)/man8
 
 include $(top_builddir)/make.tmpl
 
-CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) \
-	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM)
+CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8GEN) $(MAN8CLUSTER) \
+	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) *.gen man-generator
 DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
 	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CLVMDMAN) $(CMIRRORDMAN) \
 	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN) $(LVMRAIDMAN)
@@ -125,11 +127,11 @@ all: man device-mapper
 
 device-mapper: $(MAN8DM)
 
-man: $(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS)
+man: $(MAN5) $(MAN7) $(MAN8) $(MAN8GEN) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS)
 
 all_man: man
 
-$(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
+$(MAN5) $(MAN7) $(MAN8) $(MAN8GEN) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 
 Makefile: Makefile.in
 	@:
@@ -140,6 +142,18 @@ Makefile: Makefile.in
 	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#DEFAULT_PID_DIR#+ at DEFAULT_PID_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+;" $< > $@ ;; \
 	esac
 
+man-generator:
+	$(CC) -DMAN_PAGE_GENERATOR -I$(top_builddir)/tools $(CFLAGS) $(top_srcdir)/tools/command.c -o $@
+	- ./man-generator lvmconfig > test.gen
+	if [ ! -s test.gen ] ; then cp genfiles/*.gen $(top_builddir)/man; fi;
+
+$(MAN8GEN): man-generator
+	echo "Generating $@" ;
+	if [ ! -e $@.gen ]; then ./man-generator $(basename $@) $(top_srcdir)/man/$@.des > $@.gen; fi
+	if [ -f $(top_srcdir)/man/$@.end ]; then cat $(top_srcdir)/man/$@.end >> $@.gen; fi;
+	cat $(top_srcdir)/man/see_also.end >> $@.gen
+	$(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;s+#DEFAULT_RUN_DIR#+ at DEFAULT_RUN_DIR@+;s+#DEFAULT_PID_DIR#+ at DEFAULT_PID_DIR@+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+;" $@.gen > $@
+
 install_man5: $(MAN5)
 	$(INSTALL) -d $(MAN5DIR)
 	$(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
@@ -148,9 +162,10 @@ install_man7: $(MAN7)
 	$(INSTALL) -d $(MAN7DIR)
 	$(INSTALL_DATA) $(MAN7) $(MAN7DIR)/
 
-install_man8: $(MAN8)
+install_man8: $(MAN8) $(MAN8GEN)
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8) $(MAN8DIR)/
+	$(INSTALL_DATA) $(MAN8GEN) $(MAN8DIR)/
 
 install_lvm2: install_man5 install_man7 install_man8
 
diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index 9b9310d..21f8c7d 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -154,6 +154,32 @@ This timeout will be ignored if you start \fBclvmd\fP with the \fB\-d\fP.
 .br
 Display the version of the cluster LVM daemon.
 .
+.SH NOTES
+.
+.SS Activation
+.
+In a clustered VG, clvmd is used for activation, and the following values are
+possible with \fBlvchange/vgchange -a\fP:
+.IP \fBy\fP|\fBsy\fP
+clvmd activates the LV in shared mode (with a shared lock),
+allowing multiple nodes to activate the LV concurrently.
+If the LV type prohibits shared access, such as an LV with a snapshot,
+an exclusive lock is automatically used instead.
+clvmd attempts to activate the LV concurrently on all nodes.
+.IP \fBey\fP
+clvmd activates the LV in exclusive mode (with an exclusive lock),
+allowing a single node to activate the LV.
+clvmd attempts to activate the LV concurrently on all nodes, but only
+one will succeed.
+.IP \fBly\fP
+clvmd attempts to activate the LV only on the local node.
+If the LV type allows concurrent access, then shared mode is used,
+otherwise exclusive.
+.IP \fBn\fP
+clvmd deactivates the LV on all nodes.
+.IP \fBln\fP
+clvmd deactivates the LV on the local node.
+.
 .SH ENVIRONMENT VARIABLES
 .TP
 .B LVM_CLVMD_BINARY
diff --git a/man/lvchange.8.des b/man/lvchange.8.des
new file mode 100644
index 0000000..7aa8ce7
--- /dev/null
+++ b/man/lvchange.8.des
@@ -0,0 +1,2 @@
+lvchange changes LV attributes in the VG, changes LV activation in the
+kernel, and includes other utilities for LV maintenance.
diff --git a/man/lvchange.8.end b/man/lvchange.8.end
new file mode 100644
index 0000000..7134e46
--- /dev/null
+++ b/man/lvchange.8.end
@@ -0,0 +1,6 @@
+.SH EXAMPLES
+
+Change LV permission to read-only:
+.sp
+.B lvchange \-pr vg00/lvol1
+
diff --git a/man/lvchange.8.in b/man/lvchange.8.in
deleted file mode 100644
index 8da9f2d..0000000
--- a/man/lvchange.8.in
+++ /dev/null
@@ -1,491 +0,0 @@
-.TH LVCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-
-.de UNITS
-..
-
-.
-.SH NAME
-.
-lvchange \(em change attributes of a logical volume
-.
-.SH SYNOPSIS
-.
-.ad l
-.B lvchange
-.RB [ \-a | \-\-activate
-.RB [ a ][ e | s | l ]{ y | n }]
-.RB [ \-\-activationmode
-.RB { complete | degraded | partial }]
-.RB [ \-\-addtag
-.IR Tag ]
-.RB [ \-K | \-\-ignoreactivationskip ]
-.RB [ \-k | \-\-setactivationskip
-.RB { y | n }]
-.RB [ \-\-alloc
-.IR AllocationPolicy ]
-.RB [ \-A | \-\-autobackup
-.RB { y | n }]
-.RB [ \-\-rebuild
-.IR PhysicalVolume ]
-.RB [ \-\-cachemode
-.RB { passthrough | writeback | writethrough }]
-.RB [ \-\-cachepolicy
-.IR Policy ]
-.RB [ \-\-cachesettings
-.IR Key \fB= Value ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-C | \-\-contiguous
-.RB { y | n }]
-.RB [ \-d | \-\-debug ]
-.RB [ \-\-deltag
-.IR Tag ]
-.RB [ \-\-detachprofile ]
-.RB [ \-\-discards
-.RB { ignore | nopassdown | passdown }]
-.RB [ \-\-errorwhenfull
-.RB { y | n }]
-.RB [ \-h | \-? | \-\-help ]
-.RB \%[ \-\-ignorelockingfailure ]
-.RB \%[ \-\-ignoremonitoring ]
-.RB \%[ \-\-ignoreskippedcluster ]
-.RB \%[ \-\-metadataprofile
-.IR ProfileName ]
-.RB [ \-\-monitor
-.RB { y | n }]
-.RB [ \-\-noudevsync ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-p | \-\-permission
-.RB { r | rw }]
-.RB [ \-M | \-\-persistent
-.RB { y | n }
-.RB [ \-\-major
-.IR Major ]
-.RB [ \-\-minor
-.IR Minor ]]
-.RB [ \-\-poll
-.RB { y | n }]
-.RB [ \-\- [ raid ] maxrecoveryrate
-.IR Rate ]
-.RB [ \-\- [ raid ] minrecoveryrate
-.IR Rate ]
-.RB [ \-\- [ raid ] syncaction
-.RB { check | repair }]
-.RB [ \-\- [ raid ] writebehind
-.IR IOCount ]
-.RB [ \-\- [ raid ] writemostly
-.BR \fIPhysicalVolume [ : { y | n | t }]]
-.RB [ \-r | \-\-readahead
-.RB { \fIReadAheadSectors | auto | none }]
-.RB [ \-\-refresh ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-resync ]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-\-sysinit ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-Z | \-\-zero
-.RB { y | n }]
-.RI [ LogicalVolumePath ...]
-.ad b
-.
-.SH DESCRIPTION
-.
-lvchange allows you to change the attributes of a logical volume
-including making them known to the kernel ready for use.
-.
-.SH OPTIONS
-.
-See \fBlvm\fP(8) for common options.
-.
-.HP
-.BR \-a | \-\-activate
-.RB [ a ][ e | s | l ]{ y | n }
-.br
-Controls the availability of the logical volumes for use.
-Communicates with the kernel device-mapper driver via
-libdevmapper to activate (\fB\-ay\fP) or deactivate (\fB\-an\fP) the
-logical volumes.
-.br
-Activation of a logical volume creates a symbolic link
-\fI/dev/VolumeGroupName/LogicalVolumeName\fP pointing to the device node.
-This link is removed on deactivation.
-All software and scripts should access the device through
-this symbolic link and present this as the name of the device.
-The location and name of the underlying device node may depend on
-the distribution and configuration (e.g. udev) and might change
-from release to release.
-.br
-If autoactivation option is used (\fB\-aay\fP),
-the logical volume is activated only if it matches an item in
-the \fBactivation/auto_activation_volume_list\fP
-set in \fBlvm.conf\fP(5).
-If this list is not set, then all volumes are considered for
-activation. The \fB\-aay\fP option should be also used during system
-boot so it's possible to select which volumes to activate using
-the \fBactivation/auto_activation_volume_list\fP setting.
-.br
-In a clustered VG, clvmd is used for activation, and the
-following options are possible:
-
-With \fB\-aey\fP, clvmd activates the LV in exclusive mode
-(with an exclusive lock), allowing a single node to activate the LV.
-
-With \fB\-asy\fP, clvmd activates the LV in shared mode
-(with a shared lock), allowing multiple nodes to activate the LV concurrently.
-If the LV type prohibits shared access, such as an LV with a snapshot,
-the '\fBs\fP' option is ignored and an exclusive lock is used.
-
-With \fB\-ay\fP (no mode specified), clvmd activates the LV in shared mode
-if the LV type allows concurrent access, such as a linear LV.
-Otherwise, clvmd activates the LV in exclusive mode.
-
-With \fB\-aey\fP, \fB\-asy\fP, and \fB\-ay\fP, clvmd attempts to activate the LV
-on all nodes.  If exclusive mode is used, then only one of the
-nodes will be successful.
-
-With \fB\-an\fP, clvmd attempts to deactivate the LV on all nodes.
-
-With \fB\-aly\fP, clvmd activates the LV only on the local node, and \fB\-aln\fP
-deactivates only on the local node.  If the LV type allows concurrent
-access, then shared mode is used, otherwise exclusive.
-
-LVs with snapshots are always activated exclusively because they can only
-be used on one node at once.
-
-For local VGs \fB\-ay\fP, \fB\-aey\fP, and \fB\-asy\fP are all equivalent.
-.
-.HP
-.BR \-\-activationmode
-.RB { complete | degraded | partial }
-.br
-The activation mode determines whether logical volumes are allowed to
-activate when there are physical volumes missing (e.g. due to a device
-failure).  \fBcomplete\fP is the most restrictive; allowing only those
-logical volumes to be activated that are not affected by the missing
-PVs.  \fBdegraded\fP allows RAID logical volumes to be activated even if
-they have PVs missing.  (Note that the "\fImirror\fP" segment type is not
-considered a RAID logical volume.  The "\fIraid1\fP" segment type should
-be used instead.)  Finally, \fBpartial\fP allows any logical volume to
-be activated even if portions are missing due to a missing or failed
-PV.  This last option should only be used when performing recovery or
-repair operations.  \fBdegraded\fP is the default mode.  To change it,
-modify \fBactivation_mode\fP in \fBlvm.conf\fP(5).
-.
-.HP
-.BR \-K | \-\-ignoreactivationskip
-.br
-Ignore the flag to skip Logical Volumes during activation.
-.
-.HP
-.BR \-k | \-\-setactivationskip
-.RB { y | n }
-.br
-Controls  whether Logical Volumes are persistently flagged to be
-skipped during activation. By default, thin snapshot volumes are
-flagged for activation skip.  To activate such volumes,
-an extra \fB\-\-ignoreactivationskip\fP option must be used.
-The flag is not applied during deactivation. To see whether
-the flag is attached, use \fBlvs\fP(8) command where the state
-of the flag is reported within \fBlv_attr\fP bits.
-.
-.HP
-.BR \-\-cachemode
-.RB { passthrough | writeback | writethrough }
-.br
-Specifying a cache mode determines when the writes to a cache LV
-are considered complete.  When \fBwriteback\fP is specified, a write is
-considered complete as soon as it is stored in the cache pool LV.
-If \fBwritethough\fP is specified, a write is considered complete only
-when it has been stored in the cache pool LV and on the origin LV.
-While \fBwritethrough\fP may be slower for writes, it is more
-resilient if something should happen to a device associated with the
-cache pool LV. With \fBpassthrough\fP mode, all reads are served
-from origin LV (all reads miss the cache) and all writes are
-forwarded to the origin LV; additionally, write hits cause cache
-block invalidates. See \fBlvmcache(7)\fP for more details.
-.
-.HP
-.BR  \-\-cachepolicy
-.IR Policy ,
-.BR \-\-cachesettings
-.IR Key \fB= Value
-.br
-Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
-the cache policy and its associated tunable settings. In most use-cases,
-default values should be adequate.
-.
-.HP
-.BR \-C | \-\-contiguous
-.RB { y | n }
-.br
-Tries to set or reset the contiguous allocation policy for
-logical volumes. It's only possible to change a non-contiguous
-logical volume's allocation policy to contiguous, if all of the
-allocated physical extents are already contiguous.
-.
-.HP
-.BR \-\-detachprofile
-.br
-Detach any metadata configuration profiles attached to given
-Logical Volumes. See \fBlvm.conf\fP(5) for more information
-about metadata profiles.
-.
-.HP
-.BR \-\-discards
-.RB { ignore | nopassdown | passdown }
-.br
-Set this to \fBignore\fP to ignore any discards received by a
-thin pool Logical Volume.  Set to \fBnopassdown\fP to process such
-discards within the thin pool itself and allow the no-longer-needed
-extents to be overwritten by new data.  Set to \fBpassdown\fP (the
-default) to process them both within the thin pool itself and to
-pass them down the underlying device.
-.
-.HP
-.BR \-\-errorwhenfull
-.RB { y | n }
-.br
-Sets thin pool behavior when data space is exhaused. See
-.BR lvcreate (8)
-for information.
-.
-.HP
-.BR \-\-ignoremonitoring
-.br
-Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
-is specified.
-Do not use this if dmeventd is already monitoring a device.
-.
-.HP
-.BR \-\-major
-.IR Major
-.br
-Sets the major number. This option is supported only on older systems
-(kernel version 2.4) and is ignored on modern Linux systems where major
-numbers are dynamically assigned.
-.
-.HP
-.BR \-\-minor
-.IR Minor
-.br
-Set the minor number.
-.
-.HP
-.BR \-\-metadataprofile
-.IR ProfileName
-.br
-Uses and attaches \fIProfileName\fP configuration profile to the logical
-volume metadata. Whenever the logical volume is processed next time,
-the profile is automatically applied. If the volume group has another
-profile attached, the logical volume profile is preferred.
-See \fBlvm.conf\fP(5) for more information about metadata profiles.
-.
-.HP
-.BR \-\-monitor
-.RB { y | n }
-.br
-Start or stop monitoring a mirrored or snapshot logical volume with
-dmeventd, if it is installed.
-If a device used by a monitored mirror reports an I/O error,
-the failure is handled according to
-\%\fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
-set in \fBlvm.conf\fP(5).
-.
-.HP
-.BR \-\-noudevsync
-.br
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.
-.HP
-.BR \-p | \-\-permission
-.RB { r | rw }
-.br
-Change access permission to read-only or read/write.
-.
-.HP
-.BR \-M | \-\-persistent
-.RB { y | n }
-.br
-Set to \fBy\fP to make the minor number specified persistent.
-Change of persistent numbers is not supported for pool volumes.
-.
-.HP
-.BR \-\-poll
-.RB { y | n }
-.br
-Without polling a logical volume's backgrounded transformation process
-will never complete.  If there is an incomplete pvmove or lvconvert (for
-example, on rebooting after a crash), use \fB\-\-poll y\fP to restart the
-process from its last checkpoint.  However, it may not be appropriate to
-immediately poll a logical volume when it is activated, use
-\fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
-.
-.HP
-.BR \-\- [ raid ] rebuild 
-.BR \fIPhysicalVolume
-.br
-Option can be repeated multiple times.
-Selects PhysicalVolume(s) to be rebuild in a RaidLV.
-Use this option instead of
-.BR \-\-resync
-or
-.BR \-\- [ raid ] syncaction
-\fBrepair\fP in case the PVs with corrupted data are known and their data
-should be reconstructed rather than reconstructing default (rotating) data.
-.br
-E.g. in a raid1 mirror, the master leg on /dev/sda may hold corrupt data due
-to a known transient disk error, thus
-.br
-\fBlvchange --rebuild /dev/sda LV\fP
-.br
-will request the master leg to be rebuild rather than rebuilding
-all other legs from the master.
-On a raid5 with rotating data and parity
-.br
-\fBlvchange --rebuild /dev/sda LV\fP
-.br
-will rebuild all data and parity blocks in the stripe on /dev/sda.
-.HP
-.BR \-\- [ raid ] maxrecoveryrate
-.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
-.br
-Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as an amount per second for each device in the array.
-If no suffix is given, then KiB/sec/device is assumed.  Setting the
-recovery rate to \fB0\fP means it will be unbounded.
-.
-.HP
-.BR \-\- [ raid ] minrecoveryrate
-.BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
-.br
-Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as an amount per second for each device in the array.
-If no suffix is given, then KiB/sec/device is assumed.  Setting the
-recovery rate to \fB0\fP means it will be unbounded.
-.
-.HP
-.BR \-\- [ raid ] syncaction
-.RB { check | repair }
-.br
-This argument is used to initiate various RAID synchronization operations.
-The \fBcheck\fP and \fBrepair\fP options provide a way to check the
-integrity of a RAID logical volume (often referred to as "scrubbing").
-These options cause the RAID logical volume to
-read all of the data and parity blocks in the array and check for any
-discrepancies (e.g. mismatches between mirrors or incorrect parity values).
-If \fBcheck\fP is used, the discrepancies will be counted but not repaired.
-If \fBrepair\fP is used, the discrepancies will be corrected as they are
-encountered.  The \fBlvs\fP(8) command can be used to show the number of
-discrepancies found or repaired.
-.
-.HP
-.BR \-\- [ raid ] writebehind
-.IR IOCount
-.br
-Specify the maximum number of outstanding writes that are allowed to
-devices in a RAID1 logical volume that are marked as write-mostly.
-Once this value is exceeded, writes become synchronous (i.e. all writes
-to the constituent devices must complete before the array signals the
-write has completed).  Setting the value to zero clears the preference
-and allows the system to choose the value arbitrarily.
-.
-.HP
-.BR \-\- [ raid ] writemostly
-.BR \fIPhysicalVolume [ : { y | n | t }]
-.br
-Mark a device in a RAID1 logical volume as write-mostly.  All reads
-to these drives will be avoided unless absolutely necessary.  This keeps
-the number of I/Os to the drive to a minimum.  The default behavior is to
-set the write-mostly attribute for the specified physical volume in the
-logical volume.  It is possible to also remove the write-mostly flag by
-appending a "\fB:n\fP" to the physical volume or to toggle the value by specifying
-"\fB:t\fP".  The \fB\-\-writemostly\fP argument can be specified more than one time
-in a single command; making it possible to toggle the write-mostly attributes
-for all the physical volumes in a logical volume at once.
-.
-.HP
-.BR \-r | \-\-readahead
-.RB { \fIReadAheadSectors | auto | none }
-.br
-Set read ahead sector count of this logical volume.
-For volume groups with metadata in lvm1 format, this must
-be a value between 2 and 120 sectors.
-The default value is "\fBauto\fP" which allows the kernel to choose
-a suitable value automatically.
-"\fBnone\fP" is equivalent to specifying zero.
-.
-.HP
-.BR \-\-refresh
-.br
-If the logical volume is active, reload its metadata.
-This is not necessary in normal operation, but may be useful
-if something has gone wrong or if you're doing clustering
-manually without a clustered lock manager.
-.
-.HP
-.BR \-\-resync
-.br
-Forces the complete resynchronization of a mirror.  In normal
-circumstances you should not need this option because synchronization
-happens automatically.  Data is read from the primary mirror device
-and copied to the others, so this can take a considerable amount of
-time - and during this time you are without a complete redundant copy
-of your data.
-.
-.HP
-.BR \-\-sysinit
-.br
-Indicates that \fBlvchange\fP(8) is being invoked from early system
-initialisation scripts (e.g. rc.sysinit or an initrd),
-before writeable filesystems are available. As such,
-some functionality needs to be disabled and this option
-acts as a shortcut which selects an appropriate set of options. Currently
-this is equivalent to using  \fB\-\-ignorelockingfailure\fP,
-\fB\-\-ignoremonitoring\fP, \fB\-\-poll n\fP and setting
-\fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
-environment variable.
-
-If \fB\-\-sysinit\fP is used in conjunction with
-\fBlvmetad\fP(8) enabled and running,
-autoactivation is preferred over manual activation via direct lvchange call.
-Logical volumes are autoactivated according to
-\fBauto_activation_volume_list\fP set in \fBlvm.conf\fP(5).
-.
-.HP
-.BR \-Z | \-\-zero
-.RB { y | n }
-.br
-Set zeroing mode for thin pool. Note: already provisioned blocks from pool
-in non-zero mode are not cleared in unwritten parts when setting zero to
-\fBy\fP.
-.
-.SH ENVIRONMENT VARIABLES
-.
-.TP
-.B LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES
-Suppress locking failure messages.
-.
-.SH Examples
-.
-Changes the permission on volume lvol1 in volume group vg00 to be read-only:
-.sp
-.B lvchange \-pr vg00/lvol1
-.
-.SH SEE ALSO
-.
-.nh
-.BR lvm (8),
-.BR lvmetad (8),
-.BR lvs (8),
-.BR lvcreate (8),
-.BR vgchange (8),
-.BR lvmcache (7),
-.BR lvmthin (7),
-.BR lvm.conf (5)
diff --git a/man/lvconvert.8.des b/man/lvconvert.8.des
new file mode 100644
index 0000000..2aa95a1
--- /dev/null
+++ b/man/lvconvert.8.des
@@ -0,0 +1,32 @@
+lvconvert changes the LV type and includes utilities for LV data
+maintenance. The LV type controls data layout and redundancy.
+The LV type is also called the segment type or segtype.
+
+To display the current LV type, run the command:
+
+.B lvs \-o name,segtype
+.I LV
+
+The
+.B linear
+type is equivalent to the
+.B striped
+type when one stripe exists.
+In that case, the types can sometimes be used interchangably.
+
+In most cases, the
+.B mirror
+type is deprecated and the
+.B raid1
+type should be used.  They are both implementations of mirroring.
+
+In some cases, an LV is a single device mapper (dm) layer above physical
+devices.  In other cases, hidden LVs (dm devices) are layered between the
+visible LV and physical devices.  LVs in the middle layers are called sub LVs.
+A command run on a visible LV sometimes operates on a sub LV rather than
+the specified LV.  In other cases, a sub LV must be specified directly on
+the command line.
+
+Sub LVs can be displayed with the command
+.B lvs -a
+
diff --git a/man/lvconvert.8.end b/man/lvconvert.8.end
new file mode 100644
index 0000000..fa8cc1d
--- /dev/null
+++ b/man/lvconvert.8.end
@@ -0,0 +1,95 @@
+.SH EXAMPLES
+
+Convert a linear LV to a two-way mirror LV.
+.br
+.B lvconvert \-\-type mirror \-\-mirrors 1 vg/lvol1
+
+Convert a linear LV to a two-way RAID1 LV.
+.br
+.B lvconvert \-\-type raid1 \-\-mirrors 1 vg/lvol1
+
+Convert a mirror LV to use an in\-memory log.
+.br
+.B lvconvert \-\-mirrorlog core vg/lvol1
+
+Convert a mirror LV to use a disk log.
+.br
+.B lvconvert \-\-mirrorlog disk vg/lvol1
+
+Convert a mirror or raid1 LV to a linear LV.
+.br
+.B lvconvert --type linear vg/lvol1
+
+Convert a mirror LV to a raid1 LV with the same number of images.
+.br
+.B lvconvert \-\-type raid1 vg/lvol1
+
+Convert a linear LV to a two-way mirror LV, allocating new extents from specific
+PV ranges.
+.br
+.B lvconvert \-\-mirrors 1 vg/lvol1 /dev/sda:0\-15 /dev/sdb:0\-15
+
+Convert a mirror LV to a linear LV, freeing physical extents from a specific PV.
+.br
+.B lvconvert \-\-type linear vg/lvol1 /dev/sda
+
+Split one image from a mirror or raid1 LV, making it a new LV.
+.br
+.B lvconvert \-\-splitmirrors 1 \-\-name lv_split vg/lvol1
+
+Split one image from a raid1 LV, and track changes made to the raid1 LV
+while the split image remains detached.
+.br
+.B lvconvert \-\-splitmirrors 1 \-\-trackchanges vg/lvol1
+
+Merge an image (that was previously created with \-\-splitmirrors and
+\-\-trackchanges) back into the original raid1 LV.
+.br
+.B lvconvert \-\-mergemirrors vg/lvol1_rimage_1
+
+Replace PV /dev/sdb1 with PV /dev/sdf1 in a raid1/4/5/6/10 LV.
+.br
+.B lvconvert \-\-replace /dev/sdb1 vg/lvol1 /dev/sdf1
+
+Replace 3 PVs /dev/sd[b-d]1 with PVs /dev/sd[f-h]1 in a raid1 LV.
+.br
+.B lvconvert \-\-replace /dev/sdb1 \-\-replace /dev/sdc1 \-\-replace /dev/sdd1
+.RS
+.B vg/lvol1 /dev/sd[fgh]1
+.RE
+
+Replace the maximum of 2 PVs /dev/sd[bc]1 with PVs /dev/sd[gh]1 in a raid6 LV.
+.br
+.B lvconvert \-\-replace /dev/sdb1 \-\-replace /dev/sdc1 vg/lvol1 /dev/sd[gh]1
+
+Convert an LV into a thin LV in the specified thin pool.  The existing LV
+is used as an external read\-only origin for the new thin LV.
+.br
+.B lvconvert \-\-type thin \-\-thinpool vg/tpool1 vg/lvol1
+
+Convert an LV into a thin LV in the specified thin pool.  The existing LV
+is used as an external read\-only origin for the new thin LV, and is
+renamed "external".
+.br
+.B lvconvert \-\-type thin \-\-thinpool vg/tpool1
+.RS
+.B \-\-originname external vg/lvol1
+.RE
+
+Convert an LV to a cache pool LV using another specified LV for cache pool
+metadata.
+.br
+.B lvconvert \-\-type cache-pool \-\-poolmetadata vg/poolmeta1 vg/lvol1
+
+Convert an LV to a cache LV using the specified cache pool and chunk size.
+.br
+.B lvconvert \-\-type cache \-\-cachepool vg/cpool1 \-c 128 vg/lvol1
+
+Detach and keep the cache pool from a cache LV.
+.br
+.B lvconvert \-\-splitcache vg/lvol1
+
+Detach and remove the cache pool from a cache LV.
+.br
+.B lvconvert \-\-uncache vg/lvol1
+
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
deleted file mode 100644
index 0becc8a..0000000
--- a/man/lvconvert.8.in
+++ /dev/null
@@ -1,1199 +0,0 @@
-.TH LVCONVERT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc" \" -*- nroff -*-
-.SH NAME
-lvconvert \(em change LV type and other utilities
-.
-.SH SYNOPSIS
-
-.B lvconvert
-.RI [ OPTION ]...
-.IR VolumeGroup / LogicalVolume
-
-OPTIONS:
-.br
-.BR \-b ,
-.BR \-\-background
-.br
-.BR \-\-cachepolicy
-.IR Policy
-.br
-.BR \-\-cachepool
-.IR CachePoolLogicalVolume { Name | Path }
-.br
-.BR \-\-cachesettings
-.IB Key = Value
-.br
-.BR \-c ,
-.BR \-\-chunksize
-.BR \fIChunkSize [ b | B | s | S | k | K | m | M | g | G ]
-.br
-.BR \-\-corelog
-.br
-.BR \-\-discards
-.RB { ignore | nopassdown | passdown }
-.br
-.BR \-i ,
-.BR \-\-interval
-.IR Seconds
-.br
-.BR \-\-merge
-.br
-.BR \-\-mirrorlog
-.RB { disk | core | mirrored }
-.br
-.BR \-m ,
-.BR \-\-mirrors
-.IR Number
-.br
-.BR \-n ,
-.BR \-\-name
-.IR Name
-.br
-.BR \-\-noudevsync
-.br
-.BR \-\-originname
-.IR NewExternalOriginVolumeName
-.br
-.BR \-\-poolmetadata
-.IR PoolMetadataLogicalVolume { Name | Path }
-.br
-.BR \-\-poolmetadatasize
-.BR \fIPoolMetadataSize [ b | B | s | S | k | K | m | M | g | G ]
-.br
-.BR \-\-poolmetadataspare
-.RB { y | n }
-.br
-.BR \-r ,
-.BR \-\-readahead
-.RB { \fIReadAheadSectors | auto | none }
-.br
-.BR \-R ,
-.BR \-\-regionsize
-.IR MirrorLogRegionSize
-.br
-.BR \-\-repair
-.br
-.BR \-\-replace
-.IR PhysicalVolume
-.br
-.BR \-\-splitcache
-.br
-.BR \-\-splitmirrors
-.IR Number
-.br
-.BR \-\-splitsnapshot
-.br
-.BR \-\-stripes
-.IR Number
-.br
-.BR \-I ,
-.BR \-\-stripesize
-.IR StripeSize
-.br
-.B \-\-type striped
-.br
-.B \-\-type snapshot
-|
-.B \-\-snapshot
-|
-.B \-s
-.br
-.B \-\-type mirror
-.br
-.B \-\-type raid*
-.br
-.B \-\-type thin
-|
-.B \-\-thin
-|
-.B \-T
-.br
-.B \-\-type cache
-|
-.B \-\-cache
-|
-.B \-H
-.br
-.B \-\-type thin\-pool
-.br
-.B \-\-type cache\-pool
-.br
-.BR \-\-thinpool
-.IR ThinPoolLogicalVolume { Name | Path }
-.br
-.BR \-\-trackchanges
-.br
-.BR \-\-uncache
-.br
-.BR \-Z ,
-.BR \-\-zero
-.RB { y | n }
-.br
-
-Common options:
-.br
-.BR \-A ,
-.BR \-\-alloc
-.IR AllocationPolicy
-.br
-.BR \-f ,
-.BR \-\-force
-.br
-.BR \-\-commandprofile
-.IR ProfileName
-.br
-.BR \-h ,
-.BR \-? ,
-.BR \-\-help
-.br
-.BR \-v ,
-.BR \-\-verbose
-.br
-.BR \-y ,
-.BR \-\-yes
-.br
-.BR \-\-version
-
-
-
-
-.SH DESCRIPTION
-
-lvconvert changes the LV type and includes various LV utilities.
-
-To display the current LV type, run the command:
-
-.B lvs \-o name,segtype
-.IR VG / LV
-
-To change the LV type, run the command:
-
-.B lvconvert \-\-type
-.I NewType
-.IR VG / LV
-
-.SS LV types
-
-The LV type is also called the "segment type" or "segtype".
-
-LVs with the following types can be modified by lvconvert:
-.B striped,
-.B snapshot,
-.B mirror,
-.B raid*,
-.B thin,
-.B cache,
-.B thin\-pool,
-.B cache\-pool.
-
-The specific operations available on each LV type are listed below.
-
-The
-.B linear
-type is equivalent to the
-.B striped
-type when one stripe exists.
-In that case, the types can sometimes be used interchangably.
-
-In most cases, the
-.B mirror
-type is deprecated and the
-.B raid1
-type should be used.  They are both implementations of mirroring.
-
-The
-.B raid*
-type refers to one of many raid levels, e.g.
-.B raid1,
-.B raid5.
-
-.SS LV layers
-
-In some cases, an LV is a single device mapper (dm) layer above physical
-devices.  In other cases, hidden LVs (dm devices) are layered between the
-visible LV and physical devices.  LVs in the middle layers are sometimes
-called sub LVs.
-
-Changing the LV type will often change the composition of sub LVs.
-
-Sub LVs can be displayed with the command
-.B lvs -a.
-
-A command run on a visible LV sometimes operates on a sub LV rather than
-the specified LV.  These cases are noted below.
-
-Sometimes a sub LV must be specified directly on the command line, but
-this is a non-standard form.  These cases may change in the future to
-avoid the direct use of hidden LVs.
-
-.SH COMMANDS
-
-.SS Operations on a StripedLV with type striped or linear:
-
-\&
-
-.B lvconvert \-\-merge
-VG/StripedLV
-./" FIXME: use --merge-mirror
-.br
-\[bu]
-Merge StripedLV into an LV when it is a previously split mirror.
-.br
-\[bu]
-Options \-\-background, \-\-interval.
-.br
-\[bu]
-See corresponding operation --splitmirrors.
-
-.B lvconvert \-\-type snapshot
-VG/StripedLV VG/SnapshotLV
-.br
-\[bu]
-Recombine StripedLV with SnapshotLV which was previously split.
-.br
-\[bu]
-Options \-\-chunksize, \-\-zero.
-.br
-\[bu]
-See corresponding operation --splitsnapshot.
-
-.B lvconvert \-\-type thin
-VG/StripedLV
-.br
-\[bu]
-Convert StripedLV to type thin with an external origin.
-.br
-\[bu]
-StripedLV becomes a read\-only external origin LV with a new name.
-.br
-\[bu]
-Requires \-\-thinpool to specify the thin pool to use.
-.br
-\[bu]
-Options \-\-originname.
-
-.B lvconvert \-\-type cache
-VG/StripedLV
-.br
-\[bu]
-Convert StripedLV to type cache.
-.br
-\[bu]
-Requires \-\-cachepool to specify the cache pool to use.
-.br
-\[bu]
-Options \-\-cachepolicy, \-\-cachesettings.
-
-.B lvconvert \-\-type thin\-pool
-VG/StripedLV
-.br
-\[bu]
-Convert StripedLV to type thin\-pool.
-.br
-\[bu]
-The StripedLV is used for thin pool data.
-.br
-\[bu]
-Options \-\-chunksize, \-\-discards, \-\-poolmetadata{size,spare},
-.br
-  \-\-readahead, \-\-zero.
-
-.B lvconvert \-\-type cache\-pool
-VG/StripedLV
-.br
-\[bu]
-Convert StripedLV to type cache\-pool.
-.br
-\[bu]
-Options \-\-chunksize, \-\-poolmetadata{size,spare}.
-
-.B lvconvert \-\-type mirror
-VG/StripedLV
-.br
-\[bu]
-Convert StripedLV to type mirror.
-.br
-\[bu]
-Requires \-\-mirrors to specify the number of mirrors to use.
-.br
-\[bu]
-Options \-\-mirrorlog, \-\-regionsize.
-
-.B lvconvert \-\-type raid*
-VG/StripedLV
-.br
-\[bu]
-Convert StripedLV to type raid*.
-.br
-\[bu]
-Required options depend on the raid level.
-
-.SS Operations on RaidLV with type raid*:
-
-\&
-
-.B lvconvert \-\-mirrors
-Number
-VG/RaidLV
-.br
-\[bu]
-Change the number of images in raid1 RaidLV.
-
-.B lvconvert \-\-splitmirrors
-Number
-VG/RaidLV
-.br
-\[bu]
-Split images from raid1 RaidLV and use them to create a new LV.
-.br
-\[bu]
-Requires \-\-name for the new LV, or the use of \-\-trackchanges.
-
-.B lvconvert \-\-merge
-VG/RaidLV
-./" FIXME: use --merge-mirror
-.br
-\[bu]
-Merge RaidLV into an LV when it is a previously split mirror.
-.br
-\[bu]
-Options \-\-background, \-\-interval.
-.br
-\[bu]
-See corresponding operation --splitmirrors.
-
-.B lvconvert \-\-repair
-VG/RaidLV
-.br
-\[bu]
-Options \-\-background, \-\-interval.
-.br
-\[bu]
-Replace failed PVs in RaidLV.
-
-.B lvconvert \-\-replace
-PV
-VG/RaidLV
-.br
-\[bu]
-Replace specific PV(s) in a raid* LV with another PV.
-.br
-\[bu]
-The new PV(s) to use can be optionally specified after the LV.
-.br
-\[bu]
-Repeat to replace multiple: \-\-replace PV1 \-\-replace PV2 ...
-
-.B lvconvert \-\-type snapshot
-VG/RaidLV
-VG/SnapshotLV
-.br
-\[bu]
-Combine RaidLV with SnapshotLV that was previously split.
-.br
-\[bu]
-Options \-\-chunksize, \-\-zero.
-.br
-\[bu]
-See corresponding operation \-\-splitsnapshot.
-
-.B lvconvert \-\-type thin
-VG/RaidLV
-.br
-\[bu]
-Convert RaidLV to type thin with an external origin.
-.br
-\[bu]
-RaidLV becomes a read\-only external origin LV with a new name.
-.br
-\[bu]
-Requires \-\-thinpool to specify the thin pool to use.
-.br
-\[bu]
-Options \-\-originname.
-
-.B lvconvert \-\-type cache
-VG/RaidLV
-.br
-\[bu]
-Convert RaidLV to type cache.
-.br
-\[bu]
-Requires \-\-cachepool to specify the cache pool to use.
-.br
-\[bu]
-Options \-\-cachepolicy, \-\-cachesettings.
-
-.B lvconvert \-\-type thin\-pool
-VG/RaidLV
-.br
-\[bu]
-Convert RaidLV to type thin\-pool.
-.br
-\[bu]
-The RaidLV is used for thin pool data.
-.br
-\[bu]
-Options \-\-chunksize, \-\-discards, \-\-poolmetadata{size,spare},
-.br
-  \-\-readahead, \-\-zero.
-
-.B lvconvert \-\-type cache\-pool
-VG/RaidLV
-.br
-\[bu]
-Convert RaidLV to type cache\-pool.
-.br
-\[bu]
-Options \-\-chunksize, \-\-poolmetadata{size,spare}.
-
-.B lvconvert \-\-type raid*
-VG/RaidLV
-.br
-\[bu]
-Convert RaidLV to use a different raid level.
-.br
-\[bu]
-Required options depend on the raid level.
-
-.B lvconvert \-\-type mirror
-VG/RaidLV
-.br
-\[bu]
-Convert RaidLV to type mirror.
-
-.B lvconvert \-\-type striped
-VG/RaidLV
-.br
-\[bu]
-Convert RaidLV to type striped.
-
-.B lvconvert \-\-type linear
-VG/RaidLV
-.br
-\[bu]
-Convert RaidLV to type linear.
-
-.SS Operations on MirrorLV with type mirror:
-
-\&
-
-.B lvconvert \-\-mirrors
-Number
-VG/MirrorLV
-.br
-\[bu]
-Change the number of images in MirrorLV.
-
-.B lvconvert \-\-splitmirrors
-Number
-VG/MirrorLV
-.br
-\[bu]
-Split images from MirrorLV and use them to create a new LV.
-.br
-\[bu]
-Requires \-\-name for the new LV.
-
-.B lvconvert \-\-mirrorlog
-LogType
-VG/MirrorLV
-.br
-\[bu]
-Change the type of log used by MirrorLV.
-
-.B lvconvert \-\-repair
-VG/MirrorLV
-.br
-\[bu]
-Options \-\-background, \-\-interval.
-.br
-\[bu]
-Replace failed PVs in MirrorLV.
-
-.B lvconvert \-\-type linear
-VG/MirrorLV
-.br
-\[bu]
-Convert MirrorLV to type linear.
-
-.B lvconvert \-\-type raid*
-VG/MirrorLV
-.br
-\[bu]
-Convert MirrorLV to type raid*.
-.br
-\[bu]
-Required options depend on the raid level.
-
-.SS Operations on CachePoolLV with type cache\-pool:
-
-\&
-
-.B lvconvert \-\-splitcache
-VG/CachePoolLV
-.br
-\[bu]
-Split the cache LV from CachePoolLV.
-.br
-\[bu]
-Equivalent to --splitcache on CacheLV.
-
-.SS Operations on CacheLV with type cache:
-
-\&
-
-.B lvconvert \-\-splitcache
-VG/CacheLV
-.br
-\[bu]
-Split and keep the cache pool from CacheLV.
-
-.B lvconvert \-\-uncache
-VG/CacheLV
-.br
-\[bu]
-Split and remove the cache pool from CacheLV.
-
-.B lvconvert \-\-splitmirrors
-Number
-VG/CacheLV
-.br
-\[bu]
-Split images from the mirrored origin of CacheLV to create a new LV.
-.br
-\[bu]
-Operates on mirror or raid1 sub LV.
-.br
-\[bu]
-Requires \-\-name for the new LV, or the use of \-\-trackchanges.
-
-.B lvconvert \-\-type thin\-pool
-VG/CacheLV
-.br
-\[bu]
-Convert CacheLV to type thin-pool.
-.br
-\[bu]
-The CacheLV is used for thin pool data.
-.br
-\[bu]
-Options \-\-chunksize, \-\-discards, \-\-poolmetadata{size,spare},
-.br
-  \-\-readahead, \-\-zero.
-
-
-.SS Operations on ThinPoolLV with type thin\-pool:
-
-\&
-
-.B lvconvert \-\-splitcache
-VG/ThinPoolLV
-.br
-\[bu]
-Split and keep the cache pool from the data portion of ThinPoolLV.
-.br
-\[bu]
-Operates on the data sub LV of the thin pool LV.
-.br
-\[bu]
-The data sub LV of the thin pool must be a cache LV.
-
-.B lvconvert \-\-uncache
-VG/ThinPoolLV
-.br
-\[bu]
-Split and remove the cache pool from the data portion of ThinPoolLV.
-.br
-\[bu]
-Operates on the data sub LV of the thin pool LV.
-.br
-\[bu]
-The data sub LV of the thin pool must be a cache LV.
-
-.B lvconvert \-\-type cache
-VG/ThinPoolLV
-.br
-\[bu]
-Convert the data portion of ThinPoolLV to type cache.
-.br
-\[bu]
-Requires \-\-cachepool to specify the cache pool to use.
-.br
-\[bu]
-Operates on the data sub LV of the thin pool LV.
-.br
-\[bu]
-Options \-\-cachepolicy, \-\-cachesettings.
-
-.B lvconvert \-\-repair
-VG/ThinPoolLV
-.br
-\[bu]
-Repair ThinPoolLV.
-
-.SS Operations on ThinLV with type thin:
-
-\&
-
-.B lvconvert \-\-merge
-VG/ThinLV
-./" FIXME: use --merge-snapshot
-.br
-\[bu]
-Merge ThinLV into its origin LV.
-.br
-\[bu]
-ThinLV must have been created as a snapshot of another thin LV.
-.br
-\[bu]
-Options \-\-background, \-\-interval.
-
-.SS Operations on SnapshotLV with type snapshot:
-
-\&
-
-.B lvconvert \-\-splitsnapshot
-VG/SnapshotLV
-.br
-\[bu]
-Separate COW snapshot SnapshotLV from its origin LV.
-
-.B lvconvert \-\-merge
-VG/SnapshotLV
-./" FIXME: use --merge-snapshot
-.br
-\[bu]
-Merge COW snapshot SnapshotLV into its origin.
-.br
-\[bu]
-Options \-\-background, \-\-interval.
-
-.SH OPTIONS
-.
-See \fBlvm\fP(8) for common options.
-.br
-.
-.HP
-.BR \-b ,
-.BR \-\-background
-.br
-If the operation requires polling, this option causes the command to
-return before the operation is complete, and polling is done in the
-background.
-.
-.HP
-.BR \-\-cachepolicy
-.IR Policy
-.br
-Specifies the cache policy for a cache LV.  Also see
-.BR lvmcache (7).
-.
-.HP
-.BR \-\-cachepool
-.IR CachePoolLogicalVolume { Name | Path }
-.br
-Specifies the cache pool to use when converting an LV to a cache LV.  If
-CachePoolLogicalVolume is not yet a cache pool, the command will attempt
-to convert it into a cache pool prior to the cache LV conversion.
-Also see
-.BR lvmcache (7).
-.
-.HP
-.BR \-\-cachesettings
-.IB Key = Value
-.br
-Specifies tunable values for a cache LV.  (The default values should
-usually be adequate.)  The special string value \fBdefault\fP switches
-settings back to their default kernel values and removes them from the
-list of settings stored in LVM metadata.
-Also see
-.BR lvmcache (7).
-.
-.HP
-.BR \-c ,
-.BR \-\-chunksize
-.BR \fIChunkSize [ b | B | s | S | k | K | m | M | g | G ]
-.br
-Sets the chunk size for a snapshot, cache pool or thin pool.
-The default unit is in kilobytes.
-.sp
-For snapshots, the value must be a power of 2 between 4KiB and 512KiB
-and the default value is 4.
-.sp
-For a cache pool the value must be between 32KiB and 1GiB and
-the default value is 64.
-.sp
-For a thin pool the value must be between 64KiB and
-1GiB and the default value starts with 64 and scales
-up to fit the pool metadata size within 128MiB,
-if the pool metadata size is not specified.
-The value must be a multiple of 64KiB.
-(Early kernel support until thin target version 1.4 required the value
-to be a power of 2.  Discards were not supported for non-power of 2 values
-until thin target version 1.5.)
-.
-.HP
-.BR \-\-corelog
-.br
-Specifies or changes the log type for a mirror LV.
-It is an alias for \fB\-\-mirrorlog core\fP.
-(This option does not apply to the \fBraid1\fP LV type.)
-.
-.HP
-.BR \-\-discards
-.RB { ignore | nopassdown | passdown }
-.br
-Specifies if discards will be processed by the thin layer in the
-kernel and passed down to the Physical Volume.  This applies only
-to thin pools.  The default is \fBpassdown\fP.
-Also see
-.BR lvmthin (7).
-.
-.HP
-.BR \-H ,
-.BR \-\-cache
-.br
-Alias for
-.B \-\-type cache.
-See COMMANDS description for
-.br
-.B lvconvert \-\-type cache.
-.
-.HP
-.BR \-i ,
-.BR \-\-interval
-.IR Seconds
-.br
-Report progress as a percentage at regular intervals.
-.
-.HP
-.BR \-\-merge
-.br
-Merges a snapshot that was split from an origin LV using
-\fB\-\-splitsnapshot\fP, back into the origin LV.
-
-Merges a raid1 image that was split from a raid1 LV using
-\fB\-\-splitsnapshot\fP and \fB\-\-trackchanges\fP, back into
-the original raid1 LV.
-
-To check if the kernel supports the snapshot merge feature, look for
-"snapshot\-merge" in the output of \fBdmsetup targets\fP.
-
-When merging a snapshot, if both the origin and snapshot LVs are not open,
-the merge will start immediately.  Otherwise, the merge will start the
-first time either the origin or snapshot LV are activated and both are
-closed.  Merging a snapshot into an origin that cannot be closed, for
-example a root filesystem, is deferred until the next time the origin
-volume is activated.  When merging starts, the resulting LV will have the
-origin's name, minor number and UUID.  While the merge is in progress,
-reads or writes to the origin appear as being directed to the snapshot
-being merged.  When the merge finishes, the merged snapshot is removed.
-Multiple snapshots may be specified on the command line or a @tag may be
-used to specify multiple snapshots be merged to their respective origin.
-.
-.HP
-.BR \-\-mirrorlog
-.RB { disk | core | mirrored }
-.br
-Specifies or changes the log type for a mirror LV.
-The default is \fBdisk\fP, which is persistent and requires
-a small amount of storage space, usually on a separate device
-from the data being mirrored.
-\fBCore\fP may be useful for short-lived mirrors.  It means the mirror is
-regenerated by copying the data from the first device again every
-time the device is activated - e.g. possibly after every reboot.
-Using \fBmirrored\fP will create a persistent log that is itself mirrored.
-(This option does not apply to the \fBraid1\fP LV type.)
-.
-.HP
-.BR \-m ,
-.BR \-\-mirrors
-.IR Number
-.br
-Specifies the number mirror images in addition to the original LV image,
-e.g. \fB\-\-mirrors 1\fP means two copies of the data, the original and
-one mirror image.
-
-The current maximum is 9 providing 10 raid1 images.
-
-This option is required when converting an LV to a \fBraid1\fP or
-\fBmirror\fP LV.
-
-This option can be used alone to change the number of mirror images in an
-existing \fBraid1\fP or \fBmirror\fP LV.
-
-The special case \fB\-\-mirrors 0\fP has been used historically to
-indicate a linear LV with no mirror images.
-.
-.HP
-.BR \-n ,
-.BR \-\-name
-.IR Name
-.br
-Specifies the name to use when the command is creating a new LV, e.g.
-.B \-\-splitmirrors.
-.
-.HP
-.BR \-\-noudevsync
-.br
-Disables udev synchronisation. The process will not wait for notification
-from udev.  It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running or has
-rules that ignore the devices LVM creates.
-.
-.HP
-.BR \-\-originname
-.IR NewExternalOriginVolumeName
-.br
-Specifies the name to use for the external origin LV when converting an LV
-to a thin LV.  The LV being converted becomes a read\-only external origin
-with this name.
-.br
-Without this option, the default name of "lvol<n>" will be generated where
-<n> is the LVM internal number of the LV.
-.br
-.
-.\" .HP
-.\" .BR \-\-pooldatasize
-.\" .IR PoolDataVolumeSize [ \fBbBsSkKmMgGtTpPeE ]
-.\" .br
-.\" Sets the size of pool's data logical volume.
-.\" The option \fB\-\-size\fP could be still used with thin pools.
-.
-.HP
-.BR \-\-poolmetadata
-.IR PoolMetadataLogicalVolume { Name | Path }
-.br
-Specifies the LV to use for thin pool metadata when converting an LV to a
-thin pool LV.
-.br
-Specifies the LV to use for cache pool metadata when converting an LV to a
-cache pool LV.
-.br
-The size should be between 2MiB and 16GiB.
-.br
-(This option can also be used when a thin pool or cache pool are created
-as an auxiliary operation within a different command.)
-Also see
-.BR lvmthin (7),
-and
-.BR lvmcache (7).
-.
-.HP
-.BR \-\-poolmetadatasize
-.BR \fIPoolMetadataSize [ b | B | s | S | k | K | m | M | g | G ]
-.br
-Specifies the size of a cache pool metadata LV or a thin pool metadata LV.
-This is used if a command creates a pool metadata LV automatically as part
-of the operation.  This option is not used when an existing LV is
-specified as the pool metadata LV, i.e. \fB\-\-poolmetadata\fP.
-The default unit is megabytes.
-Also see
-.BR lvmthin (7),
-and
-.BR lvmcache (7).
-.
-.HP
-.BR \-\-poolmetadataspare
-.RB { y | n }
-.br
-Specifies if a spare pool metadata LV should be created.
-A spare pool metadata LV will be used for pool repair.
-Only one spare pool metadata LV is maintained within a VG, with the size
-of the largest existing pool metadata LV.
-The default is \fBy\fPes.
-.
-.HP
-.BR \-r ,
-.BR \-\-readahead
-.RB { \fIReadAheadSectors | auto | none }
-.br
-Specifies the read ahead sector count of a thin pool metadata LV.
-The default value is \fBauto\fP which allows the kernel to choose
-a suitable value automatically.
-\fBNone\fP is equivalent to specifying zero.
-.
-.HP
-.BR \-R ,
-.BR \-\-regionsize
-.IR MirrorLogRegionSize
-.br
-A mirror LV is divided into regions of this size (in MB), and the mirror
-log uses this granularity to track which regions are in sync.
-(This option does not apply to the \fBraid1\fP LV type.)
-.
-.HP
-.BR \-\-repair
-.br
-Replaces failed PVs in a raid1 or mirror LV with other PVs available in
-the VG.  By default, the original number of mirror images will be restored
-if possible.  Specify \fB\-y\fP on the command line to skip the prompts.
-Use \fB\-f\fP if you do not want any replacement.  You may use
-\fB\-\-use\-policies\fP to use the device replacement policy specified in
-\fBlvm.conf\fP(5), see \fBactivation/mirror_log_fault_policy\fP or
-\fBactivation/mirror_device_fault_policy\fP.
-
-When used with a thin pool LV, this option automates the use of the
-\fBthin_repair\fP(8) tool on the thin pool.  This repairs a very limitted
-number of problems.  Only inactive thin pools can be repaired.  There is
-no validation of metadata between kernel and LVM.  This requires further
-manual work.  After successfull repair the old unmodified metadata are
-still available in "<pool>_meta<n>" LV.
-Also see
-.BR lvmthin (7).
-.
-.HP
-.BR \-\-replace
-.IR PhysicalVolume
-.br
-Remove the specified device \fIPhysicalVolume\fP and replace it with one
-that is available in the VG, or from a specific list of PVs specified on
-the command line following the LV name. This option may be repeated multiple
-times depending on the RaidLV type.
-.
-.HP
-.BR \-s ,
-.BR \-\-snapshot
-.br
-Alias for
-.B \-\-type snapshot.
-See COMMANDS description for
-.br
-.B lvconvert \-\-type snapshot.
-.HP
-.BR \-\-split
-.br
-Separates \fISplitableLogicalVolume\fP.
-This option tries to detect the necessary split operation from its arguments.
-Avoid using this option and use one of the following instead:
-.B \-\-splitcache, \-\-splitmirrors, \-\-splitsnapshot.
-.
-.HP
-.BR \-\-splitcache
-.br
-Separates a cache pool from a cache LV, and keeps the unused cache pool
-LV.  Before the separation, the cache is flushed.  See similar option
-.B \-\-uncache.
-Also see
-.BR lvmcache (7).
-.
-.HP
-.BR \-\-splitmirrors
-.IR Number
-.br
-Splits the specified number of images from a \fBraid1\fP or \fBmirror\fP
-LV and uses them to create a new LV.
-
-If \fB\-\-trackchanges\fP is also specified, changes to the raid1 LV are
-tracked while the split LV remains detached.
-.B lvconvert \-\-merge
-can be used to recombine the split images with the original raid1 LV.
-
-A name can be specified for the new LV with \fB\-\-name\fP (a name is
-required without \fB\-\-trackchanges\fP).
-.
-.HP
-.BR \-\-splitsnapshot
-.br
-Separates a COW snapshot from its origin LV.  The LV that is split off
-contains the chunks that differ from the origin LV along with metadata
-describing them.  This LV can be wiped and then destroyed with lvremove.
-See corresponding operation
-.B lvconvert \-\-type snapshot.
-.
-.HP
-.BR \-\-stripes
-.IR Number
-.br
-Specifies the number of stripes in a striped LV.  This is the number of
-physical volumes (devices) that a striped LV is spread across.  Data that
-appears sequential in the LV is spread across multiple devices in units of
-the stripe size (see \fB\-\-stripesize\fP).  This does not apply to
-existing allocated space, only newly allocated space can be striped.
-.
-.HP
-.BR \-I ,
-.BR \-\-stripesize
-.IR StripeSize
-.br
-Specifies the stripe size in kilobytes for a striped LV.  The stripe size
-is the number of kilobytes written to each stripe, i.e. to one device,
-before writing to the next stripe/device.  StripeSize must be a power of 2
-and cannot exceed the VG physical extent (PE) size.
-.
-.HP
-.BR \-\-type
-.IR SegmentType
-.br
-Converts an LV from one segment type to another.
-See COMMANDS section for a description of converting between each type.
-.
-.HP
-.BR \-\-thinpool
-.IR ThinPoolLogicalVolume { Name | Path }
-.br
-Specifies the thin pool to use when converting an LV to a thin LV.  If
-ThinPoolLogicalVolume is not yet a thin pool, the command will attempt to
-convert it to a thin pool prior to the thin LV conversion.
-Also see
-.BR lvmthin (7).
-.
-.HP
-.BR \-\-trackchanges
-.br
-Can be used with \fB\-\-splitmirrors\fP on a raid1 LV.  This causes
-changes to the original raid1 LV to be tracked while the split images
-remain detached.  This allows the read\-only detached image(s) to be
-merged efficiently back into the raid1 LV later.  Only the regions with
-changed data are resynchronized during merge.  (This option only applies
-to the \fBraid1\fP LV type.)
-.
-.HP
-.BR \-T ,
-.BR \-\-thin
-.br
-Alias for
-.B \-\-type thin.
-See COMMANDS description for
-.br
-.B lvconvert \-\-type thin.
-.
-.HP
-.BR \-\-uncache
-.br
-Separates a cache pool from a cache LV, and removes the unused cache pool
-LV.  Before the separation, the cache is flushed.  See similar option
-.B \-\-splitcache.
-Also see
-.BR lvmcache (7).
-.
-.HP
-.BR \-Z ,
-.BR \-\-zero
-.RB { y | n }
-.br
-For snapshots, this controls zeroing of the first 4KiB of data in the
-snapshot.  If the LV is read\-only, the snapshot will not be zeroed.
-
-For thin pools, this controls zeroing of provisioned blocks.
-Provisioning of large zeroed chunks negatively impacts performance.
-Also see
-.BR lvmthin (7).
-.
-
-.SH Examples
-.
-Convert a linear LV to a two-way mirror LV:
-.br
-.B lvconvert \-\-type mirror \-\-mirrors 1 vg/lvol1
-
-Convert a linear LV to a two-way RAID1 LV:
-.br
-.B lvconvert \-\-type raid1 \-\-mirrors 1 vg/lvol1
-
-Convert a mirror LV to use an in\-memory log:
-.br
-.B lvconvert \-\-mirrorlog core vg/lvol1
-
-Convert a mirror LV to use a disk log:
-.br
-.B lvconvert \-\-mirrorlog disk vg/lvol1
-
-Convert a mirror or raid1 LV to a linear LV:
-.br
-.B lvconvert --type linear vg/lvol1
-
-Convert a mirror LV to a raid1 LV with the same number of images:
-.br
-.B lvconvert \-\-type raid1 vg/lvol1
-
-./" Split and merge a COW snapshot:
-./" TODO
-Convert a linear LV to a two-way mirror LV, allocating new extents from specific
-PV ranges:
-.br
-.B lvconvert \-\-mirrors 1 vg/lvol1 /dev/sda:0\-15 /dev/sdb:0\-15
-
-Convert a mirror LV to a linear LV, freeing physical extents from a specific PV:
-.br
-.B lvconvert \-\-type linear vg/lvol1 /dev/sda
-
-Split one image from a mirror or raid1 LV, making it a new LV:
-.br
-.B lvconvert \-\-splitmirrors 1 \-\-name lv_split vg/lvol1
-
-Split one image from a raid1 LV, and track changes made to the raid1 LV
-while the split image remains detached:
-.br
-.B lvconvert \-\-splitmirrors 1 \-\-trackchanges vg/lvol1
-
-Merge an image (that was previously created with \-\-splitmirrors and
-\-\-trackchanges) back into the original raid1 LV:
-.br
-.B lvconvert \-\-merge vg/lvol1_rimage_1
-./" FIXME: use merge-mirror
-
-Replace PV /dev/sdb1 with PV /dev/sdf1 in a raid1/4/5/6/10 LV:
-.br
-.B lvconvert \-\-replace /dev/sdb1 vg/lvol1 /dev/sdf1
-
-Replace 3 PVs /dev/sd[b-d]1 with PVs /dev/sd[f-h]1 in a raid1 LV:
-.br
-.B lvconvert \-\-replace /dev/sdb1 \-\-replace /dev/sdc1 \-\-replace /dev/sdd1
-.RS
-.B vg/lvol1 /dev/sd[fgh]1
-.RE
-
-Replace the maximum of 2 PVs /dev/sd[bc]1 with PVs /dev/sd[gh]1 in a raid6 LV:
-.br
-.B lvconvert \-\-replace /dev/sdb1 \-\-replace /dev/sdc1 vg/lvol1 /dev/sd[gh]1
-
-Convert an LV into a thin LV in the specified thin pool.  The existing LV
-is used as an external read\-only origin for the new thin LV.
-.br
-.B lvconvert \-\-type thin \-\-thinpool vg/tpool1 vg/lvol1
-
-Convert an LV into a thin LV in the specified thin pool.  The existing LV
-is used as an external read\-only origin for the new thin LV, and is
-renamed "external":
-.br
-.B lvconvert \-\-type thin \-\-thinpool vg/tpool1
-.RS
-.B \-\-originname external vg/lvol1
-.RE
-
-Convert an LV to a cache pool LV using another specified LV for cache pool
-metadata:
-.br
-.B lvconvert \-\-type cache-pool \-\-poolmetadata vg/poolmeta1 vg/lvol1
-
-Convert an LV to a cache LV using the specified cache pool and chunk size:
-.br
-.B lvconvert \-\-type cache \-\-cachepool vg/cpool1 \-c 128 vg/lvol1
-
-Detach and keep the cache pool from a cache LV:
-.br
-.B lvconvert \-\-splitcache vg/lvol1
-
-Detach and remove the cache pool from a cache LV:
-.br
-.B lvconvert \-\-uncache vg/lvol1
-
-.SH SEE ALSO
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmcache (7),
-.BR lvmthin (7),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvscan (8),
-.BR vgcreate (8),
-.BR cache_dump (8),
-.BR cache_repair (8),
-.BR cache_restore (8),
-.BR thin_dump (8),
-.BR thin_repair (8),
-.BR thin_restore (8)
diff --git a/man/lvcreate.8.des b/man/lvcreate.8.des
new file mode 100644
index 0000000..e18affe
--- /dev/null
+++ b/man/lvcreate.8.des
@@ -0,0 +1,28 @@
+lvcreate creates a new LV in a VG. For standard LVs, this requires
+allocating logical extents from the VG's free physical extents. If there
+is not enough free space, then the VG can be extended (see
+\fBvgextend\fP(8)) with other PVs, or existing LVs can be reduced or
+removed (see \fBlvremove\fP, \fBlvreduce\fP.)
+
+To control which PVs a new LV will use, specify one or more PVs as
+position args at the end of the command line. lvcreate will allocate
+physical extents only from the specified PVs.
+
+lvcreate can also create snapshots of existing LVs, e.g. for backup
+purposes. The data in a new snapshot LV represents the content of the
+original LV from the time the snapshot was created.
+
+RAID LVs can be created by specifying an LV type when creating the LV (see
+\fBlvmraid\fP(7)). Different RAID levels require different numbers of
+unique PVs be available in the VG for allocation.
+
+Thin pools (for thin provisioning) and cache pools (for caching) are
+represented by special LVs with types thin-pool and cache-pool (see
+\fBlvmthin\fP(7) and \fBlvmcache\fP(7)). The pool LVs are not usable as
+standard block devices, but the LV names act references to the pools.
+
+Thin LVs are thinly provisioned from a thin pool, and are created with a
+virtual size rather than a physical size. A cache LV is the combination of
+a standard LV with a cache pool, used to cache active portions of the LV
+to improve performance.
+
diff --git a/man/lvcreate.8.end b/man/lvcreate.8.end
new file mode 100644
index 0000000..74ae599
--- /dev/null
+++ b/man/lvcreate.8.end
@@ -0,0 +1,98 @@
+.SH EXAMPLES
+
+Create a striped LV with 3 stripes, a stripe size of 8KiB and a size of 100MiB.
+The LV name is chosen by lvcreate.
+.br
+.B lvcreate \-i 3 \-I 8 \-L 100m vg00
+
+Create a raid1 LV with two images, and a useable size of 500 MiB. This
+operation requires two devices, one for each mirror image. RAID metadata
+(superblock and bitmap) is also included on the two devices.
+.br
+.B lvcreate \-\-type raid1 \-m1 \-L 500m \-n mylv vg00
+
+Create a mirror LV with two images, and a useable size of 500 MiB.
+This operation requires three devices: two for mirror images and
+one for a disk log.
+.br
+.B lvcreate \-\-type mirror \-m1 \-L 500m \-n mylv vg00
+
+Create a mirror LV with 2 images, and a useable size of 500 MiB.
+This operation requires 2 devices because the log is in memory.
+.br
+.B lvcreate \-\-type mirror \-m1 \-\-mirrorlog core \-L 500m \-n mylv vg00
+
+Create a copy\-on\-write snapshot of an LV:
+.br
+.B lvcreate \-\-snapshot \-\-size 100m \-\-name mysnap vg00/mylv
+
+Create a copy\-on\-write snapshot with a size sufficient
+for overwriting 20% of the size of the original LV.
+.br
+.B lvcreate \-s \-l 20%ORIGIN \-n mysnap vg00/mylv
+
+Create a sparse LV with 1TiB of virtual space, and actual space just under
+100MiB.
+.br
+.B lvcreate \-\-snapshot \-\-virtualsize 1t \-\-size 100m \-\-name mylv vg00
+
+Create a linear LV with a usable size of 64MiB on specific physical extents.
+.br
+.B lvcreate \-L 64m \-n mylv vg00 /dev/sda:0\-7 /dev/sdb:0\-7
+
+Create a RAID5 LV with a usable size of 5GiB, 3 stripes, a stripe size of
+64KiB, using a total of 4 devices (including one for parity).
+.br
+.B lvcreate \-\-type raid5 \-L 5G \-i 3 \-I 64 \-n mylv vg00
+
+Create a RAID5 LV using all of the free space in the VG and spanning all the
+PVs in the VG (note that the command will fail if there are more than 8 PVs in
+the VG, in which case \fB\-i 7\fP must be used to get to the current maximum of
+8 devices including parity for RaidLVs).
+.br
+.B lvcreate \-\-config allocation/raid_stripe_all_devices=1
+.RS
+.B \-\-type raid5 \-l 100%FREE \-n mylv vg00
+.RE
+
+Create RAID10 LV with a usable size of 5GiB, using 2 stripes, each on
+a two-image mirror. (Note that the \fB-i\fP and \fB-m\fP arguments behave
+differently:
+\fB-i\fP specifies the total number of stripes,
+but \fB-m\fP specifies the number of images in addition
+to the first image).
+.br
+.B lvcreate \-\-type raid10 \-L 5G \-i 2 \-m 1 \-n mylv vg00
+
+Create a 1TiB thin LV, first creating a new thin pool for it, where
+the thin pool has 100MiB of space, uses 2 stripes, has a 64KiB stripe
+size, and 256KiB chunk size.
+.br
+.B lvcreate \-\-type thin \-\-name mylv \-\-thinpool mypool
+.RS
+.B \-V 1t \-L 100m \-i 2 \-I 64 \-c 256 vg00
+.RE
+
+Create a thin snapshot of a thin LV (the size option must not be
+used, otherwise a copy-on-write snapshot would be created).
+.br
+.B lvcreate \-\-snapshot \-\-name mysnap vg00/thinvol
+
+Create a thin snapshot of the read-only inactive LV named "origin"
+which becomes an external origin for the thin snapshot LV.
+.br
+.B lvcreate \-\-snapshot \-\-name mysnap \-\-thinpool mypool vg00/origin
+
+Create a cache pool from a fast physical device. The cache pool can
+then be used to cache an LV.
+.br
+.B lvcreate \-\-type cache-pool \-L 1G \-n my_cpool vg00 /dev/fast1
+
+Create a cache LV, first creating a new origin LV on a slow physical device,
+then combining the new origin LV with an existing cache pool.
+.br
+.B lvcreate \-\-type cache \-\-cachepool my_cpool
+.RS
+.B \-L 100G \-n mylv vg00 /dev/slow1
+.RE
+
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
deleted file mode 100644
index 84afbda..0000000
--- a/man/lvcreate.8.in
+++ /dev/null
@@ -1,914 +0,0 @@
-.TH LVCREATE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.
-.\" Use 1st. parameter with \% to fix 'man2html' rendeing on same line!
-.de SIZE_G
-.  IR \\$1 \c
-.  RB [ b | B | s | S | k | K | m | M | g | G ]
-..
-.de SIZE_E
-.  IR \\$1 \c
-.  RB [ b | B | s | S | k | K | m | M | \c
-.  BR g | G | t | T | p | P | e | E ]
-..
-.
-.SH NAME
-.
-lvcreate \- create a logical volume in an existing volume group
-.
-.SH SYNOPSIS
-.
-.ad l
-.B lvcreate
-.RB [ \-a | \-\-activate
-.RB [ a ][ e | l | s ]{ y | n }]
-.RB [ \-\-addtag
-.IR Tag ]
-.RB [ \-\-alloc
-.IR Allocation\%Policy ]
-.RB [ \-A | \-\-autobackup
-.RB { y | n }]
-.RB [ \-H | \-\-cache ]
-.RB [ \-\-cachemode
-.RB { passthrough | writeback | writethrough }]
-.RB [ \-\-cachepolicy
-.IR Policy ]
-.RB \%[ \-\-cachepool
-.IR CachePoolLogicalVolume ]
-.RB [ \-\-cachesettings
-.IR Key \fB= Value ]
-.RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB \%[ \-C | \-\-contiguous
-.RB { y | n }]
-.RB [ \-d | \-\-debug ]
-.RB [ \-\-discards
-.RB \%{ ignore | nopassdown | passdown }]
-.RB [ \-\-errorwhenfull
-.RB { y | n }]
-.RB [{ \-l | \-\-extents
-.BR \fILogicalExtents\%Number [ % { FREE | PVS | VG }]
-.RB |
-.BR \-L | \-\-size
-.BR \fILogicalVolumeSize }
-.RB [ \-i | \-\-stripes
-.IR Stripes
-.RB [ \-I | \-\-stripesize
-.IR StripeSize ]]]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-K | \-\-ignoreactivationskip ]
-.RB [ \-\-ignoremonitoring ]
-.RB [ \-\-minor
-.IR Minor
-.RB [ \-j | \-\-major
-.IR Major ]]
-.RB [ \-\-metadataprofile
-.IR Profile\%Name ]
-.RB [ \-m | \-\-mirrors
-.IR Mirrors
-.RB [ \-\-corelog | \-\-mirrorlog
-.RB { disk | core | mirrored }]
-.RB [ \-\-nosync ]
-.RB [ \-R | \-\-regionsize
-.BR \fIMirrorLogRegionSize ]]
-.RB [ \-\-monitor
-.RB { y | n }]
-.RB [ \-n | \-\-name
-.IR Logical\%Volume ]
-.RB [ \-\-noudevsync ]
-.RB [ \-p | \-\-permission
-.RB { r | rw }]
-.RB [ \-M | \-\-persistent
-.RB { y | n }]
-.\" .RB [ \-\-pooldatasize
-.\" .I DataVolumeSize
-.RB \%[ \-\-poolmetadatasize
-.IR MetadataVolumeSize ]
-.RB [ \-\-poolmetadataspare
-.RB { y | n }]
-.RB [ \-\- [ raid ] maxrecoveryrate
-.IR Rate ]
-.RB [ \-\- [ raid ] minrecoveryrate
-.IR Rate ]
-.RB [ \-r | \-\-readahead
-.RB { \fIReadAheadSectors | auto | none }]
-.RB [ \-\-reportformat
-.RB {basic | json}]
-.RB \%[ \-k | \-\-setactivationskip
-.RB { y | n }]
-.RB [ \-s | \-\-snapshot ]
-.RB [ \-V | \-\-virtualsize
-.IR VirtualSize ]
-.RB [ \-t | \-\-test ]
-.RB [ \-T | \-\-thin ]
-.RB [ \-\-thinpool
-.IR ThinPoolLogicalVolume ]
-.RB [ \-\-type
-.IR SegmentType ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-W | \-\-wipesignatures
-.RB { y | n }]
-.RB [ \-Z | \-\-zero
-.RB { y | n }]
-.RI [ VolumeGroup
-.RI |
-.RI \%{ ExternalOrigin | Origin | Pool } LogicalVolume
-.RI \%[ PhysicalVolumePath [ \fB: \fIPE \fR[ \fB\- PE ]]...]]
-.LP
-.B lvcreate
-.RB [ \-l | \-\-extents
-.BR \fILogicalExtentsNumber [ % { FREE | ORIGIN | PVS | VG }]
-|
-.BR \-L | \-\-size
-.\" | \-\-pooldatasize
-.IR LogicalVolumeSize ]
-.RB [ \-c | \-\-chunksize
-.IR ChunkSize ]
-.RB \%[ \-\-commandprofile
-.IR Profile\%Name ]
-.RB [ \-\-noudevsync ]
-.RB [ \-\-ignoremonitoring ]
-.RB [ \-\-metadataprofile
-.IR Profile\%Name ]
-.RB \%[ \-\-monitor
-.RB { y | n }]
-.RB [ \-n | \-\-name
-.IR SnapshotLogicalVolumeName ]
-.RB [ \-\-reportformat
-.RB {basic | json}]
-.BR \-s | \-\-snapshot | \-H | \-\-cache
-.RI \%{[ VolumeGroup \fB/\fP] OriginalLogicalVolume
-.RB \%[ \-V | \-\-virtualsize
-.IR VirtualSize ]}
-.ad b
-.
-.SH DESCRIPTION
-.
-lvcreate creates a new logical volume in a volume group (see
-.BR vgcreate "(8), " vgchange (8))
-by allocating logical extents from the free physical extent pool
-of that volume group.  If there are not enough free physical extents then
-the volume group can be extended (see
-.BR vgextend (8))
-with other physical volumes or by reducing existing logical volumes
-of this volume group in size (see
-.BR lvreduce (8)).
-If you specify one or more PhysicalVolumes, allocation of physical
-extents will be restricted to these volumes.
-.br
-.br
-The second form supports the creation of snapshot logical volumes which
-keep the contents of the original logical volume for backup purposes.
-.
-.SH OPTIONS
-.
-See
-.BR lvm (8)
-for common options.
-.
-.HP
-.BR \-a | \-\-activate
-.RB [ a ][ l | e | s ]{ y | n }
-.br
-Controls the availability of the Logical Volumes for immediate use after
-the command finishes running.
-By default, new Logical Volumes are activated (\fB\-ay\fP).
-If it is possible technically, \fB\-an\fP will leave the new Logical
-Volume inactive. But for example, snapshots of active origin can only be
-created in the active state so \fB\-an\fP cannot be used with
-\fB-\-type snapshot\fP. This does not apply to thin volume snapshots,
-which are by default created with flag to skip their activation
-(\fB-ky\fP).
-Normally the \fB\-\-zero n\fP argument has to be supplied too because
-zeroing (the default behaviour) also requires activation.
-If autoactivation option is used (\fB\-aay\fP), the logical volume is
-activated only if it matches an item in the
-\fBactivation/auto_activation_volume_list\fP
-set in \fBlvm.conf\fP(5).
-For autoactivated logical volumes, \fB\-\-zero n\fP and
-\fB\-\-wipesignatures n\fP is always assumed and it can't
-be overridden. If the clustered locking is enabled,
-\fB\-aey\fP will activate exclusively on one node and
-.BR \-a { a | l } y
-will activate only on the local node.
-.
-.HP
-.BR \-H | \-\-cache
-.br
-Creates cache or cache pool logical volume.
-.\" or both.
-Specifying the optional argument \fB\-\-extents\fP or \fB\-\-size\fP
-will cause the creation of the cache logical volume.
-.\" Specifying the optional argument \fB\-\-pooldatasize\fP will cause
-.\" the creation of the cache pool logical volume.
-.\" Specifying both arguments will cause the creation of cache with its
-.\" cache pool volume.
-When the Volume group name is specified together with existing logical volume
-name which is NOT a cache pool name, such volume is treated
-as cache origin volume and cache pool is created. In this case the
-\fB\-\-extents\fP or \fB\-\-size\fP is used to specify size of cache pool volume.
-See \fBlvmcache\fP(7) for more info about caching support.
-Note that the cache segment type requires a dm-cache kernel module version
-1.3.0 or greater.
-.
-.HP
-.BR \-\-cachemode
-.RB { passthrough | writeback | writethrough }
-.br
-Specifying a cache mode determines when the writes to a cache LV
-are considered complete.  When \fBwriteback\fP is specified, a write is
-considered complete as soon as it is stored in the cache pool LV.
-If \fBwritethough\fP is specified, a write is considered complete only
-when it has been stored in the cache pool LV and on the origin LV.
-While \fBwritethrough\fP may be slower for writes, it is more
-resilient if something should happen to a device associated with the
-cache pool LV. With \fBpassthrough\fP mode, all reads are served
-from origin LV (all reads miss the cache) and all writes are
-forwarded to the origin LV; additionally, write hits cause cache
-block invalidates. See \fBlvmcache(7)\fP for more details.
-.
-.HP
-.BR \-\-cachepolicy
-.IR Policy
-.br
-Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
-the cache policy. \fBmq\fP is the basic policy name. \fBsmq\fP is more advanced
-version available in newer kernels.
-.
-.HP
-.BR \-\-cachepool
-.IR CachePoolLogicalVolume { Name | Path }
-.br
-Specifies the name of cache pool volume name. The other way to specify pool name
-is to append name to Volume group name argument.
-.
-.HP
-.BR \-\-cachesettings
-.IB Key = Value
-.br
-Only applicable to cached LVs; see also \fBlvmcache(7)\fP. Sets
-the cache tunable settings. In most use-cases, default values should be adequate.
-Special string value \fBdefault\fP switches setting back to its default kernel value
-and removes it from the list of settings stored in lvm2 metadata.
-.
-.HP
-.BR \-c | \-\-chunksize
-.SIZE_G \%ChunkSize
-.br
-Gives the size of chunk for snapshot, cache pool and thin pool logical volumes.
-Default unit is in kilobytes.
-.br
-For snapshots the value must be power of 2 between 4KiB and 512KiB
-and the default value is 4KiB.
-.br
-For cache pools the value must a multiple of 32KiB
-between 32KiB and 1GiB. The default is 64KiB.
-When the size is specified with volume caching, it may not be smaller
-than cache pool creation chunk size was.
-.br
-For thin pools the value must be a multiple of 64KiB
-between 64KiB and 1GiB.
-Default value starts with 64KiB and grows up to
-fit the pool metadata size within 128MiB,
-if the pool metadata size is not specified.
-See
-.BR lvm.conf (5)
-setting \fBallocation/thin_pool_chunk_size_policy\fP
-to select different calculation policy.
-Thin pool target version <1.4 requires this value to be a power of 2.
-For target version <1.5 discard is not supported for non power of 2 values.
-.
-.HP
-.BR \-C | \-\-contiguous
-.RB { y | n }
-.br
-Sets or resets the contiguous allocation policy for
-logical volumes. Default is no contiguous allocation based
-on a next free principle.
-.
-.HP
-.BR \-\-corelog
-.br
-This is shortcut for option \fB\-\-mirrorlog core\fP.
-.
-.HP
-.BR \-\-discards
-.RB { ignore | nopassdown | passdown }
-.br
-Sets discards behavior for thin pool.
-Default is \fBpassdown\fP.
-.
-.HP
-.BR \-\-errorwhenfull
-.RB { y | n }
-.br
-Configures thin pool behaviour when data space is exhausted.
-Default is \fBn\fPo.
-Device will queue I/O operations until target timeout
-(see dm-thin-pool kernel module option \fPno_space_timeout\fP)
-expires. Thus configured system has a time to i.e. extend
-the size of thin pool data device.
-When set to \fBy\fPes, the I/O operation is immeditelly errored.
-.
-.HP
-.BR \-K | \-\-ignoreactivationskip
-.br
-Ignore the flag to skip Logical Volumes during activation.
-Use \fB\-\-setactivationskip\fP option to set or reset
-activation skipping flag persistently for logical volume.
-.
-.HP
-.BR \-\-ignoremonitoring
-.br
-Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
-is specified.
-.
-.HP
-.BR -l | \-\-extents
-.IR LogicalExtentsNumber \c
-.RB [ % { VG | PVS | FREE | ORIGIN }]
-.br
-Specifies the size of the new LV in logical extents.  The number of
-physical extents allocated may be different, and depends on the LV type.
-Certain LV types require more physical extents for data redundancy or
-metadata.  An alternate syntax allows the size to be determined indirectly
-as a percentage of the size of a related VG, LV, or set of PVs.  The
-suffix \fB%VG\fP denotes the total size of the VG, the suffix \fB%FREE\fP
-the remaining free space in the VG, and the suffix \fB%PVS\fP the free
-space in the specified Physical Volumes.  For a snapshot, the size
-can be expressed as a percentage of the total size of the Origin Logical
-Volume with the suffix \fB%ORIGIN\fP (\fB100%ORIGIN\fP provides space for
-the whole origin).
-When expressed as a percentage, the size defines an upper limit for the
-number of logical extents in the new LV. The precise number of logical
-extents in the new LV is not determined until the command has completed.
-.
-.HP
-.BR \-j | \-\-major
-.IR Major
-.br
-Sets the major number.
-Major numbers are not supported with pool volumes.
-This option is supported only on older systems
-(kernel version 2.4) and is ignored on modern Linux systems where major
-numbers are dynamically assigned.
-.
-.HP
-.BR \-\-metadataprofile
-.IR ProfileName
-.br
-Uses and attaches the \fIProfileName\fP configuration profile to the logical
-volume metadata. Whenever the logical volume is processed next time,
-the profile is automatically applied. If the volume group has another
-profile attached, the logical volume profile is preferred.
-See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
-.
-.HP
-.BR \-\-minor
-.IR Minor
-.br
-Sets the minor number.
-Minor numbers are not supported with pool volumes.
-.
-.HP
-.BR \-m | \-\-mirrors
-.IR mirrors
-.br
-Creates a mirrored logical volume with \fImirrors\fP copies.
-For example, specifying \fB\-m 1\fP
-would result in a mirror with two-sides; that is,
-a linear volume plus one copy.
-
-Specifying the optional argument \fB\-\-nosync\fP will cause the creation
-of the mirror LV to skip the initial resynchronization.  Any data written
-afterwards will be mirrored, but the original contents will not be copied.
-
-This is useful for skipping a potentially long and resource intensive initial
-sync of an empty mirrored RaidLV.
-
-There are two implementations of mirroring which can be used and correspond
-to the "\fIraid1\fP" and "\fImirror\fP" segment types.
-The default is "\fIraid1\fP".  See the
-\fB\-\-type\fP option for more information if you would like to use the
-legacy "\fImirror\fP" segment type.  See
-.BR lvm.conf (5)
-settings \fB global/mirror_segtype_default\fP
-and \fBglobal/raid10_segtype_default\fP
-to configure default mirror segment type.
-The options
-\fB\-\-mirrorlog\fP and \fB\-\-corelog\fP apply
-to the legacy "\fImirror\fP" segment type only.
-
-Note the current maxima for mirrors are 7 for "mirror" providing
-8 mirror legs and 9 for "raid1" providing 10 legs.
-.
-.HP
-.BR \-\-mirrorlog
-.RB { disk | core | mirrored }
-.br
-Specifies the type of log to be used for logical volumes utilizing
-the legacy "\fImirror\fP" segment type.
-.br
-The default is \fBdisk\fP, which is persistent and requires
-a small amount of storage space, usually on a separate device from the
-data being mirrored.
-.br
-Using \fBcore\fP means the mirror is regenerated by copying the data
-from the first device each time the logical volume is activated,
-like after every reboot.
-.br
-Using \fBmirrored\fP will create a persistent log that is itself mirrored.
-.
-.HP
-.BR \-\-monitor
-.RB { y | n }
-.br
-Starts or avoids monitoring a mirrored, snapshot or thin pool logical volume with
-dmeventd, if it is installed.
-If a device used by a monitored mirror reports an I/O error,
-the failure is handled according to
-\fBactivation/mirror_image_fault_policy\fP
-and \fBactivation/mirror_log_fault_policy\fP
-set in \fBlvm.conf\fP(5).
-.
-.HP
-.BR \-n | \-\-name
-.IR LogicalVolume { Name | Path }
-.br
-Sets the name for the new logical volume.
-.br
-Without this option a default name of "lvol#" will be generated where
-# is the LVM internal number of the logical volume.
-.
-.HP
-.BR \-\-nosync
-.br
-Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
-initial resynchronization.  In case of mirror, raid1 and raid10, any data
-written afterwards will be mirrored, but the original contents will not be
-copied.  In case of raid4 and raid5, no parity blocks will be written,
-though any data written afterwards will cause parity blocks to be stored.
-.br
-This is useful for skipping a potentially long and resource intensive initial
-sync of an empty mirror/raid1/raid4/raid5 and raid10 LV.
-.br
-This option is not valid for raid6, because raid6 relies on proper parity
-(P and Q Syndromes) being created during initial synchronization in order
-to reconstruct proper user date in case of device failures.
-
-raid0 and raid0_meta don't provide any data copies or parity support
-and thus don't support initial resynchronization.
-.
-.HP
-.BR \-\-noudevsync
-.br
-Disables udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.
-.HP
-.BR \-p | \-\-permission
-.RB { r | rw }
-.br
-Sets access permissions to read only (\fBr\fP) or read and write (\fBrw\fP).
-.br
-Default is read and write.
-.
-.HP
-.BR \-M | \-\-persistent
-.RB { y | n }
-.br
-Set to \fBy\fP to make the minor number specified persistent.
-Pool volumes cannot have persistent major and minor numbers.
-Defaults to \fBy\fPes only when major or minor number is specified.
-Otherwise it is \fBn\fPo.
-.\" .HP
-.\" .IR \fB\-\-pooldatasize " " PoolDataVolumeSize [ bBsSkKmMgGtTpPeE ]
-.\" Sets the size of pool's data logical volume.
-.\" For thin pools you may also specify the size
-.\" with the option \fB\-\-size\fP.
-.\"
-.
-.HP
-.BR \-\-poolmetadatasize
-.SIZE_G \%MetadataVolumeSize
-.br
-Sets the size of pool's metadata logical volume.
-Supported values are in range between 2MiB and 16GiB for thin pool,
-and upto 16GiB for cache pool. The minimum value is computed from pool's
-data size.
-Default value for thin pool is (Pool_LV_size / Pool_LV_chunk_size * 64b).
-To work with a thin pool, there should be at least 25% of free space
-when the size of metadata is smaller then 16MiB,
-or at least 4MiB of free space otherwise.
-Default unit is megabytes.
-.
-.HP
-.BR \-\-poolmetadataspare
-.RB { y | n }
-.br
-Controls creation and maintanence of pool metadata spare logical volume
-that will be used for automated pool recovery.
-Only one such volume is maintained within a volume group
-with the size of the biggest pool metadata volume.
-Default is \fBy\fPes.
-.
-.HP
-.BR \-\- [ raid ] maxrecoveryrate
-.SIZE_G \%Rate
-.br
-Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as an amount per second for each device in the array.
-If no suffix is given, then KiB/sec/device is assumed.  Setting the
-recovery rate to 0 means it will be unbounded.
-.
-.HP
-.BR \-\- [ raid ] minrecoveryrate
-.SIZE_G \%Rate
-.br
-Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as an amount per second for each device in the array.
-If no suffix is given, then KiB/sec/device is assumed.  Setting the
-recovery rate to 0 means it will be unbounded.
-.
-.HP
-.BR \-r | \-\-readahead
-.RB { \fIReadAheadSectors | auto | none }
-.br
-Sets read ahead sector count of this logical volume.
-For volume groups with metadata in lvm1 format, this must
-be a value between 2 and 120.
-The default value is \fBauto\fP which allows the kernel to choose
-a suitable value automatically.
-\fBnone\fP is equivalent to specifying zero.
-.
-.HP
-.BR \-R | \-\-regionsize
-.SIZE_G \%MirrorLogRegionSize
-.br
-A mirror is divided into regions of this size (in MiB), and the mirror log
-uses this granularity to track which regions are in sync.
-.
-.HP
-.BR \-k | \-\-setactivationskip
-.RB { y | n }
-.br
-Controls whether Logical Volumes are persistently flagged to be skipped during
-activation. By default, thin snapshot volumes are flagged for activation skip.
-See
-.BR lvm.conf (5)
-\fBactivation/auto_set_activation_skip\fP
-how to change its default behaviour.
-To activate such volumes, an extra \fB\-\-ignoreactivationskip\fP
-option must be used. The flag is not applied during deactivation. Use
-\fBlvchange \-\-setactivationskip\fP
-command to change the skip flag for existing volumes.
-To see whether the flag is attached, use \fBlvs\fP command
-where the state of the flag is reported within \fBlv_attr\fP bits.
-.
-.HP
-.BR \-L | \-\-size
-.SIZE_E \%LogicalVolumeSize
-.br
-Gives the size to allocate for the new logical volume.
-A size suffix of \fBB\fP for bytes, \fBS\fP for sectors as 512 bytes,
-\fBK\fP for kilobytes, \fBM\fP for megabytes,
-\fBG\fP for gigabytes, \fBT\fP for terabytes, \fBP\fP for petabytes
-or \fBE\fP for exabytes is optional.
-.br
-Default unit is megabytes.
-.
-.HP
-.BR \-s | \fB\-\-snapshot
-.IR OriginalLogicalVolume { Name | Path }
-.br
-Creates a snapshot logical volume (or snapshot) for an existing, so called
-original logical volume (or origin).
-Snapshots provide a 'frozen image' of the contents of the origin
-while the origin can still be updated. They enable consistent
-backups and online recovery of removed/overwritten data/files.
-.br
-Thin snapshot is created when the origin is a thin volume and
-the size IS NOT specified. Thin snapshot shares same blocks within
-the thin pool volume.
-The non thin volume snapshot with the specified size does not need
-the same amount of storage the origin has. In a typical scenario,
-15-20% might be enough. In case the snapshot runs out of storage, use
-.BR lvextend (8)
-to grow it. Shrinking a snapshot is supported by
-.BR lvreduce (8)
-as well. Run
-.BR lvs (8)
-on the snapshot in order to check how much data is allocated to it.
-Note: a small amount of the space you allocate to the snapshot is
-used to track the locations of the chunks of data, so you should
-allocate slightly more space than you actually need and monitor
-(\fB\-\-monitor\fP) the rate at which the snapshot data is growing
-so you can \fBavoid\fP running out of space.
-If \fB\-\-thinpool\fP is specified, thin volume is created that will
-use given original logical volume as an external origin that
-serves unprovisioned blocks.
-Only read-only volumes can be used as external origins.
-To make the volume external origin, lvm expects the volume to be inactive.
-External origin volume can be used/shared for many thin volumes
-even from different thin pools. See
-.BR lvconvert (8)
-for online conversion to thin volumes with external origin.
-.
-.HP
-.BR \-i | \-\-stripes
-.IR Stripes
-.br
-Gives the number of stripes.
-This is equal to the number of physical volumes to scatter
-the logical volume data.  When creating a RAID 4/5/6 logical volume,
-the extra devices which are necessary for parity are
-internally accounted for.  Specifying \fB\-i 3\fP
-would cause 3 devices for striped and RAID 0 logical volumes,
-4 devices for RAID 4/5, 5 devices for RAID 6 and 6 devices for RAID 10.
-Alternatively, RAID 0 will stripe across 2 devices,
-RAID 4/5 across 3 PVs, RAID 6 across 5 PVs and RAID 10 across
-4 PVs in the volume group if the \fB\-i\fP argument is omitted.
-In order to stripe across all PVs of the VG if the \fB\-i\fP argument is
-omitted, set raid_stripe_all_devices=1 in the allocation
-section of \fBlvm.conf (5)\fP or add
-.br
-\fB\-\-config allocation/raid_stripe_all_devices=1\fP
-.br
-to the command.
-
-Note the current maxima for stripes depend on the created RAID type.
-For raid10, the maximum of stripes is 32,
-for raid0, it is 64,
-for raid4/5, it is 63
-and for raid6 it is 62.
-
-See the \fB\-\-nosync\fP option to optionally avoid initial syncrhonization of RaidLVs.
-
-Two implementations of basic striping are available in the kernel.
-The original device-mapper implementation is the default and should
-normally be used.  The alternative implementation using MD, available
-since version 1.7 of the RAID device-mapper kernel target (kernel
-version 4.2) is provided to facilitate the development of new RAID
-features.  It may be accessed with \fB--type raid0[_meta]\fP, but is best
-avoided at present because of assorted restrictions on resizing and converting
-such devices.
-.HP
-.BR \-I | \-\-stripesize
-.IR StripeSize
-.br
-Gives the number of kilobytes for the granularity of the stripes.
-.br
-StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
-For metadata in LVM2 format, the stripe size may be a larger
-power of 2 but must not exceed the physical extent size.
-.
-.HP
-.BR \-T | \-\-thin
-.br
-Creates thin pool or thin logical volume or both.
-Specifying the optional argument \fB\-\-size\fP or \fB\-\-extents\fP
-will cause the creation of the thin pool logical volume.
-Specifying the optional argument \fB\-\-virtualsize\fP will cause
-the creation of the thin logical volume from given thin pool volume.
-Specifying both arguments will cause the creation of both
-thin pool and thin volume using this pool.
-See \fBlvmthin\fP(7) for more info about thin provisioning support.
-Thin provisioning requires device mapper kernel driver
-from kernel 3.2 or greater.
-.
-.HP
-.BR \-\-thinpool
-.IR ThinPoolLogicalVolume { Name | Path }
-.br
-Specifies the name of thin pool volume name. The other way to specify pool name
-is to append name to Volume group name argument.
-.
-.HP
-.BR \-\-type
-.IR SegmentType
-.br
-Creates a logical volume with the specified segment type.
-Supported types are:
-.BR cache ,
-.BR cache-pool ,
-.BR error ,
-.BR linear ,
-.BR mirror,
-.BR raid0 ,
-.BR raid1 ,
-.BR raid4 ,
-.BR raid5_la ,
-.BR raid5_ls
-.RB (=
-.BR raid5 ),
-.BR raid5_ra ,
-.BR raid5_rs ,
-.BR raid6_nc ,
-.BR raid6_nr ,
-.BR raid6_zr
-.RB (=
-.BR raid6 ),
-.BR raid10 ,
-.BR snapshot ,
-.BR striped,
-.BR thin ,
-.BR thin-pool
-or
-.BR zero .
-Segment type may have a commandline switch alias that will
-enable its use.
-When the type is not explicitly specified an implicit type
-is selected from combination of options:
-.BR \-H | \-\-cache | \-\-cachepool
-(cache or cachepool),
-.BR \-T | \-\-thin | \-\-thinpool
-(thin or thinpool),
-.BR \-m | \-\-mirrors
-(raid1 or mirror),
-.BR \-s | \-\-snapshot | \-V | \-\-virtualsize
-(snapshot or thin),
-.BR \-i | \-\-stripes
-(striped).
-The default segment type is \fBlinear\fP.
-.
-.HP
-.BR \-V | \-\-virtualsize
-.SIZE_E \%VirtualSize
-.br
-Creates a thinly provisioned device or a sparse device of the given size (in MiB by default).
-See
-.BR lvm.conf (5)
-settings \fBglobal/sparse_segtype_default\fP
-to configure default sparse segment type.
-See \fBlvmthin\fP(7) for more info about thin provisioning support.
-Anything written to a sparse snapshot will be returned when reading from it.
-Reading from other areas of the device will return blocks of zeros.
-Virtual snapshot (sparse snapshot) is implemented by creating
-a hidden virtual device of the requested size using the zero target.
-A suffix of _vorigin is used for this device.
-Note: using sparse snapshots is not efficient for larger
-device sizes (GiB), thin provisioning should be used for this case.
-.
-.HP
-.BR \-W | \-\-wipesignatures
-.RB { y | n }
-.br
-Controls detection and subsequent wiping of signatures on newly created
-Logical Volume. There's a prompt for each signature detected to confirm
-its wiping (unless \fB--yes\fP is used where LVM assumes 'yes' answer
-for each prompt automatically). If this option is not specified, then by
-default \fB-W\fP | \fB--wipesignatures y\fP is assumed each time the
-zeroing is done (\fB\-Z\fP | \fB\-\-zero y\fP). This default behaviour
-can be controlled by \fB\%allocation/wipe_signatures_when_zeroing_new_lvs\fP
-setting found in
-.BR lvm.conf (5).
-.br
-If blkid wiping is used (\fBallocation/use_blkid_wiping\fP setting in
-.BR lvm.conf (5))
-and LVM2 is compiled with blkid wiping support, then \fBblkid\fP(8) library is used
-to detect the signatures (use \fBblkid \-k\fP command to list the signatures that are recognized).
-Otherwise, native LVM2 code is used to detect signatures (MD RAID, swap and LUKS
-signatures are detected only in this case).
-.br
-Logical volume is not wiped if the read only flag is set.
-.
-.HP
-.BR \-Z | \-\-zero
-.RB { y | n }
-.br
-Controls zeroing of the first 4KiB of data in the new logical volume.
-Default is \fBy\fPes.
-Snapshot COW volumes are always zeroed.
-Logical volume is not zeroed if the read only flag is set.
-.br
-Warning: trying to mount an unzeroed logical volume can cause the system to
-hang.
-.
-.SH Examples
-.
-Creates a striped logical volume with 3 stripes, a stripe size of 8KiB
-and a size of 100MiB in the volume group named vg00.
-The logical volume name will be chosen by lvcreate:
-.sp
-.B lvcreate \-i 3 \-I 8 \-L 100M vg00
-
-Creates a mirror logical volume with 2 sides with a useable size of 500 MiB.
-This operation would require 3 devices (or option
-\fB\-\-alloc \%anywhere\fP) - two for the mirror
-devices and one for the disk log:
-.sp
-.B lvcreate \-m1 \-L 500M vg00
-
-Creates a mirror logical volume with 2 sides with a useable size of 500 MiB.
-This operation would require 2 devices - the log is "in-memory":
-.sp
-.B lvcreate \-m1 \-\-mirrorlog core \-L 500M vg00
-
-Creates a snapshot logical volume named "vg00/snap" which has access to the
-contents of the original logical volume named "vg00/lvol1"
-at snapshot logical volume creation time. If the original logical volume
-contains a file system, you can mount the snapshot logical volume on an
-arbitrary directory in order to access the contents of the filesystem to run
-a backup while the original filesystem continues to get updated:
-.sp
-.B lvcreate \-\-size 100m \-\-snapshot \-\-name snap /dev/vg00/lvol1
-
-Creates a snapshot logical volume named "vg00/snap" with size
-for overwriting 20% of the original logical volume named "vg00/lvol1".:
-.sp
-.B lvcreate \-s \-l 20%ORIGIN \-\-name snap vg00/lvol1
-
-Creates a sparse device named /dev/vg1/sparse of size 1TiB with space for just
-under 100MiB of actual data on it:
-.sp
-.B lvcreate \-\-virtualsize 1T \-\-size 100M \-\-snapshot \-\-name sparse vg1
-
-Creates a linear logical volume "vg00/lvol1" using physical extents
-/dev/sda:0\-7 and /dev/sdb:0\-7 for allocation of extents:
-.sp
-.B lvcreate \-L 64M \-n lvol1 vg00 /dev/sda:0\-7 /dev/sdb:0\-7
-
-Creates a 5GiB RAID5 logical volume "vg00/my_lv", with 3 stripes (plus
-a parity drive for a total of 4 devices) and a stripesize of 64KiB:
-.sp
-.B lvcreate \-\-type raid5 \-L 5G \-i 3 \-I 64 \-n my_lv vg00
-
-Creates a RAID5 logical volume "vg00/my_lv", using all of the free
-space in the VG and spanning all the PVs in the VG (note that the command
-will fail if there's more than 8 PVs in the VG in which case \fB\-i 7\fP
-has to be used to get to the currently possible maximum of
-8 devices including parity for RaidLVs):
-.sp
-.B lvcreate \-\-config allocation/raid_stripe_all_devices=1 \-\-type raid5 \-l 100%FREE \-n my_lv vg00
-
-Creates a 5GiB RAID10 logical volume "vg00/my_lv", with 2 stripes on
-2 2-way mirrors.  Note that the \fB-i\fP and \fB-m\fP arguments behave
-differently.
-The \fB-i\fP specifies the number of stripes.
-The \fB-m\fP specifies the number of
-.B additional
-copies:
-.sp
-.B lvcreate \-\-type raid10 \-L 5G \-i 2 \-m 1 \-n my_lv vg00
-
-Creates 100MiB pool logical volume for thin provisioning
-build with 2 stripes 64KiB and chunk size 256KiB together with
-1TiB thin provisioned logical volume "vg00/thin_lv":
-.sp
-.B lvcreate \-i 2 \-I 64 \-c 256 \-L100M \-T vg00/pool \-V 1T \-\-name thin_lv
-
-Creates a thin snapshot volume "thinsnap" of thin volume "thinvol" that
-will share the same blocks within the thin pool.
-Note: the size MUST NOT be specified, otherwise the non-thin snapshot
-is created instead:
-.sp
-.B lvcreate \-s vg00/thinvol \-\-name thinsnap
-
-Creates a thin snapshot volume of read-only inactive volume "origin"
-which then becomes the thin external origin for the thin snapshot volume
-in vg00 that will use an existing thin pool "vg00/pool":
-.sp
-.B lvcreate \-s \-\-thinpool vg00/pool  origin
-
-Create a cache pool LV that can later be used to cache one
-logical volume.
-.sp
-.B lvcreate \-\-type cache-pool \-L 1G \-n my_lv_cachepool vg /dev/fast1
-
-If there is an existing cache pool LV, create the large slow
-device (i.e. the origin LV) and link it to the supplied cache pool LV,
-creating a cache LV.
-.sp
-.B lvcreate \-\-cache \-L 100G \-n my_lv vg/my_lv_cachepool /dev/slow1
-
-If there is an existing logical volume, create the small and fast
-cache pool LV and link it to the supplied existing logical
-volume (i.e. the origin LV), creating a cache LV.
-.sp
-.B lvcreate \-\-type cache \-L 1G \-n my_lv_cachepool vg/my_lv /dev/fast1
-
-.\" Create a 1G cached LV "lvol1" with  10M cache pool "vg00/pool".
-.\" .sp
-.\" .B lvcreate \-\-cache \-L 1G \-n lv \-\-pooldatasize 10M vg00/pool
-.
-.SH SEE ALSO
-.
-.nh
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvmcache (7),
-.BR lvmthin (7),
-.BR lvconvert (8),
-.BR lvchange (8),
-.BR lvextend (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8)
-.BR lvs (8),
-.BR lvscan (8),
-.BR vgcreate (8),
-.BR blkid (8)
diff --git a/man/lvdisplay.8.des b/man/lvdisplay.8.des
new file mode 100644
index 0000000..48552cc
--- /dev/null
+++ b/man/lvdisplay.8.des
@@ -0,0 +1,5 @@
+lvdisplay shows the attributes of LVs, like size, read/write status,
+snapshot information, etc.
+
+\fBlvs\fP(8) is a preferred alternative that shows the same information
+and more, using a more compact and configurable output format.
diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
deleted file mode 100644
index e8e7809..0000000
--- a/man/lvdisplay.8.in
+++ /dev/null
@@ -1,134 +0,0 @@
-.TH LVDISPLAY 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvdisplay \(em display attributes of a logical volume
-.SH SYNOPSIS
-.B lvdisplay
-.RB [ \-a | \-\-all ]
-.RB [ \-c | \-\-colon ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-maps ]
-.RB [ \-\-nosuffix ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-\-units
-.IR hHbBsSkKmMgGtTpPeE ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]
-.br
-
-.B lvdisplay
-.BR \-C | \-\-columns
-.RB [ \-\-aligned ]
-.RB [ \-\-binary ]
-.RB [ \-a | \-\-all ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [[ \-\-configreport
-.IR ReportName ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field1 [, Field2 ...]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [, Key2 ...]]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB ...]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-logonly ]
-.RB [ \-\-noheadings ]
-.RB [ \-\-nosuffix ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-segments ]
-.RB [ \-\-separator
-.IR Separator ]
-.RB [ \-\-unbuffered ]
-.RB [ \-\-units
-.IR hHbBsSkKmMgGtTpPeE ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]
-.SH DESCRIPTION
-lvdisplay allows you to see the attributes of a logical volume
-like size, read/write status, snapshot information etc.
-.P
-\fBlvs\fP(8) is an alternative that provides the same information
-in the style of \fBps\fP(1).
-\fBlvs\fP(8) is recommended over \fBlvdisplay\fP.
-
-.SH OPTIONS
-See \fBlvm\fP(8) for common options and \fBlvs\fP for options given with
-\fB\-\-columns\fP.
-.TP
-.B \-\-all
-Include information in the output about internal Logical Volumes that
-are components of normally-accessible Logical Volumes, such as mirrors,
-but which are not independently accessible (e.g. not mountable).
-For example, after creating a mirror using
-\fBlvcreate \-m1 \-\-mirrorlog disk\fP,
-this option will reveal three internal Logical Volumes, with suffixes
-mimage_0, mimage_1, and mlog.
-.TP
-.BR \-C ", " \-\-columns
-Display output in columns, the equivalent of \fBlvs\fP(8).
-Options listed are the same as options given in \fBlvs\fP(8).
-.TP
-.BR \-c ", " \-\-colon
-Generate colon separated output for easier parsing in scripts or programs.
-N.B. \fBlvs\fP(8) provides considerably more control over the output.
-.nf
-
-The values are:
-
-\(bu logical volume name
-\(bu volume group name
-\(bu logical volume access
-\(bu logical volume status
-\(bu internal logical volume number
-\(bu open count of logical volume
-\(bu logical volume size in sectors
-\(bu current logical extents associated to logical volume
-\(bu allocated logical extents of logical volume
-\(bu allocation policy of logical volume
-\(bu read ahead sectors of logical volume
-\(bu major device number of logical volume
-\(bu minor device number of logical volume
-
-.fi
-.TP
-.BR \-m ", " \-\-maps
-Display the mapping of logical extents to physical volumes and
-physical extents.  To map physical extents
-to logical extents use:
-.B pvs \-\-segments \-o+lv_name,seg_start_pe,segtype
-.SH Examples
-Shows attributes of that logical volume. If snapshot
-logical volumes have been created for this original logical volume,
-this command shows a list of all snapshot logical volumes and their
-status (active or inactive) as well:
-.sp
-.B lvdisplay \-v vg00/lvol2
-
-Shows the attributes of this snapshot logical volume and also which
-original logical volume it is associated with:
-.sp
-.B lvdisplay vg00/snapshot
-
-.SH SEE ALSO
-.BR lvm (8),
-.BR lvcreate (8),
-.BR lvs (8),
-.BR lvscan (8),
-.BR pvs (8)
diff --git a/man/lvextend.8.des b/man/lvextend.8.des
new file mode 100644
index 0000000..2a3781d
--- /dev/null
+++ b/man/lvextend.8.des
@@ -0,0 +1,5 @@
+lvextend extends the size of an LV. This requires allocating logical
+extents from the VG's free physical extents. A copy\-on\-write snapshot LV
+can also be extended to provide more space to hold COW blocks. Use
+\fBlvconvert\fP(8) to change the number of data images in a RAID or
+mirrored LV.
diff --git a/man/lvextend.8.end b/man/lvextend.8.end
new file mode 100644
index 0000000..6d197de
--- /dev/null
+++ b/man/lvextend.8.end
@@ -0,0 +1,16 @@
+.SH EXAMPLES
+
+Extend the size of an LV by 54MiB, using a specific PV.
+.br
+.B lvextend \-L +54 vg01/lvol10 /dev/sdk3
+
+Extend the size of an LV by the amount of free
+space on PV /dev/sdk3. This is equivalent to specifying
+"\-l +100%PVS" on the command line.
+.br
+.B lvextend vg01/lvol01 /dev/sdk3
+
+Extend an LV by 16MiB using specific physical extents.
+.br
+.B lvextend \-L+16m vg01/lvol01 /dev/sda:8\-9 /dev/sdb:8\-9
+
diff --git a/man/lvextend.8.in b/man/lvextend.8.in
deleted file mode 100644
index eefbf79..0000000
--- a/man/lvextend.8.in
+++ /dev/null
@@ -1,134 +0,0 @@
-.TH LVEXTEND 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvextend \(em extend the size of a logical volume
-.SH SYNOPSIS
-.B lvextend
-.RB [ \-\-alloc
-.IR AllocationPolicy ]
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-f | \-\-force ]
-.RB [ \-i | \-\-stripes
-.I Stripes
-.RB [ \-I | \-\-stripesize
-.IR StripeSize ]]
-.RB { \-l | \-\-extents
-.RI [ + ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN }]
-|
-.BR \-L | \-\-size
-.RI [ + ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
-.RB [ \-n | \-\-nofsck ]
-.RB [ \-\-noudevsync]
-.RB [ \-r | \-\-resizefs ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-use\-policies ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.I LogicalVolumePath
-.RI [ PhysicalVolumePath [ :PE [ \-PE ]]...]
-.SH DESCRIPTION
-lvextend allows you to extend the size of a logical volume.
-Extension of snapshot logical volumes (see
-.BR lvcreate (8)
-for information to create snapshots) is supported as well.
-But to change the number of copies in a mirrored logical
-volume use
-.BR lvconvert (8).
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-f ", " \-\-force
-Proceed with size extension without prompting.
-.TP
-.IR \fB\-l ", " \fB\-\-extents " [" + ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN }]
-Extend or set the logical volume size in units of logical extents.
-With the '\fI+\fP' sign the value is added to the actual size
-of the logical volume and without it, the value is taken as an absolute one.
-The total number of physical extents allocated will be
-greater than this, for example, if the volume is mirrored.
-The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix \fI%VG\fP, relative to the existing
-size of the Logical Volume with the suffix \fI%LV\fP, of the remaining
-free space for the specified PhysicalVolume(s) with the suffix \fI%PVS\fP,
-as a percentage of the remaining free space in the Volume Group
-with the suffix \fI%FREE\fP, or (for a snapshot) as a percentage of the total
-space in the Origin Logical Volume with the suffix \fI%ORIGIN\fP.
-The resulting value is rounded upward.
-N.B. In a future release, when expressed as a percentage with PVS, VG or FREE,
-the number will be treated as an approximate upper limit for the total number
-of physical extents to be allocated (including extents used by any mirrors, for
-example).  The code may currently allocate more space than you might otherwise
-expect.
-.TP
-.IR \fB\-L ", " \fB\-\-size " [" + ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
-Extend or set the logical volume size in units of megabytes.
-A size suffix of M for megabytes,
-G for gigabytes, T for terabytes, P for petabytes
-or E for exabytes is optional.
-With the + sign the value is added to the actual size
-of the logical volume and without it, the value is taken as an absolute one.
-.TP
-.BR \-i ", " \-\-stripes " " \fIStripes
-Gives the number of stripes for the extension.
-Not applicable to LVs using the original metadata LVM format, which must
-use a single value throughout.
-.TP
-.BR \-I ", " \-\-stripesize " " \fIStripeSize
-Gives the number of kilobytes for the granularity of the stripes.
-Not applicable to LVs using the original metadata LVM format, which must
-use a single value throughout.
-.br
-StripeSize must be 2^n (n = 2 to 9)
-.TP
-.BR \-n ", " \-\-nofsck
-Do not perform fsck before extending filesystem when filesystem
-requires it. You may need to use \fB\-\-force\fR to proceed with
-this option.
-.TP
-.B \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.TP
-.BR \-r ", " \-\-resizefs
-Resize underlying filesystem together with the logical volume using
-\fBfsadm\fR(8).
-.TP
-.B \-\-use\-policies
-Resizes the logical volume according to configured policy. See
-\fBlvm.conf\fR(5) for some details.
-
-.SH Examples
-Extends the size of the logical volume "vg01/lvol10" by 54MiB on physical
-volume /dev/sdk3. This is only possible if /dev/sdk3 is a member of
-volume group vg01 and there are enough free physical extents in it:
-.sp
-.B lvextend \-L +54 /dev/vg01/lvol10 /dev/sdk3
-
-Extends the size of logical volume "vg01/lvol01" by the amount of free
-space on physical volume /dev/sdk3. This is equivalent to specifying
-"\-l +100%PVS" on the command line:
-.sp
-.B lvextend /dev/vg01/lvol01 /dev/sdk3
-
-Extends a logical volume "vg01/lvol01" by 16MiB using physical extents
-/dev/sda:8\-9 and /dev/sdb:8\-9 for allocation of extents:
-.sp
-.B lvextend -L+16M vg01/lvol01 /dev/sda:8\-9 /dev/sdb:8\-9
-
-.SH SEE ALSO
-.BR fsadm (8),
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR lvcreate (8),
-.BR lvconvert (8),
-.BR lvreduce (8),
-.BR lvresize (8),
-.BR lvchange (8)
diff --git a/man/lvm-config.8.des b/man/lvm-config.8.des
new file mode 100644
index 0000000..1d36566
--- /dev/null
+++ b/man/lvm-config.8.des
@@ -0,0 +1,5 @@
+This command is the same as \fBlvmconfig\fP(8).
+
+lvm config produces formatted output from the LVM configuration tree. The
+sources of the configuration data include \fBlvm.conf\fP(5) and command
+line settings from \-\-config.
diff --git a/man/lvm-config.8.in b/man/lvm-config.8.in
deleted file mode 100644
index 5050d77..0000000
--- a/man/lvm-config.8.in
+++ /dev/null
@@ -1 +0,0 @@
-.so man8/lvmconfig.8
diff --git a/man/lvm-dumpconfig.8.des b/man/lvm-dumpconfig.8.des
new file mode 100644
index 0000000..18593fb
--- /dev/null
+++ b/man/lvm-dumpconfig.8.des
@@ -0,0 +1,5 @@
+This command is the same as \fBlvmconfig\fP(8).
+
+lvm dumpconfig produces formatted output from the LVM configuration tree. The
+sources of the configuration data include \fBlvm.conf\fP(5) and command
+line settings from \-\-config.
diff --git a/man/lvm-dumpconfig.8.in b/man/lvm-dumpconfig.8.in
deleted file mode 100644
index 5050d77..0000000
--- a/man/lvm-dumpconfig.8.in
+++ /dev/null
@@ -1 +0,0 @@
-.so man8/lvmconfig.8
diff --git a/man/lvm-fullreport.8.des b/man/lvm-fullreport.8.des
new file mode 100644
index 0000000..f350a0a
--- /dev/null
+++ b/man/lvm-fullreport.8.des
@@ -0,0 +1,6 @@
+lvm fullreport produces formatted output about PVs, PV segments, VGs, LVs
+and LV segments. The information is all gathered together for each VG
+(under a per-VG lock) so it is consistent. Information gathered from
+separate calls to \fBvgs\fP, \fBpvs\fP, and \fBlvs\fP can be inconsistent
+if information changes between commands.
+
diff --git a/man/lvm-fullreport.8.in b/man/lvm-fullreport.8.in
deleted file mode 100644
index 96ac937..0000000
--- a/man/lvm-fullreport.8.in
+++ /dev/null
@@ -1,145 +0,0 @@
-.TH LVM-FULLREPORT 8 "LVM TOOLS #VERSION#" "Red Hat, Inc" \" -*- nroff -*-
-.SH NAME
-lvm fullreport \(em Report information about PVs, PV segments, VGs, LVs and LV segments, all at once for each VG.
-.SH SYNOPSIS
-.B lvm fullreport
-.RB [ \-a | \-\-all ]
-.RB [ \-\-aligned ]
-.RB [ \-\-binary ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [[ \-\-configreport
-.IR ReportName ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field1 [, Field2 ...]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [, Key2 ...]]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB ...]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-logonly ]
-.RB [ \-\-nameprefixes ]
-.RB [ \-\-noheadings ]
-.RB [ \-\-nosuffix ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-rows ]
-.RB [ \-\-separator
-.IR Separator ]
-.RB [ \-\-unbuffered ]
-.RB [ \-\-units
-.IR hHbBsSkKmMgGtTpPeE ]
-.RB [ \-\-unquoted ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RI [ VolumeGroupName
-.RI [ VolumeGroupName ...]]
-.SH DESCRIPTION
-lvm fullreport produces formatted output about PVs, PV segments, VGs, LVs 
-and LV segments, all at once for each VG and guarded by per-VG lock
-for consistency.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.B \-\-all
-Include information in the output about internal Logical Volumes that
-are components of normally-accessible Logical Volumes, such as mirrors,
-but which are not independently accessible (e.g. not mountable).
-The names of such Logical Volumes are enclosed within square brackets
-in the output.  For example, after creating a mirror using
-.B lvcreate -m1 \-\-mirrorlog disk
-, this option will reveal three internal Logical
-Volumes, with suffixes mimage_0, mimage_1, and mlog.
-.TP
-.B \-\-aligned
-Use with \fB\-\-separator\fP to align the output columns.
-.TP
-.B \-\-binary
-Use binary values "0" or "1" instead of descriptive literal values
-for columns that have exactly two valid values to report (not counting
-the "unknown" value which denotes that the value could not be determined).
-.TP
-.B \-\-configreport  \fI ReportName
-Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
-\fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
-is 'pv' for PV subreport, 'pvseg' for PV segment subreport, 'vg' for
-VG subreport, 'lv' for LV subreport, 'seg' for LV segment subreport or 'log'
-for log report. If \fB\-\-configreport\fP option is not used to identify a
-report, then all command's subreports are assumed except log report. The log
-report is available only if enabled by \fBlog/report_command_log\fP
-\fBlvm.conf\fP(5) setting or if \fB\-\-logonly\fP option is used.
-.TP
-.B \-\-logonly
-Suppress the main report itself and display only log report on output.
-.TP
-.B \-\-nameprefixes
-Add an "LVM2_" prefix plus the field name to the output.  Useful
-with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
-be used to set environment variables (for example, in \fBudev\fP(7) rules).
-.TP
-.B \-\-noheadings
-Suppress the headings line that is normally the first line of output.
-Useful if grepping the output.
-.TP
-.B \-\-nosuffix
-Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
-(except h and H) if processing the output.
-.TP
-.BR \-o ", " \-\-options
-Comma-separated ordered list of columns.
-.IP
-Precede the list with '\fI+\fP' to append to the current list
-of columns, '\fI-\fP' to remove from the current list of columns
-or '\fI#\fP' to compact given columns. The \fI\-o\fP option can
-be repeated, providing several lists. These lists are evaluated
-from left to right.
-.IP
-For the list of columns, see \fBpvs\fP(8), \fBvgs\fP(8),
-\fBlvs\fP(8) man page or check \fBpvs\fP, \fBvgs\fP, \fBlvs -o help\fP
-output.
-.TP
-.BR \-O ", " \-\-sort
-Comma-separated ordered list of columns to sort by.  Replaces the default
-selection. Precede any column with '\fI\-\fP' for a reverse sort on that
-column.
-.TP
-.B \-\-rows
-Output columns as rows.
-.TP
-.BR  \-S ", " \-\-select " " \fISelection
-Display only rows that match Selection criteria. All rows are displayed with
-the additional "selected" column (\fB-o selected\fP) showing 1 if the row
-matches the Selection and 0 otherwise. The Selection criteria are defined
-by specifying column names and their valid values (that can include reserved
-values) while making use of supported comparison operators. See \fBlvm\fP(8)
-and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
-about constructing the Selection criteria. As a quick help and to see full
-list of column names that can be used in Selection including the list of
-reserved values and the set of supported selection operators, check the
-output of \fBpvs\fP, \fBvgs\fP, \fBlvs -S help\fP command.
-.TP
-.B \-\-separator \fISeparator
-String to use to separate each column.  Useful if grepping the output.
-.TP
-.B \-\-unbuffered
-Produce output immediately without sorting or aligning the columns properly.
-.TP
-.B \-\-units \fIhHbBsSkKmMgGtTpPeE
-All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
-Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
-custom units e.g. \-\-units 3M
-.TP
-.B \-\-unquoted
-When used with \fB\-\-nameprefixes\fP, output values in the field=value
-pairs are not quoted.
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvs (8),
-.BR vgs (8),
-.BR lvs (8)
diff --git a/man/lvm-lvpoll.8.des b/man/lvm-lvpoll.8.des
new file mode 100644
index 0000000..35c2522
--- /dev/null
+++ b/man/lvm-lvpoll.8.des
@@ -0,0 +1,4 @@
+lvm lvpoll is an internal command used by \fBlvmpolld\fP(8) to monitor and
+complete \fBlvconvert\fP(8) and \fBpvmove\fP(8) operations. lvpoll itself
+does not initiate these operations and should not normally need to be run
+directly.
diff --git a/man/lvm-lvpoll.8.end b/man/lvm-lvpoll.8.end
new file mode 100644
index 0000000..eddb364
--- /dev/null
+++ b/man/lvm-lvpoll.8.end
@@ -0,0 +1,33 @@
+.SH NOTES
+
+To find the name of the pvmove LV that was created by an original
+\fBpvmove /dev/name\fP command, use the command:
+.br
+\fBlvs -a -S move_pv=/dev/name\fP.
+
+.SH EXAMPLES
+
+Continue polling a pvmove operation.
+.br
+.B lvm lvpoll --polloperation pvmove vg00/pvmove0
+
+Abort a pvmove operation.
+.br
+.B lvm lvpoll --polloperation pvmove --abort vg00/pvmove0
+
+Continue polling a mirror conversion.
+.br
+.B lvm lvpoll --polloperation convert vg00/lvmirror
+
+Continue mirror repair.
+.br
+.B lvm lvpoll --polloperation convert vg/damaged_mirror --handlemissingpvs
+
+Continue snapshot merge.
+.br
+.B lvm lvpoll --polloperation merge vg/snapshot_old
+
+Continue thin snapshot merge.
+.br
+.B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
+
diff --git a/man/lvm-lvpoll.8.in b/man/lvm-lvpoll.8.in
deleted file mode 100644
index 8ffbdd4..0000000
--- a/man/lvm-lvpoll.8.in
+++ /dev/null
@@ -1,89 +0,0 @@
-.TH "LVPOLL" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" \" -*- nroff -*-
-.SH NAME
-lvpoll \(em Internal command used by lvmpolld to complete some Logical Volume operations.
-
-.SH SYNOPSIS
-.B lvm lvpoll
-.BR \-\-polloperation
-.RI { pvmove | convert | merge | merge_thin }
-.RB [ \-\-abort ]
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-handlemissingpvs ]
-.RB [ \-i | \-\-interval
-.IR Seconds ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.IR LogicalVolume [ Path ]
-.SH DESCRIPTION
-\fBlvpoll\fP is an internal command used by \fBlvmpolld\fP(8) to monitor and
-complete \fBlvconvert\fP(8) and \fBpvmove\fP(8) operations.
-\fBlvpoll\fP itself does not initiate these operations and
-you should never normally need to invoke it directly.
-
-.I LogicalVolume
-The Logical Volume undergoing conversion or, in the case of pvmove, the name of
-the internal pvmove Logical Volume (see \fBEXAMPLES\fP).
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-\-polloperation " {" \fIconvert | \fImerge | \fImerge_thin | \fIpvmove }
-Mandatory option.
-\fIpvmove\fP refers to a pvmove operation that is moving data.
-\fIconvert\fP refers to an operation that is increasing the number of redundant copies of data maintained by a mirror.
-\fImerge\fP indicates a merge operation that doesn't involve thin volumes.
-\fImerge_thin\fP indicates a merge operation involving thin snapshots.
-\fBpvmove\fP(8) and \fBlvconvert\fP(8) describe how to initiate these operations.
-.TP
-.B \-\-abort
-Abort pvmove in progress.  See \fBpvmove\fP(8).
-.TP
-.B \-\-handlemissingpvs
-Used when the polling operation needs to handle missing PVs to be able to
-continue. This can happen when \fBlvconvert\fP(8) is repairing a mirror
-with one or more faulty devices.
-.TP
-.BR \-i ", " \-\-interval " "\fISeconds
-Report progress at regular intervals
-
-.SH EXAMPLES
-Resume polling of a pvmove operation identified by the Logical Volume vg00/pvmove0:
-.sp
-.B lvm lvpoll --polloperation pvmove vg00/pvmove0
-.P
-Abort the same pvmove operation:
-.sp
-.B lvm lvpoll --polloperation pvmove --abort vg00/pvmove0
-.P
-To find out the name of the pvmove Logical Volume resulting from an original
-\fBpvmove /dev/sda1\fP command you may use the following \fBlvs\fP command.
-(Remove the parentheses from the LV name.)
-.sp
-.B lvs -a -S move_pv=/dev/sda1
-.P
-Resume polling of mirror conversion vg00/lvmirror:
-.sp
-.B lvm lvpoll --polloperation convert vg00/lvmirror
-.P
-Complete mirror repair:
-.sp
-.B lvm lvpoll --polloperation convert vg/damaged_mirror --handlemissingpvs
-.P
-Process snapshot merge:
-.sp
-.B lvm lvpoll --polloperation merge vg/snapshot_old
-.P
-Finish thin snapshot merge:
-.sp
-.B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
-.SH SEE ALSO
-.BR lvconvert (8),
-.BR lvm (8),
-.BR lvmpolld (8),
-.BR lvs (8),
-.BR pvmove (8)
diff --git a/man/lvmchange.8.in b/man/lvmchange.8.in
deleted file mode 100644
index dc6b3bd..0000000
--- a/man/lvmchange.8.in
+++ /dev/null
@@ -1,10 +0,0 @@
-.TH LVMCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvmchange \(em change attributes of the logical volume manager
-.SH SYNOPSIS
-.B lvmchange
-.SH DESCRIPTION
-lvmchange is not currently supported under LVM2, although
-\fBdmsetup\fP(8) has a \fBremove_all\fP command.
-.SH SEE ALSO
-.BR dmsetup (8)
diff --git a/man/lvmconfig.8.des b/man/lvmconfig.8.des
new file mode 100644
index 0000000..17f9f18
--- /dev/null
+++ b/man/lvmconfig.8.des
@@ -0,0 +1,3 @@
+lvmconfig produces formatted output from the LVM configuration tree. The
+sources of the configuration data include \fBlvm.conf\fP(5) and command
+line settings from \-\-config.
diff --git a/man/lvmconfig.8.in b/man/lvmconfig.8.in
deleted file mode 100644
index f4b6abd..0000000
--- a/man/lvmconfig.8.in
+++ /dev/null
@@ -1,225 +0,0 @@
-.TH "LVMCONFIG" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-.SH "NAME"
-lvmconfig, lvm dumpconfig, lvm config \(em Display LVM configuration 
-.SH SYNOPSIS
-.
-.ad l
-.B lvmconfig
-.RB [ \-f | \-\-file
-.IR Filename ]
-.RB [ \-\-type
-.RB { current | default | diff | full |\: list | missing | new \c
-.RB | profilable | profilable-command | profilable-metadata }]
-.RB [ \-\-atversion
-.IR Version ]
-.RB [ \-\-sinceversion
-.IR Version ]
-.RB [ \-\-ignoreadvanced ]
-.RB [ \-\-ignoreunsupported ]
-.RB [ \-\-ignorelocal ]
-.RB [ \-l | \-\-list ]
-.RB [ \-\-config
-.IR ConfigurationString ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-\-profile
-.IR ProfileName ]
-.RB [ \-\-metadataprofile
-.IR ProfileName ]
-.RB [ \-\-mergedconfig ]
-.RB [ \-\-showdeprecated ]
-.RB [ \-\-showunsupported ]
-.RB [ \-\-validate ]
-.RB [ \-\-withsummary ]
-.RB [ \-\-withcomments ]
-.RB [ \-\-withspaces ]
-.RB [ \-\-withversions ]
-.RB [ ConfigurationNode... ]
-.ad b
-.
-.SH DESCRIPTION
-lvmconfig produces formatted output from the LVM configuration tree.
-The command was added in release 2.02.119 and has an identical longer form 
-\fBlvm dumpconfig\fP.
-
-.SH OPTIONS
-.TP
-.BR \-f ", " \-\-file " \fIFilename"
-Send output to a file named 'filename'.
-
-.TP
-.BR \-l ", " \-\-list
-List configuration settings with summarizing comment. This is the same as using
-\fBlvmconfig --type list --withsummary\fP.
-
-.TP
-.BR \-\-type " {" current | default | diff | full | missing | new | profilable |\: profilable-command | profilable-metadata }
-Select the type of configuration to display. The configuration settings
-displayed have either default values or currently-used values assigned based on
-the type selected. If no type is selected, \fB\-\-type current\fP is used
-by default. Whenever a configuration setting with a default value is
-commented out, it means the setting does not have any concrete default
-value defined. Output can be saved and used as a proper \fBlvm.conf\fP(5)
-file.
-.RS
-.IP \fBcurrent\fP 3
-Display the current \fBlvm.conf\fP configuration merged with any \fBtag
-config\fP if used. See also \fBlvm.conf\fP(5) for more info about LVM
-configuration methods.
-.IP \fBdefault\fP 3
-Display all possible configuration settings with default values assigned.
-.IP \fBdiff\fP 3
-Display all configuration settings for which the values used differ from defaults.
-The value assigned for each configuration setting is the value currently used.
-Using this type also implies the use of \fB\-\-mergedconfig\fP option.
-This is actually minimal LVM configuration which can be used without
-a change to current configured behaviour.
-.IP \fBfull\fP 3
-Display full configuration tree - a combination of current configuration tree
-(\fB\-\-type current\fP) and tree of settings for which default values are
-used (\fB\-\-type missing\fP). This is exactly the configuration tree that
-LVM2 uses during command execution. Using this type also implies
-the use of \fB\-\-mergedconfig\fP option. If comments are displayed
-(see \fB\-\-withcomments\fP and \fB\-\-withsummary\fP options), then
-for each setting found in existing configuration and for which defaults
-are not used, there's an extra comment line printed to denote this.
-.IP \fBlist\fP 3
-Display plain list of configuration settings.
-.IP \fBmissing\fP 3
-Display all configuration settings with default values assigned which are
-missing in the configuration currently used and for which LVM automatically
-fallbacks to using these default values.
-.IP \fBnew\fP 3
-Display all new configuration settings introduced in current LVM version
-or specific version as defined by \fB\-\-atversion\fP option.
-.IP \fBprofilable\fP 3
-Display all profilable configuration settings with default values assigned.
-See \fBlvm.conf\fP(5) for more info about \fBprofile config\fP method.
-.IP \fBprofilable-command\fP 3
-Display all profilable configuration settings with default values assigned
-that can be used in command profile. This is a subset of settings displayed
-by \fB\-\-type profilable\fP.
-.IP \fBprofilable-metadata\fP 3
-Display all profilable configuration settings with default values assigned
-that can be used in metadata profile. This is a subset of settings displayed
-by \fB\-\-type profilable\fP.
-.RE
-
-.TP
-.BI \-\-atversion " Version"
-Specify an LVM version in x.y.z format where x is the major version,
-the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-When configuration is displayed, the configuration settings recognized
-at this LVM version will be considered only. This can be used
-to display a configuration that a certain LVM version understands and
-which does not contain any newer settings for which LVM would
-issue a warning message when checking the configuration.
-
-.TP
-.BI \-\-sinceversion " Version"
-Specify an LVM version in x.y.z format where x is the major version,
-the y is the minor version and z is the patchlevel (e.g. 2.2.106).
-This option is currently applicable only with \fB\-\-type new\fP
-to display all configuration settings introduced since given version.
-
-.TP
-.B \-\-ignoreadvanced
-Exclude advanced configuration settings from the output.
-
-.TP
-.B \-\-ignoreunsupported
-Exclude unsupported configuration settings from the output. These settings are
-either used for debugging and development purposes only or their support is not
-yet complete and they are not meant to be used in production. The \fBcurrent\fP
-and \fBdiff\fP types include unsupported settings in their output by default,
-all the other types ignore unsupported settings.
-
-.TP
-.B \-\-ignorelocal
-Ignore local section.
-
-.TP
-.BI \-\-config " ConfigurationString"
-Use \fIConfigurationString\fP to override existing configuration.
-This configuration is then applied for the lvmconfig command itself.
-See also \fBlvm.conf\fP(5) for more info about \fBconfig cascade\fP.
-
-.TP
-.BI \-\-commandprofile " ProfileName"
-Use \fIProfileName\fP to override existing configuration.
-This configuration is then applied for the lvmconfig command itself.
-See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for
-more info about \fBconfig cascade\fP.
-
-.TP
-.BI \-\-profile " ProfileName"
-The same as using \fB\-\-commandprofile\fP but the configuration is not
-applied for the lvmconfig command itself.
-
-.TP
-.BI \-\-metadataprofile " ProfileName"
-Use \fIProfileName\fP to override existing configuration.
-The configuration defined in metadata profile has no effect for
-the lvmconfig command itself. lvmconfig displays the configuration only.
-See also \fB\-\-mergedconfig\fP option and \fBlvm.conf\fP(5) for more
-info about \fBconfig cascade\fP.
-
-.TP
-.B \-\-mergedconfig
-When the lvmconfig command is run with the \fB\-\-config\fP option
-and/or \fB\-\-commandprofile\fP (or using \fBLVM_COMMAND_PROFILE\fP
-environment variable), \fB\-\-profile\fP, \fB\-\-metadataprofile\fP
-option, merge all the contents of the \fBconfig cascade\fP before displaying it.
-Without the \fB\-\-mergeconfig\fP option used, only the configuration at
-the front of the cascade is displayed. See also \fBlvm.conf\fP(5) for more
-info about \fBconfig cascade\fP.
-
-.TP
-.B \-\-showdeprecated
-Include deprecated configuration settings in the output. These settings
-are always deprecated since certain version. If concrete version is specified
-with \fB--atversion\fP option, deprecated settings are automatically included
-if specified version is lower that the version in which the settings were
-deprecated. The \fBcurrent\fP and \fBdiff\fP types include deprecated settings
-int their output by default, all the other types ignore deprecated settings.
-
-.TP
-.B \-\-showunsupported
-Include unsupported configuration settings in the output. These settings
-are either used for debugging or development purposes only or their support
-is not yet complete and they are not meant to be used in production. The
-\fBcurrent\fP and \fBdiff\fP types include unsupported settings in their
-output by default, all the other types ignore unsupported settings.
-
-.TP
-.B \-\-validate
-Validate current configuration used and exit with appropriate
-return code. The validation is done only for the configuration
-at the front of the \fBconfig cascade\fP. To validate the whole
-merged configuration tree, use also the \fB\-\-mergedconfig\fP option.
-The validation is done even if \fBconfig/checks\fP \fBlvm.conf\fP(5)
-option is disabled.
-
-.TP
-.B \-\-withsummary
-Display a one line comment for each configuration node.
-
-.TP
-.B \-\-withcomments
-Display a full comment for each configuration node. For deprecated
-settings, also display comments about deprecation in addition.
-
-.TP
-.B \-\-withspaces
-Where appropriate, add more spaces in output for better readability.
-
-.TP
-.B \-\-withversions
-Also display a comment containing the version of introduction for
-each configuration node. If the setting is deprecated, also display
-the version since which it is deprecated.
-
-.SH SEE ALSO
-.BR lvm (8)
-.BR lvmconf (8)
-.BR lvm.conf (5)
diff --git a/man/lvmdiskscan.8.des b/man/lvmdiskscan.8.des
new file mode 100644
index 0000000..c1e87cc
--- /dev/null
+++ b/man/lvmdiskscan.8.des
@@ -0,0 +1,7 @@
+lvmdiskscan scans all SCSI, (E)IDE disks, multiple devices and a bunch of
+other block devices in the system looking for LVM PVs. The size reported
+is the real device size. Define a filter in \fBlvm.conf\fP(5) to restrict
+the scan to avoid a CD ROM, for example.
+
+This command is deprecated, use \fBpvs\fP instead.
+
diff --git a/man/lvmdiskscan.8.in b/man/lvmdiskscan.8.in
deleted file mode 100644
index 6de34c1..0000000
--- a/man/lvmdiskscan.8.in
+++ /dev/null
@@ -1,27 +0,0 @@
-.TH LVMDISKSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvmdiskscan \(em scan for all devices visible to LVM2
-.SH SYNOPSIS
-.B lvmdiskscan
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-l | \-\-lvmpartition ]
-.RB [ \-v | \-\-verbose ]
-.SH DESCRIPTION
-lvmdiskscan scans all SCSI, (E)IDE disks, multiple devices and a bunch
-of other block devices in the system looking for LVM physical volumes.
-The size reported is the real device size.
-Define a filter in \fBlvm.conf\fP(5) to restrict
-the scan to avoid a CD ROM, for example.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-l ", " \-\-lvmpartition
-Only reports Physical Volumes.
-.SH SEE ALSO
-.BR lvm (8),
-.BR lvm.conf (5),
-.BR pvscan (8),
-.BR vgscan (8)
diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index f01c695..6e9b703 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -573,25 +573,37 @@ To place the lvmlock LV on a specific device, create the VG with only that
 device, then use vgextend to add other devices.
 
 
-.SS shared LVs
-
-When an LV is used concurrently from multiple hosts (e.g. by a
-multi\-host/cluster application or file system), the LV can be activated
-on multiple hosts concurrently using a shared lock.
-
-To activate the LV with a shared lock:  lvchange \-asy vg/lv.
-
-With lvmlockd, an unspecified activation mode is always exclusive, i.e.
-\-ay defaults to \-aey.
-
-If the LV type does not allow the LV to be used concurrently from multiple
-hosts, then a shared activation lock is not allowed and the lvchange
-command will report an error.  LV types that cannot be used concurrently
+.SS LV activation
+
+In a shared VG, activation changes involve locking through lvmlockd, and
+the following values are possible with lvchange/vgchange -a:
+
+.IP \fBy\fP|\fBey\fP
+The command activates the LV in exclusive mode, allowing a single host
+to activate the LV.  Before activating the LV, the command uses lvmlockd
+to acquire an exclusive lock on the LV.  If the lock cannot be acquired,
+the LV is not activated and an error is reported.  This would happen if
+the LV is active on another host.
+
+.IP \fBsy\fP
+The command activates the LV in shared mode, allowing multiple hosts to
+activate the LV concurrently.  Before activating the LV, the
+command uses lvmlockd to acquire a shared lock on the LV.  If the lock
+cannot be acquired, the LV is not activated and an error is reported.
+This would happen if the LV is active exclusively on another host.  If the
+LV type prohibits shared access, such as a snapshot, the command will
+report an error and fail.
+The shared mode is intended for a multi\-host/cluster application or
+file system.
+LV types that cannot be used concurrently
 from multiple hosts include thin, cache, raid, mirror, and snapshot.
-
 lvextend on LV with shared locks is not yet allowed.  The LV must be
 deactivated, or activated exclusively to run lvextend.
 
+.IP \fBn\fP
+The command deactivates the LV.  After deactivating the LV, the command
+uses lvmlockd to release the current lock on the LV.
+
 
 .SS recover from lost PV holding sanlock locks
 
diff --git a/man/lvmsadc.8.des b/man/lvmsadc.8.des
new file mode 100644
index 0000000..e4cfd8d
--- /dev/null
+++ b/man/lvmsadc.8.des
@@ -0,0 +1,3 @@
+lvmsadc is not currently supported in LVM. The device-mapper statistics
+facility provides similar performance metrics using the \fBdmstats(8)\fP
+command.
diff --git a/man/lvmsadc.8.in b/man/lvmsadc.8.in
deleted file mode 100644
index 81d2b66..0000000
--- a/man/lvmsadc.8.in
+++ /dev/null
@@ -1,16 +0,0 @@
-.TH "LVMSADC" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
-.SH "NAME"
-lvmsadc \(em LVM system activity data collector
-
-.SH "SYNOPSIS"
-.B lvmsadc
-
-.SH "DESCRIPTION"
-lvmsadc is not currently supported under LVM2: the device-mapper statistics
-facility provides similar performance metrics using the \fBdmstats(8)\fP
-command.
-
-.SH "SEE ALSO"
-.BR dmstats (8)
-.BR lvm (8)
diff --git a/man/lvmsar.8.des b/man/lvmsar.8.des
new file mode 100644
index 0000000..3177506
--- /dev/null
+++ b/man/lvmsar.8.des
@@ -0,0 +1,3 @@
+lvmsar is not currently supported in LVM. The device-mapper statistics
+facility provides similar performance metrics using the \fBdmstats(8)\fP
+command.
diff --git a/man/lvmsar.8.in b/man/lvmsar.8.in
deleted file mode 100644
index fca111f..0000000
--- a/man/lvmsar.8.in
+++ /dev/null
@@ -1,16 +0,0 @@
-.TH "LVMSAR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
-
-.SH "NAME"
-lvmsar \(em LVM system activity reporter
-
-.SH "SYNOPSIS"
-.B lvmsar
-
-.SH "DESCRIPTION"
-lvmsar is not currently supported under LVM2: the device-mapper statistics
-facility provides similar performance metrics using the \fBdmstats(8)\fP
-command.
-
-.SH "SEE ALSO"
-.BR dmstats (8)
-.BR lvm (8)
diff --git a/man/lvreduce.8.des b/man/lvreduce.8.des
new file mode 100644
index 0000000..7f0ba0c
--- /dev/null
+++ b/man/lvreduce.8.des
@@ -0,0 +1,14 @@
+lvreduce reduces the size of an LV. The freed logical extents are returned
+to the VG to be used by other LVs. A copy\-on\-write snapshot LV can also
+be reduced if less space is needed to hold COW blocks. Use
+\fBlvconvert\fP(8) to change the number of data images in a RAID or
+mirrored LV.
+
+Be careful when reducing an LV's size, because data in the reduced area is
+lost. Ensure that any file system on the LV is resized \fBbefore\fP
+running lvreduce so that the removed extents are not in use by the file
+system.
+
+Sizes will be rounded if necessary. For example, the LV size must be an
+exact number of extents, and the size of a striped segment must be a
+multiple of the number of stripes.
diff --git a/man/lvreduce.8.end b/man/lvreduce.8.end
new file mode 100644
index 0000000..59fde52
--- /dev/null
+++ b/man/lvreduce.8.end
@@ -0,0 +1,5 @@
+.SH EXAMPLES
+
+Reduce the size of an LV by 3 logical extents:
+.br
+.B lvreduce \-l \-3 vg00/lvol1
diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
deleted file mode 100644
index edf0c92..0000000
--- a/man/lvreduce.8.in
+++ /dev/null
@@ -1,110 +0,0 @@
-.TH LVREDUCE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvreduce \(em reduce the size of a logical volume
-.SH SYNOPSIS
-.B lvreduce
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ \-f | \-\-force ]
-.RB [ \-\-noudevsync ]
-.RB { \-l | \-\-extents
-.RI [ \- ] LogicalExtentsNumber [ % { VG | LV | FREE | ORIGIN }]
-.RB |
-.BR \-L | \-\-size
-.RI [ \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
-.RB [ \-n | \-\-nofsck ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-r | \-\-resizefs ]
-.IR LogicalVolume { Name | Path }
-.SH DESCRIPTION
-lvreduce allows you to reduce the size of a logical volume.
-Be careful when reducing a logical volume's size, because data in the
-reduced part is lost!!!
-.br
-You should therefore ensure that any filesystem on the volume is
-resized
-.I before
-running lvreduce so that the extents that are to be removed are not in use.
-.br
-Shrinking snapshot logical volumes (see
-.BR lvcreate (8)
-for information to create snapshots) is supported as well.
-But to change the number of copies in a mirrored logical
-volume use
-.BR lvconvert (8).
-.br
-Sizes will be rounded if necessary - for example, the volume size must
-be an exact number of extents and the size of a striped segment must
-be a multiple of the number of stripes.
-.br
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-f ", " \-\-force
-Force size reduction without prompting even when it may cause data loss.
-.TP
-.IR \fB\-l ", " \fB\-\-extents " [" \- ] LogicalExtentsNumber [ % { VG | LV | FREE | ORIGIN }]
-Reduce or set the logical volume size in units of logical extents.
-With the \fI-\fP sign the value will be subtracted from
-the logical volume's actual size and without it the value will be taken
-as an absolute size.
-The total number of physical extents freed will be greater than this logical
-value if, for example, the volume is mirrored.
-The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix \fI%VG\fP, relative to the existing
-size of the Logical Volume with the suffix \fI%LV\fP, as a percentage of the
-remaining free space in the Volume Group with the suffix \fI%FREE\fP, or (for
-a snapshot) as a percentage of the total space in the Origin Logical
-Volume with the suffix \fI%ORIGIN\fP.
-The resulting value for the subtraction is rounded downward, for the absolute
-size it is rounded upward.
-N.B. In a future release, when expressed as a percentage with VG or FREE, the
-number will be treated as an approximate total number of physical extents to be
-freed (including extents used by any mirrors, for example).  The code may
-currently release more space than you might otherwise expect.
-.TP
-.IR \fB\-L ", " \fB\-\-size " [" \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
-Reduce or set the logical volume size in units of megabytes.
-A size suffix of \fIk\fP for kilobyte, \fIm\fP for megabyte,
-\fIg\fP for gigabytes, \fIt\fP for terabytes, \fIp\fP for petabytes
-or \fIe\fP for exabytes is optional.
-With the \fI\-\fP sign the value will be subtracted from
-the logical volume's actual size and without it it will be taken as
-an absolute size.
-.TP
-.BR \-n ", " \-\-nofsck
-Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use \fB\-\-force\fR to proceed with
-this option.
-.TP
-.BR \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.TP
-.BR \-r ", " \-\-resizefs
-Resize underlying filesystem together with the logical volume using
-.BR fsadm (8).
-.SH Examples
-Reduce the size of logical volume lvol1 in volume group vg00 by 3 logical extents:
-.sp
-.B lvreduce \-l \-3 vg00/lvol1
-.SH SEE ALSO
-.BR fsadm (8),
-.BR lvchange (8),
-.BR lvconvert (8),
-.BR lvcreate (8),
-.BR lvextend (8),
-.BR lvm (8),
-.BR lvresize (8),
-.BR vgreduce (8)
diff --git a/man/lvremove.8.des b/man/lvremove.8.des
new file mode 100644
index 0000000..d049c63
--- /dev/null
+++ b/man/lvremove.8.des
@@ -0,0 +1,22 @@
+lvremove removes one or more LVs. For standard LVs, this returns the
+logical extents that were used by the LV to the VG for use by other LVs.
+
+Confirmation will be requested before deactivating any active LV prior to
+removal.  LVs cannot be deactivated or removed while they are open (e.g.
+if they contain a mounted filesystem). Removing an origin LV will also
+remove all dependent snapshots.
+
+\fBHistorical LVs\fP
+
+If the configuration setting \fBmetadata/record_lvs_history\fP is enabled
+and the LV being removed forms part of the history of at least one LV that
+is still present, then a simplified representation of the LV will be
+retained. This includes the time of removal (\fBlv_time_removed\fP
+reporting field), creation time (\fBlv_time\fP), name (\fBlv_name\fP), LV
+uuid (\fBlv_uuid\fP) and VG name (\fBvg_name\fP). This allows later
+reporting to see the ancestry chain of thin snapshot volumes, even after
+some intermediate LVs have been removed. The names of such historical LVs
+acquire a hyphen as a prefix (e.g. '-lvol1') and cannot be reactivated.
+Use lvremove a second time, with the hyphen, to remove the record of the
+former LV completely.
+
diff --git a/man/lvremove.8.end b/man/lvremove.8.end
new file mode 100644
index 0000000..5c70ed6
--- /dev/null
+++ b/man/lvremove.8.end
@@ -0,0 +1,11 @@
+.SH EXAMPLES
+
+Remove an active LV without asking for confirmation.
+.br
+.B lvremove \-f vg00/lvol1
+
+Remove all LVs the specified VG.
+.br
+.B lvremove vg00
+
+
diff --git a/man/lvremove.8.in b/man/lvremove.8.in
deleted file mode 100644
index fe9375c..0000000
--- a/man/lvremove.8.in
+++ /dev/null
@@ -1,80 +0,0 @@
-.TH LVREMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvremove \(em remove a logical volume
-.SH SYNOPSIS
-.B lvremove
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-\-nohistory ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ \-f | \-\-force ]
-.RB [ \-\-noudevsync ]
-.RI [ LogicalVolume { Name | Path }...]
-.SH DESCRIPTION
-lvremove removes one or more logical volumes.
-Confirmation will be requested before deactivating any active logical
-volume prior to removal.  Logical volumes cannot be deactivated
-or removed while they are open (e.g. if they contain a mounted filesystem).
-Removing an origin logical volume will also remove all dependent snapshots.
-.sp
-If the logical volume is clustered then it must be deactivated on all
-nodes in the cluster before it can be removed. A single lvchange command
-issued from one node can do this.
-.sp
-If the configuration setting \fBmetadata/record_lvs_history\fP is enabled 
-and the logical volume being removed forms part of the history of at least
-one logical volume that is still present then a simplified representation of
-the logical volume will be retained.  This includes the time of removal
-(\fBlv_time_removed\fP reporting field), creation time (\fBlv_time\fP), name
-(\fBlv_name\fP), LV uuid (\fBlv_uuid\fP) and VG name (\fBvg_name\fP) and
-allows you to see the ancestry chain of thin snapshot volumes even after
-some intermediate logical volumes have been removed.
-The names of such historical logical volumes acquire a hyphen as a prefix
-(e.g. '-lvol1') and cannot be reactivated.  Use lvremove a second time,
-with the hyphen, to remove the record of the former logical volume completely.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-f ", " \-\-force
-Remove active logical volumes without confirmation.
-Tool will try to deactivate \fIunused\fP volume.
-To proceed with damaged pools use \-ff
-.TP
-.B \-\-nohistory
-Disable the recording of history of logical volumes which are being removed.
-(This has no effect unless the configuration setting
-\fBmetadata/record_lvs_history\fP is enabled.)
-.TP
-.B \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.SH Examples
-Remove the active logical volume lvol1 in volume group vg00
-without asking for confirmation:
-.sp
-.B lvremove \-f vg00/lvol1
-.sp
-Remove all logical volumes in volume group vg00:
-.sp
-.B lvremove vg00
-.SH SEE ALSO
-.BR lvcreate (8),
-.BR lvdisplay (8),
-.BR lvchange (8),
-.BR lvm (8),
-.BR lvs (8),
-.BR lvscan (8),
-.BR vgremove (8)
diff --git a/man/lvrename.8.des b/man/lvrename.8.des
new file mode 100644
index 0000000..a8455fc
--- /dev/null
+++ b/man/lvrename.8.des
@@ -0,0 +1,2 @@
+lvrename renames an existing LV or a historical LV (see \fBlvremove\fP for
+historical LV information.)
diff --git a/man/lvrename.8.end b/man/lvrename.8.end
new file mode 100644
index 0000000..3409b8a
--- /dev/null
+++ b/man/lvrename.8.end
@@ -0,0 +1,10 @@
+.SH EXAMPLES
+
+Rename "lvold" to "lvnew":
+.br
+.B lvrename /dev/vg02/lvold vg02/lvnew
+
+An alternate syntax to rename "lvold" to "lvnew":
+.br
+.B lvrename vg02 lvold lvnew
+
diff --git a/man/lvrename.8.in b/man/lvrename.8.in
deleted file mode 100644
index de6e519..0000000
--- a/man/lvrename.8.in
+++ /dev/null
@@ -1,51 +0,0 @@
-.TH LVRENAME 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvrename \(em rename a logical volume
-.SH SYNOPSIS
-.B lvrename
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ \-f | \-\-force ]
-.RB [ \-\-noudevsync ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RI { OldLogicalVolume { Name | Path }
-.IR NewLogicalVolume { Name | Path }
-|
-.I VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName\fR}
-.SH DESCRIPTION
-lvrename renames an existing logical volume or an existing
-historical logical volume from
-.IR OldLogicalVolume { Name | Path }
-to
-.IR NewLogicalVolume { Name | Path }.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.SH EXAMPLE
-To rename lvold in volume group vg02 to lvnew:
-.sp
-.B lvrename /dev/vg02/lvold vg02/lvnew
-.sp
-An alternate syntax to rename this logical volume is:
-.sp
-.B lvrename vg02 lvold lvnew
-.sp
-.SH SEE ALSO
-.BR lvm (8), 
-.BR lvchange (8),
-.BR vgcreate (8), 
-.BR vgrename (8)
diff --git a/man/lvresize.8.des b/man/lvresize.8.des
new file mode 100644
index 0000000..7fdcacc
--- /dev/null
+++ b/man/lvresize.8.des
@@ -0,0 +1,2 @@
+lvresize resizes an LV in the same way as lvextend and lvreduce. See
+\fBlvextend\fP(8) and \fBlvreduce\fP(8) for more information.
diff --git a/man/lvresize.8.end b/man/lvresize.8.end
new file mode 100644
index 0000000..a336d62
--- /dev/null
+++ b/man/lvresize.8.end
@@ -0,0 +1,6 @@
+.SH EXAMPLES
+
+Extend an LV by 16MB using specific physical extents:
+.br
+.B lvresize \-L+16M vg1/lv1 /dev/sda:0\-1 /dev/sdb:0\-1
+
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
deleted file mode 100644
index 9cdb787..0000000
--- a/man/lvresize.8.in
+++ /dev/null
@@ -1,124 +0,0 @@
-.TH LVRESIZE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvresize \(em resize a logical volume
-.SH SYNOPSIS
-.B lvresize
-.RB [ \-\-alloc " " \fIAllocationPolicy ]
-.RB [ \-\-noudevsync ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-i | \-\-stripes " " \fIStripes
-.RB [ \-I | \-\-stripesize " " \fIStripeSize ]]
-.RB { \-l | \-\-extents
-.RI [ + | \- ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN "}] |"
-.BR \-L | \-\-size
-.RI [ + | \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
-.RB [ \-\-poolmetadatasize
-.RI [ + ] MetadataVolumeSize [ bBsSkKmMgG ]]
-.RB [ \-f | \-\-force ]
-.RB [ \-n | \-\-nofsck ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-r | \-\-resizefs ]
-.IR LogicalVolume { Name | Path }
-.RI [ PhysicalVolumePath [ :PE [ \-PE ]]...]
-.SH DESCRIPTION
-lvresize allows you to resize a logical volume.
-Be careful when reducing a logical volume's size, because data in the reduced
-part is lost!!!
-You should therefore ensure that any filesystem on the volume is
-shrunk first so that the extents that are to be removed are not in use.
-Resizing snapshot logical volumes (see
-.BR lvcreate (8)
-for information about creating snapshots) is supported as well.
-But to change the number of copies in a mirrored logical
-volume use
-.BR lvconvert (8).
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-f ", " \-\-force
-Force resize without prompting even when it may cause data loss.
-.TP
-.BR \-n ", " \-\-nofsck
-Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use \fB\-\-force\fR to proceed with
-this option.
-.TP
-.BR \-r ", " \-\-resizefs
-Resize underlying filesystem together with the logical volume using
-\fBfsadm\fR(8).
-.TP
-.IR \fB\-l ", " \fB\-\-extents " [" + | \- ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN }]
-Change or set the logical volume size in units of logical extents.
-With the \fI+\fP or \fI\-\fP sign the value is added to or subtracted from the actual size
-of the logical volume and without it, the value is taken as an absolute one.
-The total number of physical extents affected will be
-greater than this if, for example, the volume is mirrored.
-The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix \fI%VG\fP, relative to the existing
-size of the Logical Volume with the suffix \fI%LV\fP, as a percentage of
-the remaining free space of the PhysicalVolumes on the command line with the
-suffix \fI%PVS\fP, as a percentage of the remaining free space in the
-Volume Group with the suffix \fI%FREE\fP, or (for a snapshot) as a percentage
-of the total space in the Origin Logical Volume with the suffix \fI%ORIGIN\fP.
-The resulting value is rounded downward for the subtraction otherwise
-it is rounded upward.
-N.B. In a future release, when expressed as a percentage with PVS, VG or FREE,
-the number will be treated as an approximate total number of physical extents
-to be allocated or freed (including extents used by any mirrors, for example).
-The code may currently allocate or remove more space than you might otherwise
-expect.
-.TP
-.IR \fB\-L ", " \fB\-\-size " [" + | \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
-Change or set the logical volume size in units of megabytes.
-A size suffix of \fIM\fP for megabytes,
-\fIG\fP for gigabytes, \fIT\fP for terabytes, \fIP\fP for petabytes
-or \fIE\fP for exabytes is optional.
-With the \fI+\fP or \fI\-\fP sign the value is added or subtracted
-from the actual size of the logical volume and rounded
-to the full extent size and without it,
-the value is taken as an absolute one.
-.TP
-.BR \-i ", " \-\-stripes " " \fIStripes
-Gives the number of stripes to use when extending a Logical Volume.
-Defaults to whatever the last segment of the Logical Volume uses.
-Not applicable to LVs using the original metadata LVM format, which must
-use a single value throughout.
-.TP
-.IR \fB\-\-poolmetadatasize " [" + ] MetadataVolumeSize [ bBsSkKmMgG ]
-Change or set the thin pool metadata logical volume size.
-With the \fI+\fP sign the value is added to the actual size
-of the metadata volume and rounded to the full extent size
-and without it, the value is taken as an absolute one.
-Maximal size is 16GiB. Default unit is megabytes.
-.TP
-.BR \-I ", " \-\-stripesize " " \fIStripeSize
-Gives the number of kilobytes for the granularity of the stripes.
-Defaults to whatever the last segment of the Logical Volume uses.
-Not applicable to LVs using the original metadata LVM format, which
-must use a single value throughout.
-.br
-StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
-For metadata in LVM2 format, the stripe size may be a larger
-power of 2 but must not exceed the physical extent size.
-.TP
-.B \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.SH EXAMPLES
-.br
-Extend a logical volume vg1/lv1 by 16MB using physical extents
-/dev/sda:0\-1 and /dev/sdb:0\-1 for allocation of extents:
-.sp
-.B lvresize \-L+16M vg1/lv1 /dev/sda:0\-1 /dev/sdb:0\-1
-.SH SEE ALSO
-.BR fsadm (8),
-.BR lvm (8),
-.BR lvconvert (8),
-.BR lvcreate (8),
-.BR lvreduce (8),
-.BR lvchange (8)
diff --git a/man/lvs.8.des b/man/lvs.8.des
new file mode 100644
index 0000000..5f80764
--- /dev/null
+++ b/man/lvs.8.des
@@ -0,0 +1 @@
+lvs produces formatted output about LVs.
diff --git a/man/lvs.8.end b/man/lvs.8.end
new file mode 100644
index 0000000..d71f7c1
--- /dev/null
+++ b/man/lvs.8.end
@@ -0,0 +1,75 @@
+.SH NOTES
+.
+The lv_attr bits are:
+.IP 1 3
+Volume type: (C)ache, (m)irrored, (M)irrored without initial sync, (o)rigin,
+(O)rigin with merging snapshot, (r)aid, (R)aid without initial sync,
+(s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
+mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,
+under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, raid or
+pool m(e)tadata or pool metadata spare.
+.IP 2 3
+Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
+volume
+.IP 3 3
+Allocation policy:  (a)nywhere, (c)ontiguous, (i)nherited, c(l)ing, (n)ormal
+This is capitalised if the volume is currently locked against allocation
+changes, for example during
+.BR pvmove (8).
+.IP 4 3
+fixed (m)inor
+.IP 5 3
+State: (a)ctive, (h)istorical, (s)uspended, (I)nvalid snapshot,
+invalid (S)uspended snapshot, snapshot (m)erge failed,
+suspended snapshot (M)erge failed, mapped (d)evice present without tables,
+mapped device present with (i)nactive table, thin-pool (c)heck needed,
+suspended thin-pool (C)heck needed, (X) unknown
+.IP 6 3
+device (o)pen, (X) unknown
+.IP 7 3
+Target type: (C)ache, (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.
+This groups logical volumes related to the same kernel target together.  So,
+for example, mirror images, mirror logs as well as mirrors themselves appear as
+(m) if they use the original device-mapper mirror kernel driver; whereas the raid
+equivalents using the md raid kernel driver all appear as (r).
+Snapshots using the original device-mapper driver appear as (s); whereas
+snapshots of thin volumes using the new thin provisioning driver appear as (t).
+.IP 8 3
+Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
+.IP 9 3
+Volume Health, where there are currently three groups of attributes identified:
+.IP
+Common ones for all Logical Volumes: (p)artial, (X) unknown.
+.br
+(p)artial signifies that one or more of the Physical Volumes this Logical
+Volume uses is missing from the system. (X) unknown signifies the status
+is unknown.
+.IP
+Related to RAID Logical Volumes: (r)efresh needed, (m)ismatches exist, (w)ritemostly.
+.br
+(r)efresh signifies that one or more of the Physical Volumes this RAID Logical
+Volume uses had suffered a write error. The write error could be due to a
+temporary failure of that Physical Volume or an indication that it is failing.
+The device should be refreshed or replaced. (m)ismatches signifies that the
+RAID logical volume has portions of the array that are not coherent.
+Inconsistencies are detected by initiating a "check" on a RAID logical volume.
+(The scrubbing operations, "check" and "repair", can be performed on a RAID
+logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
+devices in a RAID 1 logical volume that have been marked write-mostly.
+.IP
+Related to Thin pool Logical Volumes: (F)ailed, out of (D)ata space,
+(M)etadata read only.
+.br
+(F)ailed is set if thin pool encounters serious failures and hence no further I/O
+is permitted at all. The out of (D)ata space is set if thin pool has run out of
+data space. (M)etadata read only signifies that thin pool encounters certain
+types of failures but it's still possible to do reads at least,
+but no metadata changes are allowed.
+.IP
+Related to Thin Logical Volumes: (F)ailed.
+.br
+(F)ailed is set when related thin pool enters Failed state and no further I/O
+is permitted at all.
+.IP 10 3
+s(k)ip activation: this volume is flagged to be skipped during activation.
+
diff --git a/man/lvs.8.in b/man/lvs.8.in
deleted file mode 100644
index 48ef866..0000000
--- a/man/lvs.8.in
+++ /dev/null
@@ -1,290 +0,0 @@
-.TH LVS 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvs \(em report information about logical volumes
-.SH SYNOPSIS
-.B lvs
-.RB [ \-\-aligned ]
-.RB [ \-\-binary ]
-.RB [ \-a | \-\-all ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [[ \-\-configreport
-.IR ReportName ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field1 [, Field2 ...]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [, Key2 ...]]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB ...]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-H | \-\-history ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-logonly ]
-.RB [ \-\-nameprefixes ]
-.RB [ \-\-noheadings ]
-.RB [ \-\-nosuffix ]
-.RI [ + | \- ] Key1 [,[ + | \- ] Key2 [,...]]]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-rows ]
-.RB [ \-\-separator
-.IR Separator ]
-.RB [ \-\-segments ]
-.RB [ \-\-unbuffered ]
-.RB [ \-\-units
-.IR hHbBsSkKmMgGtTpPeE ]
-.RB [ \-\-unquoted ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RI [ VolumeGroupName | LogicalVolume { Name | Path }
-.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]]
-
-.SH DESCRIPTION
-lvs produces formatted output about logical volumes.
-.SH OPTIONS
-See
-.BR lvm (8)
-for common options.
-.TP
-.B \-\-aligned
-Use with \fB\-\-separator\fP to align the output columns.
-.TP
-.B \-\-all
-Include information in the output about internal Logical Volumes that
-are components of normally-accessible Logical Volumes, such as mirrors,
-but which are not independently accessible (e.g. not mountable).
-The names of such Logical Volumes are enclosed within square brackets
-in the output.  For example, after creating a mirror using
-.B lvcreate -m1 \-\-mirrorlog disk
-, this option will reveal three internal Logical
-Volumes, with suffixes mimage_0, mimage_1, and mlog.
-.TP
-.B \-\-binary
-Use binary values "0" or "1" instead of descriptive literal values
-for columns that have exactly two valid values to report (not counting
-the "unknown" value which denotes that the value could not be determined).
-.TP
-.B \-\-configreport  \fI ReportName
-Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
-\fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
-is either 'lv' for command's main report or 'log' for log report.
-If \fB\-\-configreport\fP option is not used to identify a report, then
-command's main report is assumed. The log report is available only if
-enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or
-if \fB\-\-logonly\fP option is used.
-.TP
-.B \-H ", " \-\-history
-Include historical logical volumes in the output.
-(This has no effect unless logical volumes were removed while the configuration
-setting \fBmetadata/record_lvs_history\fP was enabled.)
-.TP
-.B \-\-logonly
-Suppress the lvs report itself and display only log report on output.
-.TP
-.B \-\-nameprefixes
-Add an "LVM2_" prefix plus the field name to the output.  Useful
-with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
-be used to set environment variables (for example, in
-.BR udev (7)
-rules).
-.TP
-.B \-\-noheadings
-Suppress the headings line that is normally the first line of output.
-Useful if grepping the output.
-.TP
-.B \-\-nosuffix
-Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
-(except h and H) if processing the output.
-.TP
-.BR \-o ", " \-\-options
-Comma-separated ordered list of columns.
-.IP
-Precede the list with '\fI+\fP' to append to the current list
-of columns, '\fI-\fP' to remove from the current list of columns
-or '\fI#\fP' to compact given columns. The \fI\-o\fP option can
-be repeated, providing several lists. These lists are evaluated
-from left to right.
-.IP
-Use \fB\-o lv_all\fP to select all logical volume columns,
-and \fB\-o seg_all\fP
-to select all logical volume segment columns.
-.IP
-Use \fB\-o help\fP to view the full list of columns available.
-.IP
-Column names include:
-chunk_size,
-convert_lv,
-copy_percent,
-data_lv,
-devices,
-discards,
-lv_attr,
-lv_host,
-lv_kernel_major,
-lv_kernel_minor,
-lv_kernel_read_ahead,
-lv_major,
-lv_minor,
-lv_name,
-lv_path,
-lv_profile,
-lv_read_ahead,
-lv_size,
-lv_tags,
-lv_time,
-lv_uuid,
-metadata_lv,
-mirror_log,
-modules,
-move_pv,
-origin,
-origin_size,
-pool_lv,
-raid_max_recovery_rate,
-raid_min_recovery_rate,
-raid_mismatch_count,
-raid_sync_action,
-raid_write_behind,
-region_size,
-segtype,
-seg_count,
-seg_pe_ranges,
-seg_size,
-seg_size_pe,
-seg_start,
-seg_start_pe,
-seg_tags,
-snap_percent,
-stripes,
-stripe_size,
-sync_percent,
-thin_count,
-transaction_id,
-zero.
-.IP
-With \fB\-\-segments\fP, any "seg_" prefixes are optional;
-otherwise any "lv_" prefixes are optional. Columns mentioned in
-.BR vgs (8)
-can also be chosen.
-.IP
-The lv_attr bits are:
-.RS
-.IP 1 3
-Volume type: (C)ache, (m)irrored, (M)irrored without initial sync, (o)rigin,
-(O)rigin with merging snapshot, (r)aid, (R)aid without initial sync,
-(s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
-mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,
-under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, raid or
-pool m(e)tadata or pool metadata spare.
-.IP 2 3
-Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
-volume
-.IP 3 3
-Allocation policy:  (a)nywhere, (c)ontiguous, (i)nherited, c(l)ing, (n)ormal
-This is capitalised if the volume is currently locked against allocation
-changes, for example during
-.BR pvmove (8).
-.IP 4 3
-fixed (m)inor
-.IP 5 3
-State: (a)ctive, (h)istorical, (s)uspended, (I)nvalid snapshot,
-invalid (S)uspended snapshot, snapshot (m)erge failed,
-suspended snapshot (M)erge failed, mapped (d)evice present without tables,
-mapped device present with (i)nactive table, thin-pool (c)heck needed,
-suspended thin-pool (C)heck needed, (X) unknown
-.IP 6 3
-device (o)pen, (X) unknown
-.IP 7 3
-Target type: (C)ache, (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.
-This groups logical volumes related to the same kernel target together.  So,
-for example, mirror images, mirror logs as well as mirrors themselves appear as
-(m) if they use the original device-mapper mirror kernel driver; whereas the raid
-equivalents using the md raid kernel driver all appear as (r).
-Snapshots using the original device-mapper driver appear as (s); whereas
-snapshots of thin volumes using the new thin provisioning driver appear as (t).
-.IP 8 3
-Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
-.IP 9 3
-Volume Health, where there are currently three groups of attributes identified:
-.IP
-Common ones for all Logical Volumes: (p)artial, (X) unknown.
-.br
-(p)artial signifies that one or more of the Physical Volumes this Logical
-Volume uses is missing from the system. (X) unknown signifies the status
-is unknown.
-.IP
-Related to RAID Logical Volumes: (r)efresh needed, (m)ismatches exist, (w)ritemostly.
-.br
-(r)efresh signifies that one or more of the Physical Volumes this RAID Logical
-Volume uses had suffered a write error. The write error could be due to a
-temporary failure of that Physical Volume or an indication that it is failing.
-The device should be refreshed or replaced. (m)ismatches signifies that the
-RAID logical volume has portions of the array that are not coherent.
-Inconsistencies are detected by initiating a "check" on a RAID logical volume.
-(The scrubbing operations, "check" and "repair", can be performed on a RAID
-logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
-devices in a RAID 1 logical volume that have been marked write-mostly.
-.IP
-Related to Thin pool Logical Volumes: (F)ailed, out of (D)ata space,
-(M)etadata read only.
-.br
-(F)ailed is set if thin pool encounters serious failures and hence no further I/O
-is permitted at all. The out of (D)ata space is set if thin pool has run out of
-data space. (M)etadata read only signifies that thin pool encounters certain
-types of failures but it's still possible to do reads at least,
-but no metadata changes are allowed.
-.IP
-Related to Thin Logical Volumes: (F)ailed.
-.br
-(F)ailed is set when related thin pool enters Failed state and no further I/O
-is permitted at all.
-.IP 10 3
-s(k)ip activation: this volume is flagged to be skipped during activation.
-.RE
-.TP
-.BR \-O ", " \-\-sort
-Comma-separated ordered list of columns to sort by.  Replaces the default
-selection. Precede any column with '\fI\-\fP' for a reverse sort on that column.
-.TP
-.B \-\-rows
-Output columns as rows.
-.TP
-.BR  \-S ", " \-\-select " " \fISelection
-Display only rows that match Selection criteria. All rows are displayed with
-the additional "selected" column (\fB-o selected\fP) showing 1 if the row
-matches the Selection and 0 otherwise. The Selection criteria are defined
-by specifying column names and their valid values (that can include reserved
-values) while making use of supported comparison operators. See \fBlvm\fP(8)
-and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
-about constructing the Selection criteria. As a quick help and to see full
-list of column names that can be used in Selection including the list of
-reserved values and the set of supported selection operators, check the
-output of \fBlvs -S help\fP command.
-.TP
-.B \-\-segments
-Use default columns that emphasize segment information.
-.TP
-.B \-\-separator \fISeparator
-String to use to separate each column.  Useful if grepping the output.
-.TP
-.B \-\-unbuffered
-Produce output immediately without sorting or aligning the columns properly.
-.TP
-.B \-\-units \fIhHbBsSkKmMgGtTpPeE
-All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
-Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify
-custom units e.g. \fB\-\-units 3M\fP
-.TP
-.B \-\-unquoted
-When used with \fB\-\-nameprefixes\fP, output values in the field=value
-pairs are not quoted.
-.SH SEE ALSO
-.BR lvm (8),
-.BR lvdisplay (8),
-.BR pvs (8),
-.BR vgs (8)
diff --git a/man/lvscan.8.des b/man/lvscan.8.des
new file mode 100644
index 0000000..e30eb58
--- /dev/null
+++ b/man/lvscan.8.des
@@ -0,0 +1,5 @@
+lvscan scans all VGs or all supported LVM block devices in the system for
+LVs. The output consists of one line for each LV indicating whether or not
+it is active, a snapshot or origin, the size of the device and its
+allocation policy. Use \fBlvs\fP(8) or \fBlvdisplay\fP(8) to obtain more
+comprehensive information about LVs.
diff --git a/man/lvscan.8.in b/man/lvscan.8.in
deleted file mode 100644
index 5710e3c..0000000
--- a/man/lvscan.8.in
+++ /dev/null
@@ -1,52 +0,0 @@
-.TH LVSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvscan \(em scan (all disks) for Logical Volumes
-.SH SYNOPSIS
-.B lvscan
-.RB [ \-a | \-\-all]
-.RB [ \-b | \-\-blockdevice ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-v | \-\-verbose ]
-.SH DESCRIPTION
-lvscan scans all known volume groups or all supported LVM block devices
-in the system for defined Logical Volumes.  The output consists
-of one line for each Logical Volume indicating whether or not it is active,
-a snapshot or origin, the size of the device and its allocation policy.
-Use \fBlvs\fP(8) or \fBlvdisplay\fP(8) to obtain more-comprehensive
-information about the Logical Volumes.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-\-all
-Include information in the output about internal Logical Volumes that
-are components of normally-accessible Logical Volumes, such as mirrors,
-but which are not independently accessible (e.g. not mountable).
-For example, after creating a mirror using
-.B lvcreate \-m1 \-\-mirrorlog disk\fR,
-this option will reveal three internal Logical Volumes, with suffixes
-mimage_0, mimage_1, and mlog.
-.TP
-.BR \-b ", " \-\-blockdevice
-This option is now ignored.  Instead, use \fBlvs\fP(8) or
-\fBlvdisplay\fP(8) to obtain the device number.
-.TP
-.IR \fB\-\-cache " " LogicalVolume
-Applicable only when \fBlvmetad\fP(8) is in use (see also \fBlvm.conf\fP(5),
-global/use_lvmetad). This command issues a rescan of physical volume labels and
-metadata areas of all PVs that the logical volume uses. In particular, this can
-be used when a RAID logical volume becomes degraded, to update information
-about physical volume availability. This is only necessary if the logical
-volume is \fBnot\fP being monitored by dmeventd (see \fBlvchange\fP(8), option
-\fB\-\-monitor\fP).
-.SH SEE ALSO
-.BR lvm (8),
-.BR lvcreate (8),
-.BR lvdisplay (8)
-.BR lvs (8)
diff --git a/man/pvchange.8.des b/man/pvchange.8.des
new file mode 100644
index 0000000..802850f
--- /dev/null
+++ b/man/pvchange.8.des
@@ -0,0 +1 @@
+pvchange changes PV attributes in the VG.
diff --git a/man/pvchange.8.end b/man/pvchange.8.end
new file mode 100644
index 0000000..a524d07
--- /dev/null
+++ b/man/pvchange.8.end
@@ -0,0 +1,6 @@
+.SH EXAMPLES
+
+Disallow the allocation of physical extents on a PV (e.g. because of
+disk errors, or because it will be removed after freeing it).
+.br
+.B pvchange \-x n /dev/sdk1
diff --git a/man/pvchange.8.in b/man/pvchange.8.in
deleted file mode 100644
index c7ddc58..0000000
--- a/man/pvchange.8.in
+++ /dev/null
@@ -1,59 +0,0 @@
-.TH PVCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-pvchange \(em change attributes of a physical volume
-.SH SYNOPSIS
-.B pvchange
-.RB [ \-\-addtag
-.IR Tag ]
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-f | \-\-force ]
-.RB [ \-\-deltag
-.IR Tag ]
-.RB [ \-\-metadataignore
-.RI { y | n }]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-a | \-\-all ]
-.RB [ \-x | \-\-allocatable
-.RI { y | n }]
-.RB [ \-u | \-\-uuid ]
-.RI [ PhysicalVolumePath ...]
-.SH DESCRIPTION
-pvchange allows you to change the allocation permissions of one or
-more physical volumes.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-a ", " \-\-all
-If PhysicalVolumePath is not specified on the command line all
-physical volumes are searched for and used.
-.TP
-.BR \-\-metadataignore " {" \fIy | \fIn }
-Ignore or un-ignore metadata areas on this physical volume.
-If metadata areas on a physical volume are ignored, LVM will
-not not store metadata in the metadata areas present on this Physical
-Volume.
-.TP
-.BR \-u ", " \-\-uuid
-Generate new random UUID for specified physical volumes.
-.TP
-.BR \-x ", " \-\-allocatable " {" \fIy | \fIn }
-Enable or disable allocation of physical extents on this physical volume.
-.SH Example
-Disallows the allocation of physical extents on this physical volume
-(possibly because of disk errors, or because it will be removed after
-freeing it:
-.sp
-.B pvchange \-x n /dev/sdk1
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvcreate (8)
diff --git a/man/pvck.8.des b/man/pvck.8.des
new file mode 100644
index 0000000..0a32657
--- /dev/null
+++ b/man/pvck.8.des
@@ -0,0 +1 @@
+pvck checks the LVM metadata for consistency on PVs.
diff --git a/man/pvck.8.end b/man/pvck.8.end
new file mode 100644
index 0000000..67af238
--- /dev/null
+++ b/man/pvck.8.end
@@ -0,0 +1,8 @@
+.SH EXAMPLES
+
+If the partition table is corrupted or lost on /dev/sda, and you suspect
+there was an LVM partition at approximately 100 MiB, then this
+area of the disk can be scanned using the \fB\-\-labelsector\fP
+parameter with a value of 204800 (100 * 1024 * 1024 / 512 = 204800).
+.br
+.B pvck \-\-labelsector 204800 /dev/sda
diff --git a/man/pvck.8.in b/man/pvck.8.in
deleted file mode 100644
index 368dc06..0000000
--- a/man/pvck.8.in
+++ /dev/null
@@ -1,37 +0,0 @@
-.TH PVCK 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-pvck \(em check physical volume metadata
-.SH SYNOPSIS
-.B pvck
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-labelsector
-.IR sector ]
-.I PhysicalVolume
-.RI [ PhysicalVolume ...]
-.SH DESCRIPTION
-pvck checks physical volume LVM metadata for consistency.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.B \-\-labelsector \fIsector
-By default, 4 sectors of \fBPhysicalVolume\fP are scanned for an LVM label,
-starting at sector 0.  This parameter allows you to specify a different
-starting sector for the scan and is useful for recovery situations.  For
-example, suppose the partition table is corrupted or lost on /dev/sda,
-but you suspect there was an LVM partition at approximately 100 MiB.  This
-area of the disk may be scanned by using the \fB\-\-labelsector\fP parameter
-with a value of 204800 (100 * 1024 * 1024 / 512 = 204800):
-.sp
-.B pvck \-\-labelsector 204800 /dev/sda
-.sp
-Note that a script can be used with \fB\-\-labelsector\fP to automate the
-process of finding LVM labels.
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvcreate (8),
-.BR pvscan (8)
-.BR vgck (8)
diff --git a/man/pvcreate.8.des b/man/pvcreate.8.des
new file mode 100644
index 0000000..3dfddbc
--- /dev/null
+++ b/man/pvcreate.8.des
@@ -0,0 +1,18 @@
+pvcreate initializes a PV so that it is recognized as belonging to LVM,
+and allows the PV to be used in a VG. A PV can be a disk partition, whole
+disk, meta device, or loopback file.
+
+For DOS disk partitions, the partition id should be set to 0x8e using
+.BR fdisk (8),
+.BR cfdisk (8),
+or a equivalent. For GUID Partition Table (GPT), the id is
+E6D6D379-F507-44C2-A23C-238F2A3DF928. For
+whole disk devices only
+the partition table must be erased, which will effectively destroy all
+data on that disk. This can be done by zeroing the first sector with:
+
+.BI "dd if=/dev/zero of=" PhysicalVolume " bs=512 count=1"
+
+Use \fBvgcreate\fP(8) to create a new VG on the PV, or \fBvgextend\fP(8)
+to add the PV to existing VG.
+
diff --git a/man/pvcreate.8.end b/man/pvcreate.8.end
new file mode 100644
index 0000000..b1b0f3e
--- /dev/null
+++ b/man/pvcreate.8.end
@@ -0,0 +1,13 @@
+.SH EXAMPLES
+
+Initialize a partition and a full device.
+.br
+.B pvcreate /dev/sdc4 /dev/sde
+
+If a device is a 4KiB sector drive that compensates for windows
+partitioning (sector 7 is the lowest aligned logical block, the 4KiB
+sectors start at LBA -1, and consequently sector 63 is aligned on a 4KiB
+boundary) manually account for this when initializing for use by LVM.
+.br
+.B pvcreate \-\-dataalignmentoffset 7s /dev/sdb
+
diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
deleted file mode 100644
index 97a9909..0000000
--- a/man/pvcreate.8.in
+++ /dev/null
@@ -1,210 +0,0 @@
-.TH PVCREATE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-pvcreate \(em initialize a disk or partition for use by LVM
-.SH SYNOPSIS
-.B pvcreate
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ \-f [ f ]| \-\-force
-.RB [ \-\-force ]]
-.RB [ \-y | \-\-yes ]
-.RB [ \-\-labelsector ]
-.RB [ \-\-bootloaderareasize
-.IR size ]
-.RB [ \-M | \-\-metadatatype
-.IR type ]
-.RB [ \-\- [ pv ] metadatacopies
-.IR NumberOfCopies ]
-.RB [ \-\-metadatasize
-.IR size ]
-.RB [ \-\-metadataignore
-.RI { y | n }]
-.RB [ \-\-dataalignment
-.IR alignment ]
-.RB [ \-\-dataalignmentoffset
-.IR alignment_offset ]
-.RB [ \-\-restorefile
-.IR file ]
-.RB [ \-\-norestorefile ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-setphysicalvolumesize
-.IR size ]
-.RB [ \-u | \-\-uuid
-.IR uuid ]
-.RB [ \-Z | \-\-zero
-.RI { y | n }]
-.I PhysicalVolume
-.RI [ PhysicalVolume ...]
-.SH DESCRIPTION
-pvcreate initializes
-.I PhysicalVolume
-for later use by the Logical Volume Manager (LVM).  Each
-.I PhysicalVolume
-can be a disk partition, whole disk, meta device, or loopback file.
-For DOS disk partitions, the partition id should be set to 0x8e using
-.BR fdisk (8),
-.BR cfdisk (8),
-or a equivalent. For GUID Partition Table (GPT), the id is
-E6D6D379-F507-44C2-A23C-238F2A3DF928. For
-.B whole disk devices only
-the partition table must be erased, which will effectively destroy all
-data on that disk.  This can be done by zeroing the first sector with:
-.sp
-.BI "dd if=/dev/zero of=" PhysicalVolume " bs=512 count=1"
-.sp
-Continue with
-.BR vgcreate (8)
-to create a new volume group on
-.IR PhysicalVolume ,
-or
-.BR vgextend (8)
-to add
-.I PhysicalVolume
-to an existing volume group.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-f ", " \-\-force
-Force the creation without any confirmation.  You can not recreate
-(reinitialize) a physical volume belonging to an existing volume group.
-In an emergency you can override this behaviour with \fB-ff\fP.
-.TP
-.BR \-u ", " \-\-uuid " " \fIuuid
-Specify the uuid for the device.
-Without this option, \fBpvcreate\fP(8) generates a random uuid.
-All of your physical volumes must have unique uuids.
-You need to use this option before restoring a backup of LVM metadata
-onto a replacement device - see \fBvgcfgrestore\fP(8).  As such, use of
-\fB\-\-restorefile\fP is compulsory unless the \fB\-\-norestorefile\fP is
-used.
-.TP
-.BR \-y ", " \-\-yes
-Answer yes to all questions.
-.TP
-.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
-Whether or not the first 4 sectors (2048 bytes) of the device should be
-wiped.
-If this option is not given, the
-default is to wipe these sectors unless either or both of the
-\fB\-\-restorefile\fP or \fB\-\-uuid\fP options were specified.
-.SH NEW METADATA OPTIONS
-LVM2 introduces a new format for storing metadata on disk.
-This new format is more efficient and resilient than the format the
-original version of LVM used and offers the advanced user greater
-flexibility and control.
-.P
-The new format may be selected on the command line with \fB\-M2\fP or by
-setting \fBformat = "lvm2"\fP in the \fBglobal\fP section of \fBlvm.conf\fP(5).
-Each physical volume in the same volume group must use the same format, but
-different volume groups on a machine may use different formats
-simultaneously: the tools can handle both formats.
-Additional formats can be added as shared libraries.
-.P
-Additional tools for manipulating the locations and sizes of metadata areas
-will be written in due course.  Use the verbose/debug options on the tools
-to see where the metadata areas are placed.
-.TP
-.B \-\-metadatasize \fIsize
-The approximate amount of space to be set aside for each metadata area.
-(The size you specify may get rounded.)
-.TP
-.B \-\-dataalignment \fIalignment
-Align the start of the data to a multiple of this number.
-You should also specify an appropriate \fIPhysicalExtentSize\fP when creating
-the Volume Group with \fBvgcreate\fP.
-.sp
-To see the location of the first Physical Extent of an existing Physical Volume
-use \fBpvs \-o +pe_start\fP .  It will be a multiple of the requested
-alignment.  In addition it may be shifted by \fIalignment_offset\fP from
-\fIdata_alignment_offset_detection\fP (if enabled in \fBlvm.conf\fP(5)) or
-\fB\-\-dataalignmentoffset\fP.
-.TP
-.B \-\-dataalignmentoffset \fIalignment_offset
-Shift the start of the data area by this additional \fIalignment_offset\fP.
-.TP
-.BR \-\- [ pv ] metadatacopies " " \fINumberOfCopies
-The number of metadata areas to set aside on each PV.  Currently
-this can be 0, 1 or 2.
-If set to 2, two copies of the volume group metadata
-are held on the PV, one at the front of the PV and one at the end.
-If set to 1 (the default), one copy is kept at the front of the PV
-(starting in the 5th sector).
-If set to 0, no copies are kept on this PV - you might wish to use this
-with VGs containing large numbers of PVs.  But if you do this and
-then later use \fBvgsplit\fP(8) you must ensure that each VG is still going
-to have a suitable number of copies of the metadata after the split!
-.TP
-.BR \-\-metadataignore " {" \fIy | \fIn }
-Ignore or un-ignore metadata areas on this physical volume.
-The default is "n".  This setting can be changed with \fBpvchange\fP.
-If metadata areas on a physical volume are ignored, LVM will
-not store metadata in the metadata areas present on this Physical
-Volume.  Metadata areas cannot be created or extended after Logical
-Volumes have been allocated on the device. If you do not want to store
-metadata on this device, it is still wise always to allocate a metadata
-area in case you need it in the future and to use this option to instruct
-LVM2 to ignore it.
-.TP
-.B \-\-restorefile \fIfile
-In conjunction with \fB\-\-uuid\fP, this extracts the location and size
-of the data on the PV from the file (produced by \fBvgcfgbackup\fP)
-and ensures that the metadata that the program produces is consistent
-with the contents of the file i.e. the physical extents will be in
-the same place and not get overwritten by new metadata.  This provides
-a mechanism to upgrade the metadata format or to add/remove metadata
-areas. Use with care. See also \fBvgconvert\fP(8).
-.TP
-.B \-\-norestorefile
-In conjunction with \fB\-\-uuid\fP, this allows a \fIuuid\fP to be specified
-without also requiring that a backup of the metadata be provided.
-.TP
-.B \-\-labelsector \fIsector
-By default the PV is labelled with an LVM2 identifier in its second
-sector (sector 1).  This lets you use a different sector near the
-start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
-in the source).  Use with care.
-.TP
-.B \-\-bootloaderareasize \fIsize
-Create a separate bootloader area of specified size besides PV's data
-area. The bootloader area is an area of reserved space on the PV from
-which LVM2 will not allocate any extents and it's kept untouched. This is
-primarily aimed for use with bootloaders to embed their own data or metadata.
-The start of the bootloader area is always aligned, see also \fB\-\-dataalignment\fP
-and \fB\-\-dataalignmentoffset\fP. The bootloader area size may eventually
-end up increased due to the alignment, but it's never less than the
-size that is requested. To see the bootloader area start and size of
-an existing Physical Volume use \fBpvs \-o +pv_ba_start,pv_ba_size\fP.
-.TP
-.B \-\-setphysicalvolumesize \fIsize
-Overrides the automatically-detected size of the PV.  Use with care.
-.SH Examples
-Initialize partition #4 on the third SCSI disk and the entire fifth
-SCSI disk for later use by LVM:
-.sp
-.B pvcreate /dev/sdc4 /dev/sde
-
-If the 2nd SCSI disk is a 4KiB sector drive that compensates for windows
-partitioning (sector 7 is the lowest aligned logical block, the 4KiB
-sectors start at LBA -1, and consequently sector 63 is aligned on a 4KiB
-boundary) manually account for this when initializing for use by LVM:
-.sp
-.B pvcreate \-\-dataalignmentoffset 7s /dev/sdb
-
-.SH SEE ALSO
-.BR lvm.conf (5),
-.BR lvm (8),
-.BR vgcreate (8),
-.BR vgextend (8),
-.BR lvcreate (8),
-.BR cfdisk (8),
-.BR fdisk (8),
-.BR losetup (8),
-.BR mdadm (8),
-.BR vgcfgrestore (8),
-.BR vgconvert (8)
diff --git a/man/pvdisplay.8.des b/man/pvdisplay.8.des
new file mode 100644
index 0000000..74d57ca
--- /dev/null
+++ b/man/pvdisplay.8.des
@@ -0,0 +1,5 @@
+pvdisplay shows the attributes of PVs, like size, physical extent size,
+space used for the VG descriptor area, etc.
+
+\fBpvs\fP(8) is a preferred alternative that shows the same information
+and more, using a more compact and configurable output format.
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
deleted file mode 100644
index 9bca720..0000000
--- a/man/pvdisplay.8.in
+++ /dev/null
@@ -1,109 +0,0 @@
-.TH PVDISPLAY 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-pvdisplay \- display attributes of a physical volume
-.SH SYNOPSIS
-.B pvdisplay
-.RB [ \-c | \-\-colon ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-maps ]
-.RB [ \-\-nosuffix ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-s | \-\-short ]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-\-units
-.IR hsbkmgtHKMGT ]
-.RB [ \-v [ v ]| \-\-verbose
-.RB [ \-\-verbose ]]
-.RB [ \-\-version ]
-.RI [ PhysicalVolumePath ...]
-.br
-
-.br
-.B pvdisplay
-.BR \-C | \-\-columns
-.RB [ \-\-aligned ]
-.RB [ \-\-binary ]
-.RB [ \-a | \-\-all ]
-.RB [ \-\-commandprofile
-.RB [[ \-\-configreport
-.IR ReportName ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field1 [, Field2 ...]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [, Key2 ...]]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB ...]
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-logonly ]
-.RB [ \-\-noheadings ]
-.RB [ \-\-nosuffix ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-separator
-.IR Separator ]
-.RB [ \-\-unbuffered ]
-.RB [ \-\-units
-.IR hHbBsSkKmMgGtTpPeE ]
-.RB [ \-v [ v ]| \-\-verbose
-.RB [ \-\-verbose ]]
-.RB [ \-\-version ]
-.RI [ PhysicalVolumePath ...]
-.SH DESCRIPTION
-pvdisplay allows you to see the attributes of one or more physical volumes
-like size, physical extent size, space used for the volume group descriptor
-area and so on.
-.P
-\fBpvs\fP(8) is an alternative that provides the same information 
-in the style of \fBps\fP(1).
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-C ", " \-\-columns
-Display output in columns, the equivalent of \fBpvs\fP(8).  See
-\fBpvs\fP(8) for a description of other options with this form of
-\fBpvdisplay\fP.
-.TP
-.BR \-c ", " \-\-colon
-Generate colon separated output for easier parsing in scripts or programs.
-N.B. \fBpvs\fP(8) provides considerably more control over the output.
-.nf
-
-The values are:
-
-\(bu physical volume device name
-\(bu volume group name
-\(bu physical volume size in sectors
-\(bu internal physical volume number (obsolete)
-\(bu physical volume status
-\(bu physical volume (not) allocatable
-\(bu current number of logical volumes on this physical volume
-\(bu physical extent size in kilobytes
-\(bu total number of physical extents
-\(bu free number of physical extents
-\(bu allocated number of physical extents
-
-.fi
-.TP
-.BR \-s ", " \-\-short
-Only display the size of the given physical volumes.
-.TP
-.BR \-m ", " \-\-maps
-Display the mapping of physical extents to logical volumes and
-logical extents.
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvs (8),
-.BR pvcreate (8),
-.BR lvcreate (8),
-.BR vgcreate (8)
diff --git a/man/pvmove.8.des b/man/pvmove.8.des
new file mode 100644
index 0000000..5286ef4
--- /dev/null
+++ b/man/pvmove.8.des
@@ -0,0 +1,61 @@
+pvmove moves the allocated physical extents (PEs) on a source PV to one or
+more destination PVs.  You can optionally specify a source LV in which
+case only extents used by that LV will be moved to free (or specified)
+extents on the destination PV. If no destination PV is specified, the
+normal allocation rules for the VG are used.
+
+If pvmove is interrupted for any reason (e.g. the machine crashes) then
+run pvmove again without any PV arguments to restart any operations that
+were in progress from the last checkpoint. Alternatively, use the abort
+option at any time to abort the operation. The resulting location of LVs
+after an abort depends on whether the atomic option was used.
+
+More than one pvmove can run concurrently if they are moving data from
+different source PVs, but additional pvmoves will ignore any LVs already
+in the process of being changed, so some data might not get moved.
+
+pvmove works as follows:
+
+1. A temporary 'pvmove' LV is created to store details of all the data
+movements required.
+
+2. Every LV in the VG is searched for contiguous data that need moving
+according to the command line arguments.
+For each piece of data found, a new segment is added to the end of the
+pvmove LV.
+This segment takes the form of a temporary mirror to copy the data 
+from the original location to a newly allocated location.
+The original LV is updated to use the new temporary mirror segment
+in the pvmove LV instead of accessing the data directly.
+
+3. The VG metadata is updated on disk.
+
+4. The first segment of the pvmove LV is activated and starts to mirror
+the first part of the data.  Only one segment is mirrored at once as this
+is usually more efficient.
+
+5. A daemon repeatedly checks progress at the specified time interval.
+When it detects that the first temporary mirror is in sync, it breaks that
+mirror so that only the new location for that data gets used and writes a
+checkpoint into the VG metadata on disk.  Then it activates the mirror for
+the next segment of the pvmove LV.
+
+6. When there are no more segments left to be mirrored, the temporary LV
+is removed and the VG metadata is updated so that the LVs reflect the new
+data locations.
+
+Note that this new process cannot support the original LVM1
+type of on-disk metadata.  Metadata can be converted using
+\fBvgconvert\fP(8).
+
+If the \fB\-\-atomic\fP option is used, a slightly different approach is
+used for the move.  Again, a temporary 'pvmove' LV is created to store the
+details of all the data movements required.  This temporary LV contains
+all the segments of the various LVs that need to be moved.  However, in
+this case, an identical LV is allocated that contains the same number of
+segments and a mirror is created to copy the contents from the first
+temporary LV to the second.  After a complete copy is made, the temporary
+LVs are removed, leaving behind the segments on the destination PV.  If an
+abort is issued during the move, all LVs being moved will remain on the
+source PV.
+
diff --git a/man/pvmove.8.end b/man/pvmove.8.end
new file mode 100644
index 0000000..9dd3adc
--- /dev/null
+++ b/man/pvmove.8.end
@@ -0,0 +1,46 @@
+.SH EXAMPLES
+
+Move all physical extents that are used by simple LVs on the specified PV to
+free physical extents elsewhere in the VG.
+.br
+.B pvmove /dev/sdb1
+
+Use a specific destination PV when moving physical extents.
+.br
+.B pvmove /dev/sdb1 /dev/sdc1
+
+Move extents belonging to a single LV.
+.br
+.B pvmove \-n lvol1 /dev/sdb1 /dev/sdc1
+
+Rather than moving the contents of an entire device, it is possible to
+move a range of physical extents, for example numbers 1000 to 1999
+inclusive on the specified PV.
+.br
+.B pvmove /dev/sdb1:1000\-1999
+
+A range of physical extents to move can be specified as start+length. For
+example, starting from PE 1000. (Counting starts from 0, so this refers to the
+1001st to the 2000th PE inclusive.)
+.br
+.B pvmove /dev/sdb1:1000+1000
+
+Move a range of physical extents to a specific PV (which must have
+sufficient free extents).
+.br
+.B pvmove /dev/sdb1:1000\-1999 /dev/sdc1
+
+Move a range of physical extents to specific new extents on a new PV.
+.br
+.B pvmove /dev/sdb1:1000\-1999 /dev/sdc1:0\-999
+
+If the source and destination are on the same disk, the
+\fBanywhere\fP allocation policy is needed.
+.br
+.B pvmove \-\-alloc anywhere /dev/sdb1:1000\-1999 /dev/sdb1:0\-999
+
+The part of a specific LV present within in a range of physical
+extents can also be picked out and moved.
+.br
+.B pvmove \-n lvol1 /dev/sdb1:1000\-1999 /dev/sdc1
+
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
deleted file mode 100644
index 39fdfe4..0000000
--- a/man/pvmove.8.in
+++ /dev/null
@@ -1,187 +0,0 @@
-.TH PVMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-pvmove \(em move physical extents
-.SH SYNOPSIS
-.B pvmove
-.RB [ \-\-abort ]
-.RB [ \-\-alloc
-.IR AllocationPolicy ]
-.RB [ \-\-atomic ]
-.RB [ \-b | \-\-background ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-i | \-\-interval
-.IR Seconds ]
-.RB [ \-\-noudevsync ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-n | \-\-name
-.IR LogicalVolume ]
-.RI [ SourcePhysicalVolume [ :PE [ \-PE ]...]
-.RI [ DestinationPhysicalVolume [ :PE [ \-PE ]...]...]]
-.SH DESCRIPTION
-pvmove allows you to move the allocated physical extents (PEs) on
-.I SourcePhysicalVolume
-to one or more other physical volumes (PVs).
-You can optionally specify a source
-.I LogicalVolume
-in which case only extents used by that LV will be moved to 
-free (or specified) extents on
-.IR DestinationPhysicalVolume (s).
-If no
-.I DestinationPhysicalVolume
-is specified, the normal allocation rules for the Volume Group are used.
-
-If pvmove gets interrupted for any reason (e.g. the machine crashes)
-then run pvmove again without any PhysicalVolume arguments to
-restart any moves that were in progress from the last checkpoint.
-Alternatively use \fBpvmove \-\-abort\fP at any time to abort.  The
-resulting location of logical volumes after an abort is issued depends
-on whether the
-.B \-\-atomic
-option was used when starting the pvmove process.
-
-You can run more than one pvmove at once provided they are moving data
-off different SourcePhysicalVolumes, but additional pvmoves will ignore
-any Logical Volumes already in the process of being changed, so some
-data might not get moved.
-
-\fBpvmove\fP works as follows:
-
-1. A temporary 'pvmove' Logical Volume is created to store
-details of all the data movements required.
-
-2. Every Logical Volume in the Volume Group is searched
-for contiguous data that need moving
-according to the command line arguments.
-For each piece of data found, a new segment is added to the end of the
-pvmove LV.
-This segment takes the form of a temporary mirror to copy the data 
-from the original location to a newly-allocated location. 
-The original LV is updated to use the new temporary mirror segment
-in the pvmove LV instead of accessing the data directly.
-
-3. The Volume Group metadata is updated on disk.
-
-4. The first segment of the pvmove Logical Volume is activated and starts
-to mirror the first part of the data.  Only one segment is mirrored at once
-as this is usually more efficient.
-
-5. A daemon repeatedly checks progress at the specified time interval.
-When it detects that the first temporary mirror is in-sync,
-it breaks that mirror so that only the new location for that data gets used 
-and writes a checkpoint into the Volume Group metadata on disk.
-Then it activates the mirror for the next segment of the pvmove LV.
-
-6. When there are no more segments left to be mirrored, 
-the temporary Logical Volume is removed and the Volume Group metadata 
-is updated so that the Logical Volumes reflect the new data locations.
-
-Note that this new process cannot support the original LVM1
-type of on-disk metadata.  Metadata can be converted using \fBvgconvert\fP(8).
-
-If the
-.B \-\-atomic
-option is used, a slightly different approach is used for the move.  Again,
-a temporary 'pvmove' logical volume is created to store the details of all
-the data movements required.  This temporary LV contains all the segments of
-the various LVs that need to be moved.  However this time, an identical
-logical volume is allocated that contains the same number of segments and
-a mirror is created to copy the contents from the first temporary LV to the
-second.  When a complete copy is accomplished, the temporary logical volumes
-are removed, leaving behind the segments on the destination physical volume.
-If an abort is issued during the move, all logical volumes being moved will
-remain on the source physical volume.
-
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.B \-\-abort
-Abort any moves in progress.  If the
-.B \-\-atomic
-option was used to start the pvmove, all logical volumes will remain on
-the source physical volume.  Otherwise, those segments that have completed
-the move will stay on the destination physical volume, while those that
-have not will remain on the source physical volume.
-.TP
-.B \-\-atomic
-Make the entire operation atomic.  That is, ensure that all affected logical
-volumes are moved to the destination physical volume together; unless the move
-has been aborted.  If the move has been aborted, all logical volumes will
-remain on the source physical volume.
-.TP
-.B \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.TP
-.BR \-b ", " \-\-background
-Run the daemon in the background.
-.TP
-.BR \-i ", " \-\-interval " " \fISeconds
-Report progress as a percentage@regular intervals.
-.TP
-.BR \-n ", " \-\-name " " \fILogicalVolume
-Move only the extents belonging to
-.I LogicalVolume
-from
-.I SourcePhysicalVolume
-instead of all allocated extents to the destination physical volume(s).
-
-.SH Examples
-To move all Physical Extents that are used by simple Logical Volumes on
-/dev/sdb1 to free Physical Extents elsewhere in the Volume Group use:
-.sp
-.B pvmove /dev/sdb1
-.P
-Additionally, a specific destination device /dev/sdc1
-can be specified like this:
-.sp
-.B pvmove /dev/sdb1 /dev/sdc1
-.P
-To perform the action only on extents belonging to the single Logical Volume 
-lvol1 do this:
-.sp
-.B pvmove \-n lvol1 /dev/sdb1 /dev/sdc1
-.P
-Rather than moving the contents of the entire device, it is possible to
-move a range of Physical Extents - for example numbers 1000 to 1999
-inclusive on /dev/sdb1 - like this:
-.sp
-.B pvmove /dev/sdb1:1000\-1999
-.P
-A range can also be specified as start+length, so
-.sp
-.B pvmove /dev/sdb1:1000+1000
-.P
-also refers to 1000 Physical Extents starting from Physical Extent number 1000.
-(Counting starts from 0, so this refers to the 1001st to the 2000th inclusive.)
-.P
-To move a range of Physical Extents to a specific location (which must have
-sufficient free extents) use the form:
-.sp
-.B pvmove /dev/sdb1:1000\-1999 /dev/sdc1
-.sp
-or
-.sp
-.B pvmove /dev/sdb1:1000\-1999 /dev/sdc1:0\-999
-.P
-If the source and destination are on the same disk, the 
-.B anywhere
-allocation policy would be needed, like this:
-.sp
-.B pvmove \-\-alloc anywhere /dev/sdb1:1000\-1999 /dev/sdb1:0\-999
-.P
-The part of a specific Logical Volume present within in a range of Physical
-Extents can also be picked out and moved, like this:
-.sp
-.B pvmove \-n lvol1 /dev/sdb1:1000\-1999 /dev/sdc1
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgconvert (8)
-.BR pvs (8)
diff --git a/man/pvremove.8.des b/man/pvremove.8.des
new file mode 100644
index 0000000..f12b76e
--- /dev/null
+++ b/man/pvremove.8.des
@@ -0,0 +1,2 @@
+pvremove wipes the label on a device so that LVM will no longer recognise
+it as a PV.
diff --git a/man/pvremove.8.in b/man/pvremove.8.in
deleted file mode 100644
index 6444884..0000000
--- a/man/pvremove.8.in
+++ /dev/null
@@ -1,37 +0,0 @@
-.TH PVREMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-pvremove \(em remove a physical volume
-.SH SYNOPSIS
-.B pvremove
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ \-f [ f ]| \-\-force 
-.RB [ \-\-force ]]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-y | \-\-yes ]
-.I PhysicalVolume
-.RI [ PhysicalVolume ...]
-.SH DESCRIPTION
-pvremove wipes the label on a device so that LVM will no longer
-recognise it as a physical volume.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-ff ", " \-\-force " " \-\-force
-Force the removal of a physical volume belonging to an existing volume group.
-Normally \fBvgreduce\fP(8) should be used instead of this command.
-You cannot remove a physical volume which in use by some active logical volume.
-.TP
-.BR \-y ", " \-\-yes
-Answer yes to all questions.
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR vgreduce (8)
diff --git a/man/pvresize.8.des b/man/pvresize.8.des
new file mode 100644
index 0000000..b3cfe63
--- /dev/null
+++ b/man/pvresize.8.des
@@ -0,0 +1,2 @@
+pvresize resizes a PV. The PV may already be in a VG and may have active
+LVs allocated on it.
diff --git a/man/pvresize.8.end b/man/pvresize.8.end
new file mode 100644
index 0000000..316e408
--- /dev/null
+++ b/man/pvresize.8.end
@@ -0,0 +1,16 @@
+.SH NOTES
+
+pvresize will refuse to shrink a PV if it has allocated extents beyond the
+new end.
+
+.SH EXAMPLES
+
+Expand a PV after enlarging the partition.
+.br
+.B pvresize /dev/sda1
+
+Shrink a PV prior to shrinking the partition (ensure that the PV size is
+appropriate for the intended new partition size).
+.br
+.B pvresize \-\-setphysicalvolumesize 40G /dev/sda1
+
diff --git a/man/pvresize.8.in b/man/pvresize.8.in
deleted file mode 100644
index b7d8f33..0000000
--- a/man/pvresize.8.in
+++ /dev/null
@@ -1,56 +0,0 @@
-.TH PVRESIZE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-pvresize \(em resize a disk or partition in use by LVM2
-.SH SYNOPSIS
-.B pvresize
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-setphysicalvolumesize
-.IR size ]
-.I PhysicalVolume 
-.RI [ PhysicalVolume ...]
-.SH DESCRIPTION
-pvresize resizes
-.I PhysicalVolume
-which may already be in a volume group and have active logical volumes
-allocated on it.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BI \-\-setphysicalvolumesize " size"
-Overrides the automatically-detected size of the PV.  Use with care, or
-prior to reducing the physical size of the device.
-.SH EXAMPLES
-Expand the PV on /dev/sda1 after enlarging the partition with fdisk:
-.sp
-.B pvresize /dev/sda1
-.sp
-Shrink the PV on /dev/sda1 prior to shrinking the partition with fdisk
-(ensure that the PV size is appropriate for your intended new partition
-size):
-.sp
-.B pvresize \-\-setphysicalvolumesize 40G /dev/sda1
-.sp
-.SH RESTRICTIONS
-pvresize will refuse to shrink
-.I PhysicalVolume
-if it has allocated extents after where its new end would be. In the future,
-it should relocate these elsewhere in the volume group if there is sufficient
-free space, like
-.B pvmove
-does.
-.sp
-.B pvresize
-won't currently work correctly on LVM1 volumes.
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvmove (8),
-.BR lvresize (8),
-.BR fdisk (8)
diff --git a/man/pvs.8.des b/man/pvs.8.des
new file mode 100644
index 0000000..08497ce
--- /dev/null
+++ b/man/pvs.8.des
@@ -0,0 +1 @@
+pvs produces formatted output about PVs.
diff --git a/man/pvs.8.end b/man/pvs.8.end
new file mode 100644
index 0000000..ba36a8b
--- /dev/null
+++ b/man/pvs.8.end
@@ -0,0 +1,11 @@
+.SH NOTES
+.
+The pv_attr bits are:
+.IP 1 3
+(d)uplicate, (a)llocatable, (u)sed
+.IP 2 3
+e(x)ported
+.IP 3 3
+(m)issing
+
+
diff --git a/man/pvs.8.in b/man/pvs.8.in
deleted file mode 100644
index 54f21c3..0000000
--- a/man/pvs.8.in
+++ /dev/null
@@ -1,153 +0,0 @@
-.TH PVS 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-pvs \(em report information about physical volumes
-.SH SYNOPSIS
-.B pvs
-.RB [ \-a | \-\-all ]
-.RB [ \-\-aligned ]
-.RB [ \-\-binary ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [[ \-\-configreport
-.IR ReportName ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field1 [, Field2 ...]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [, Key2 ...]]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB ...]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-logonly ]
-.RB [ \-\-nameprefixes ]
-.RB [ \-\-noheadings ]
-.RB [ \-\-nosuffix ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-rows ]
-.RB [ \-\-segments ]
-.RB [ \-\-separator
-.IR Separator ]
-.RB [ \-\-unbuffered ]
-.RB [ \-\-units
-.IR hHbBsSkKmMgGtTpPeE ]
-.RB [ \-\-unquoted ]
-.RB [ \-v|\-\-verbose ]
-.RB [ \-\-version]
-.RI [ PhysicalVolume
-.RI [ PhysicalVolume ...]]
-.SH DESCRIPTION
-pvs produces formatted output about physical volumes.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.B \-\-all
-Include information in the output about devices that have not been
-initialized with \fBpvcreate\fP(8).
-.TP
-.B \-\-aligned
-Use with \fB\-\-separator\fP to align the output columns.
-.TP
-.B \-\-binary
-Use binary values "0" or "1" instead of descriptive literal values
-for columns that have exactly two valid values to report (not counting
-the "unknown" value which denotes that the value could not be determined).
-.TP
-.B \-\-configreport  \fI ReportName
-Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
-\fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
-is either 'pv' for command's main report or 'log' for log report.
-If \fB\-\-configreport\fP option is not used to identify a report, then
-command's main report is assumed. The log report is available only if
-enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or
-if \fB\-\-logonly\fP option is used.
-.TP
-.B \-\-logonly
-Suppress the pvs report itself and display only log report on output.
-.TP
-.B \-\-nameprefixes
-Add an "LVM2_" prefix plus the field name to the output.  Useful
-with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
-be used to set environment variables (for example, in \fBudev\fP(7) rules).
-.TP
-.B \-\-noheadings
-Suppress the headings line that is normally the first line of output.
-Useful if grepping the output.
-.TP
-.B \-\-nosuffix
-Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
-(except h and H) if processing the output.
-.TP
-.BR \-o ", " \-\-options
-Comma-separated ordered list of columns.
-.IP
-Precede the list with '\fI+\fP' to append to the current list
-of columns, '\fI-\fP' to remove from the current list of columns
-or '\fI#\fP' to compact given columns. The \fI\-o\fP option can
-be repeated, providing several lists. These lists are evaluated
-from left to right.
-.IP
-Use \fB-o pv_all\fP to select all physical volume columns,
-and \fB-o pvseg_all\fP to select all Physical Volume segment columns.
-.IP
-Use \fB-o help\fP to view the full list of columns available.
-.IP
-Column names include: pv_fmt, pv_uuid, dev_size, pv_name, pv_mda_free,
-pv_mda_size, pv_ba_start, pv_ba_size, pe_start, pv_size, pv_free, pv_used,
-pv_attr, pv_pe_count, pv_pe_alloc_count, pv_tags, pv_mda_count,
-pv_mda_used_count, pvseg_start, and pvseg_size
-.IP
-With \fB\-\-segments\fP, any "pvseg_" prefixes are optional; otherwise any
-"pv_" prefixes are optional.  Columns mentioned in \fBvgs\fP(8) can also
-be chosen. The pv_attr bits are: @llocatable, e(x)ported, (m)issing,
-(u)sed (but not allocatable), (d)uplicate.
-.TP
-.B \-\-segments
-Produces one line of output for each contiguous allocation of space on each
-Physical Volume, showing the start (pvseg_start) and length (pvseg_size) in
-units of physical extents.
-.TP
-.BR  \-S ", " \-\-select " " \fISelection
-Display only rows that match Selection criteria. All rows are displayed with
-the additional "selected" column (\fB-o selected\fP) showing 1 if the row
-matches the Selection and 0 otherwise. The Selection criteria are defined
-by specifying column names and their valid values (that can include reserved
-values) while making use of supported comparison operators. See \fBlvm\fP(8)
-and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
-about constructing the Selection criteria. As a quick help and to see full
-list of column names that can be used in Selection including the list of
-reserved values and the set of supported selection operators, check the
-output of \fBpvs -S help\fP command.
-.TP
-.BR \-O ", " \-\-sort
-Comma-separated ordered list of columns to sort by.  Replaces the default
-selection. Precede any column with '\fI\-\fP' for a reverse sort on that
-column.
-.TP
-.B \-\-rows
-Output columns as rows.
-.TP
-.B \-\-separator \fISeparator
-String to use to separate each column.  Useful if grepping the output.
-.TP
-.B \-\-unbuffered
-Produce output immediately without sorting or aligning the columns properly.
-.TP
-.B \-\-units \fIhHbBsSkKmMgGtTpPeE
-All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
-Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify
-custom units e.g. \-\-units 3M
-.TP
-.B \-\-unquoted
-When used with \fB\-\-nameprefixes\fP, output values in the field=value
-pairs are not quoted.
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvdisplay (8),
-.BR lvs (8),
-.BR vgs (8)
diff --git a/man/pvscan.8.des b/man/pvscan.8.des
new file mode 100644
index 0000000..ab8c50c
--- /dev/null
+++ b/man/pvscan.8.des
@@ -0,0 +1,105 @@
+pvscan scans all supported LVM block devices in the system for PVs.
+
+\fBScanning with lvmetad\fP
+
+pvscan operates differently when used with the
+.BR lvmetad (8)
+daemon.
+
+Scanning disks is required to read LVM metadata and identify LVM PVs.
+Once read, lvmetad caches the metadata so that LVM commands can read it
+without repeatedly scanning disks.  This is helpful because scanning disks
+is time consuming, and frequent scanning may interfere with the normal
+work of the system and disks.
+
+When lvmetad is not used, LVM commands revert to scanning disks to read
+metadata.  Any LVM command that needs metadata will scan disks for it;
+running the pvscan command is not necessary for the sake of other LVM
+commands.
+
+When lvmetad is used, LVM commands avoid scanning disks by reading
+metadata from lvmetad.  When new disks appear, they must be scanned so
+their metadata can be cached in lvmetad.  This is done by the command
+pvscan \-\-cache, which scans disks and passes the metadata to lvmetad.
+
+The pvscan \-\-cache command is typically run automatically by system
+services when a new device appears.  Users do not generally need to run
+this command if the system and lvmetad are running properly.
+
+Many scripts contain unnecessary pvscan (or vgscan) commands for
+historical reasons.  To avoid disrupting the system with extraneous disk
+scanning, an ordinary pvscan (without \-\-cache) will simply read metadata
+from lvmetad like other LVM commands.  It does not do anything beyond
+displaying the current state of the cache.
+
+.IP \[bu] 2
+When given specific device name arguments, pvscan \-\-cache will only
+read the named devices.
+
+.IP \[bu] 2
+LVM udev rules and systemd services are used to initiate automatic device
+scanning.
+
+.IP \[bu] 2
+To prevent devices from being scanned by pvscan --cache, add them
+to
+.BR lvm.conf (5)
+.B devices/global_filter.
+The devices/filter setting does not
+apply to system level scanning.
+For more information, see:
+.br
+.B lvmconfig --withcomments devices/global_filter
+
+.IP \[bu] 2
+If lvmetad is started or restarted after devices are visible, or
+if the global_filter has changed, then all devices must be rescanned
+for metadata with the command pvscan \-\-cache.
+
+.IP \[bu] 2
+lvmetad does not cache older metadata formats, e.g. lvm1, and will
+be temporarily disabled if they are seen.
+
+.IP \[bu] 2
+To notify lvmetad about a device that is no longer present, the major and
+minor numbers must be given, not the path.
+
+.P
+
+\fBAutomatic activation\fP
+
+When event-driven system services detect a new LVM device, the first step
+is to automatically scan and cache the metadata from the device.  This is
+done by pvscan \-\-cache.  A second step is to automatically activate LVs
+that are present on the new device.  This auto-activation is done by the
+same pvscan \-\-cache command when the option '\-a|\-\-activate ay' is
+included.
+
+Auto-activation of VGs or LVs can be enabled/disabled using:
+.br
+.BR lvm.conf (5)
+.B activation/auto_activation_volume_list
+
+For more information, see:
+.br
+.B lvmconfig --withcomments activation/auto_activation_volume_list
+
+When this setting is undefined, all LVs are auto-activated (when lvm is
+fully integrated with the event-driven system services.)
+
+When a VG or LV is not auto-activated, traditional activation using
+vgchange or lvchange -a|--activate is needed.
+
+.IP \[bu] 2
+pvscan auto-activation can be only done in combination with \-\-cache.
+
+.IP \[bu] 2
+Auto-activation is designated by the "a" argument in '-a|--activate ay'.
+This is meant to distinguish system generated commands from explicit user
+commands, although it can be used in any activation command.  Whenever it
+is used, the auto_activation_volume_list is applied.
+
+.IP \[bu] 2
+Auto-activation is not yet supported for LVs that are part of partial or
+clustered volume groups.
+
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
deleted file mode 100644
index 5ff5fa5..0000000
--- a/man/pvscan.8.in
+++ /dev/null
@@ -1,178 +0,0 @@
-.TH PVSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-pvscan \(em scan all disks for physical volumes
-
-.SH SYNOPSIS
-.B pvscan
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-e | \-\-exported ]
-.RB [ \-n | \-\-novolumegroup ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-s | \-\-short ]
-.RB [ \-u | \-\-uuid ]
-.BR
-
-.B pvscan
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.B \-\-cache
-.RB [ \-a | \-\-activate " " \fIay ]
-.RB [ \-b | \-\-background ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-major
-.I major
-.B \-\-minor
-.I minor
-|
-.IR DevicePath
-|
-.IR major:minor ]...
-
-.SH DESCRIPTION
-pvscan scans all supported LVM block devices in the system for physical
-volumes.
-
-.SS Scanning with lvmetad
-
-pvscan operates differently when used with the
-.BR lvmetad (8)
-daemon.
-
-Scanning disks is required to read LVM metadata and identify LVM PVs.
-Once read, lvmetad caches the metadata so that LVM commands can read it
-without repeatedly scanning disks.  This is helpful because scanning disks
-is time consuming, and frequent scanning may interfere with the normal
-work of the system and disks.
-
-When lvmetad is not used, LVM commands revert to scanning disks to read
-metadata.  Any LVM command that needs metadata will scan disks for it;
-running the pvscan command is not necessary for the sake of other LVM
-commands.
-
-When lvmetad is used, LVM commands avoid scanning disks by reading
-metadata from lvmetad.  When new disks appear, they must be scanned so
-their metadata can be cached in lvmetad.  This is done by the command
-pvscan \-\-cache, which scans disks and passes the metadata to lvmetad.
-
-The pvscan \-\-cache command is typically run automatically by system
-services when a new device appears.  Users do not generally need to run
-this command if the system and lvmetad are running properly.
-
-Many scripts contain unnecessary pvscan (or vgscan) commands for
-historical reasons.  To avoid disrupting the system with extraneous disk
-scanning, an ordinary pvscan (without \-\-cache) will simply read metadata
-from lvmetad like other LVM commands.  It does not do anything beyond
-displaying the current state of the cache.
-
-.I Notes
-
-.IP \[bu] 2
-When given specific device name arguments, pvscan \-\-cache will only
-read the named devices.
-
-.IP \[bu] 2
-LVM udev rules and systemd services are used to initiate automatic device
-scanning.
-
-.IP \[bu] 2
-To prevent devices from being scanned by pvscan --cache, add them
-to
-.BR lvm.conf (5)
-.B devices/global_filter.
-The devices/filter setting does not
-apply to system level scanning.
-For more information, see:
-.br
-.B lvmconfig --withcomments devices/global_filter
-
-.IP \[bu] 2
-If lvmetad is started or restarted after devices are visible, or
-if the global_filter has changed, then all devices must be rescanned
-for metadata with the command pvscan \-\-cache.
-
-.IP \[bu] 2
-lvmetad does not cache older metadata formats, e.g. lvm1, and will
-be temporarily disabled if they are seen.
-
-.IP \[bu] 2
-To notify lvmetad about a device that is no longer present, the major and
-minor numbers must be given, not the path.
-
-.SS Automatic activation
-
-When event-driven system services detect a new LVM device, the first step
-is to automatically scan and cache the metadata from the device.  This is
-done by pvscan \-\-cache.  A second step is to automatically activate LVs
-that are present on the new device.  This auto-activation is done by the
-same pvscan \-\-cache command when the option '\-a|\-\-activate ay' is
-included.
-
-Auto-activation of VGs or LVs can be enabled/disabled using:
-.br
-.BR lvm.conf (5)
-.B activation/auto_activation_volume_list
-
-For more information, see:
-.br
-.B lvmconfig --withcomments activation/auto_activation_volume_list
-
-When this setting is undefined, all LVs are auto-activated (when lvm is
-fully integrated with the event-driven system services.)
-
-When a VG or LV is not auto-activated, traditional activation using
-vgchange or lvchange -a|--activate is needed.
-
-.I Notes
-
-.IP \[bu] 2
-pvscan auto-activation can be only done in combination with \-\-cache.
-
-.IP \[bu] 2
-Auto-activation is designated by the "a" argument in '-a|--activate ay'.
-This is meant to distinguish system generated commands from explicit user
-commands, although it can be used in any activation command.  Whenever it
-is used, the auto_activation_volume_list is applied.
-
-.IP \[bu] 2
-Auto-activation is not yet supported for LVs that are part of partial or
-clustered volume groups.
-
-.P
-
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-e ", " \-\-exported
-Only show physical volumes belonging to exported volume groups.
-.TP
-.BR \-n ", " \-\-novolumegroup
-Only show physical volumes not belonging to any volume group.
-.TP
-.BR \-s ", " \-\-short
-Short listing format.
-.TP
-.BR \-u ", " \-\-uuid
-Show UUIDs in addition to device names.
-.TP
-.BR \-a ", " \-\-activate " " \fIay
-Automatically activate any logical volumes that are possible to activate
-with the addition of the new devices.
-.TP
-.BR \-b ", " \-\-background
-Run the command in the background.
-.TP
-.BR \-\-cache " [" \-\-major " " \fImajor " " \-\-minor " " \fIminor " | " \fIDevicePath " | " \fImajor:minor " ]..."
-Scan one or more devices and send the metadata to lvmetad.
-
-.SH SEE ALSO
-.BR lvm (8),
-.BR lvmconfig (8),
-.BR lvmetad (8)
diff --git a/man/see_also.end b/man/see_also.end
new file mode 100644
index 0000000..70eeb89
--- /dev/null
+++ b/man/see_also.end
@@ -0,0 +1,67 @@
+.SH SEE ALSO
+
+.BR lvm (8)
+.BR lvm.conf (5)
+.BR lvmconfig (8)
+
+.BR pvchange (8)
+.BR pvck (8)
+.BR pvcreate (8)
+.BR pvdisplay (8)
+.BR pvmove (8)
+.BR pvremove (8)
+.BR pvresize (8)
+.BR pvs (8)
+.BR pvscan (8) 
+
+.BR vgcfgbackup (8)
+.BR vgcfgrestore (8)
+.BR vgchange (8)
+.BR vgck (8)
+.BR vgcreate (8)
+.BR vgconvert (8)
+.BR vgdisplay (8)
+.BR vgexport (8)
+.BR vgextend (8)
+.BR vgimport (8)
+.BR vgimportclone (8)
+.BR vgmerge (8)
+.BR vgmknodes (8)
+.BR vgreduce (8)
+.BR vgremove (8)
+.BR vgrename (8)
+.BR vgs (8)
+.BR vgscan (8)
+.BR vgsplit (8) 
+
+.BR lvcreate (8)
+.BR lvchange (8)
+.BR lvconvert (8)
+.BR lvdisplay (8)
+.BR lvextend (8)
+.BR lvreduce (8)
+.BR lvremove (8)
+.BR lvrename (8)
+.BR lvresize (8)
+.BR lvs (8)
+.BR lvscan (8)
+
+.BR lvm2-activation-generator (8)
+.BR blkdeactivate (8)
+.BR lvmdump (8)
+
+.BR dmeventd (8)
+.BR lvmetad (8)
+.BR lvmpolld (8)
+.BR lvmlockd (8)
+.BR lvmlockctl (8)
+.BR clvmd (8)
+.BR cmirrord (8)
+.BR lvmdbusd (8)
+
+.BR lvmsystemid (7)
+.BR lvmreport (7)
+.BR lvmraid (7)
+.BR lvmthin (7)
+.BR lvmcache (7)
+
diff --git a/man/vgcfgbackup.8.des b/man/vgcfgbackup.8.des
new file mode 100644
index 0000000..0720e01
--- /dev/null
+++ b/man/vgcfgbackup.8.des
@@ -0,0 +1,16 @@
+vgcfgbackup creates back up files containing metadata of VGs.
+If no VGs are named, back up files are created for all VGs.
+See \fBvgcfgrestore\fP for information on using the back up
+files.
+
+In a default installation, each VG is backed up into a separate file
+bearing the name of the VG in the directory \fI#DEFAULT_BACKUP_DIR#\fP.
+
+To use an alternative back up file, use \fB\-f\fP. In this case, when
+backing up multiple VGs, the file name is treated as a template, with %s
+replaced by the VG name.
+
+NB. This DOES NOT back up the data content of LVs.
+
+It may also be useful to regularly back up the files in
+\fI#DEFAULT_SYS_DIR#\fP.
diff --git a/man/vgcfgbackup.8.in b/man/vgcfgbackup.8.in
deleted file mode 100644
index c6f20d9..0000000
--- a/man/vgcfgbackup.8.in
+++ /dev/null
@@ -1,36 +0,0 @@
-.TH VGCFGBACKUP 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgcfgbackup \(em backup volume group descriptor area
-.SH SYNOPSIS
-.B vgcfgbackup
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-f | \-\-file
-.IR Filename ]
-.RB [ \-h | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-v | \-\-verbose ]
-.RI [ VolumeGroupName ...]
-.SH DESCRIPTION
-vgcfgbackup allows you to backup the metadata of your volume groups.
-If you don't name any volume groups on the command line, all of them
-will be backed up.
-.sp
-In a default installation, each volume group gets backed up into a separate
-file bearing the name of the volume group in the directory
-\fI#DEFAULT_BACKUP_DIR#\fP.
-You can write the backup to an alternative file using \fB\-f\fP.  In this case
-if you are backing up more than one volume group the filename is
-treated as a template, and %s gets replaced by the volume group name.
-.sp
-NB. This DOESN'T backup user/system data in logical
-volume(s)!  Backup \fI#DEFAULT_SYS_DIR#\fP regularly too.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgcfgrestore (8)
diff --git a/man/vgcfgrestore.8.des b/man/vgcfgrestore.8.des
new file mode 100644
index 0000000..cb7867d
--- /dev/null
+++ b/man/vgcfgrestore.8.des
@@ -0,0 +1,8 @@
+vgcfgrestore restores the metadata of a VG from a text back up file
+produced by \fBvgcfgbackup\fP. This writes VG metadata onto the devices
+specifed in back up file.
+
+A back up file can be specified with \fB\-\-file\fP.  If no backup file is
+specified, the most recent one is used. Use \fB\-\-list\fP for a list of
+the available back up and archive files of a VG.
+
diff --git a/man/vgcfgrestore.8.end b/man/vgcfgrestore.8.end
new file mode 100644
index 0000000..5ac451d
--- /dev/null
+++ b/man/vgcfgrestore.8.end
@@ -0,0 +1,9 @@
+.SH NOTES
+
+To replace PVs, \fBvgdisplay \-\-partial \-\-verbose\fP will show the
+UUIDs and sizes of any PVs that are no longer present. If a PV in the VG
+is lost and you wish to substitute another of the same size, use
+\fBpvcreate \-\-restorefile filename \-\-uuid uuid\fP (plus additional
+arguments as appropriate) to initialise it with the same UUID as the
+missing PV. Repeat for all other missing PVs in the VG.  Then use
+\fBvgcfgrestore \-\-file filename\fP to restore the VG's metadata.
diff --git a/man/vgcfgrestore.8.in b/man/vgcfgrestore.8.in
deleted file mode 100644
index 96b0a10..0000000
--- a/man/vgcfgrestore.8.in
+++ /dev/null
@@ -1,58 +0,0 @@
-.TH VGCFGRESTORE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgcfgrestore \(em restore volume group descriptor area
-.SH SYNOPSIS
-.B vgcfgrestore
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-f | \-\-file
-.RI < filename >]
-.RB [ \-\-force ]
-.RB [ \-l [ l ]| \-\-list ]
-.RB [ \-h | \-\-help ]
-.RB [ \-M | \-\-metadatatype
-.IR 1 | 2 ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RI \fIVolumeGroupName\fP
-.SH DESCRIPTION
-vgcfgrestore allows you to restore the metadata of \fIVolumeGroupName\fP
-from a text backup file produced by \fBvgcfgbackup\fP.
-You can specify a backup file with \fB\-\-file\fP.
-If no backup file is specified, the most recent
-one is used.  Use \fB\-\-list\fP for a list of the available
-backup and archive files of \fIVolumeGroupName\fP.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-l ", " \-\-list\fP
-List files pertaining to \fIVolumeGroupName\fP
-List metadata backup and archive files pertaining to \fIVolumeGroupName\fP.
-May be used with the \fB\-f\fP option.  Does not restore \fIVolumeGroupName\fP.
-.TP
-.BR \-f ", " \-\-file " " \fIfilename
-Name of LVM metadata backup file
-Specifies a metadata backup or archive file to be used for restoring 
-VolumeGroupName.  Often this file has been created with \fBvgcfgbackup\fP.
-.TP
-.B \-\-force
-Necessary to restore metadata with thin pool volumes.
-.br
-\fBWARNING: Use with extreme caution.
-Most changes to thin metadata cannot be reverted.
-You may lose data if you restore metadata that does not match the thin pool
-kernel metadata precisely.\fP
-.SH REPLACING PHYSICAL VOLUMES
-\fBvgdisplay \-\-partial \-\-verbose\fP will show you the UUIDs and sizes of
-any PVs that are no longer present.
-If a PV in the VG is lost and you wish to substitute 
-another of the same size, use 
-\fBpvcreate \-\-restorefile filename \-\-uuid uuid\fP (plus additional 
-arguments as appropriate) to initialise it with the same UUID as 
-the missing PV.  Repeat for all other missing PVs in the VG. 
-Then use \fBvgcfgrestore \-\-file filename\fP to restore the volume
-group's metadata.
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgcreate (8)
diff --git a/man/vgchange.8.des b/man/vgchange.8.des
new file mode 100644
index 0000000..6b873d8
--- /dev/null
+++ b/man/vgchange.8.des
@@ -0,0 +1,2 @@
+vgchange changes VG attributes, changes LV activation in the kernel, and
+includes other utilities for VG maintenance.
diff --git a/man/vgchange.8.end b/man/vgchange.8.end
new file mode 100644
index 0000000..a11bdd1
--- /dev/null
+++ b/man/vgchange.8.end
@@ -0,0 +1,16 @@
+.SH NOTES
+
+If vgchange recognizes COW snapshot LVs that were dropped because they ran
+out of space, it displays a message informing the administrator that the
+snapshots should be removed.
+
+.SH EXAMPLES
+
+Activate all LVs in all VGs on all existing devices.
+.br
+.B vgchange \-a y
+
+Change the maximum number of LVs for an inactive VG.
+.br
+.B vgchange \-l 128 vg00
+
diff --git a/man/vgchange.8.in b/man/vgchange.8.in
deleted file mode 100644
index 3b2fc3e..0000000
--- a/man/vgchange.8.in
+++ /dev/null
@@ -1,346 +0,0 @@
-.TH VGCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgchange \(em change attributes of a volume group
-.SH SYNOPSIS
-.B vgchange
-.RB [ \-\-addtag
-.IR Tag ]
-.RB [ \-\-alloc
-.IR AllocationPolicy ]
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-a | \-\-activate
-.RI [ a | e | s | l ]
-.RI { y | n }]
-.RB [ \-\-activationmode
-.IB { complete | degraded | partial } ]
-.RB [ \-K | \-\-ignoreactivationskip ]
-.RB [ \-\-monitor
-.RI { y | n }]
-.RB [ \-\-poll
-.RI { y | n }]
-.RB [ \-c | \-\-clustered
-.RI { y | n }]
-.RB [ \-u | \-\-uuid ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-\-deltag
-.IR Tag ]
-.RB [ \-\-detachprofile ]
-.RB [ \-h | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoremonitoring ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-sysinit ]
-.RB [ \-\-noudevsync ]
-.RB [ \-\-lock\-start ]
-.RB [ \-\-lock\-stop ]
-.RB [ \-\-lock\-type
-.IR LockType ]
-.RB [ \-l | \-\-logicalvolume
-.IR MaxLogicalVolumes ]
-.RB [ \-p | \-\-maxphysicalvolumes
-.IR MaxPhysicalVolumes ]
-.RB [ \-\-metadataprofile
-.IR ProfileName ]
-.RB [ \-\- [ vg ] metadatacopies
-.IR NumberOfCopies | unmanaged | all ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-s | \-\-physicalextentsize
-.IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-\-systemid
-.IR SystemID ]
-.RB [ \-\-refresh ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ \-x | \-\-resizeable
-.RI { y | n }]
-.RI [ VolumeGroupName ...]
-.SH DESCRIPTION
-vgchange allows you to change the attributes of one or more
-volume groups. Its main purpose is to activate and deactivate
-.IR VolumeGroupName ,
-or all volume groups if none is specified.  Only active volume groups
-are subject to changes and allow access to their logical volumes.
-[Not yet implemented: During volume group activation, if
-.B vgchange
-recognizes snapshot logical volumes which were dropped because they ran
-out of space, it displays a message informing the administrator that such
-snapshots should be removed (see
-.BR lvremove (8)).
-]
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-A ", " \-\-autobackup " {" \fIy | \fIn }
-Controls automatic backup of metadata after the change.  See
-.BR vgcfgbackup (8).
-Default is yes.
-.TP
-.BR \-a ", " \-\-activate " [" \fIa | \fIe | \fIs | \fIl ]{ \fIy | \fIn }
-Controls the availability of the logical volumes in the volume
-group for input/output.
-In other words, makes the logical volumes known/unknown to the kernel.
-If autoactivation option is used (\-aay), each logical volume in
-the volume group is activated only if it matches an item in the
-activation/auto_activation_volume_list set in lvm.conf. If this
-list is not set, then all volumes are considered for activation.
-The \-aay option should be also used during system boot so it's
-possible to select which volumes to activate using the
-activation/auto_activation_volume_list settting.
-.IP
-Activation of a logical volume creates a symbolic link 
-/dev/VolumeGroupName/LogicalVolumeName pointing to the device node.
-This link is removed on deactivation.
-All software and scripts should access the device through
-this symbolic link and present this as the name of the device.
-The location and name of the underlying device node may depend on   
-the distribution and configuration (e.g. udev) and might change 
-from release to release.
-.IP
-In a clustered VG, clvmd is used for activation, and the
-following options are possible:
-
-With \-aey, clvmd activates the LV in exclusive mode
-(with an exclusive lock), allowing a single node to activate the LV.
-
-With \-asy, clvmd activates the LV in shared mode
-(with a shared lock), allowing multiple nodes to activate the LV concurrently.
-If the LV type prohibits shared access, such as an LV with a snapshot,
-the 's' option is ignored and an exclusive lock is used.
-
-With \-ay (no mode specified), clvmd activates the LV in shared mode
-if the LV type allows concurrent access, such as a linear LV.
-Otherwise, clvmd activates the LV in exclusive mode.
-
-With \-aey, \-asy, and \-ay, clvmd attempts to activate the LV
-on all nodes.  If exclusive mode is used, then only one of the
-nodes will be successful.
-
-With \-an, clvmd attempts to deactivate the LV on all nodes.
-
-With \-aly, clvmd activates the LV only on the local node, and \-aln
-deactivates only on the local node.  If the LV type allows concurrent
-access, then shared mode is used, otherwise exclusive.
-
-LVs with snapshots are always activated exclusively because they can only
-be used on one node at once.
-
-For local VGs, \-ay, \-aey, and \-asy are all equivalent.
-.IP
-In a shared VG, lvmlockd is used for locking if LVM is compiled with lockd
-support, and the following options are possible:
-
-With \-aey, the command activates the LV in exclusive mode, allowing a
-single host to activate the LV (the host running the command).  Before
-activating the LV, the command uses lvmlockd to acquire an exclusive lock
-on the LV.  If the lock cannot be acquired, the LV is not activated and an
-error is reported.  This would happen if the LV is active on another host.
-
-With \-asy, the command activates the LV in shared mode, allowing multiple
-hosts to activate the LV concurrently.  Before activating the LV, the
-command uses lvmlockd to acquire a shared lock on the LV.  If the lock
-cannot be acquired, the LV is not activated and an error is reported.
-This would happen if the LV is active exclusively on another host.  If the
-LV type prohibits shared access, such as a snapshot, the command will
-report an error and fail.
-
-With \-an, the command deactivates the LV on the host running the command.
-After deactivating the LV, the command uses lvmlockd to release the
-current lock on the LV.
-
-With lvmlockd, an unspecified mode is always exclusive, \-ay defaults to
-\-aey.
-
-.TP
-.BR \-\-activationmode " {" \fIcomplete | \fIdegraded | \fIpartial }
-The activation mode determines whether logical volumes are allowed to
-activate when there are physical volumes missing (e.g. due to a device
-failure).  \fIcomplete\fP is the most restrictive; allowing only those
-logical volumes to be activated that are not affected by the missing
-PVs.  \fIdegraded\fP allows RAID logical volumes to be activated even if
-they have PVs missing.  (Note that the "mirror" segment type is not
-considered a RAID logical volume.  The "raid1" segment type should
-be used instead.)  Finally, \fIpartial\fP allows any logical volume to
-be activated even if portions are missing due to a missing or failed
-PV.  This last option should only be used when performing recovery or
-repair operations.  \fIdegraded\fP is the default mode.  To change it, modify
-.B activation_mode
-in
-.BR lvm.conf (5).
-.TP
-.BR \-K ", " \-\-ignoreactivationskip
-Ignore the flag to skip Logical Volumes during activation.
-.TP
-.BR \-c ", " \-\-clustered " {" \fIy | \fIn }
-If clustered locking is enabled, this indicates whether this
-Volume Group is shared with other nodes in the cluster or whether
-it contains only local disks that are not visible on the other nodes.
-If the cluster infrastructure is unavailable on a particular node at a
-particular time, you may still be able to use Volume Groups that
-are not marked as clustered.
-.TP
-.BR \-\-detachprofile
-Detach any metadata configuration profiles attached to given
-Volume Groups. See \fBlvm.conf\fP(5) for more information
-about \fBmetadata profiles\fP.
-.TP
-.BR \-u ", " \-\-uuid
-Generate new random UUID for specified Volume Groups.
-.TP
-.BR \-\-monitor " {" \fIy | \fIn }
-Start or stop monitoring a mirrored or snapshot logical volume with
-dmeventd, if it is installed.
-If a device used by a monitored mirror reports an I/O error,
-the failure is handled according to
-.B mirror_image_fault_policy
-and
-.B mirror_log_fault_policy
-set in
-.BR lvm.conf (5).
-.TP
-.BR \-\-poll " {" \fIy | \fIn }
-Without polling a logical volume's backgrounded transformation process
-will never complete.  If there is an incomplete pvmove or lvconvert (for
-example, on rebooting after a crash), use \fB\-\-poll y\fP to restart the
-process from its last checkpoint.  However, it may not be appropriate to
-immediately poll a logical volume when it is activated, use 
-\fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
-.TP
-.BR \-\-sysinit
-Indicates that vgchange(8) is being invoked from early system initialisation
-scripts (e.g. rc.sysinit or an initrd), before writeable filesystems are
-available. As such, some functionality needs to be disabled and this option
-acts as a shortcut which selects an appropriate set of options. Currently
-this is equivalent to using
-.BR \-\-ignorelockingfailure ,
-.BR \-\-ignoremonitoring ,
-.B \-\-poll n
-and setting \fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
-environment variable.
-
-If \fB\-\-sysinit\fP is used in conjunction with lvmetad(8) enabled and running,
-autoactivation is preferred over manual activation via direct vgchange call.
-Logical volumes are autoactivated according to auto_activation_volume_list
-set in lvm.conf(5).
-.TP
-.BR \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.TP
-.BR \-\-ignoremonitoring
-Make no attempt to interact with dmeventd unless
-.BR \-\-monitor
-is specified.
-Do not use this if dmeventd is already monitoring a device.
-.TP
-.BR \-\-lock\-start
-Start the lockspace of a shared VG in lvmlockd.  lvmlockd locks becomes
-available for the VG, allowing LVM to use the VG.  See
-.BR lvmlockd (8).
-.TP
-.BR \-\-lock\-stop
-Stop the lockspace of a shared VG in lvmlockd.  lvmlockd locks become
-unavailable for the VG, preventing LVM from using the VG.  See
-.BR lvmlockd (8).
-.TP
-.BR \-\-lock\-type " " \fILockType
-Change the VG lock type to or from a shared lock type used with lvmlockd.  See
-.BR lvmlockd (8).
-.TP
-.BR \-l ", " \-\-logicalvolume " " \fIMaxLogicalVolumes
-Changes the maximum logical volume number of an existing inactive
-volume group.
-.TP
-.BR \-p ", " \-\-maxphysicalvolumes " " \fIMaxPhysicalVolumes
-Changes the maximum number of physical volumes that can belong
-to this volume group.
-For volume groups with metadata in lvm1 format, the limit is 255.
-If the metadata uses lvm2 format, the value 0 removes this restriction:
-there is then no limit.  If you have a large number of physical volumes in
-a volume group with metadata in lvm2 format, for tool performance reasons,
-you should consider some use of \fB\-\-pvmetadatacopies 0\fP as described in
-\fBpvcreate(8)\fP, and/or use \fB\-\-vgmetadatacopies\fP.
-.TP
-.BR \-\-metadataprofile " " \fIProfileName
-Uses and attaches ProfileName configuration profile to the volume group
-metadata. Whenever the volume group is processed next time, the profile
-is automatically applied. The profile is inherited by all logical volumes
-in the volume group unless the logical volume itself has its own profile
-attached. See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
-.TP
-.BR \-\- [ vg ] metadatacopies " " \fINumberOfCopies | \fIunmanaged | \fIall
-Sets the desired number of metadata copies in the volume group.  If set to
-a non-zero value, LVM will automatically manage the 'metadataignore'
-flags on the physical volumes (see \fBpvchange\fP or \fBpvcreate \-\-metadataignore\fP) in order
-to achieve \fINumberOfCopies\fP copies of metadata.  If set to \fIunmanaged\fP,
-LVM will not automatically manage the 'metadataignore' flags.  If set to
-\fIall\fP, LVM will first clear all of the 'metadataignore' flags on all
-metadata areas in the volume group, then set the value to \fIunmanaged\fP.
-The \fBvgmetadatacopies\fP option is useful for volume groups containing
-large numbers of physical volumes with metadata as it may be used to
-minimize metadata read and write overhead.
-.TP
-.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize [ \fIBbBsSkKmMgGtTpPeE ]
-Changes the physical extent size on physical volumes of this volume group.
-A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
-is the default if no suffix is present.  For LVM2 format, the value must be a
-power of 2 of at least 1 sector (where the sector size is the largest sector
-size of the PVs currently used in the VG) or, if not a power of 2, at least
-128KiB.  For the older LVM1 format, it must be a power of 2 of at least 8KiB.
-The default is 4 MiB.
-
-Before increasing the physical extent size, you might need to use lvresize,
-pvresize and/or pvmove so that everything fits.  For example, every
-contiguous range of extents used in a logical volume must start and
-end on an extent boundary.
-
-If the volume group metadata uses lvm1 format, extents can vary in size from
-8KiB to 16GiB and there is a limit of 65534 extents in each logical volume.
-The default of 4 MiB leads to a maximum logical volume size of around 256GiB.
-
-If the volume group metadata uses lvm2 format those restrictions do not apply,
-but having a large number of extents will slow down the tools but have no
-impact on I/O performance to the logical volume.  The smallest PE is 1KiB.
-
-The 2.4 kernel has a limitation of 2TiB per block device.
-.TP
-.BR \-\-systemid " " \fISystemID
-Changes the system ID of the VG.  Using this option requires caution
-because the VG may become foreign to the host running the command,
-leaving the host unable to access it.  See
-.BR lvmsystemid (7).
-.TP
-.BR \-\-refresh
-If any logical volume in the volume group is active, reload its metadata.
-This is not necessary in normal operation, but may be useful
-if something has gone wrong or if you're doing clustering
-manually without a clustered lock manager.
-.TP
-.BR \-x ", " \-\-resizeable " {" \fIy | \fIn }
-Enables or disables the extension/reduction of this volume group
-with/by physical volumes.
-.SH Examples
-To activate all known volume groups in the system:
-.sp
-.B vgchange \-a y
-
-To change the maximum number of logical volumes of inactive volume group
-vg00 to 128.
-.sp
-.B vgchange \-l 128 /dev/vg00
-
-
-.SH SEE ALSO
-.BR lvchange (8),
-.BR lvm (8),
-.BR vgcreate (8)
diff --git a/man/vgck.8.des b/man/vgck.8.des
new file mode 100644
index 0000000..24e1dbe
--- /dev/null
+++ b/man/vgck.8.des
@@ -0,0 +1 @@
+vgck checks LVM metadata for consistency.
diff --git a/man/vgck.8.in b/man/vgck.8.in
deleted file mode 100644
index b10f57e..0000000
--- a/man/vgck.8.in
+++ /dev/null
@@ -1,22 +0,0 @@
-.TH VGCK 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgck \(em check volume group metadata
-.SH SYNOPSIS
-.B vgck
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-v | \-\-verbose ]
-.RI [ VolumeGroupName ...]
-.SH DESCRIPTION
-vgck checks LVM metadata for each named volume group for consistency.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgcreate (8),
-.BR vgchange (8),
-.BR vgscan (8)
diff --git a/man/vgconvert.8.des b/man/vgconvert.8.des
new file mode 100644
index 0000000..47bc0cc
--- /dev/null
+++ b/man/vgconvert.8.des
@@ -0,0 +1,7 @@
+vgconvert converts VG metadata from one format to another.  The new
+metadata format must be able to fit into the space provided by the old
+format.
+
+Because the LVM1 format should no longer be used, this command is no
+longer needed in general.
+
diff --git a/man/vgconvert.8.in b/man/vgconvert.8.in
deleted file mode 100644
index d864483..0000000
--- a/man/vgconvert.8.in
+++ /dev/null
@@ -1,48 +0,0 @@
-.TH VGCONVERT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgconvert \- convert volume group metadata format
-.SH SYNOPSIS
-.B vgconvert
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-labelsector ]
-.RB [ \-\-bootloaderareasize
-.IR size ]
-.RB [ \-M | \-\-metadatatype
-.IR type ]
-.RB [ \-\-pvmetadatacopies
-.IR NumberOfCopies ]
-.RB [ \-\-metadatasize
-.IR size ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-version ]
-.I VolumeGroupName
-.RI [ VolumeGroupName ...]
-.SH DESCRIPTION
-vgconvert converts
-.I VolumeGroupName
-metadata from one format to another provided that the metadata
-fits into the same space.
-.SH OPTIONS
-See \fBlvm\fP(8) and \fBpvcreate\fP(8) for options.
-.SH Examples
-Convert volume group vg1 from LVM1 metadata format to the new LVM2
-metadata format.
-.sp
-.B vgconvert \-M2 vg1
-.SH RECOVERY
-Use \fBpvscan\fP(8) to see which PVs lost their metadata.
-Run \fBpvcreate\fP(8) with the \fB\-\-uuid\fP and \fB\-\-restorefile\fP
-options on each such PV to reformat it as it was, using the archive
-file that \fBvgconvert\fP(8) created at the start of the procedure.
-Finally run \fBvgcfgrestore\fP(8) with that archive file to restore
-the original metadata.
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvcreate (8),
-.BR vgcfgrestore (8)
diff --git a/man/vgcreate.8.des b/man/vgcreate.8.des
new file mode 100644
index 0000000..a2d7161
--- /dev/null
+++ b/man/vgcreate.8.des
@@ -0,0 +1,4 @@
+vgcreate creates a new VG on block devices. If the devices were not
+previously intialized as PVs with \fBpvcreate\fP(8), vgcreate will
+inititialize them, making them PVs. The pvcreate options for initializing
+devices are also available with vgcreate.
diff --git a/man/vgcreate.8.end b/man/vgcreate.8.end
new file mode 100644
index 0000000..66bcfbb
--- /dev/null
+++ b/man/vgcreate.8.end
@@ -0,0 +1,6 @@
+.SH EXAMPLES
+
+Create a VG with two PVs, using the default physical extent size.
+.br
+.B vgcreate myvg /dev/sdk1 /dev/sdl1
+
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
deleted file mode 100644
index c66753b..0000000
--- a/man/vgcreate.8.in
+++ /dev/null
@@ -1,187 +0,0 @@
-.TH VGCREATE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgcreate \(em create a volume group
-.SH SYNOPSIS
-.B vgcreate
-.RB [ \-\-addtag
-.IR Tag ]
-.RB [ \-\-alloc
-.IR AllocationPolicy ]
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-c | \-\-clustered
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-l | \-\-maxlogicalvolumes
-.IR MaxLogicalVolumes ]
-.RB [ \-M | \-\-metadatatype
-.IR type ]
-.RB [ \-\-metadataprofile
-.IR ProfileName ]
-.RB [ \-p | \-\-maxphysicalvolumes
-.IR MaxPhysicalVolumes ]
-.RB [ \-\- [ vg ] metadatacopies
-.IR NumberOfCopies | unmanaged | all ]
-.RB [ \-s | \-\-physicalextentsize
-.IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-shared ]
-.RB [ \-\-systemid
-.IR SystemID ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RB [ "PHYSICAL DEVICE OPTIONS" ]
-.I VolumeGroupName PhysicalDevicePath
-.RI [ PhysicalDevicePath ...]
-.SH DESCRIPTION
-vgcreate creates a new volume group called
-.I VolumeGroupName
-using the block special device \fIPhysicalDevicePath\fP.
-.sp
-If \fIPhysicalDevicePath\fP was not previously configured for LVM with
-\fBpvcreate\fP(8), the device will be initialized with the same
-default values used with \fBpvcreate\fP(8).  If non-default
-\fPpvcreate\fP values are desired, they may be given on the
-commandline with the same options as \fBpvcreate\fP(8).  See
-.B PHYSICAL DEVICE OPTIONS
-for available options.  Note that the restore-related options such as
-.BR \-\-restorefile ", " \-\-uuid " and " \-\-physicalvolumesize
-are not available.  If a restore operation is needed, use 
-\fBpvcreate\fP(8) and \fBvgcfgrestore\fP(8).
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-c ", " \-\-clustered " {" \fIy | \fIn }
-If clustered locking is enabled, this defaults to \fBy\fP indicating that
-this Volume Group is shared with other nodes in the cluster.
-
-If the new Volume Group contains only local disks that are not visible
-on the other nodes, you must specify \fB\-\-clustered\ n\fP.
-If the cluster infrastructure is unavailable on a particular node at a
-particular time, you may still be able to use such Volume Groups.
-.TP
-.BR \-l ", " \-\-maxlogicalvolumes " " \fIMaxLogicalVolumes
-Sets the maximum number of logical volumes allowed in this
-volume group.
-The setting can be changed with \fBvgchange\fP(8).
-For volume groups with metadata in lvm1 format, the limit
-and default value is 255.
-If the metadata uses lvm2 format, the default value is 0
-which removes this restriction: there is then no limit.
-.TP
-.BR \-p ", " \-\-maxphysicalvolumes " " \fIMaxPhysicalVolumes
-Sets the maximum number of physical volumes that can belong
-to this volume group.
-The setting can be changed with \fBvgchange\fP.
-For volume groups with metadata in lvm1 format, the limit
-and default value is 255.
-If the metadata uses lvm2 format, the value 0 removes this restriction:
-there is then no limit.  If you have a large number of physical volumes in
-a volume group with metadata in lvm2 format, for tool performance reasons,
-you should consider some use of \fB\-\-pvmetadatacopies 0\fP as described in
-\fBpvcreate\fP(8), and/or use \fB\-\-vgmetadatacopies\fP.
-.TP
-.BR \-\- [ vg ] metadatacopies " " \fINumberOfCopies | \fIunmanaged | \fIall
-Sets the desired number of metadata copies in the volume group.  If set to
-a non-zero value, LVM will automatically manage the 'metadataignore'
-flags on the physical volumes (see \fBpvcreate\fP(8) or
-\fBpvchange \-\-metadataignore\fP) in order
-to achieve \fINumberOfCopies\fP copies of metadata.  If set to \fIunmanaged\fP,
-LVM will not automatically manage the 'metadataignore' flags.  If set to
-\fIall\fP, LVM will first clear all of the 'metadataignore' flags on all
-metadata areas in the volume group, then set the value to \fIunmanaged\fP.
-The \fBvgmetadatacopies\fP option is useful for volume groups containing
-large numbers of physical volumes with metadata as it may be used to
-minimize metadata read and write overhead.
-The default value is \fIunmanaged\fP.
-.TP
-.BR \-\-metadataprofile " " \fIProfileName
-Uses and attaches the ProfileName configuration profile to the volume group
-metadata. Whenever the volume group is processed next time, the profile is
-automatically applied. The profile is inherited by all logical volumes in
-the volume group unless the logical volume itself has its own profile attached.
-See \fBlvm.conf\fP(5) for more information about \fBmetadata profiles\fP.
-.TP
-.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize [ \fIbBsSkKmMgGtTpPeE ]
-Sets the physical extent size on physical volumes of this volume group.
-A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
-is the default if no suffix is present. For LVM2 format, the value must be a
-power of 2 of at least 1 sector (where the sector size is the largest sector
-size of the PVs currently used in the VG) or, if not a power of 2, at least
-128KiB.  For the older LVM1 format, it must be a power of 2 of at least 8KiB.
-The default is 4 MiB.
-Once this value has been set, it is difficult to change it without recreating
-the volume group which would involve backing up and restoring data on any
-logical volumes.  However, if no extents need moving for the new
-value to apply, it can be altered using \fBvgchange \-s\fP.
-
-If the volume group metadata uses lvm1 format, extents can vary in size from
-8KiB to 16GiB and there is a limit of 65534 extents in each logical volume.  The
-default of 4 MiB leads to a maximum logical volume size of around 256GiB.
-
-If the volume group metadata uses lvm2 format those restrictions do not apply,
-but having a large number of extents will slow down the tools but have no
-impact on I/O performance to the logical volume.  The smallest PE is 1KiB
-
-The 2.4 kernel has a limitation of 2TiB per block device.
-
-.TP
-.B \-\-shared
-Create a shared VG using lvmlockd if LVM is compiled with lockd support.
- lvmlockd will select lock type sanlock or dlm depending on which lock
-manager is running.  This allows multiple hosts to share a VG on shared
-devices.  lvmlockd and a lock manager must be configured and running.  See
-.BR lvmlockd (8).
-
-.TP
-.BR \-\-systemid " " \fISystemID
-Specifies the system ID that will be given to the new VG, overriding the
-system ID of the host running the command.  A VG is normally created
-without this option, in which case the new VG is given the system ID of
-the host creating it.  Using this option requires caution because the
-system ID of the new VG may not match the system ID of the host running
-the command, leaving the VG inaccessible to the host.  See
-.BR lvmsystemid (7).
-
-.SH PHYSICAL DEVICE OPTIONS
-The following options are available for initializing physical devices in the
-volume group.  These options are further described in the \fBpvcreate\fP(8)
-man page.
-.TP
-.BR \-f ", " \-\-force
-.TP
-.BR \-y ", " \-\-yes
-.TP
-.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
-.TP
-.B \-\-labelsector \fIsector
-.TP
-.B \-\-metadatasize \fIsize
-.TP
-.B \-\-pvmetadatacopies \fIcopies
-.TP
-.B \-\-dataalignment \fIalignment
-.TP
-.B \-\-dataalignmentoffset \fIalignment_offset
-.SH Examples
-Creates a volume group named "test_vg" using physical volumes "/dev/sdk1"
-and "/dev/sdl1" with default physical extent size of 4MiB:
-.sp
-.B vgcreate test_vg /dev/sdk1 /dev/sdl1
-
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvdisplay (8),
-.BR pvcreate (8),
-.BR vgdisplay (8),
-.BR vgextend (8),
-.BR vgreduce (8),
-.BR lvcreate (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvreduce (8)
diff --git a/man/vgdisplay.8.des b/man/vgdisplay.8.des
new file mode 100644
index 0000000..c42f821
--- /dev/null
+++ b/man/vgdisplay.8.des
@@ -0,0 +1,4 @@
+vgdisplay shows the attributes of VGs, and the associated PVs and LVs.
+
+\fBvgs\fP(8) is a preferred alternative that shows the same information
+and more, using a more compact and configurable output format.
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
deleted file mode 100644
index 045a6ae..0000000
--- a/man/vgdisplay.8.in
+++ /dev/null
@@ -1,123 +0,0 @@
-.TH VGDISPLAY 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgdisplay \(em display attributes of volume groups
-.SH SYNOPSIS
-.B vgdisplay
-.RB [ \-A | \-\-activevolumegroups ]
-.RB [ \-c | \-\-colon ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-s | \-\-short ]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-nosuffix ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-units
-.IR hHbBsSkKmMgGtTpPeE ]
-.RB [ \-\-version ]
-.RI [ VolumeGroupName ...]
-.br
-
-.br
-.B vgdisplay
-.BR \-C | \-\-columns
-.RB [ \-\-aligned ]
-.RB [ \-\-binary ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [[ \-\-configreport
-.IR ReportName ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field1 [, Field2 ...]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [, Key2 ...]]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB ...]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-logonly ]
-.RB [ \-\-noheadings ]
-.RB [ \-\-nosuffix ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-separator
-.IR Separator ]
-.RB [ \-\-unbuffered ]
-.RB [ \-\-units
-.IR hHbBsSkKmMgGtTpPeE ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RI [ VolumeGroupName ...]
-.SH DESCRIPTION
-vgdisplay allows you to see the attributes of
-.I VolumeGroupName
-(or all volume groups if none is given) with it's physical and logical
-volumes and their sizes etc.
-.P
-\fBvgs\fP(8) is an alternative that provides the same information
-in the style of \fBps\fP(1).
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-A ", " \-\-activevolumegroups
-Only select the active volume groups. The volume group is considered active
-if at least one of its logical volumes is active.
-.TP
-.BR \-C ", " \-\-columns
-Display output in columns, the equivalent of \fBvgs\fP(8). 
-Options listed are the same as options given in \fPvgs\fP(8).
-.TP
-.BR \-c ", " \-\-colon
-Generate colon separated output for easier parsing in scripts or programs.
-N.B. \fBvgs\fP(8) provides considerably more control over the output.
-.nf
-
-The values are:
-
-1  volume group name
-2  volume group access
-3  volume group status
-4  internal volume group number
-5  maximum number of logical volumes
-6  current number of logical volumes
-7  open count of all logical volumes in this volume group
-8  maximum logical volume size
-9  maximum number of physical volumes
-10 current number of physical volumes
-11 actual number of physical volumes
-12 size of volume group in kilobytes
-13 physical extent size
-14 total number of physical extents for this volume group
-15 allocated number of physical extents for this volume group
-16 free number of physical extents for this volume group
-17 uuid of volume group
-
-.fi
-.TP
-.BR \-s ", " \-\-short
-Give a short listing showing the existence of volume groups.
-.TP
-.BR \-v ", " \-\-verbose
-Display verbose information containing long listings of physical
-and logical volumes.  If given twice, also display verbose runtime
-information of vgdisplay's activities.
-.TP
-.B \-\-version
-Display version and exit successfully.
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgs (8),
-.BR pvcreate (8),
-.BR vgcreate (8),
-.BR lvcreate (8)
diff --git a/man/vgexport.8.des b/man/vgexport.8.des
new file mode 100644
index 0000000..f9fa49c
--- /dev/null
+++ b/man/vgexport.8.des
@@ -0,0 +1,8 @@
+vgexport makes inactive VGs unknown to the system. In this state, all the
+PVs in the VG can be moved to a different system, from which
+\fBvgimport\fP can then be run.
+
+Most LVM tools ignore exported VGs.
+
+vgexport clears the VG system ID, and vgimport sets the VG system ID to
+match the host running vgimport (if the host has a system ID).
diff --git a/man/vgexport.8.in b/man/vgexport.8.in
deleted file mode 100644
index 6e2ecbf..0000000
--- a/man/vgexport.8.in
+++ /dev/null
@@ -1,37 +0,0 @@
-.TH VGEXPORT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgexport \- make volume groups unknown to the system
-.SH SYNOPSIS
-.B vgexport
-.RB [ \-a | \-\-all ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-v | \-\-verbose ]
-.RI [ VolumeGroupName ...]
-.SH DESCRIPTION
-vgexport allows you to make the inactive
-.IR VolumeGroupName (s)
-unknown to the system.
-You can then move all the Physical Volumes in that Volume Group to
-a different system for later
-.BR vgimport (8).
-Most LVM2 tools ignore exported Volume Groups.
-vgexport clears the VG system ID, and vgimport sets the VG system ID
-to match the host running vgimport (if the host has a system ID).
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-a ", " \-\-all
-Export all inactive Volume Groups.
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvscan (8),
-.BR vgimport (8),
-.BR vgscan (8),
-.BR lvmsystemid (7)
diff --git a/man/vgextend.8.des b/man/vgextend.8.des
new file mode 100644
index 0000000..85fe6fc
--- /dev/null
+++ b/man/vgextend.8.des
@@ -0,0 +1,11 @@
+vgextend adds one or more PVs to a VG. This increases the space available
+for LVs in the VG.
+
+Also, PVs that have gone missing and then returned, e.g. due to a
+transient device failure, can be added back to the VG without
+re-initializing them (see \-\-restoremissing).
+
+If the specified PVs have not yet been initialized with pvcreate, vgextend
+will initialize them. In this case pvcreate options can be used, e.g.
+\-\-labelsector, \-\-metadatasize, \-\-metadataignore,
+\-\-pvmetadatacopies, \-\-dataalignment, \-\-dataalignmentoffset.
diff --git a/man/vgextend.8.end b/man/vgextend.8.end
new file mode 100644
index 0000000..e50fcce
--- /dev/null
+++ b/man/vgextend.8.end
@@ -0,0 +1,6 @@
+.SH EXAMPLES
+
+Add two PVs to a VG.
+.br
+.B vgextend vg00 /dev/sda4 /dev/sdn1
+
diff --git a/man/vgextend.8.in b/man/vgextend.8.in
deleted file mode 100644
index 51bd615..0000000
--- a/man/vgextend.8.in
+++ /dev/null
@@ -1,71 +0,0 @@
-.TH VGEXTEND 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgextend \(em add physical volumes to a volume group
-.SH SYNOPSIS
-.B vgextend
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-restoremissing ]
-.RB [ \-f | \-\-force ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RB [ "PHYSICAL DEVICE OPTIONS" ]
-.I VolumeGroupName PhysicalDevicePath
-.RI [ PhysicalDevicePath ...]
-.SH DESCRIPTION
-vgextend allows you to add one or more initialized physical volumes
-(see \fBpvcreate\fP(8)) to an existing volume group to extend it in size. Moreover, it allows you to
-re-add a physical volume that has gone missing previously, due to a transient
-device failure, without re-initialising it. Use
-\fBvgextend \-\-restoremissing\fP to that effect.
-.sp
-If \fIPhysicalDevicePath\fP was not previously configured for LVM with
-\fBpvcreate\fP(8), the device will be initialized with the same
-default values used with \fBpvcreate\fP(8).  If non-default
-\fPpvcreate\fP(8) values are desired, they may be given on the
-commandline with the same options as \fPpvcreate\fP(8).  See
-.B PHYSICAL DEVICE OPTIONS
-for available options.  Note that the restore-related options such as
-.BR \-\-restorefile ", " \-\-uuid " and " \-\-physicalvolumesize
-are not available.  If a restore operation
-is needed, use \fBpvcreate\fP(8) and \fBvgcfgrestore\fP(8).
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.SH PHYSICAL DEVICE OPTIONS
-The following options are available for initializing physical devices in the
-volume group.  These options are further described in the
-\fBpvcreate\fP(8) man page.
-.TP
-.BR \-f ", " \-\-force
-.TP
-.BR \-y ", " \-\-yes
-.TP
-.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
-.TP
-.B \-\-labelsector \fIsector
-.TP
-.B \-\-metadatasize \fIsize
-.TP
-.BR \-\-metadataignore " {" \fIy | \fIn }
-.TP
-.B \-\-pvmetadatacopies \fIcopies
-.TP
-.B \-\-dataalignment \fIalignment
-.TP
-.B \-\-dataalignmentoffset \fIalignment_offset
-.SH Examples
-Extends the existing volume group "vg00" by the new physical volumes
-(see \fBpvcreate\fP(8)) "/dev/sda4" and "/dev/sdn1".
-.sp
-.B vgextend vg00 /dev/sda4 /dev/sdn1
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgcreate (8),
-.BR vgreduce (8),
-.BR pvcreate (8)
diff --git a/man/vgimport.8.des b/man/vgimport.8.des
new file mode 100644
index 0000000..91196b6
--- /dev/null
+++ b/man/vgimport.8.des
@@ -0,0 +1,5 @@
+vgimport makes exported VGs known to the system again, perhaps after
+moving the PVs from a different system.
+
+vgexport clears the VG system ID, and vgimport sets the VG system ID to
+match the host running vgimport (if the host has a system ID).
diff --git a/man/vgimport.8.in b/man/vgimport.8.in
deleted file mode 100644
index ba4fdf9..0000000
--- a/man/vgimport.8.in
+++ /dev/null
@@ -1,38 +0,0 @@
-.TH VGIMPORT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgimport \(em make exported volume groups known to the system
-.SH SYNOPSIS
-.B vgimport
-.RB [ \-a | \-\-all ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-v | \-\-verbose ]
-.RI [ VolumeGroupName ...]
-.SH DESCRIPTION
-vgimport allows you to make a Volume Group that was previously
-exported using
-.BR vgexport (8)
-known to the system again, perhaps after moving its Physical Volumes
-from a different machine.
-vgexport clears the VG system ID, and vgimport sets the VG system ID
-to match the host running vgimport (if the host has a system ID).
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-a ", " \-\-all
-Import all exported Volume Groups.
-.TP
-.BR \-\-force
-Import exported Volume Groups even if there are missing Physical Volumes.
-This option should only be used if the missing devices are known to have
-failed and they cannot be restored.
-.SH SEE ALSO
-.BR lvm (8),
-.BR pvscan (8),
-.BR vgexport (8),
-.BR vgscan (8),
-.BR lvmsystemid (7)
diff --git a/man/vgimportclone.8.des b/man/vgimportclone.8.des
new file mode 100644
index 0000000..a5002da
--- /dev/null
+++ b/man/vgimportclone.8.des
@@ -0,0 +1,6 @@
+vgimportclone imports a VG from duplicated PVs, e.g. created by a hardware
+snapshot of existing PVs.
+
+A duplicated VG cannot used until it is made to coexist with the original
+VG. vgimportclone renames the VG associated with the specified PVs and
+changes the associated VG and PV UUIDs.
diff --git a/man/vgimportclone.8.end b/man/vgimportclone.8.end
new file mode 100644
index 0000000..83394b5
--- /dev/null
+++ b/man/vgimportclone.8.end
@@ -0,0 +1,9 @@
+.SH EXAMPLES
+
+An original VG "vg00" has PVs "/dev/sda" and "/dev/sdb".
+The corresponding PVs from a hardware snapshot are "/dev/sdc" and "/dev/sdd".
+Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_snap"
+(and change associated UUIDs).
+.br
+.B vgimportclone \-\-basevgname vg00_snap /dev/sdc /dev/sdd
+
diff --git a/man/vgimportclone.8.in b/man/vgimportclone.8.in
deleted file mode 100644
index cdf5e68..0000000
--- a/man/vgimportclone.8.in
+++ /dev/null
@@ -1,46 +0,0 @@
-.TH VGIMPORTCLONE 8 "LVM TOOLS #VERSION#" "Red Hat, Inc." \" -*- nroff -*-
-.SH NAME
-vgimportclone \(em import and rename duplicated volume group (e.g. a hardware snapshot)
-.SH SYNOPSIS
-.B vgimportclone
-.RB [ \-n | \-\-basevgname
-.IR VolumeGroupName ]
-.RB [ \-i | \-\-import ]
-.I PhysicalVolume
-.RI [ PhysicalVolume ...]
-.SH DESCRIPTION
-vgimportclone is used to import a duplicated VG (e.g. hardware snapshot).
-Duplicate VG(s) and PV(s) are not able to be used until they are made
-to coexist with the origin VG(s) and PV(s).
-vgimportclone renames the VG associated with the specified PV(s) and
-changes the associated VG and PV UUIDs.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-n ", " \-\-basevgname " " \fIVolumeGroupName
-By default the snapshot VG will be renamed to the original name plus a
-numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed
-to 'test_vg1').  This option will override the base VG name that is
-used for all VG renames.  If a VG already exists with the specified name
-a numeric suffix will be added (like the previous example) to make it unique.
-.TP
-.BR \-i ", " \-\-import
-Import exported Volume Groups.  Otherwise VGs that have been exported
-will not be changed (nor will their associated PVs).
-.SH ENVIRONMENT VARIABLES
-.TP
-.B LVM_BINARY
-The LVM2 binary to use. Defaults to "lvm".
-.SH Examples
-The origin VG "vg00" has origin PVs "/dev/sda" and "/dev/sdb"
-and the respective snapshot PVs are "/dev/sdc" and "/dev/sdd".
-To rename the VG associated with "/dev/sdc" and "/dev/sdd"
-from "vg00" to "vg00_snap"
-(and to change associated VG and PV UUIDs) do:
-.sp
-.B vgimportclone \-\-basevgname vg00_snap /dev/sdc /dev/sdd
-
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgrename (8)
-
diff --git a/man/vgmerge.8.des b/man/vgmerge.8.des
new file mode 100644
index 0000000..ff7c177
--- /dev/null
+++ b/man/vgmerge.8.des
@@ -0,0 +1,3 @@
+vgmerge merges two existing VGs. The inactive source VG is merged into the
+destination VG if physical extent sizes are equal and PV and LV summaries
+of both VGs fit into the destination VG's limits.
diff --git a/man/vgmerge.8.end b/man/vgmerge.8.end
new file mode 100644
index 0000000..9787c6a
--- /dev/null
+++ b/man/vgmerge.8.end
@@ -0,0 +1,7 @@
+.SH EXAMPLES
+
+Merge an inactive VG named "vg00" into the active or inactive VG named
+"databases", giving verbose runtime information.
+.br
+.B vgmerge \-v databases vg00
+
diff --git a/man/vgmerge.8.in b/man/vgmerge.8.in
deleted file mode 100644
index bfc8c34..0000000
--- a/man/vgmerge.8.in
+++ /dev/null
@@ -1,41 +0,0 @@
-.TH VGMERGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgmerge \(em merge two volume groups
-.SH SYNOPSIS
-.B vgmerge
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-l | \-\-list ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.I DestinationVolumeGroupName
-.I SourceVolumeGroupName
-.SH DESCRIPTION
-vgmerge merges two existing volume groups. The inactive
-\fISourceVolumeGroupName\fP will be merged into 
-the \fIDestinationVolumeGroupName\fP if physical extent sizes
-are equal and physical and logical volume summaries of both volume groups
-fit into \fIDestinationVolumeGroupName\fP's limits.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-l ", " \-\-list
-Display merged \fIDestinationVolumeGroupName\fP like \fBvgdisplay \-v\fP.
-.TP 
-.BR \-t ", " \-\-test
-Do a test run WITHOUT making any real changes.
-.SH Examples
-Merge the inactive volume group named "my_vg"
-into the active or inactive volume group named "databases" giving verbose
-runtime information:
-.sp
-.B vgmerge \-v databases my_vg
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgcreate (8),
-.BR vgextend (8),
-.BR vgreduce (8)
diff --git a/man/vgmknodes.8.des b/man/vgmknodes.8.des
new file mode 100644
index 0000000..a93d629
--- /dev/null
+++ b/man/vgmknodes.8.des
@@ -0,0 +1,5 @@
+vgmknodes checks the LVM device nodes in /dev that are needed for active
+LVs and creates any that are missing and removes unused ones.
+
+This command should not usually be needed if all the system components are
+interoperating correctly.
diff --git a/man/vgmknodes.8.in b/man/vgmknodes.8.in
deleted file mode 100644
index c5bb5d4..0000000
--- a/man/vgmknodes.8.in
+++ /dev/null
@@ -1,30 +0,0 @@
-.TH VGMKNODES 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgmknodes \(em recreate volume group directory and logical volume special files
-.SH SYNOPSIS
-.B vgmknodes
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-\-refresh ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-v | \-\-verbose ]
-.RI [[ VolumeGroupName | LogicalVolumePath ]...]
-.SH DESCRIPTION
-Checks the LVM2 special files in /dev that are needed for active 
-logical volumes and creates any missing ones and removes unused ones.
-.SH OPTIONS
-.TP
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-\-refresh
-If any logical volume in the volume group is active, reload its metadata.
-This is not necessary in normal operation, but may be useful
-if something has gone wrong or if you're doing clustering
-manually without a clustered lock manager.
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgscan (8),
-.BR dmsetup (8)
diff --git a/man/vgreduce.8.des b/man/vgreduce.8.des
new file mode 100644
index 0000000..1bcdaf9
--- /dev/null
+++ b/man/vgreduce.8.des
@@ -0,0 +1 @@
+vgreduce removes one or more unused PVs from a VG.
diff --git a/man/vgreduce.8.in b/man/vgreduce.8.in
deleted file mode 100644
index cce31e8..0000000
--- a/man/vgreduce.8.in
+++ /dev/null
@@ -1,49 +0,0 @@
-.TH VGREDUCE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgreduce \(em reduce a volume group
-.SH SYNOPSIS
-.B vgreduce
-.RB [ \-a | \-\-all ]
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-removemissing ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.I VolumeGroupName
-.RI [ PhysicalVolumePath ...]
-.SH DESCRIPTION
-vgreduce allows you to remove one or more unused physical volumes
-from a volume group.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-a ", " \-\-all
-Removes all empty physical volumes if none are given on command line.
-.TP
-.B \-\-removemissing
-Removes all missing physical volumes from the volume group, if there are no
-logical volumes allocated on those. This resumes normal operation of the volume
-group (new logical volumes may again be created, changed and so on).
-
-If this is not possible (there are logical volumes referencing the missing
-physical volumes) and you cannot or do not want to remove them manually, you
-can run this option with \fB\-\-force\fP to have \fBvgreduce\fP
-remove any partial LVs.
-
-Any logical volumes and dependent snapshots that were partly on the 
-missing disks get removed completely. This includes those parts 
-that lie on disks that are still present.
-
-If your logical volumes spanned several disks including the ones that are
-lost, you might want to try to salvage data first by activating your
-logical volumes with \fB\-\-partial\fP as described in \fBlvm\fP(8).
-
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgextend (8)
diff --git a/man/vgremove.8.des b/man/vgremove.8.des
new file mode 100644
index 0000000..04dc0e3
--- /dev/null
+++ b/man/vgremove.8.des
@@ -0,0 +1,6 @@
+vgremove removes one or more VGs. If LVs exist in the VG, a prompt is used
+to confirm LV removal.
+
+If one or more PVs in the VG are lost, consider
+\fBvgreduce \-\-removemissing\fP to make the VG
+metadata consistent again.
diff --git a/man/vgremove.8.in b/man/vgremove.8.in
deleted file mode 100644
index 4e600ef..0000000
--- a/man/vgremove.8.in
+++ /dev/null
@@ -1,46 +0,0 @@
-.TH VGREMOVE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgremove \(em remove a volume group
-.SH SYNOPSIS
-.B vgremove
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-f | \-\-force ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-noudevsync ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.RI [ VolumeGroupName ...]
-.SH DESCRIPTION
-vgremove allows you to remove one or more volume groups.
-If one or more physical volumes in the volume group are lost,
-consider \fBvgreduce \-\-removemissing\fP to make the volume group
-metadata consistent again.
-.sp
-If there are logical volumes that exist in the volume group,
-a prompt will be given to confirm removal.  You can override
-the prompt with \fB\-f\fP.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.BR \-f ", " \-\-force
-Force the removal of any logical volumes on the volume group
-without confirmation.
-To remove also damaged pool volumes use \-ff.
-.TP
-.BR \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.SH SEE ALSO
-.BR lvm (8),
-.BR lvremove (8),
-.BR vgcreate (8),
-.BR vgreduce (8)
diff --git a/man/vgrename.8.des b/man/vgrename.8.des
new file mode 100644
index 0000000..2384b6b
--- /dev/null
+++ b/man/vgrename.8.des
@@ -0,0 +1,9 @@
+vgrename renames a VG.
+
+All VGs visible to a system need to have different names, otherwise many
+LVM commands will refuse to run or give warning messages. VGs with the
+same name can occur when disks are moved between machines, or filters are
+changed. If a newly connected disk has a VG with the same name as the VG
+containing the root filesystem, the machine may not boot correctly. When
+two VGs have the same name, the VG UUID can be used in place of the source
+VG name.
diff --git a/man/vgrename.8.end b/man/vgrename.8.end
new file mode 100644
index 0000000..98eeb53
--- /dev/null
+++ b/man/vgrename.8.end
@@ -0,0 +1,10 @@
+.SH EXAMPLES
+
+Rename VG "vg02" to "myvg":
+.br
+.B vgrename "vg02" "myvg"
+
+Rename the VG with the specified UUID to "myvg".
+.br
+.B vgrename Zvlifi\-Ep3t\-e0Ng\-U42h\-o0ye\-KHu1\-nl7Ns4 myvg
+
diff --git a/man/vgrename.8.in b/man/vgrename.8.in
deleted file mode 100644
index 322d740..0000000
--- a/man/vgrename.8.in
+++ /dev/null
@@ -1,58 +0,0 @@
-.TH VGRENAME 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgrename \(em rename a volume group
-.SH SYNOPSIS
-.B vgrename
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.IR OldVolumeGroup { Path | Name | UUID }
-.IR NewVolumeGroup { Path | Name }
-.SH DESCRIPTION
-vgrename renames an existing (see
-.BR vgcreate (8))
-volume group from
-.IR OldVolumeGroup { Name | Path | UUID }
-to
-.IR NewVolumeGroup { Name | Path }.
-
-All the Volume Groups visible to a system need to have different
-names.  Otherwise many LVM2 commands will refuse to run or give
-warning messages.
-
-This situation could arise when disks are moved between machines.  If
-a disk is connected and it contains a Volume Group with the same name
-as the Volume Group containing your root filesystem the machine might
-not even boot correctly.  However, the two Volume Groups should have
-different UUIDs (unless the disk was cloned) so you can rename
-one of the conflicting Volume Groups with
-\fBvgrename\fP.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.SH Examples
-Renames existing volume group vg02 to my_volume_group:
-.sp
-.B vgrename /dev/vg02 /dev/my_volume_group
-
-or
-.sp
-.B vgrename vg02 my_volume_group
-
-Changes the name of the Volume Group with UUID
-.br
-Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 to VolGroup00_tmp:
-.sp
-.B vgrename Zvlifi\-Ep3t\-e0Ng\-U42h\-o0ye\-KHu1\-nl7Ns4 VolGroup00_tmp
-
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgchange (8),
-.BR vgcreate (8),
-.BR lvrename (8)
diff --git a/man/vgs.8.des b/man/vgs.8.des
new file mode 100644
index 0000000..15bdb97
--- /dev/null
+++ b/man/vgs.8.des
@@ -0,0 +1 @@
+vgs produces formatted output about VGs.
diff --git a/man/vgs.8.end b/man/vgs.8.end
new file mode 100644
index 0000000..b8cda26
--- /dev/null
+++ b/man/vgs.8.end
@@ -0,0 +1,17 @@
+.SH NOTES
+.
+The vg_attr bits are:
+.IP 1 3
+Permissions: (w)riteable, (r)ead-only
+.IP 2 3
+Resi(z)eable
+.IP 3 3
+E(x)ported
+.IP 4 3
+(p)artial: one or more physical volumes belonging to the volume group
+are missing from the system
+.IP 5 3
+Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
+.IP 6 3
+(c)lustered, (s)hared
+
diff --git a/man/vgs.8.in b/man/vgs.8.in
deleted file mode 100644
index 080086c..0000000
--- a/man/vgs.8.in
+++ /dev/null
@@ -1,161 +0,0 @@
-.TH VGS 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgs \(em report information about volume groups
-.SH SYNOPSIS
-.B vgs
-.RB [ \-a | \-\-all ]
-.RB [ \-\-aligned ]
-.RB [ \-\-binary ]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [[ \-\-configreport
-.IR ReportName ]
-.RB [ \-o | \-\-options
-.RI [ + | \- | # ] Field1 [, Field2 ...]
-.RB [ \-O | \-\-sort
-.RI [ + | \- ] Key1 [, Key2 ...]]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB ...]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-ignoreskippedcluster ]
-.RB [ \-\-logonly ]
-.RB [ \-\-nameprefixes ]
-.RB [ \-\-noheadings ]
-.RB [ \-\-nosuffix ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-\-rows ]
-.RB [ \-\-separator
-.IR Separator ]
-.RB [ \-\-unbuffered ]
-.RB [ \-\-units
-.IR hHbBsSkKmMgGtTpPeE ]
-.RB [ \-\-unquoted ]
-.RB [ \-v | \-\-verbose ]
-.RB [ \-\-version ]
-.RI [ VolumeGroupName
-.RI [ VolumeGroupName ...]]
-.SH DESCRIPTION
-vgs produces formatted output about volume groups.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.B \-\-all
-List all volume groups.  Equivalent to not specifying any volume groups.
-.TP
-.B \-\-aligned
-Use with \fB\-\-separator\fP to align the output columns.
-.TP
-.B \-\-binary
-Use binary values "0" or "1" instead of descriptive literal values
-for columns that have exactly two valid values to report (not counting
-the "unknown" value which denotes that the value could not be determined).
-.TP
-.B \-\-configreport  \fI ReportName
-Make any subsequent \fB\-o, \-\-options\fP, \fB\-O, \-\-sort\fP or
-\fB\-S, \-\-select\fP to apply for \fIReportName\fP where \fIReportName\fP
-is either 'vg' for command's main report or 'log' for log report.
-If \fB\-\-configreport\fP option is not used to identify a report, then
-command's main report is assumed. The log report is available only if
-enabled by \fBlog/report_command_log\fP \fBlvm.conf\fP(5) setting or
-if \fB\-\-logonly\fP option is used.
-.TP
-.B \-\-logonly
-Suppress the vgs report itself and display only log report on output.
-.TP
-.B \-\-nameprefixes
-Add an "LVM2_" prefix plus the field name to the output.  Useful
-with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
-be used to set environment variables (for example, in \fBudev\fP(7) rules).
-.TP
-.B \-\-noheadings
-Suppress the headings line that is normally the first line of output.
-Useful if grepping the output.
-.TP
-.B \-\-nosuffix
-Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
-(except h and H) if processing the output.
-.TP
-.BR \-o ", " \-\-options
-Comma-separated ordered list of columns.
-.IP
-Precede the list with '\fI+\fP' to append to the current list
-of columns, '\fI-\fP' to remove from the current list of columns
-or '\fI#\fP' to compact given columns. The \fI\-o\fP option can
-be repeated, providing several lists. These lists are evaluated
-from left to right.
-.IP
-Use \fB\-o vg_all\fP to select all volume group columns.
-.IP
-Use \fB\-o help\fP to view the full list of columns available.
-.IP
-Column names include: vg_fmt, vg_uuid, vg_name, vg_attr, vg_size, vg_free,
-vg_sysid, vg_extent_size, vg_extent_count, vg_free_count, vg_profile, max_lv,
-max_pv, pv_count, lv_count, snap_count, vg_seqno, vg_tags, vg_mda_count,
-vg_mda_free, and vg_mda_size, vg_mda_used_count.
-.IP
-Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs\fP(8)
-or \fBlvs\fP(8) can also be chosen, but columns cannot be taken from both
-at the same time.  
-.IP
-The vg_attr bits are:
-.RS
-.IP 1 3
-Permissions: (w)riteable, (r)ead-only
-.IP 2 3
-Resi(z)eable
-.IP 3 3
-E(x)ported
-.IP 4 3
-(p)artial: one or more physical volumes belonging to the volume group
-are missing from the system
-.IP 5 3
-Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
-.IP 6 3
-(c)lustered, (s)hared
-.RE
-.TP
-.BR \-O ", " \-\-sort
-Comma-separated ordered list of columns to sort by.  Replaces the default
-selection. Precede any column with '\fI\-\fP' for a reverse sort on that
-column.
-.TP
-.B \-\-rows
-Output columns as rows.
-.TP
-.BR  \-S ", " \-\-select " " \fISelection
-Display only rows that match Selection criteria. All rows are displayed with
-the additional "selected" column (\fB-o selected\fP) showing 1 if the row
-matches the Selection and 0 otherwise. The Selection criteria are defined
-by specifying column names and their valid values (that can include reserved
-values) while making use of supported comparison operators. See \fBlvm\fP(8)
-and \fB\-S\fP, \fB\-\-select\fP description for more detailed information
-about constructing the Selection criteria. As a quick help and to see full
-list of column names that can be used in Selection including the list of
-reserved values and the set of supported selection operators, check the
-output of \fBvgs -S help\fP command.
-.TP
-.B \-\-separator \fISeparator
-String to use to separate each column.  Useful if grepping the output.
-.TP
-.B \-\-unbuffered
-Produce output immediately without sorting or aligning the columns properly.
-.TP
-.B \-\-units \fIhHbBsSkKmMgGtTpPeE
-All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
-Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
-custom units e.g. \-\-units 3M
-.TP
-.B \-\-unquoted
-When used with \fB\-\-nameprefixes\fP, output values in the field=value
-pairs are not quoted.
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgdisplay (8),
-.BR pvs (8),
-.BR lvs (8)
diff --git a/man/vgscan.8.des b/man/vgscan.8.des
new file mode 100644
index 0000000..e8041ed
--- /dev/null
+++ b/man/vgscan.8.des
@@ -0,0 +1 @@
+vgscan scans all supported LVM block devices in the system for VGs.
diff --git a/man/vgscan.8.in b/man/vgscan.8.in
deleted file mode 100644
index e85d817..0000000
--- a/man/vgscan.8.in
+++ /dev/null
@@ -1,43 +0,0 @@
-.TH VGSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgscan \(em scan all disks for volume groups and rebuild caches
-.SH SYNOPSIS
-.B vgscan
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-ignorelockingfailure ]
-.RB [ \-\-mknodes ]
-.RB [ \-\-notifydbus ]
-.RB [ \-P | \-\-partial ]
-.RB [ \-\-reportformat
-.RB { basic | json }]
-.RB [ \-v | \-\-verbose ]
-.SH DESCRIPTION
-vgscan scans all SCSI, (E)IDE disks, multiple devices and a bunch
-of other disk devices in the system looking for LVM physical volumes
-and volume groups.  Define a filter in \fBlvm.conf\fP(5) to restrict 
-the scan to avoid a CD ROM, for example.
-.LP
-In LVM2, vgscans take place automatically; but you might still need to
-run one explicitly after changing hardware.
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.TP
-.B \-\-mknodes
-Also checks the LVM special files in /dev that are needed for active 
-logical volumes and creates any missing ones and removes unused ones.
-.TP
-.B \-\-notifydbus
-Send a notification to D-Bus. The command will exit with an error
-if LVM is not built with support for D-Bus notification, or if the
-notify_dbus config setting is disabled.
-.TP
-.B \-\-cache
-Scan devices for LVM physical volumes and volume groups and instruct
-the lvmetad daemon to update its cached state accordingly.
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgcreate (8),
-.BR vgchange (8)
diff --git a/man/vgsplit.8.des b/man/vgsplit.8.des
new file mode 100644
index 0000000..29eb5c5
--- /dev/null
+++ b/man/vgsplit.8.des
@@ -0,0 +1,13 @@
+vgsplit moves one or more PVs from a source VG to a destination VG. The
+PVs can be specified explicitly or implicitly by naming an LV, in which
+case on PVs underlying the LV are moved.
+
+If the destination VG does not exist, a new VG is created (command options
+can be used to specify properties of the new VG, also see
+\fBvgcreate\fP(8).)
+
+LVs cannot be split between VGs; each LV must be entirely on the PVs in
+the source or destination VG.
+
+vgsplit can only move complete PVs. (See \fBpvmove\fP(8) for moving part
+of a PV.)
diff --git a/man/vgsplit.8.in b/man/vgsplit.8.in
deleted file mode 100644
index 5939ed5..0000000
--- a/man/vgsplit.8.in
+++ /dev/null
@@ -1,80 +0,0 @@
-.TH VGSPLIT 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-vgsplit \(em split a volume group into two
-.SH SYNOPSIS
-.B vgsplit
-.RB [ \-\-alloc
-.IR AllocationPolicy ]
-.RB [ \-A | \-\-autobackup
-.RI { y | n }]
-.RB [ \-c | \-\-clustered
-.RI { y | n }]
-.RB [ \-\-commandprofile
-.IR ProfileName ]
-.RB [ \-d | \-\-debug ]
-.RB [ \-h | \-\-help ]
-.RB [ \-l | \-\-maxlogicalvolumes
-.IR MaxLogicalVolumes ]
-.RB [ \-M | \-\-metadatatype
-.IR type ]
-.RB [ \-p | \-\-maxphysicalvolumes
-.IR MaxPhysicalVolumes ]
-.RB [ \-\- [ vg ] metadatacopies
-.IR NumberOfCopies | unmanaged | all ]
-.RB [ \-n | \-\-name
-.IR LogicalVolumeName ]
-.RB [ \-t | \-\-test ]
-.RB [ \-v | \-\-verbose ]
-.I SourceVolumeGroupName DestinationVolumeGroupName
-.RI [ PhysicalVolumePath ...]
-.SH DESCRIPTION
-vgsplit moves one or more physical volumes from
-\fISourceVolumeGroupName\fP into \fIDestinationVolumeGroupName\fP.
-The physical volumes moved can be specified either explicitly via
-\fIPhysicalVolumePath\fP, or implicitly by \fB\-n\fP
-\fILogicalVolumeName\fP, in which case only physical volumes
-underlying the specified logical volume will be moved.
-
-If \fIDestinationVolumeGroupName\fP does not exist, a new volume
-group will be created.  The default attributes
-for the new volume group can be specified with
-.BR \-\-alloc ,
-.BR \-\-clustered ,
-.BR \-\-maxlogicalvolumes ,
-.BR \-\-metadatatype ,
-.B \-\-maxphysicalvolumes \fRand
-.BR \-\- [ vg ] metadatacopies
-(see \fBvgcreate\fP(8) for a description of these options).  If any
-of these options are not given, default attribute(s) are taken from
-\fISourceVolumeGroupName\fP. If a non-LVM2 metadata type (e.g. lvm1) is
-being used, you should use the \fB\-M\fP option to specify the metadata
-type directly.
-
-If
-.I DestinationVolumeGroupName
-does exist, it will be checked for compatibility with
-.I SourceVolumeGroupName
-before the physical volumes are moved. Specifying any of the above default
-volume group attributes with an existing destination volume group is an error,
-and no split will occur.
-
-Logical volumes cannot be split between volume groups. \fBvgsplit\fP(8) only
-moves complete physical volumes: To move part of a physical volume, use
-\fBpvmove\fP(8).  Each existing logical volume must be entirely on the physical
-volumes forming either the source or the destination volume group.  For this
-reason, \fBvgsplit\fP(8) may fail with an error if a split would result in a
-logical volume being split across volume groups.
-
-A vgsplit into an existing volume group retains the existing volume group's
-value of \fPvgmetadatacopies\fP (see \fBvgcreate\fP(8) and \fBlvm.conf\fP(5) for further
-explanation of \fPvgmetadatacopies\fP).  To change the value of
-\fBvgmetadatacopies\fP, use \fBvgchange\fP(8).
-
-.SH OPTIONS
-See \fBlvm\fP(8) for common options.
-.SH SEE ALSO
-.BR lvm (8),
-.BR vgcreate (8),
-.BR vgextend (8),
-.BR vgreduce (8),
-.BR vgmerge (8)
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 1761be4..5aaba2f 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -1,4 +1,3 @@
-
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.


