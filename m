From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 27 Mar 2017 10:47:08 -0400
Subject: master - man-generator/man/help: simplify hyphen escaping
Message-ID: <201703271447.v2REl8Gf004978@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c2f9172123ac558ee7142e4eea4864a1e08099f4
Commit:        c2f9172123ac558ee7142e4eea4864a1e08099f4
Parent:        6165e092215c795eafa297268cddbd9dade3a82c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Mar 27 16:45:48 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Mar 27 16:45:48 2017 +0200

man-generator/man/help: simplify hyphen escaping

Commits a29bb6a14b5e920092495fb9a1623e527d22daac
    ... 5c199d99f4dc9911d62673baba7643ea649ffe64
narrowed down on addressing the escaping of hyphens
in the dynamic creation of manuals whilst avoiding
them in creating help texts.  This lead to a sequence
of slipping through hyphens adrressed by additional
patches in aforementioned commit series.

On the other hand, postproccessing dynamically man-generator
created and statically provided manuals catches all hyphens
in need of escaping.

Changes:
- revert the above commits whilst keeping man-generator
  streamlining and the detection of any '\' when generating
  help texts in order to avoid escapes to slip in

- Dynamically escape hyphens in manaual pages using sed(1)
  in the respective Makefile targets

- remove any manually added escaping on hyphens from any
  static manual sources or headers
---
 man/Makefile.in                      |    8 +
 man/blkdeactivate.8_main             |   54 ++--
 man/clvmd.8_main                     |   66 +++---
 man/cmirrord.8_main                  |    8 +-
 man/dmeventd.8_main                  |   48 ++--
 man/dmfilemapd.8_main                |   16 +-
 man/dmsetup.8_main                   |  256 +++++++++---------
 man/dmstats.8_main                   |  396 +++++++++++++-------------
 man/fsadm.8_main                     |   14 +-
 man/lvchange.8_end                   |    2 +-
 man/lvconvert.8_des                  |    2 +-
 man/lvconvert.8_end                  |   56 ++--
 man/lvcreate.8_des                   |    6 +-
 man/lvcreate.8_end                   |   44 ++--
 man/lvextend.8_des                   |    6 +-
 man/lvextend.8_end                   |    6 +-
 man/lvm-config.8_des                 |    2 +-
 man/lvm-dumpconfig.8_des             |    2 +-
 man/lvm-lvpoll.8_end                 |   12 +-
 man/lvm.8_main                       |   36 ++--
 man/lvm.conf.5_main                  |   30 +-
 man/lvm2-activation-generator.8_main |   26 +-
 man/lvmcache.7_main                  |  112 ++++----
 man/lvmconf.8_main                   |   48 ++--
 man/lvmconfig.8_des                  |    2 +-
 man/lvmdbusd.8_main                  |   14 +-
 man/lvmdump.8_main                   |   58 ++--
 man/lvmetad.8_main                   |   50 ++--
 man/lvmlockctl.8_main                |   36 ++--
 man/lvmlockd.8_main                  |  124 ++++----
 man/lvmpolld.8_main                  |   46 ++--
 man/lvmraid.7_main                   |  518 +++++++++++++++++-----------------
 man/lvmreport.7_main                 |  258 +++++++++---------
 man/lvmsadc.8_main                   |    2 +-
 man/lvmsar.8_main                    |    2 +-
 man/lvmsystemid.7_main               |   34 ++--
 man/lvmthin.7_main                   |  406 +++++++++++++-------------
 man/lvreduce.8_des                   |    6 +-
 man/lvreduce.8_end                   |    2 +-
 man/lvremove.8_end                   |    2 +-
 man/lvresize.8_des                   |    4 +-
 man/lvresize.8_end                   |    2 +-
 man/pvchange.8_end                   |    2 +-
 man/pvck.8_end                       |    4 +-
 man/pvcreate.8_end                   |    2 +-
 man/pvmove.8_end                     |   14 +-
 man/pvresize.8_end                   |    2 +-
 man/pvscan.8_des                     |   26 +-
 man/vgcfgbackup.8_des                |    2 +-
 man/vgcfgrestore.8_des               |    4 +-
 man/vgcfgrestore.8_end               |    6 +-
 man/vgchange.8_end                   |    4 +-
 man/vgextend.8_des                   |    6 +-
 man/vgimportclone.8_end              |    2 +-
 man/vgmerge.8_end                    |    2 +-
 man/vgremove.8_des                   |    2 +-
 man/vgrename.8_end                   |    2 +-
 tools/args.h                         |  162 ++++++------
 tools/command.c                      |   95 +++----
 59 files changed, 1569 insertions(+), 1590 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 57d9627..4fcce7d 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -173,17 +173,25 @@ define SUBSTVARS
 echo "Generating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+/data/lvmtest/usr/sbin/clvmd+;s+#LVM_PATH#+/data/lvmtest/sbin/lvm+;s+#DEFAULT_RUN_DIR#+/var/run/lvm+;s+#DEFAULT_PID_DIR#+/var/run+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+;" $< > $@
 endef
 
+define ESCAPEHYPHENS
+	sed -i "s+\([^\\]\)--+\1\\\-\\\-+g;s+\([^\\]\)-+\1\\\-+g" $@
+endef
+
 %.5: $(srcdir)/%.5_main
 	$(SUBSTVARS)
+	$(ESCAPEHYPHENS)
 
 %.7: $(srcdir)/%.7_main
 	$(SUBSTVARS)
+	$(ESCAPEHYPHENS)
 
 %.8: $(srcdir)/%.8_main
 	$(SUBSTVARS)
+	$(ESCAPEHYPHENS)
 
 %.8: %.8_gen
 	$(SUBSTVARS)
+	$(ESCAPEHYPHENS)
 
 install_man5: $(MAN5)
 	$(INSTALL) -d $(MAN5DIR)
diff --git a/man/blkdeactivate.8_main b/man/blkdeactivate.8_main
index fbfd025..9a0e84e 100644
--- a/man/blkdeactivate.8_main
+++ b/man/blkdeactivate.8_main
@@ -3,27 +3,27 @@
 blkdeactivate \(em utility to deactivate block devices
 .SH SYNOPSIS
 .B blkdeactivate
-.RB [ \-d \  \fIdm_options\fP ]
-.RB [ \-e ]
-.RB [ \-h ]
-.RB [ \-l \  \fIlvm_options\fP ]
-.RB [ \-m \  \fImpath_options\fP ]
-.RB [ \-u ]
-.RB [ \-v ]
+.RB [ -d \  \fIdm_options\fP ]
+.RB [ -e ]
+.RB [ -h ]
+.RB [ -l \  \fIlvm_options\fP ]
+.RB [ -m \  \fImpath_options\fP ]
+.RB [ -u ]
+.RB [ -v ]
 .RI [ device ]
 .SH DESCRIPTION
 The blkdeactivate utility deactivates block devices. For mounted
 block devices, it attempts to unmount it automatically before
 trying to deactivate. The utility currently supports
-device\-mapper devices (DM), including LVM volumes and
+device-mapper devices (DM), including LVM volumes and
 software RAID MD devices. LVM volumes are handled directly
-using the \fBlvm\fP(8) command, the rest of device\-mapper
+using the \fBlvm\fP(8) command, the rest of device-mapper
 based devices are handled using the \fBdmsetup\fP(8) command.
 MD devices are handled using the \fBmdadm\fP(8) command.
 .SH OPTIONS
 .TP
-.BR \-d ", " \-\-dmoption \ \fIdm_options\fP
-Comma separated list of device\-mapper specific options.
+.BR -d ", " --dmoption \ \fIdm_options\fP
+Comma separated list of device-mapper specific options.
 Accepted \fBdmsetup\fP(8) options are:
 .RS
 .IP \fIretry\fP
@@ -32,17 +32,17 @@ Retry removal several times in case of failure.
 Force device removal.
 .RE
 .TP
-.BR \-e ", " \-\-errors
+.BR -e ", " --errors
 Show errors reported from tools called by \fBblkdeactivate\fP. Without this
 option, any error messages from these external tools are suppressed and the
 \fBblkdeactivate\fP itself provides only a summary message to indicate
 the device was skipped.
 .TP
-.BR \-h ", " \-\-help
+.BR -h ", " --help
 Display the help text.
 .TP
-.BR \-l ", " \-\-lvmoption \ \fIlvm_options\fP
-Comma\-separated list of LVM specific options:
+.BR -l ", " --lvmoption \ \fIlvm_options\fP
+Comma-separated list of LVM specific options:
 .RS
 .IP \fIretry\fP
 Retry removal several times in case of failure.
@@ -52,22 +52,22 @@ Deactivating the Volume Group as a whole is quicker than deactivating
 each Logical Volume separately.
 .RE
 .TP
-.BR \-m ", " \-\-mpathoption \ \fImpath_options\fP
-Comma\-separated list of device\-mapper multipath specific options:
+.BR -m ", " --mpathoption \ \fImpath_options\fP
+Comma-separated list of device-mapper multipath specific options:
 .RS
 .IP \fIdisablequeueing\fP
 Disable queueing on all multipath devices before deactivation.
 This avoids a situation where blkdeactivate may end up waiting if
-all the paths are unavailable for any underlying device\-mapper multipath
+all the paths are unavailable for any underlying device-mapper multipath
 device.
 .RE
 .TP
-.BR \-u ", " \-\-umount
+.BR -u ", " --umount
 Unmount a mounted device before trying to deactivate it.
 Without this option used, a device that is mounted is not deactivated.
 .TP
-.BR \-v ", " \-\-verbose
-Run in verbose mode. Use \-\-vv for even more verbose mode.
+.BR -v ", " --verbose
+Run in verbose mode. Use --vv for even more verbose mode.
 .SH EXAMPLES
 .
 Deactivate all supported block devices found in the system, skipping mounted
@@ -81,29 +81,29 @@ Deactivate all supported block devices found in the system, unmounting any
 mounted devices first, if possible.
 .BR
 #
-.B blkdeactivate \-u
+.B blkdeactivate -u
 .BR
 .P
 Deactivate the device /dev/vg/lvol0 together with all its holders, unmounting 
 any mounted devices first, if possible.
 .BR
 #
-.B blkdeactivate \-u /dev/vg/lvol0
+.B blkdeactivate -u /dev/vg/lvol0
 .BR
 .P
 Deactivate all supported block devices found in the system. If the deactivation
-of a device\-mapper device fails, retry it. Deactivate the whole
+of a device-mapper device fails, retry it. Deactivate the whole
 Volume Group at once when processing an LVM Logical Volume.
 .BR
 #
-.B blkdeactivate \-u \-d retry \-l wholevg
+.B blkdeactivate -u -d retry -l wholevg
 .BR
 .P
 Deactivate all supported block devices found in the system. If the deactivation
-of a device\-mapper device fails, retry it and force removal.
+of a device-mapper device fails, retry it and force removal.
 .BR
 #
-.B blkdeactivate \-d force,retry
+.B blkdeactivate -d force,retry
 .
 .SH SEE ALSO
 .BR dmsetup (8),
diff --git a/man/clvmd.8_main b/man/clvmd.8_main
index 2e027c5..8e9921d 100644
--- a/man/clvmd.8_main
+++ b/man/clvmd.8_main
@@ -8,22 +8,22 @@ clvmd \(em cluster LVM daemon
 .
 .ad l
 .B clvmd
-.RB [ \-C ]
-.RB [ \-d
+.RB [ -C ]
+.RB [ -d
 .RI [ value ]]
-.RB [ \-E
+.RB [ -E
 .IR lock_uuid ]
-.RB [ \-f ]
-.RB [ \-h ]
-.RB [ \-I
+.RB [ -f ]
+.RB [ -h ]
+.RB [ -I
 .IR cluster_manager ]
-.RB [ \-R ]
-.RB [ \-S ]
-.RB [ \-t
+.RB [ -R ]
+.RB [ -S ]
+.RB [ -t
 .IR timeout ]
-.RB [ \-T
+.RB [ -T
 .IR start_timeout ]
-.RB [ \-V ]
+.RB [ -V ]
 .ad b
 .
 .SH DESCRIPTION
@@ -35,27 +35,27 @@ if a node in the cluster does not have this daemon running.
 .SH OPTIONS
 .
 .HP
-.BR \-C
+.BR -C
 .br
-Only valid if \fB\-d\fP is also specified.
+Only valid if \fB-d\fP is also specified.
 Tells all clvmds in a cluster to enable/disable debug logging.
 Without this switch, only the local clvmd will change its debug level to that
-given with \fB\-d\fP.
+given with \fB-d\fP.
 .br
-This does not work correctly if specified on the command\-line that starts clvmd.
+This does not work correctly if specified on the command-line that starts clvmd.
 If you want to start clvmd \fBand\fP
-enable cluster\-wide logging then the command needs to be issued twice, eg:
+enable cluster-wide logging then the command needs to be issued twice, eg:
 .br
 .BR clvmd
 .br
-.BR clvmd\ \-d2
+.BR clvmd\ -d2
 .
 .HP
-.BR \-d
+.BR -d
 .RI [ value ]
 .br
 Set debug logging level.
-If \fB\-d\fP is specified without a \fIvalue\fP
+If \fB-d\fP is specified without a \fIvalue\fP
 then 1 is assumed. \fIValue\fP can be:
 .PD 0
 .IP
@@ -63,30 +63,30 @@ then 1 is assumed. \fIValue\fP can be:
 \(em Disabled
 .IP
 .BR 1
-\(em Sends debug logs to stderr (implies \fB\-f\fP)
+\(em Sends debug logs to stderr (implies \fB-f\fP)
 .IP
 .BR 2
 \(em Sends debug logs to \fBsyslog\fP(3)
 .PD
 .
 .HP
-.BR \-E
+.BR -E
 .IR lock_uuid
 .br
 Pass lock uuid to be reacquired exclusively when clvmd is restarted.
 .
 .HP
-.BR \-f
+.BR -f
 .br
 Don't fork, run in the foreground.
 .
 .HP
-.BR \-h
+.BR -h
 .br
 Show help information.
 .
 .HP
-.BR \-I
+.BR -I
 .IR cluster_manager
 .br
 Selects the cluster manager to use for locking and internal
@@ -94,24 +94,24 @@ communications. As it is quite possible to have multiple managers available on
 the same system you might have to manually specify this option to override the
 search.
 
-By default, omit \fB\-I\fP is equivalent to \fB\-Iauto\fP.
+By default, omit \fB-I\fP is equivalent to \fB-Iauto\fP.
 Clvmd will use the first cluster manager that succeeds,
 and it checks them in a predefined order
 .BR cman ,
 .BR corosync ,
 .BR openais .
 The available managers will be listed by order as part of the
-\fBclvmd \-h\fP output.
+\fBclvmd -h\fP output.
 .
 .HP
-.BR \-R
+.BR -R
 .br
 Tells all the running instance of \fBclvmd\fP in the cluster to reload their device cache and
-re\-read the lvm configuration file \fBlvm.conf\fP(5). This command should be run whenever the
+re-read the lvm configuration file \fBlvm.conf\fP(5). This command should be run whenever the
 devices on a cluster system are changed.
 .
 .HP
-.BR \-S
+.BR -S
 .br
 Tells the running \fBclvmd\fP to exit and reexecute itself, for example at the
 end of a package upgrade. The new instance is instructed to reacquire
@@ -120,7 +120,7 @@ methods of restarting the daemon have the side effect of changing
 exclusive LV locks into shared locks.)
 .
 .HP
-.BR \-t
+.BR -t
 .IR timeout
 .br
 Specifies the \fItimeout\fP for commands to run around the cluster. This should not
@@ -129,7 +129,7 @@ may need to increase this on systems with very large disk farms.
 The default is 60 seconds.
 .
 .HP
-.BR \-T
+.BR -T
 .IR start_timeout
 .br
 Specifies the start timeout for \fBclvmd\fP daemon startup. If the
@@ -147,10 +147,10 @@ The default is \fB0\fP (no timeout) and the value is in seconds. Don't set this
 small or you will experience spurious errors. 10 or 20 seconds might be
 sensible.
 
-This timeout will be ignored if you start \fBclvmd\fP with the \fB\-d\fP.
+This timeout will be ignored if you start \fBclvmd\fP with the \fB-d\fP.
 .
 .HP
-.BR \-V
+.BR -V
 .br
 Display the version of the cluster LVM daemon.
 .
diff --git a/man/cmirrord.8_main b/man/cmirrord.8_main
index dab13cc..026c19b 100644
--- a/man/cmirrord.8_main
+++ b/man/cmirrord.8_main
@@ -3,11 +3,11 @@
 cmirrord \(em cluster mirror log daemon
 
 .SH SYNOPSIS
-\fBcmirrord\fR [\fB\-f\fR] [\fB\-h\fR]
+\fBcmirrord\fR [\fB-f\fR] [\fB-h\fR]
 
 .SH DESCRIPTION
 \fBcmirrord\fP is the daemon that tracks mirror log information in a cluster.
-It is specific to device\-mapper based mirrors (and by extension, LVM
+It is specific to device-mapper based mirrors (and by extension, LVM
 cluster mirrors).  Cluster mirrors are not possible without this daemon
 running.
 
@@ -26,9 +26,9 @@ ignored. Active cluster mirrors should be shutdown before stopping the cluster
 mirror log daemon.
 
 .SH OPTIONS
-.IP "\fB\-f\fR, \fB\-\-foreground\fR" 4
+.IP "\fB-f\fR, \fB--foreground\fR" 4
 Do not fork and log to the terminal.
-.IP "\fB\-h\fR, \fB\-\-help\fR" 4
+.IP "\fB-h\fR, \fB--help\fR" 4
 Print usage.
 
 .SH SEE ALSO
diff --git a/man/dmeventd.8_main b/man/dmeventd.8_main
index 0c1bb81..7e3f9a2 100644
--- a/man/dmeventd.8_main
+++ b/man/dmeventd.8_main
@@ -2,24 +2,24 @@
 .
 .SH NAME
 .
-dmeventd \(em Device\-mapper event daemon
+dmeventd \(em Device-mapper event daemon
 .
 .SH SYNOPSIS
 .
 .B dmeventd
-.RB [ \-d
-.RB [ \-d
-.RB [ \-d ]]]
-.RB [ \-f ]
-.RB [ \-h ]
-.RB [ \-l ]
-.RB [ \-R ]
-.RB [ \-V ]
-.RB [ \-? ]
+.RB [ -d
+.RB [ -d
+.RB [ -d ]]]
+.RB [ -f ]
+.RB [ -h ]
+.RB [ -l ]
+.RB [ -R ]
+.RB [ -V ]
+.RB [ -? ]
 .
 .SH DESCRIPTION
 .
-dmeventd is the event monitoring daemon for device\-mapper devices.
+dmeventd is the event monitoring daemon for device-mapper devices.
 Library plugins can register and carry out actions triggered when
 particular events occur.
 .
@@ -27,46 +27,46 @@ particular events occur.
 .SH OPTIONS
 .
 .HP
-.BR \-d
+.BR -d
 .br
 Repeat from 1 to 3 times (
-.BR \-d ,
-.BR \-dd ,
-.BR \-ddd
+.BR -d ,
+.BR -dd ,
+.BR -ddd
 ) to increase the detail of
 debug messages sent to syslog.
 Each extra d adds more debugging information.
 .
 .HP
-.BR \-f
+.BR -f
 .br
 Don't fork, run in the foreground.
 .
 .HP
-.BR \-h
+.BR -h
 .br
 Show help information.
 .
 .HP
-.BR \-l
+.BR -l
 .br
 Log through stdout and stderr instead of syslog.
-This option works only with option \-f, otherwise it is ignored.
+This option works only with option -f, otherwise it is ignored.
 .
 .HP
-.BR \-?
+.BR -?
 .br
 Show help information on stderr.
 .
 .HP
-.BR \-R
+.BR -R
 .br
 Replace a running dmeventd instance. The running dmeventd must be version
 2.02.77 or newer. The new dmeventd instance will obtain a list of devices and
 events to monitor from the currently running daemon.
 .
 .HP
-.BR \-V
+.BR -V
 .br
 Show version of dmeventd.
 .
@@ -106,7 +106,7 @@ of the thin pool is filled. See
 When a thin pool fills over 50% (data or metadata) thin plugin calls
 configured \fIdmeventd/thin_command\fP with every 5% increase.
 With default setting it calls internal
-\fBlvm lvextend \-\-use\-policies\fP to resize thin pool
+\fBlvm lvextend --use-policies\fP to resize thin pool
 when it's been filled above configured threshold
 \fIactivation/thin_pool_autoextend_threshold\fP.
 If the command fails, dmeventd thin plugin will keep
@@ -116,7 +116,7 @@ User may also configure external command to support more advanced
 maintenance operations of a thin pool.
 Such external command can e.g. remove some unneeded snapshots,
 use \fBfstrim\fP(8) to free recover space in a thin pool,
-but also can use \fBlvextend \-\-use\-policies\fP if other actions
+but also can use \fBlvextend --use-policies\fP if other actions
 have not released enough space.
 Command is executed with environmental variable
 \fBLVM_RUN_BY_DMEVENTD=1\fP so any lvm2 command executed
diff --git a/man/dmfilemapd.8_main b/man/dmfilemapd.8_main
index c782025..8e19e4b 100644
--- a/man/dmfilemapd.8_main
+++ b/man/dmfilemapd.8_main
@@ -21,7 +21,7 @@
 .
 .SH NAME
 .
-dmfilemapd \(em device\-mapper filemap monitoring daemon
+dmfilemapd \(em device-mapper filemap monitoring daemon
 .
 .SH SYNOPSIS
 .
@@ -44,7 +44,7 @@ dmfilemapd \(em device\-mapper filemap monitoring daemon
 .
 The dmfilemapd daemon monitors groups of \fIdmstats\fP regions that
 correspond to the extents of a file, adding and removing regions to
-reflect the changing state of the file on\-disk.
+reflect the changing state of the file on-disk.
 
 The daemon is normally launched automatically by the \fPdmstats
 create\fP command, but can be run manually, either to create a new
@@ -86,8 +86,8 @@ and the \fBmode\fP option for more information.
 .br
 The filemap monitoring mode the daemon should use: either "inode"
 (\fBDM_FILEMAP_FOLLOW_INODE\fP), or "path"
-(\fBDM_FILEMAP_FOLLOW_PATH\fP), to enable follow\-inode or
-follow\-path mode respectively.
+(\fBDM_FILEMAP_FOLLOW_PATH\fP), to enable follow-inode or
+follow-path mode respectively.
 .
 .HP
 .BR [foreground]
@@ -130,7 +130,7 @@ within the file system, while it is being monitored.
 .B Follow path
 .P
 The daemon follows the path that was given on the daemon command
-line. The file descriptor referencing the file is re\-opened on each
+line. The file descriptor referencing the file is re-opened on each
 iteration of the daemon, and the daemon will exit if no file exists
 at this location (a tolerance is allowed so that a brief delay
 between removal and replacement is permitted).
@@ -164,13 +164,13 @@ Normally the daemon is started automatically by the \fBdmstats\fP
 \fBcreate\fP or \fBupdate_filemap\fP commands but it can be run
 manually for debugging or testing purposes.
 .P
-Start the daemon in the background, in follow\-path mode
+Start the daemon in the background, in follow-path mode
 .br
 #
 .B dmfilemapd 3 0 /srv/images/vm.img path 0 0 3< /srv/images/vm.img
 .br
 .P
-Start the daemon in follow\-inode mode, disable forking and enable
+Start the daemon in follow-inode mode, disable forking and enable
 verbose logging
 .br
 #
@@ -208,5 +208,5 @@ Bryn M. Reeves <bmr@redhat.com>
 
 LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
-Device\-mapper resource page: http://sources.redhat.com/dm/
+Device-mapper resource page: http://sources.redhat.com/dm/
 .br
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index e03b50c..4421882 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -23,12 +23,12 @@ dmsetup \(em low level logical volume management
 .  ad l
 .  BR create
 .  IR device_name
-.  RB [ -u | \-\-uuid
+.  RB [ -u | --uuid
 .  IR uuid ]
-.  RB \%[ \-\-addnodeoncreate | \-\-addnodeonresume ]
-.  RB \%[ \-n | \-\-notable | \-\-table
+.  RB \%[ --addnodeoncreate | --addnodeonresume ]
+.  RB \%[ -n | --notable | --table
 .  IR \%table | table_file ]
-.  RB [ \-\-readahead
+.  RB [ --readahead
 .  RB \%[ + ] \fIsectors | auto | none ]
 .  ad b
 ..
@@ -39,7 +39,7 @@ dmsetup \(em low level logical volume management
 .de CMD_DEPS
 .  ad l
 .  BR deps
-.  RB [ \-o
+.  RB [ -o
 .  IR options ]
 .  RI [ device_name ...]
 .  ad b
@@ -50,7 +50,7 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_HELP
 .  BR help
-.  RB [ \-c | \-C | \-\-columns ]
+.  RB [ -c | -C | --columns ]
 ..
 .CMD_HELP
 .
@@ -67,18 +67,18 @@ dmsetup \(em low level logical volume management
 .de CMD_INFOLONG
 .  ad l
 .  BR info
-.  BR \-c | \-C | \-\-columns
-.  RB [ \-\-count
+.  BR -c | -C | --columns
+.  RB [ --count
 .  IR count ]
-.  RB [ \-\-interval
+.  RB [ --interval
 .  IR seconds ]
-.  RB \%[ \-\-nameprefixes ]
-.  RB \%[ \-\-noheadings ]
-.  RB [ \-o
+.  RB \%[ --nameprefixes ]
+.  RB \%[ --noheadings ]
+.  RB [ -o
 .  IR fields ]
-.  RB [ \-O | \-\-sort
+.  RB [ -O | --sort
 .  IR sort_fields ]
-.  RB [ \-\-separator
+.  RB [ --separator
 .  IR separator ]
 .  RI [ device_name ]
 .  ad b
@@ -91,7 +91,7 @@ dmsetup \(em low level logical volume management
 .  ad l
 .  BR load
 .  IR device_name
-.  RB [ \-\-table
+.  RB [ --table
 .  IR table | table_file ]
 .  ad b
 ..
@@ -102,12 +102,12 @@ dmsetup \(em low level logical volume management
 .de CMD_LS
 .  ad l
 .  BR ls
-.  RB [ \-\-target
+.  RB [ --target
 .  IR target_type ]
-.  RB [ \-\-exec
+.  RB [ --exec
 .  IR command ]
-.  RB [ \-\-tree ]
-.  RB [ \-o
+.  RB [ --tree ]
+.  RB [ -o
 .  IR options ]
 .  ad b
 ..
@@ -145,7 +145,7 @@ dmsetup \(em low level logical volume management
 .  ad l
 .  BR reload
 .  IR device_name
-.  RB [ \-\-table
+.  RB [ --table
 .  IR table | table_file ]
 .  ad b
 ..
@@ -156,9 +156,9 @@ dmsetup \(em low level logical volume management
 .de CMD_REMOVE
 .  ad l
 .  BR remove
-.  RB [ \-f | \-\-force ]
-.  RB [ \-\-retry ]
-.  RB [ \-\-deferred ]
+.  RB [ -f | --force ]
+.  RB [ --retry ]
+.  RB [ --deferred ]
 .  IR device_name ...
 .  ad b
 ..
@@ -168,8 +168,8 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_REMOVE_ALL
 .  BR remove_all
-.  RB [ \-f | \-\-force ]
-.  RB [ \-\-deferred ]
+.  RB [ -f | --force ]
+.  RB [ --deferred ]
 ..
 .CMD_REMOVE_ALL
 .
@@ -187,7 +187,7 @@ dmsetup \(em low level logical volume management
 .de CMD_RENAME_UUID
 .  BR rename
 .  IR device_name
-.  BR \-\-setuuid
+.  BR --setuuid
 .  IR uuid
 ..
 .CMD_RENAME_UUID
@@ -198,10 +198,10 @@ dmsetup \(em low level logical volume management
 .  ad l
 .  BR resume
 .  IR device_name ...
-.  RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
-.  RB [ \-\-noflush ]
-.  RB [ \-\-nolockfs ]
-.  RB \%[ \-\-readahead
+.  RB [ --addnodeoncreate | --addnodeonresume ]
+.  RB [ --noflush ]
+.  RB [ --nolockfs ]
+.  RB \%[ --readahead
 .  RB \%[ + ] \fIsectors | auto | none ]
 .  ad b
 ..
@@ -244,9 +244,9 @@ dmsetup \(em low level logical volume management
 .de CMD_STATUS
 .  ad l
 .  BR status
-.  RB [ \-\-target
+.  RB [ --target
 .  IR target_type ]
-.  RB [ \-\-noflush ]
+.  RB [ --noflush ]
 .  RI [ device_name ...]
 .  ad b
 ..
@@ -257,8 +257,8 @@ dmsetup \(em low level logical volume management
 .de CMD_SUSPEND
 .  ad l
 .  BR suspend
-.  RB [ \-\-nolockfs ]
-.  RB [ \-\-noflush ]
+.  RB [ --nolockfs ]
+.  RB [ --noflush ]
 .  IR device_name ...
 .  ad b
 ..
@@ -269,9 +269,9 @@ dmsetup \(em low level logical volume management
 .de CMD_TABLE
 .  ad l
 .  BR table
-.  RB [ \-\-target
+.  RB [ --target
 .  IR target_type ]
-.  RB [ \-\-showkeys ]
+.  RB [ --showkeys ]
 .  RI [ device_name ...]
 .  ad b
 ..
@@ -342,7 +342,7 @@ dmsetup \(em low level logical volume management
 .de CMD_WAIT
 .  ad l
 .  BR wait
-.  RB [ \-\-noflush ]
+.  RB [ --noflush ]
 .  IR device_name
 .  RI [ event_nr ]
 .  ad b
@@ -355,9 +355,9 @@ dmsetup \(em low level logical volume management
 .  ad l
 .  BR wipe_table
 .  IR device_name ...
-.  RB [ \-f | \-\-force ]
-.  RB [ \-\-noflush ]
-.  RB [ \-\-nolockfs ]
+.  RB [ -f | --force ]
+.  RB [ --noflush ]
+.  RB [ --nolockfs ]
 .  ad b
 ..
 .CMD_WIPE_TABLE
@@ -373,7 +373,7 @@ dmsetup \(em low level logical volume management
 .
 .SH DESCRIPTION
 .
-dmsetup manages logical devices that use the device\-mapper driver.
+dmsetup manages logical devices that use the device-mapper driver.
 Devices are created by loading a table that specifies a target for
 each sector (512 bytes) in the logical device.
 
@@ -383,74 +383,74 @@ The second argument is the logical device name or uuid.
 Invoking the dmsetup tool as \fBdevmap_name\fP
 (which is not normally distributed and is supported
 only for historical reasons) is equivalent to
-.BI \%dmsetup\ info\ \-c\ \-\-noheadings\ \-j \ major\  \-m \ minor \c
+.BI \%dmsetup\ info\ -c\ --noheadings\ -j \ major\  -m \ minor \c
 \fR.
 .\" dot above here fixes -Thtml rendering for next HP option
 .
 .SH OPTIONS
 .
 .HP
-.BR \-\-addnodeoncreate
+.BR --addnodeoncreate
 .br
 Ensure \fI/dev/mapper\fP node exists after \fBdmsetup create\fP.
 .
 .HP
-.BR \-\-addnodeonresume
+.BR --addnodeonresume
 .br
 Ensure \fI/dev/mapper\fP node exists after \fBdmsetup resume\fP (default with udev).
 .
 .HP
-.BR \-\-checks
+.BR --checks
 .br
 Perform additional checks on the operations requested and report
 potential problems.  Useful when debugging scripts.
 In some cases these checks may slow down operations noticeably.
 .
 .HP
-.BR \-c | \-C | \-\-columns
+.BR -c | -C | --columns
 .br
 Display output in columns rather than as Field: Value lines.
 .
 .HP
-.BR \-\-count
+.BR --count
 .IR count
 .br
 Specify the number of times to repeat a report. Set this to zero
 continue until interrupted.  The default interval is one second.
 .
 .HP
-.BR \-f | \-\-force
+.BR -f | --force
 .br
 Try harder to complete operation.
 .
 .HP
-.BR \-h | \-\-help
+.BR -h | --help
 .br
 Outputs a summary of the commands available, optionally including
 the list of report fields (synonym with \fBhelp\fP command).
 .
 .HP
-.BR \-\-inactive
+.BR --inactive
 .br
 When returning any table information from the kernel report on the
 inactive table instead of the live table.
 Requires kernel driver version 4.16.0 or above.
 .
 .HP
-.BR \-\-interval
+.BR --interval
 .IR seconds
 .br
 Specify the interval in seconds between successive iterations for
-repeating reports. If \fB\-\-interval\fP is specified but \fB\-\-count\fP
+repeating reports. If \fB--interval\fP is specified but \fB--count\fP
 is not, reports will continue to repeat until interrupted.
 The default interval is one second.
 .
 .HP
-.BR \-\-manglename
+.BR --manglename
 .BR auto | hex | none
 .br
 Mangle any character not on a whitelist using mangling_mode when
-processing device\-mapper device names and UUIDs. The names and UUIDs
+processing device-mapper device names and UUIDs. The names and UUIDs
 are mangled on input and unmangled on output where the mangling mode
 is one of:
 \fBauto\fP (only do the mangling if not mangled yet, do nothing
@@ -458,7 +458,7 @@ if already mangled, error on mixed),
 \fBhex\fP (always do the mangling) and
 \fBnone\fP (no mangling).
 Default mode is \fB#DEFAULT_MANGLING#\fP.
-Character whitelist: 0-9, A\-Z, a\-z, #+-.:=@_. This whitelist is
+Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
 also supported by udev. Any character not on a whitelist is replaced
 with its hex value (two digits) prefixed by \\x.
 Mangling mode could be also set through
@@ -466,69 +466,69 @@ Mangling mode could be also set through
 environment variable.
 .
 .HP
-.BR \-j | \-\-major
+.BR -j | --major
 .IR major
 .br
 Specify the major number.
 .
 .HP
-.BR \-m | \-\-minor
+.BR -m | --minor
 .IR minor
 .br
 Specify the minor number.
 .
 .HP
-.BR \-n | \-\-notable
+.BR -n | --notable
 .br
 When creating a device, don't load any table.
 .
 .HP
-.BR \-\-nameprefixes
+.BR --nameprefixes
 .br
 Add a "DM_" prefix plus the field name to the output.  Useful with
-\fB\-\-noheadings\fP to produce a list of
+\fB--noheadings\fP to produce a list of
 field=value pairs that can be used to set environment variables
 (for example, in
 .BR udev (7)
 rules).
 .
 .HP
-.BR \-\-noheadings
+.BR --noheadings
 Suppress the headings line when using columnar output.
 .
 .HP
-.BR \-\-noflush
+.BR --noflush
 Do not flush outstading I/O when suspending a device, or do not
-commit thin\-pool metadata when obtaining thin\-pool status.
+commit thin-pool metadata when obtaining thin-pool status.
 .
 .HP
-.BR \-\-nolockfs
+.BR --nolockfs
 .br
 Do not attempt to synchronize filesystem eg, when suspending a device.
 .
 .HP
-.BR \-\-noopencount
+.BR --noopencount
 .br
 Tell the kernel not to supply the open reference count for the device.
 .
 .HP
-.BR \-\-noudevrules
+.BR --noudevrules
 .br
-Do not allow udev to manage nodes for devices in device\-mapper directory.
+Do not allow udev to manage nodes for devices in device-mapper directory.
 .
 .HP
-.BR \-\-noudevsync
+.BR --noudevsync
 .br
 Do not synchronise with udev when creating, renaming or removing devices.
 .
 .HP
-.BR \-o | \-\-options
+.BR -o | --options
 .IR options
 .br
 Specify which fields to display.
 .
 .HP
-.BR \-\-readahead
+.BR --readahead
 .RB [ + ] \fIsectors | auto | none
 .br
 Specify read ahead size in units of sectors.
@@ -539,16 +539,16 @@ smaller than the value chosen by the kernel.
 The value \fBnone\fP is equivalent to specifying zero.
 .
 .HP
-.BR \-r | \-\-readonly
+.BR -r | --readonly
 .br
-Set the table being loaded read\-only.
+Set the table being loaded read-only.
 .
 .HP
-.BR \-S | \-\-select
+.BR -S | --select
 .IR selection
 .br
 Display only rows that match \fIselection\fP criteria. All rows are displayed
-with the additional "selected" column (\fB\-o selected\fP) showing 1 if the row
+with the additional "selected" column (\fB-o selected\fP) showing 1 if the row
 matches the \fIselection\fP and 0 otherwise. The selection criteria are defined
 by specifying column names and their valid values while making use of
 supported comparison operators. As a quick help and to see full list of
@@ -557,14 +557,14 @@ selection operators, check the output of \fBdmsetup\ info\ -c\ -S\ help\fP
 command.
 .
 .HP
-.BR \-\-table
+.BR --table
 .IR table
 .br
-Specify a one\-line table directly on the command line.
+Specify a one-line table directly on the command line.
 See below for more information on the table format.
 .
 .HP
-.BR \-\-udevcookie
+.BR --udevcookie
 .IR cookie
 .br
 Use cookie for udev synchronisation.
@@ -573,29 +573,29 @@ multiple different devices. It's not adviced to combine different
 operations on the single device.
 .
 .HP
-.BR \-u | \-\-uuid
+.BR -u | --uuid
 .br
 Specify the \fIuuid\fP.
 .
 .HP
-.BR \-y | \-\-yes
+.BR -y | --yes
 .br
 Answer yes to all prompts automatically.
 .
 .HP
-.BR \-v | \-\-verbose
-.RB [ \-v | \-\-verbose ]
+.BR -v | --verbose
+.RB [ -v | --verbose ]
 .br
 Produce additional output.
 .
 .HP
-.BR \-\-verifyudev
+.BR --verifyudev
 .br
 If udev synchronisation is enabled, verify that udev operations get performed
 correctly and try to fix up the device nodes afterwards if not.
 .
 .HP
-.BR \-\-version
+.BR --version
 .br
 Display the library and kernel driver version.
 .br
@@ -612,7 +612,7 @@ Destroys the table in the inactive table slot for device_name.
 .br
 Creates a device with the given name.
 If \fItable\fP or \fItable_file\fP is supplied, the table is loaded and made live.
-Otherwise a table is read from standard input unless \fB\-\-notable\fP is used.
+Otherwise a table is read from standard input unless \fB--notable\fP is used.
 The optional \fIuuid\fP can be used in place of
 device_name in subsequent dmsetup commands.
 If successful the device will appear in table and for live
@@ -626,7 +626,7 @@ Outputs a list of devices referenced by the live table for the specified
 device. Device names on output can be customised by following \fIoptions\fP:
 \fBdevno\fP (major and minor pair, used by default),
 \fBblkdevname\fP (block device name),
-\fBdevname\fP (map name for device\-mapper devices, equal to blkdevname otherwise).
+\fBdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).
 .
 .HP
 .CMD_HELP
@@ -640,7 +640,7 @@ the list of report fields.
 Outputs some brief information about the device in the form:
 .RS
 .RS
- State: SUSPENDED|ACTIVE, READ\-ONLY
+ State: SUSPENDED|ACTIVE, READ-ONLY
  Tables present: LIVE and/or INACTIVE
  Open reference count
  Last event sequence number (used by \fBwait\fP)
@@ -653,7 +653,7 @@ Outputs some brief information about the device in the form:
 .CMD_INFOLONG
 .br
 Output you can customise.
-Fields are comma\-separated and chosen from the following list:
+Fields are comma-separated and chosen from the following list:
 .BR name ,
 .BR major ,
 .BR minor ,
@@ -666,11 +666,11 @@ Attributes are:
 .RI ( L )ive,
 .RI ( I )nactive,
 .RI ( s )uspended,
-.RI ( r )ead\-only,
-.RI read\-( w )rite.
+.RI ( r )ead-only,
+.RI read-( w )rite.
 Precede the list with '\fB+\fP' to append
 to the default selection of columns instead of replacing it.
-Precede any sort field with '\fB\-\fP' for a reverse sort on that column.
+Precede any sort field with '\fB-\fP' for a reverse sort on that column.
 .
 .HP
 .CMD_LS
@@ -681,9 +681,9 @@ each device.  The device name is appended to the supplied command.
 Device names on output can be customised by following options:
 \fBdevno\fP (major and minor pair, used by default),
 \fBblkdevname\fP (block device name),
-\fBdevname\fP (map name for device\-mapper devices, equal to blkdevname otherwise).
-\fB\-\-tree\fP displays dependencies between devices as a tree.
-It accepts a comma\-separate list of \fIoptions\fP.
+\fBdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).
+\fB--tree\fP displays dependencies between devices as a tree.
+It accepts a comma-separate list of \fIoptions\fP.
 Some specify the information displayed against each node:
 .BR device / nodevice ;
 .BR blkdevname ;
@@ -702,14 +702,14 @@ If neither is supplied, reads a table from standard input.
 .HP
 .CMD_MANGLE
 .br
-Ensure existing device\-mapper \fIdevice_name\fP and UUID is in the correct mangled
+Ensure existing device-mapper \fIdevice_name\fP and UUID is in the correct mangled
 form containing only whitelisted characters (supported by udev) and do
 a rename if necessary. Any character not on the whitelist will be mangled
-based on the \fB\-\-manglename\fP setting. Automatic rename works only for device
+based on the \fB--manglename\fP setting. Automatic rename works only for device
 names and not for device UUIDs because the kernel does not allow changing
 the UUID of active devices. Any incorrect UUIDs are reported only and they
 must be manually corrected by deactivating the device first and then
-reactivating it with proper mangling mode used (see also \fB\-\-manglename\fP).
+reactivating it with proper mangling mode used (see also \fB--manglename\fP).
 .
 .HP
 .CMD_MESSAGE
@@ -721,23 +721,23 @@ Send message to target. If sector not needed use 0.
 .br
 Ensure that the node in \fI/dev/mapper\fP for \fIdevice_name\fP is correct.
 If no device_name is supplied, ensure that all nodes in \fI/dev/mapper\fP
-correspond to mapped devices currently loaded by the device\-mapper kernel
+correspond to mapped devices currently loaded by the device-mapper kernel
 driver, adding, changing or removing nodes as necessary.
 .
 .HP
 .CMD_REMOVE
 .br
 Removes a device.  It will no longer be visible to dmsetup.  Open devices
-cannot be removed, but adding \fB\-\-force\fP will replace the table with one
-that fails all I/O.  \fB\-\-deferred\fP will enable deferred removal of open
+cannot be removed, but adding \fB--force\fP will replace the table with one
+that fails all I/O.  \fB--deferred\fP will enable deferred removal of open
 devices - the device will be removed when the last user closes it. The deferred
-removal feature is supported since version 4.27.0 of the device\-mapper
+removal feature is supported since version 4.27.0 of the device-mapper
 driver available in upstream kernel version 3.13.  (Use \fBdmsetup version\fP
 to check this.)  If an attempt to remove a device fails, perhaps because a process run
-from a quick udev rule temporarily opened the device, the \fB\-\-retry\fP
+from a quick udev rule temporarily opened the device, the \fB--retry\fP
 option will cause the operation to be retried for a few seconds before failing.
 Do NOT combine
-\fB\-\-force\fP and \fB\-\-udevcookie\fP, as udev may start to process udev
+\fB--force\fP and \fB--udevcookie\fP, as udev may start to process udev
 rules in the middle of error target replacement and result in nondeterministic
 result.
 .
@@ -746,10 +746,10 @@ result.
 .br
 Attempts to remove all device definitions i.e. reset the driver.  This also runs
 \fBmknodes\fP afterwards.  Use with care!  Open devices cannot be removed, but
-adding \fB\-\-force\fP will replace the table with one that fails all I/O.
-\fB\-\-deferred\fP will enable deferred removal of open devices - the device
+adding \fB--force\fP will replace the table with one that fails all I/O.
+\fB--deferred\fP will enable deferred removal of open devices - the device
 will be removed when the last user closes it.  The deferred removal feature is
-supported since version 4.27.0 of the device\-mapper driver available in
+supported since version 4.27.0 of the device-mapper driver available in
 upstream kernel version 3.13.
 .
 .HP
@@ -766,9 +766,9 @@ After a uuid has been set it cannot be changed.
 .HP
 .CMD_RESUME
 .br
-Un\-suspends a device.
+Un-suspends a device.
 If an inactive table has been loaded, it becomes live.
-Postponed I/O then gets re\-queued for processing.
+Postponed I/O then gets re-queued for processing.
 .
 .HP
 .CMD_SETGEOMETRY
@@ -797,8 +797,8 @@ for more details.
 .CMD_STATUS
 .br
 Outputs status information for each of the device's targets.
-With \fB\-\-target\fP, only information relating to the specified target type
-any is displayed.  With \fB\-\-noflush\fP, the thin target (from version 1.3.0)
+With \fB--target\fP, only information relating to the specified target type
+any is displayed.  With \fB--noflush\fP, the thin target (from version 1.3.0)
 doesn't commit any outstanding changes to disk before reporting its statistics.
 
 .HP
@@ -808,9 +808,9 @@ Suspends a device.  Any I/O that has already been mapped by the device
 but has not yet completed will be flushed.  Any further I/O to that
 device will be postponed for as long as the device is suspended.
 If there's a filesystem on the device which supports the operation,
-an attempt will be made to sync it first unless \fB\-\-nolockfs\fP is specified.
+an attempt will be made to sync it first unless \fB--nolockfs\fP is specified.
 Some targets such as recent (October 2006) versions of multipath may support
-the \fB\-\-noflush\fP option.  This lets outstanding I/O that has not yet reached the
+the \fB--noflush\fP option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
 .
 .HP
@@ -818,17 +818,17 @@ device to remain unflushed.
 .br
 Outputs the current table for the device in a format that can be fed
 back in using the create or load commands.
-With \fB\-\-target\fP, only information relating to the specified target type
+With \fB--target\fP, only information relating to the specified target type
 is displayed.
 Real encryption keys are suppressed in the table output for the crypt
-target unless the \fB\-\-showkeys\fP parameter is supplied. Kernel key
+target unless the \fB--showkeys\fP parameter is supplied. Kernel key
 references prefixed with \fB:\fP are not affected by the parameter and get
 displayed always.
 .
 .HP
 .CMD_TARGETS
 .br
-Displays the names and versions of the currently\-loaded targets.
+Displays the names and versions of the currently-loaded targets.
 .
 .HP
 .CMD_UDEVCOMPLETE
@@ -844,7 +844,7 @@ Any process waiting on a cookie will be resumed immediately.
 .HP
 .CMD_UDEVCOOKIES
 .br
-List all existing cookies. Cookies are system\-wide semaphores with keys
+List all existing cookies. Cookies are system-wide semaphores with keys
 prefixed by two predefined bytes (0x0D4D).
 .
 .HP
@@ -855,10 +855,10 @@ The output is a cookie value. Normally we don't need to create cookies since
 dmsetup creates and destroys them for each action automatically. However, we can
 generate one explicitly to group several actions together and use only one
 cookie instead. We can define a cookie to use for each relevant command by using
-\fB\-\-udevcookie\fP option. Alternatively, we can export this value into the environment
+\fB--udevcookie\fP option. Alternatively, we can export this value into the environment
 of the dmsetup process as \fBDM_UDEV_COOKIE\fP variable and it will be used automatically
 with all subsequent commands until it is unset.
-Invoking this command will create system\-wide semaphore that needs to be cleaned
+Invoking this command will create system-wide semaphore that needs to be cleaned
 up explicitly by calling udevreleasecookie command.
 .
 .HP
@@ -888,16 +888,16 @@ Outputs version information.
 .CMD_WAIT
 .br
 Sleeps until the event counter for device_name exceeds event_nr.
-Use \fB\-v\fP to see the event number returned.
+Use \fB-v\fP to see the event number returned.
 To wait until the next event is triggered, use \fBinfo\fP to find
 the last event number.
-With \fB\-\-noflush\fP, the thin target (from version 1.3.0) doesn't commit
+With \fB--noflush\fP, the thin target (from version 1.3.0) doesn't commit
 any outstanding changes to disk before reporting its statistics.
 .
 .HP
 .CMD_WIPE_TABLE
 .br
-Wait for any I/O in\-flight through the device to complete, then
+Wait for any I/O in-flight through the device to complete, then
 replace the table with a new table that fails any new I/O
 sent to the device.  If successful, this should release any devices
 held open by the device's table(s).
@@ -937,8 +937,8 @@ for creating devices with holes in them.
 .TP
 .B zero
 Returns blocks of zeroes on reads.  Any data written is discarded silently.
-This is a block\-device equivalent of the \fI/dev/zero\fP
-character\-device data sink described in \fBnull\fP(4).
+This is a block-device equivalent of the \fI/dev/zero\fP
+character-device data sink described in \fBnull\fP(4).
 .P
 More complex targets include:
 .TP
@@ -969,14 +969,14 @@ Offers an interface to the kernel's software raid driver, md.
 .B snapshot
 Supports snapshots of devices.
 .TP
-.BR thin ", " thin\-pool
+.BR thin ", " thin-pool
 Supports thin provisioning of devices and also provides a better snapshot support.
 .P
 To find out more about the various targets and their table formats and status
-lines, please read the files in the Documentation/device\-mapper directory in
+lines, please read the files in the Documentation/device-mapper directory in
 the kernel source tree.
 (Your distribution might include a copy of this information in the
-documentation directory for the device\-mapper package.)
+documentation directory for the device-mapper package.)
 .
 .SH EXAMPLES
 .
@@ -1005,11 +1005,11 @@ Defaults to "\fI/dev\fP" and must be an absolute path.
 .TP
 .B DM_UDEV_COOKIE
 A cookie to use for all relevant commands to synchronize with udev processing.
-It is an alternative to using \fB\-\-udevcookie\fP option.
+It is an alternative to using \fB--udevcookie\fP option.
 .TP
 .B DM_DEFAULT_NAME_MANGLING_MODE
 A default mangling mode. Defaults to "\fB#DEFAULT_MANGLING#\fP"
-and it is an alternative to using \fB\-\-manglename\fP option.
+and it is an alternative to using \fB--manglename\fP option.
 .
 .SH AUTHORS
 .
@@ -1023,4 +1023,4 @@ Original version: Joe Thornber <thornber@redhat.com>
 .P
 LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
-Device\-mapper resource page: http://sources.redhat.com/dm/
+Device-mapper resource page: http://sources.redhat.com/dm/
diff --git a/man/dmstats.8_main b/man/dmstats.8_main
index b1dda64..da9d934 100644
--- a/man/dmstats.8_main
+++ b/man/dmstats.8_main
@@ -1,21 +1,21 @@
 .TH DMSTATS 8 "Jun 23 2016" "Linux" "MAINTENANCE COMMANDS"
 
 .de OPT_PROGRAMS
-.  RB \%[ \-\-allprograms | \-\-programid
+.  RB \%[ --allprograms | --programid
 .  IR id ]
 ..
 .
 .de OPT_REGIONS
-.  RB \%[ \-\-allregions | \-\-regionid
+.  RB \%[ --allregions | --regionid
 .  IR id ]
 ..
 .de OPT_OBJECTS
-.  RB [ \-\-area ]
-.  RB [ \-\-region ]
-.  RB [ \-\-group ]
+.  RB [ --area ]
+.  RB [ --region ]
+.  RB [ --group ]
 ..
 .de OPT_FOREGROUND
-.  RB [ \-\-foreground ]
+.  RB [ --foreground ]
 ..
 .
 .\" Print units suffix, use with arg to print human
@@ -40,7 +40,7 @@
 .
 .SH NAME
 .
-dmstats \(em device\-mapper statistics management
+dmstats \(em device-mapper statistics management
 .
 .SH SYNOPSIS
 .
@@ -57,13 +57,13 @@ dmstats \(em device\-mapper statistics management
 .  ad l
 .  IR command
 .  IR device_name " |"
-.  BR \-\-major
+.  BR --major
 .  IR major
-.  BR \-\-minor
+.  BR --minor
 .  IR minor " |"
-.  BR \-u | \-\-uuid
+.  BR -u | --uuid
 .  IR uuid
-.  RB \%[ \-v | \-\-verbose]
+.  RB \%[ -v | --verbose]
 .  ad b
 ..
 .CMD_COMMAND
@@ -85,26 +85,26 @@ dmstats \(em device\-mapper statistics management
 .de CMD_CREATE
 .  ad l
 .  BR create
-.  IR device_name... | file_path... | \fB\-\-alldevices
-.  RB [ \-\-areas
-.  IR nr_areas | \fB\-\-areasize
+.  IR device_name... | file_path... | \fB--alldevices
+.  RB [ --areas
+.  IR nr_areas | \fB--areasize
 .  IR area_size ]
-.  RB [ \-\-bounds
+.  RB [ --bounds
 .  IR \%histogram_boundaries ]
-.  RB [ \-\-filemap ]
-.  RB [ \-\-follow
+.  RB [ --filemap ]
+.  RB [ --follow
 .  IR follow_mode ]
 .  OPT_FOREGROUND
-.  RB [ \-\-nomonitor ]
-.  RB [ \-\-nogroup ]
-.  RB [ \-\-precise ]
-.  RB [ \-\-start
+.  RB [ --nomonitor ]
+.  RB [ --nogroup ]
+.  RB [ --precise ]
+.  RB [ --start
 .  IR start_sector
-.  BR \-\-length
-.  IR length | \fB\-\-segments ]
-.  RB \%[ \-\-userdata
+.  BR --length
+.  IR length | \fB--segments ]
+.  RB \%[ --userdata
 .  IR user_data ]
-.  RB [ \-\-programid
+.  RB [ --programid
 .  IR id ]
 .  ad b
 ..
@@ -115,7 +115,7 @@ dmstats \(em device\-mapper statistics management
 .de CMD_DELETE
 .  ad l
 .  BR delete
-.  IR device_name | \fB\-\-alldevices
+.  IR device_name | \fB--alldevices
 .  OPT_PROGRAMS
 .  OPT_REGIONS
 .  ad b
@@ -127,10 +127,10 @@ dmstats \(em device\-mapper statistics management
 .de CMD_GROUP
 .  ad l
 .  BR group
-.  RI [ device_name | \fB\-\-alldevices ]
-.  RB [ \-\-alias
+.  RI [ device_name | \fB--alldevices ]
+.  RB [ --alias
 .  IR name ]
-.  RB [ \-\-regions
+.  RB [ --regions
 .  IR regions ]
 .  ad b
 ..
@@ -140,7 +140,7 @@ dmstats \(em device\-mapper statistics management
 .de CMD_HELP
 .  ad l
 .  BR help
-.  RB [ \-c | \-C | \-\-columns ]
+.  RB [ -c | -C | --columns ]
 .  ad b
 ..
 .CMD_HELP
@@ -151,14 +151,14 @@ dmstats \(em device\-mapper statistics management
 .  ad l
 .  BR list
 .  RI [ device_name ]
-.  RB [ \-\-histogram ]
+.  RB [ --histogram ]
 .  OPT_PROGRAMS
-.  RB [ \-\-units
+.  RB [ --units
 .  IR units ]
 .  OPT_OBJECTS
-.  RB \%[ \-\-nosuffix ]
-.  RB [ \-\-notimesuffix ]
-.  RB \%[ \-v | \-\-verbose]
+.  RB \%[ --nosuffix ]
+.  RB [ --notimesuffix ]
+.  RB \%[ -v | --verbose]
 .  ad b
 ..
 .CMD_LIST
@@ -169,7 +169,7 @@ dmstats \(em device\-mapper statistics management
 .  ad l
 .  BR print
 .  RI [ device_name ]
-.  RB [ \-\-clear ]
+.  RB [ --clear ]
 .  OPT_PROGRAMS
 .  OPT_REGIONS
 .  ad b
@@ -182,24 +182,24 @@ dmstats \(em device\-mapper statistics management
 .  ad l
 .  BR report
 .  RI [ device_name ]
-.  RB [ \-\-interval
+.  RB [ --interval
 .  IR seconds ]
-.  RB [ \-\-count
+.  RB [ --count
 .  IR count ]
-.  RB [ \-\-units
+.  RB [ --units
 .  IR units ]
-.  RB [ \-\-histogram ]
+.  RB [ --histogram ]
 .  OPT_PROGRAMS
 .  OPT_REGIONS
 .  OPT_OBJECTS
-.  RB [ \-O | \-\-sort
+.  RB [ -O | --sort
 .  IR sort_fields ]
-.  RB [ \-S | \-\-select
+.  RB [ -S | --select
 .  IR selection ]
-.  RB [ \-\-units
+.  RB [ --units
 .  IR units ]
-.  RB [ \-\-nosuffix ]
-.  RB \%[ \-\-notimesuffix ]
+.  RB [ --nosuffix ]
+.  RB \%[ --notimesuffix ]
 .  ad b
 ..
 .CMD_REPORT
@@ -208,8 +208,8 @@ dmstats \(em device\-mapper statistics management
 .de CMD_UNGROUP
 .  ad l
 .  BR ungroup
-.  RI [ device_name | \fB\-\-alldevices ]
-.  RB [ \-\-groupid
+.  RI [ device_name | \fB--alldevices ]
+.  RB [ --groupid
 .  IR id ]
 .  ad b
 ..
@@ -220,9 +220,9 @@ dmstats \(em device\-mapper statistics management
 .  ad l
 .  BR update_filemap
 .  IR file_path
-.  RB [ \-\-groupid
+.  RB [ --groupid
 .  IR id ]
-.  RB [ \-\-follow
+.  RB [ --follow
 .  IR follow_mode ]
 .  OPT_FOREGROUND
 .  ad b
@@ -235,7 +235,7 @@ dmstats \(em device\-mapper statistics management
 .SH DESCRIPTION
 .
 The dmstats program manages IO statistics regions for devices that use
-the device\-mapper driver. Statistics regions may be created, deleted,
+the device-mapper driver. Statistics regions may be created, deleted,
 listed and reported on using the tool.
 
 The first argument to dmstats is a \fIcommand\fP.
@@ -247,48 +247,48 @@ Further options permit the selection of regions, output format
 control, and reporting behaviour.
 
 When no device argument is given dmstats will by default operate on all
-device\-mapper devices present. The \fBcreate\fP and \fBdelete\fP
-commands require the use of \fB\-\-alldevices\fP when used in this way.
+device-mapper devices present. The \fBcreate\fP and \fBdelete\fP
+commands require the use of \fB--alldevices\fP when used in this way.
 .
 .SH OPTIONS
 .
 .HP
-.BR \-\-alias
+.BR --alias
 .IR name
 .br
 Specify an alias name for a group.
 .
 .HP
-.BR \-\-alldevices
+.BR --alldevices
 .br
 If no device arguments are given allow operation on all devices when
 creating or deleting regions.
 .
 .HP
-.BR \-\-allprograms
+.BR --allprograms
 .br
 Include regions from all program IDs for list and report operations.
 .br
 .HP
-.BR \-\-allregions
+.BR --allregions
 .br
 Include all present regions for commands that normally accept a single
 region identifier.
 .
 .HP
-.BR \-\-area
+.BR --area
 .br
 When peforming a list or report, include objects of type area in the
 results.
 .
 .HP
-.BR \-\-areas
+.BR --areas
 .IR nr_areas
 .br
 Specify the number of statistics areas to create within a new region.
 .
 .HP
-.BR \-\-areasize
+.BR --areasize
 .IR area_size \c
 .RB [ \c
 .UNITS
@@ -298,45 +298,45 @@ optional suffix selects units of:
 .HELP_UNITS
 .
 .HP
-.BR \-\-clear
+.BR --clear
 .br
 When printing statistics counters, also atomically reset them to zero.
 .
 .HP
-.BR \-\-count
+.BR --count
 .IR count
 .br
 Specify the iteration count for repeating reports. If the count
 argument is zero reports will continue to repeat until interrupted.
 .
 .HP
-.BR \-\-group
+.BR --group
 .br
 When peforming a list or report, include objects of type group in the
 results.
 .
 .HP
-.BR \-\-filemap
+.BR --filemap
 .br
 Instead of creating regions on a device as specified by command line
 options, open the file found at each \fBfile_path\fP argument, and
-create regions corresponding to the locations of the on\-disk extents
+create regions corresponding to the locations of the on-disk extents
 allocated to the file(s).
 .
 .HP
-.BR \-\-nomonitor
+.BR --nomonitor
 .br
 Disable the \fBdmfilemapd\fP daemon when creating new file mapped
-groups. Normally the device\-mapper filemap monitoring daemon,
+groups. Normally the device-mapper filemap monitoring daemon,
 \fBdmfilemapd\fP, is started for each file mapped group to update the
-set of regions as the file changes on\-disk: use of this option
+set of regions as the file changes on-disk: use of this option
 disables this behaviour.
 
 Regions in the group may still be updated with the
 \fBupdate_filemap\fP command, or by starting the daemon manually.
 .
 .HP
-.BR \-\-follow
+.BR --follow
 .IR follow_mode
 .br
 Specify the \fBdmfilemapd\fP file following mode. The file map
@@ -345,46 +345,46 @@ affects the behaviour of the daemon when a file under monitoring is
 renamed or unlinked, and the conditions which cause the daemon to
 terminate.
 
-The \fBfollow_mode\fP argument is either "inode", for follow\-inode
-mode, or "path", for follow\-path.
+The \fBfollow_mode\fP argument is either "inode", for follow-inode
+mode, or "path", for follow-path.
 
-If follow\-inode mode is used, the daemon will hold the file open, and
+If follow-inode mode is used, the daemon will hold the file open, and
 continue to update regions from the same file descriptor. This means
 that the mapping will follow rename, move (within the same file
 system), and unlink operations. This mode is useful if the file is
 expected to be moved, renamed, or unlinked while it is being
 monitored.
 
-In follow\-inode mode, the daemon will exit once it detects that the
+In follow-inode mode, the daemon will exit once it detects that the
 file has been unlinked and it is the last holder of a reference to it.
 
-If follow\-path is used, the daemon will re\-open the provided path on
+If follow-path is used, the daemon will re-open the provided path on
 each monitoring iteration. This means that the group will be updated
 to reflect a new file being moved to the same path as the original
 file. This mode is useful for files that are expected to be updated
 via unlink and rename.
 
-In follow\-path mode, the daemon will exit if the file is removed and
+In follow-path mode, the daemon will exit if the file is removed and
 not replaced within a brief tolerance interval.
 
 In either mode, the daemon exits automatically if the monitored group
 is removed.
 .
 .HP
-.BR \-\-foreground
+.BR --foreground
 .br
 Specify that the \fBdmfilemapd\fP daemon should run in the foreground.
 The daemon will not fork into the background, and will replace the
 \fBdmstats\fP command that started it.
 .
 .HP
-.BR \-\-groupid
+.BR --groupid
 .IR id
 .br
 Specify the group to operate on.
 .
 .HP
-.BR \-\-bounds
+.BR --bounds
 .IR histogram_boundaries \c
 .RB [ ns | us | ms | s ]
 .br
@@ -398,22 +398,22 @@ or \fBs\fP may be given after each value to specify units of
 nanoseconds, microseconds, miliseconds or seconds respectively.
 .
 .HP
-.BR \-\-histogram
+.BR --histogram
 .br
 When used with the \fBreport\fP and \fBlist\fP commands select default
 fields that emphasize latency histogram data.
 .
 .HP
-.BR \-\-interval
+.BR --interval
 .IR seconds
 .br
 Specify the interval in seconds between successive iterations for
-repeating reports. If \fB\-\-interval\fP is specified but
-\fB\-\-count\fP is not,
+repeating reports. If \fB--interval\fP is specified but
+\fB--count\fP is not,
 reports will continue to repeat until interrupted.
 .
 .HP
-.BR \-\-length
+.BR --length
 .IR length \c
 .RB [ \c
 .UNITS
@@ -423,100 +423,100 @@ suffix selects units of:
 .HELP_UNITS
 .
 .HP
-.BR \-j | \-\-major
+.BR -j | --major
 .IR major
 .br
 Specify the major number.
 .
 .HP
-.BR \-m | \-\-minor
+.BR -m | --minor
 .IR minor
 .br
 Specify the minor number.
 .
 .HP
-.BR \-\-nogroup
+.BR --nogroup
 .br
 When creating regions mapping the extents of a file in the file
 system, do not create a group or set an alias.
 .
 .HP
-.BR \-\-nosuffix
+.BR --nosuffix
 .br
-Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
+Suppress the suffix on output sizes.  Use with \fB--units\fP
 (except h and H) if processing the output.
 .
 .HP
-.BR \-\-notimesuffix
+.BR --notimesuffix
 .br
 Suppress the suffix on output time values. Histogram boundary values
 will be reported in units of nanoseconds.
 .
 .HP
-.BR \-o | \-\-options
+.BR -o | --options
 .br
 Specify which report fields to display.
 .
 .HP
-.BR \-O | \-\-sort
+.BR -O | --sort
 .IR sort_fields
 .br
 Sort output according to the list of fields given. Precede any
-sort field with '\fB\-\fP' for a reverse sort on that column.
+sort field with '\fB-\fP' for a reverse sort on that column.
 .
 .HP
-.BR \-\-precise
+.BR --precise
 .br
 Attempt to use nanosecond precision counters when creating new
 statistics regions.
 .
 .HP
-.BR \-\-programid
+.BR --programid
 .IR id
 .br
 Specify a program ID string. When creating new statistics regions this
 string is stored with the region. Subsequent operations may supply a
 program ID in order to select only regions with a matching value. The
-default program ID for dmstats\-managed regions is "dmstats".
+default program ID for dmstats-managed regions is "dmstats".
 .
 .HP
-.BR \-\-region
+.BR --region
 .br
 When peforming a list or report, include objects of type region in the
 results.
 .
 .HP
-.BR \-\-regionid
+.BR --regionid
 .IR id
 .br
 Specify the region to operate on.
 .
 .HP
-.BR \-\-regions
+.BR --regions
 .IR region_list
 .br
-Specify a list of regions to group. The group list is a comma\-separated
+Specify a list of regions to group. The group list is a comma-separated
 list of region identifiers. Continuous sequences of identifiers may be
 expressed as a hyphen separated range, for example: '1-10'.
 .
 .HP
-.BR \-\-relative
+.BR --relative
 .br
 If displaying the histogram report show relative (percentage) values
 instead of absolute counts.
 .
 .HP
-.BR \-S | \-\-select
+.BR -S | --select
 .IR selection
 .br
 Display only rows that match \fIselection\fP criteria. All rows with the
-additional "selected" column (\fB\-o selected\fP) showing 1 if the row matches
+additional "selected" column (\fB-o selected\fP) showing 1 if the row matches
 the \fIselection\fP and 0 otherwise. The selection criteria are defined by
 specifying column names and their valid values while making use of
 supported comparison operators.
 .
 .HP
-.BR \-\-start
+.BR --start
 .IR start \c
 .RB [ \c
 .UNITS
@@ -526,30 +526,30 @@ optional suffix selects units of:
 .HELP_UNITS
 .
 .HP
-.BR \-\-segments
+.BR --segments
 .br
 When used with \fBcreate\fP, create a new statistics region for each
 target contained in the given device(s). This causes a separate region
 to be allocated for each segment of the device.
 
 The newly created regions are automatically placed into a group unless
-the \fB\-\-nogroup\fP option is given. When grouping is enabled a group
-alias may be specified using the \fB\-\-alias\fP option.
+the \fB--nogroup\fP option is given. When grouping is enabled a group
+alias may be specified using the \fB--alias\fP option.
 .
 .HP
-.BR \-\-units
+.BR --units
 .RI [ units ] \c
 .RB [ h | H | \c
 .UNITS
 .br
 Set the display units for report output.
 All sizes are output in these units:
-.RB ( h )uman\-readable,
+.RB ( h )uman-readable,
 .HELP_UNITS
-Can also specify custom units e.g. \fB\-\-units\ 3M\fP.
+Can also specify custom units e.g. \fB--units\ 3M\fP.
 .
 .HP
-.BR \-\-userdata
+.BR --userdata
 .IR user_data
 .br
 Specify user data (a word) to be stored with a new region. The value
@@ -558,12 +558,12 @@ information), and stored with the region in the aux_data field provided
 by the kernel. Whitespace is not permitted.
 .
 .HP
-.BR \-u | \-\-uuid
+.BR -u | --uuid
 .br
 Specify the uuid.
 .
 .HP
-.BR \-v | \-\-verbose " [" \-v | \-\-verbose ]
+.BR -v | --verbose " [" -v | --verbose ]
 .br
 Produce additional output.
 .
@@ -573,24 +573,24 @@ Produce additional output.
 .CMD_CLEAR
 .br
 Instructs the kernel to clear statistics counters for the speficied
-regions (with the exception of in\-flight IO counters).
+regions (with the exception of in-flight IO counters).
 .
 .HP
 .CMD_CREATE
 .br
 Creates one or more new statistics regions on the specified device(s).
 
-The region will span the entire device unless \fB\-\-start\fP and
-\fB\-\-length\fP or \fB\-\-segments\fP are given. The \fB\-\-start\fP an
-\fB\-\-length\fP options allow a region of arbitrary length to be placed
-at an arbitrary offset into the device. The \fB\-\-segments\fP option
+The region will span the entire device unless \fB--start\fP and
+\fB--length\fP or \fB--segments\fP are given. The \fB--start\fP an
+\fB--length\fP options allow a region of arbitrary length to be placed
+at an arbitrary offset into the device. The \fB--segments\fP option
 causes a new region to be created for each target in the corresponding
-device\-mapper device's table.
+device-mapper device's table.
 
-If the \fB\-\-precise\fP option is used the command will attempt to
+If the \fB--precise\fP option is used the command will attempt to
 create a region using nanosecond precision counters.
 
-If \fB\-\-bounds\fP is given a latency histogram will be tracked for
+If \fB--bounds\fP is given a latency histogram will be tracked for
 the new region. The boundaries of the histogram bins are given as a
 comma separated list of latency values. There is an implicit lower bound
 of zero on the first bin and an implicit upper bound of infinity (or the
@@ -601,14 +601,14 @@ ms, or s may be given after each value to specify units of nanoseconds,
 microseconds, miliseconds or seconds respectively, so for example, 10ms
 is equivalent to 10000000. Latency values with a precision of less than
 one milisecond can only be used when precise timestamps are enabled: if
-\fB\-\-precise\fP is not given and values less than one milisecond are
+\fB--precise\fP is not given and values less than one milisecond are
 used it will be enabled automatically.
 
 An optional \fBprogram_id\fP or \fBuser_data\fP string may be associated
 with the region. A \fBprogram_id\fP may then be used to select regions
 for subsequent list, print, and report operations. The \fBuser_data\fP
 stores an arbitrary string and is not used by dmstats or the
-device\-mapper kernel statistics subsystem.
+device-mapper kernel statistics subsystem.
 
 By default dmstats creates regions with a \fBprogram_id\fP of
 "dmstats".
@@ -616,7 +616,7 @@ By default dmstats creates regions with a \fBprogram_id\fP of
 On success the \fBregion_id\fP of the newly created region is printed
 to stdout.
 
-If the \fB\-\-filemap\fP option is given with a regular file, or list
+If the \fB--filemap\fP option is given with a regular file, or list
 of files, as the \fBfile_path\fP argument, instead of creating regions
 with parameters specified on the command line, \fBdmstats\fP will open
 the files located at \fBfile_path\fP and create regions corresponding to
@@ -624,20 +624,20 @@ the physical extents allocated to the file. This can be used to monitor
 statistics for individual files in the file system, for example, virtual
 machine images, swap areas, or large database files.
 
-To work with the \fB\-\-filemap\fP option, files must be located on a
-local file system, backed by a device\-mapper device, that supports
+To work with the \fB--filemap\fP option, files must be located on a
+local file system, backed by a device-mapper device, that supports
 physical extent data using the FIEMAP ioctl (Ext4 and XFS for e.g.).
 
 By default regions that map a file are placed into a group and the
 group alias is set to the basename of the file. This behaviour can be
-overridden with the \fB\-\-alias\fP and \fB\-\-nogroup\fP options.
+overridden with the \fB--alias\fP and \fB--nogroup\fP options.
 
 Creating a group that maps a file automatically starts a daemon,
 \fBdmfilemapd\fP to monitor the file and update the mapping as the
 extents allocated to the file change. This behaviour can be disabled
-using the \fB\-\-nomonitor\fP option.
+using the \fB--nomonitor\fP option.
 
-Use the \fB\-\-group\fP option to only display information for groups
+Use the \fB--group\fP option to only display information for groups
 when listing and reporting.
 .
 .HP
@@ -648,12 +648,12 @@ by the region are released and the region will not appear in the output
 of subsequent list, print, or report operations.
 
 All regions registered on a device may be removed using
-\fB\-\-allregions\fP.
+\fB--allregions\fP.
 
-To remove all regions on all devices both \fB\-\-allregions\fP and
-\fB\-\-alldevices\fP must be used.
+To remove all regions on all devices both \fB--allregions\fP and
+\fB--alldevices\fP must be used.
 
-If a \fB\-\-groupid\fP is given instead of a \fB\-\-regionid\fP the
+If a \fB--groupid\fP is given instead of a \fB--regionid\fP the
 command will attempt to delete the group and all regions that it
 contains.
 
@@ -666,11 +666,11 @@ will also be removed.
 Combine one or more statistics regions on the specified device into a
 group.
 
-The list of regions to be grouped is specified with \fB\-\-regions\fP
-and an optional alias may be assigned with \fB\-\-alias\fP. The set of
-regions is given as a comma\-separated list of region identifiers. A
+The list of regions to be grouped is specified with \fB--regions\fP
+and an optional alias may be assigned with \fB--alias\fP. The set of
+regions is given as a comma-separated list of region identifiers. A
 continuous range of identifers spanning from \fBR1\fP to \fBR2\fP may
-be expressed as '\fBR1\fP\-\fBR2\fP'.
+be expressed as '\fBR1\fP-\fBR2\fP'.
 
 Regions that have a histogram configured can be grouped: in this case
 the number of histogram bins and their bounds must match exactly.
@@ -693,21 +693,21 @@ the list of report fields.
 .CMD_LIST
 .br
 List the statistics regions, areas, or groups registered on the device.
-If the \fB\-\-allprograms\fP switch is given all regions will be listed
+If the \fB--allprograms\fP switch is given all regions will be listed
 regardless of region program ID values.
 
 By default only regions and groups are included in list output. If
-\fB\-v\fP or \fB\-\-verbose\fP is given the report will also include a
+\fB-v\fP or \fB--verbose\fP is given the report will also include a
 row of information for each configured group and for each area contained
 in each region displayed.
 
 Regions that contain a single area are by default omitted from the
 verbose list since their properties are identical to the area that they
 contain - to view all regions regardless of the number of areas present
-use \fB\-\-region\fP). To also view the areas contained within regions
-use \fB\-\-area\fP.
+use \fB--region\fP). To also view the areas contained within regions
+use \fB--area\fP.
 
-If \fB\-\-histogram\fP is given the report will include the bin count
+If \fB--histogram\fP is given the report will include the bin count
 and latency boundary values for any configured histograms.
 .HP
 .CMD_PRINT
@@ -720,20 +720,20 @@ present regions.
 .br
 Start a report for the specified object or for all present objects. If
 the count argument is specified, the report will repeat at a fixed
-interval set by the \fB\-\-interval\fP option. The default interval is
+interval set by the \fB--interval\fP option. The default interval is
 one second.
 
-If the \fB\-\-allprograms\fP switch is given, all regions will be
+If the \fB--allprograms\fP switch is given, all regions will be
 listed, regardless of region program ID values.
 
-If the \fB\-\-histogram\fP is given the report will include the histogram
+If the \fB--histogram\fP is given the report will include the histogram
 values and latency boundaries.
 
-If the \fB\-\-relative\fP is used the default histogram field displays
+If the \fB--relative\fP is used the default histogram field displays
 bin values as a percentage of the total number of I/Os.
 
 Object types (areas, regions and groups) to include in the report are
-selected using the \fB\-\-area\fP, \fB\-\-region\fP, and \fB\-\-group\fP
+selected using the \fB--area\fP, \fB--region\fP, and \fB--group\fP
 options.
 .
 .HP
@@ -742,35 +742,35 @@ options.
 Remove an existing group and return all the group's regions to their
 original state.
 
-The group to be removed is specified using \fB\-\-groupid\fP.
+The group to be removed is specified using \fB--groupid\fP.
 .HP
 .CMD_UPDATE_FILEMAP
 .br
 Update a group of \fBdmstats\fP regions specified by \fBgroup_id\fP,
-that were previously created with \fB\-\-filemap\fP, either directly,
+that were previously created with \fB--filemap\fP, either directly,
 or by starting the monitoring daemon, \fBdmfilemapd\fP.
 
 This will add and remove regions to reflect changes in the allocated
-extents of the file on\-disk, since the time that it was crated or last
+extents of the file on-disk, since the time that it was crated or last
 updated.
 
 Use of this command is not normally needed since the \fBdmfilemapd\fP
 daemon will automatically monitor filemap groups and perform these
 updates when required.
 
-If a filemapped group was created with \fB\-\-nomonitor\fP, or the
+If a filemapped group was created with \fB--nomonitor\fP, or the
 daemon has been killed, the \fBupdate_filemap\fP can be used to
 manually force an update or start a new daemon.
 
-Use \fB\-\-nomonitor\fP to force a direct update and disable starting
+Use \fB--nomonitor\fP to force a direct update and disable starting
 the monitoring daemon.
 .
 .SH REGIONS, AREAS, AND GROUPS
 .
-The device\-mapper statistics facility allows separate performance
+The device-mapper statistics facility allows separate performance
 counters to be maintained for arbitrary regions of devices. A region may
 span any range: from a single sector to the whole device. A region may
-be further sub\-divided into a number of distinct areas (one or more),
+be further sub-divided into a number of distinct areas (one or more),
 each with its own counter set. In this case a summary value for the
 entire region is also available for use in reports.
 
@@ -786,19 +786,19 @@ The group metadata is stored with the first (lowest numbered)
 the group and other group members will be returned to their prior
 state.
 
-By default new regions span the entire device. The \fB\-\-start\fP and
-\fB\-\-length\fP options allows a region of any size to be placed at any
+By default new regions span the entire device. The \fB--start\fP and
+\fB--length\fP options allows a region of any size to be placed at any
 location on the device.
 
 Using offsets it is possible to create regions that map individual
 objects within a block device (for example: partitions, files in a file
 system, or stripes or other structures in a RAID volume). Groups allow
-several non\-contiguous regions to be assembled together for reporting
+several non-contiguous regions to be assembled together for reporting
 and data aggregation.
 
-A region may be either divided into the specified number of equal\-sized
+A region may be either divided into the specified number of equal-sized
 areas, or into areas of the given size by specifying one of
-\fB\-\-areas\fP or \fB\-\-areasize\fP when creating a region with the
+\fB--areas\fP or \fB--areasize\fP when creating a region with the
 \fBcreate\fP command. Depending on the size of the areas and the device
 region the final area within the region may be smaller than requested.
 .P
@@ -827,14 +827,14 @@ reference the group.
 .
 .SH FILE MAPPING
 .
-Using \fB\-\-filemap\fP, it is possible to create regions that
+Using \fB--filemap\fP, it is possible to create regions that
 correspond to the extents of a file in the file system. This allows
-IO statistics to be monitored on a per\-file basis, for example to
+IO statistics to be monitored on a per-file basis, for example to
 observe large database files, virtual machine images, or other files
 of interest.
 
 To be able to use file mapping, the file must be backed by a
-device\-mapper device, and in a file system that supports the FIEMAP
+device-mapper device, and in a file system that supports the FIEMAP
 ioctl (and which returns data describing the physical location of
 extents). This currently includes \fBxfs(5)\fP and \fBext4(5)\fP.
 
@@ -843,7 +843,7 @@ group, and the group alias is set to the \fBbasename(3)\fP of the
 file. This allows statistics to be reported for the file as a whole,
 aggregating values for the regions making up the group. To see only
 the whole file (group) when using the \fBlist\fP and \fBreport\fP
-commands, use \fB\-\-group\fP.
+commands, use \fB--group\fP.
 
 Since it is possible for the file to change after the initial
 group of regions is created, the \fBupdate_filemap\fP command, and
@@ -854,29 +854,29 @@ either manually or automatically.
 .B File follow modes
 .P
 The file map monitoring daemon can monitor files in two distinct ways:
-follow\-inode mode, and follow\-path mode.
+follow-inode mode, and follow-path mode.
 
 The mode affects the behaviour of the daemon when a file under
 monitoring is renamed or unlinked, and the conditions which cause the
 daemon to terminate.
 
-If follow\-inode mode is used, the daemon will hold the file open, and
+If follow-inode mode is used, the daemon will hold the file open, and
 continue to update regions from the same file descriptor. This means
 that the mapping will follow rename, move (within the same file
 system), and unlink operations. This mode is useful if the file is
 expected to be moved, renamed, or unlinked while it is being
 monitored.
 
-In follow\-inode mode, the daemon will exit once it detects that the
+In follow-inode mode, the daemon will exit once it detects that the
 file has been unlinked and it is the last holder of a reference to it.
 
-If follow\-path is used, the daemon will re\-open the provided path on
+If follow-path is used, the daemon will re-open the provided path on
 each monitoring iteration. This means that the group will be updated
 to reflect a new file being moved to the same path as the original
 file. This mode is useful for files that are expected to be updated
 via unlink and rename.
 
-In follow\-path mode, the daemon will exit if the file is removed and
+In follow-path mode, the daemon will exit if the file is removed and
 not replaced within a brief tolerance interval (one second).
 
 To stop the daemon, delete the group containing the mapped regions:
@@ -884,12 +884,12 @@ the daemon will automatically shut down.
 
 The daemon can also be safely killed at any time and the group kept:
 if the file is still being allocated the mapping will become
-progressively out\-of\-date as extents are added and removed (in this
-case the daemon can be re\-started or the group updated manually with
+progressively out-of-date as extents are added and removed (in this
+case the daemon can be re-started or the group updated manually with
 the \fBupdate_filemap\fP command).
 
-See the \fBcreate\fP command and \fB\-\-filemap\fP, \fB\-\-follow\fP,
-and \fB\-\-nomonitor\fP options for further information.
+See the \fBcreate\fP command and \fB--filemap\fP, \fB--follow\fP,
+and \fB--nomonitor\fP options for further information.
 .
 .P
 .B Limitations
@@ -899,7 +899,7 @@ extents and the regions contained in the group, however, since it can
 only react to new allocations once they have been written, there are
 inevitably some IO events that cannot be counted when a file is
 growing, particularly if the file is being extended by a single thread
-writing beyond end\-of\-file (for example, the \fBdd\fP program).
+writing beyond end-of-file (for example, the \fBdd\fP program).
 
 There is a further loss of events in that there is currently no way
 to atomically resize a \fBdmstats\fP region and preserve its current
@@ -917,7 +917,7 @@ these limitations when kernel support is available.
 The dmstats report provides several types of field that may be added to
 the default field set, or used to create custom reports.
 
-All performance counters and metrics are calculated per\-area.
+All performance counters and metrics are calculated per-area.
 .
 .SS Derived metrics
 .
@@ -979,19 +979,19 @@ identifier, start, length, and counts, as well as the program ID and
 user data values.
 .TP
 .B region_id
-Region identifier. This is a non\-negative integer returned by the kernel
+Region identifier. This is a non-negative integer returned by the kernel
 when a statistics region is created.
 .TP
 .B region_start
 The region start location. Display units are selected by the
-\fB\-\-units\fP option.
+\fB--units\fP option.
 .TP
 .B region_len
 The length of the region. Display units are selected by the
-\fB\-\-units\fP option.
+\fB--units\fP option.
 .TP
 .B area_id
-Area identifier. Area identifiers are assigned by the device\-mapper
+Area identifier. Area identifiers are assigned by the device-mapper
 statistics library and uniquely identify each area within a region. Each
 ID corresponds to a distinct set of performance counters for that area
 of the statistics region. Area identifiers are always monotonically
@@ -1001,11 +1001,11 @@ identifiers exist.
 .TP
 .B area_start
 The area start location. Display units are selected by the
-\fB\-\-units\fP option.
+\fB--units\fP option.
 .TP
 .B area_len
 The length of the area. Display units are selected by the
-\fB\-\-units\fP option.
+\fB--units\fP option.
 .TP
 .B area_count
 The number of areas in this region.
@@ -1017,7 +1017,7 @@ The program ID value associated with this region.
 The user data value associated with this region.
 .TP
 .B group_id
-Group identifier. This is a non\-negative integer returned by the dmstats
+Group identifier. This is a non-negative integer returned by the dmstats
 \fBgroup\fP command when a statistics group is created.
 .TP
 .B interval_ns
@@ -1139,7 +1139,7 @@ indicating the unit.
 .B hist_ranges
 A list of the histogram bin ranges for the current statistics area in
 order of ascending latency value.  The values are expressed as
-"LOWER\-UPPER" in whole units of seconds, miliseconds, microseconds or
+"LOWER-UPPER" in whole units of seconds, miliseconds, microseconds or
 nanoseconds with a suffix indicating the unit.
 .TP
 .B hist_bins
@@ -1147,7 +1147,7 @@ The number of latency histogram bins configured for the area.
 .
 .SH EXAMPLES
 .
-Create a whole\-device region with one area on vg00/lvol1
+Create a whole-device region with one area on vg00/lvol1
 .br
 #
 .B dmstats create vg00/lvol1
@@ -1157,15 +1157,15 @@ vg00/lvol1: Created new region with 1 area(s) as region ID 0
 Create a 32M region 1G into device d0
 .br
 #
-.B dmstats create \-\-start 1G \-\-length 32M d0
+.B dmstats create --start 1G --length 32M d0
 .br
 d0: Created new region with 1 area(s) as region ID 0
 .P
-Create a whole\-device region with 8 areas on every device
+Create a whole-device region with 8 areas on every device
 .br
 .br
 #
-.B dmstats create \-\-areas 8
+.B dmstats create --areas 8
 .br
 vg00-lvol1: Created new region with 8 area(s) as region ID 0
 .br
@@ -1183,21 +1183,21 @@ Delete all regions on all devices
 .br
 .br
 #
-.B dmstats delete \-\-alldevices \-\-allregions
+.B dmstats delete --alldevices --allregions
 .P
-Create a whole\-device region with areas 10GiB in size on vg00/lvol1
+Create a whole-device region with areas 10GiB in size on vg00/lvol1
 using dmsetup
 .br
 .br
 #
-.B dmsetup stats create \-\-areasize 10G vg00/lvol1
+.B dmsetup stats create --areasize 10G vg00/lvol1
 .br
 vg00-lvol1: Created new region with 5 area(s) as region ID 1
 .P
 Create a 1GiB region with 16 areas at the start of vg00/lvol1
 .br
 #
-.B dmstats create \-\-start 0 \-\-len 1G \-\-areas=16 vg00/lvol1
+.B dmstats create --start 0 --len 1G --areas=16 vg00/lvol1
 .br
 vg00-lvol1: Created new region with 16 area(s) as region ID 0
 .P
@@ -1218,24 +1218,24 @@ Display five statistics reports for vg00/lvol1 at an interval of one second
 .br
 .br
 #
-.B dmstats report \-\-interval 1 \-\-count 5 vg00/lvol1
+.B dmstats report --interval 1 --count 5 vg00/lvol1
 .br
 #
 .B dmstats report
 .br
 Name             RgID  ArID  AStart ASize  RRqM/s   WRqM/s   R/s   W/s    RSz/s WSz/s   AvRqSz  QSize Util%      AWait RdAWa WrAWa
 .br
-vg_hex\-lv_home       0     0      0 61.00g     0.00     0.00  0.00 218.00     0   1.04m   4.50k  2.97      81.70 13.62  0.00 13.62
+vg_hex-lv_home       0     0      0 61.00g     0.00     0.00  0.00 218.00     0   1.04m   4.50k  2.97      81.70 13.62  0.00 13.62
 .br
-vg_hex\-lv_home       1     0 61.00g 19.20g     0.00     0.00  0.00   5.00     0 548.00k 109.50k  0.14      11.00 27.40  0.00 27.40
+vg_hex-lv_home       1     0 61.00g 19.20g     0.00     0.00  0.00   5.00     0 548.00k 109.50k  0.14      11.00 27.40  0.00 27.40
 .br
-vg_hex\-lv_home       2     0 80.20g  2.14g     0.00     0.00  0.00  14.00     0   1.15m  84.00k  0.39      18.70 27.71  0.00 27.71
+vg_hex-lv_home       2     0 80.20g  2.14g     0.00     0.00  0.00  14.00     0   1.15m  84.00k  0.39      18.70 27.71  0.00 27.71
 .P
 Create one region for reach target contained in device vg00/lvol1
 .br
 .br
 #
-.B dmstats create \-\-segments vg00/lvol1
+.B dmstats create --segments vg00/lvol1
 .br
 vg00-lvol1: Created new region with 1 area(s) as region ID 0
 .br
@@ -1247,7 +1247,7 @@ Create regions mapping each file in the directory images/ and place
 them into separate groups, each named after the corresponding file
 .br
 #
-.B dmstats create \-\-filemap images/*
+.B dmstats create --filemap images/*
 .br
 images/vm1.qcow2: Created new group with 87 region(s) as group ID 0.
 .br
@@ -1262,7 +1262,7 @@ images/vm3.img: Created new group with 2 region(s) as group ID 1560.
 Print raw counters for region 4 on device d0
 .br
 #
-.B dmstats print \-\-regionid 4 d0
+.B dmstats print --regionid 4 d0
 .br
 2097152+65536 0 0 0 0 29 0 264 701 0 41 701 0 41
 .
@@ -1276,9 +1276,9 @@ Bryn M. Reeves <bmr@redhat.com>
 
 LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
-Device\-mapper resource page: http://sources.redhat.com/dm/
+Device-mapper resource page: http://sources.redhat.com/dm/
 .br
 
-Device\-mapper statistics kernel documentation
+Device-mapper statistics kernel documentation
 .br
-.I Documentation/device\-mapper/statistics.txt
+.I Documentation/device-mapper/statistics.txt
diff --git a/man/fsadm.8_main b/man/fsadm.8_main
index 02431c5..c46033c 100644
--- a/man/fsadm.8_main
+++ b/man/fsadm.8_main
@@ -35,32 +35,32 @@ filesystem.
 .SH OPTIONS
 .
 .HP
-.BR \-e | \-\-ext\-offline
+.BR -e | --ext-offline
 .br
 Unmount ext2/ext3/ext4 filesystem before doing resize.
 .
 .HP
-.BR \-f | \-\-force
+.BR -f | --force
 .br
 Bypass some sanity checks.
 .
 .HP
-.BR \-h | \-\-help
+.BR -h | --help
 .br
 Display the help text.
 .
 .HP
-.BR \-n | \-\-dry\-run
+.BR -n | --dry-run
 .br
 Print commands without running them.
 .
 .HP
-.BR \-v | \-\-verbose
+.BR -v | --verbose
 .br
 Be more verbose.
 .
 .HP
-.BR \-y | \-\-yes
+.BR -y | --yes
 .br
 Answer "yes" at any prompts.
 .
@@ -87,7 +87,7 @@ If \fI/dev/vg/test\fP contains ext2/ext3/ext4
 filesystem it will be unmounted prior the resize.
 All [y/n] questions will be answered 'y'.
 .sp
-.B fsadm \-e \-y resize /dev/vg/test 1000M
+.B fsadm -e -y resize /dev/vg/test 1000M
 .
 .SH ENVIRONMENT VARIABLES
 .
diff --git a/man/lvchange.8_end b/man/lvchange.8_end
index 99de8a8..e3087d7 100644
--- a/man/lvchange.8_end
+++ b/man/lvchange.8_end
@@ -1,4 +1,4 @@
 .SH EXAMPLES
 Change LV permission to read-only:
 .sp
-.B lvchange \-pr vg00/lvol1
+.B lvchange -pr vg00/lvol1
diff --git a/man/lvconvert.8_des b/man/lvconvert.8_des
index f1efcbd..dc51aae 100644
--- a/man/lvconvert.8_des
+++ b/man/lvconvert.8_des
@@ -4,7 +4,7 @@ The LV type is also called the segment type or segtype.
 
 To display the current LV type, run the command:
 
-.B lvs \-o name,segtype
+.B lvs -o name,segtype
 .I LV
 
 The
diff --git a/man/lvconvert.8_end b/man/lvconvert.8_end
index bbc50a7..1087c6e 100644
--- a/man/lvconvert.8_end
+++ b/man/lvconvert.8_end
@@ -1,7 +1,7 @@
 .SH NOTES
 This previous command syntax would perform two different operations:
 .br
-\fBlvconvert \-\-thinpool\fP \fILV1\fP \fB\-\-poolmetadata\fP \fILV2\fP
+\fBlvconvert --thinpool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
 .br
 If LV1 was not a thin pool, the command would convert LV1 to
 a thin pool, optionally using a specified LV for metadata.
@@ -11,7 +11,7 @@ the current metadata LV with LV2 (for repair purposes.)
 In the same way, this previous command syntax would perform two different
 operations:
 .br
-\fBlvconvert \-\-cachepool\fP \fILV1\fP \fB\-\-poolmetadata\fP \fILV2\fP
+\fBlvconvert --cachepool\fP \fILV1\fP \fB--poolmetadata\fP \fILV2\fP
 .br
 If LV1 was not a cache pool, the command would convert LV1 to
 a cache pool, optionally using a specified LV for metadata.
@@ -20,93 +20,93 @@ the current metadata LV with LV2 (for repair purposes.)
 .SH EXAMPLES
 Convert a linear LV to a two-way mirror LV.
 .br
-.B lvconvert \-\-type mirror \-\-mirrors 1 vg/lvol1
+.B lvconvert --type mirror --mirrors 1 vg/lvol1
 
 Convert a linear LV to a two-way RAID1 LV.
 .br
-.B lvconvert \-\-type raid1 \-\-mirrors 1 vg/lvol1
+.B lvconvert --type raid1 --mirrors 1 vg/lvol1
 
-Convert a mirror LV to use an in\-memory log.
+Convert a mirror LV to use an in-memory log.
 .br
-.B lvconvert \-\-mirrorlog core vg/lvol1
+.B lvconvert --mirrorlog core vg/lvol1
 
 Convert a mirror LV to use a disk log.
 .br
-.B lvconvert \-\-mirrorlog disk vg/lvol1
+.B lvconvert --mirrorlog disk vg/lvol1
 
 Convert a mirror or raid1 LV to a linear LV.
 .br
-.B lvconvert \-\-type linear vg/lvol1
+.B lvconvert --type linear vg/lvol1
 
 Convert a mirror LV to a raid1 LV with the same number of images.
 .br
-.B lvconvert \-\-type raid1 vg/lvol1
+.B lvconvert --type raid1 vg/lvol1
 
 Convert a linear LV to a two-way mirror LV, allocating new extents from specific
 PV ranges.
 .br
-.B lvconvert \-\-mirrors 1 vg/lvol1 /dev/sda:0\-15 /dev/sdb:0\-15
+.B lvconvert --mirrors 1 vg/lvol1 /dev/sda:0-15 /dev/sdb:0-15
 
 Convert a mirror LV to a linear LV, freeing physical extents from a specific PV.
 .br
-.B lvconvert \-\-type linear vg/lvol1 /dev/sda
+.B lvconvert --type linear vg/lvol1 /dev/sda
 
 Split one image from a mirror or raid1 LV, making it a new LV.
 .br
-.B lvconvert \-\-splitmirrors 1 \-\-name lv_split vg/lvol1
+.B lvconvert --splitmirrors 1 --name lv_split vg/lvol1
 
 Split one image from a raid1 LV, and track changes made to the raid1 LV
 while the split image remains detached.
 .br
-.B lvconvert \-\-splitmirrors 1 \-\-trackchanges vg/lvol1
+.B lvconvert --splitmirrors 1 --trackchanges vg/lvol1
 
-Merge an image (that was previously created with \-\-splitmirrors and
-\-\-trackchanges) back into the original raid1 LV.
+Merge an image (that was previously created with --splitmirrors and
+--trackchanges) back into the original raid1 LV.
 .br
-.B lvconvert \-\-mergemirrors vg/lvol1_rimage_1
+.B lvconvert --mergemirrors vg/lvol1_rimage_1
 
 Replace PV /dev/sdb1 with PV /dev/sdf1 in a raid1/4/5/6/10 LV.
 .br
-.B lvconvert \-\-replace /dev/sdb1 vg/lvol1 /dev/sdf1
+.B lvconvert --replace /dev/sdb1 vg/lvol1 /dev/sdf1
 
 Replace 3 PVs /dev/sd[b-d]1 with PVs /dev/sd[f-h]1 in a raid1 LV.
 .br
-.B lvconvert \-\-replace /dev/sdb1 \-\-replace /dev/sdc1 \-\-replace /dev/sdd1
+.B lvconvert --replace /dev/sdb1 --replace /dev/sdc1 --replace /dev/sdd1
 .RS
 .B vg/lvol1 /dev/sd[fgh]1
 .RE
 
 Replace the maximum of 2 PVs /dev/sd[bc]1 with PVs /dev/sd[gh]1 in a raid6 LV.
 .br
-.B lvconvert \-\-replace /dev/sdb1 \-\-replace /dev/sdc1 vg/lvol1 /dev/sd[gh]1
+.B lvconvert --replace /dev/sdb1 --replace /dev/sdc1 vg/lvol1 /dev/sd[gh]1
 
 Convert an LV into a thin LV in the specified thin pool.  The existing LV
-is used as an external read\-only origin for the new thin LV.
+is used as an external read-only origin for the new thin LV.
 .br
-.B lvconvert \-\-type thin \-\-thinpool vg/tpool1 vg/lvol1
+.B lvconvert --type thin --thinpool vg/tpool1 vg/lvol1
 
 Convert an LV into a thin LV in the specified thin pool.  The existing LV
-is used as an external read\-only origin for the new thin LV, and is
+is used as an external read-only origin for the new thin LV, and is
 renamed "external".
 .br
-.B lvconvert \-\-type thin \-\-thinpool vg/tpool1
+.B lvconvert --type thin --thinpool vg/tpool1
 .RS
-.B \-\-originname external vg/lvol1
+.B --originname external vg/lvol1
 .RE
 
 Convert an LV to a cache pool LV using another specified LV for cache pool
 metadata.
 .br
-.B lvconvert \-\-type cache-pool \-\-poolmetadata vg/poolmeta1 vg/lvol1
+.B lvconvert --type cache-pool --poolmetadata vg/poolmeta1 vg/lvol1
 
 Convert an LV to a cache LV using the specified cache pool and chunk size.
 .br
-.B lvconvert \-\-type cache \-\-cachepool vg/cpool1 \-c 128 vg/lvol1
+.B lvconvert --type cache --cachepool vg/cpool1 -c 128 vg/lvol1
 
 Detach and keep the cache pool from a cache LV.
 .br
-.B lvconvert \-\-splitcache vg/lvol1
+.B lvconvert --splitcache vg/lvol1
 
 Detach and remove the cache pool from a cache LV.
 .br
-.B lvconvert \-\-uncache vg/lvol1
+.B lvconvert --uncache vg/lvol1
diff --git a/man/lvcreate.8_des b/man/lvcreate.8_des
index a526b85..42f4213 100644
--- a/man/lvcreate.8_des
+++ b/man/lvcreate.8_des
@@ -26,11 +26,11 @@ virtual size rather than a physical size. A cache LV is the combination of
 a standard LV with a cache pool, used to cache active portions of the LV
 to improve performance.
 .SS Usage notes
-In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
-with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB--size\fP \fISize\fP can be replaced
+with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
 
-In the usage section below, \fB\-\-name\fP is omitted from the required
+In the usage section below, \fB--name\fP is omitted from the required
 options, even though it is typically used.  When the name is not
 specified, a new LV name is generated with the "lvol" prefix and a unique
 numeric suffix.  Also see the description in the options section.
diff --git a/man/lvcreate.8_end b/man/lvcreate.8_end
index b4ebd2d..2770f62 100644
--- a/man/lvcreate.8_end
+++ b/man/lvcreate.8_end
@@ -3,56 +3,56 @@
 Create a striped LV with 3 stripes, a stripe size of 8KiB and a size of 100MiB.
 The LV name is chosen by lvcreate.
 .br
-.B lvcreate \-i 3 \-I 8 \-L 100m vg00
+.B lvcreate -i 3 -I 8 -L 100m vg00
 
 Create a raid1 LV with two images, and a useable size of 500 MiB. This
 operation requires two devices, one for each mirror image. RAID metadata
 (superblock and bitmap) is also included on the two devices.
 .br
-.B lvcreate \-\-type raid1 \-m1 \-L 500m \-n mylv vg00
+.B lvcreate --type raid1 -m1 -L 500m -n mylv vg00
 
 Create a mirror LV with two images, and a useable size of 500 MiB.
 This operation requires three devices: two for mirror images and
 one for a disk log.
 .br
-.B lvcreate \-\-type mirror \-m1 \-L 500m \-n mylv vg00
+.B lvcreate --type mirror -m1 -L 500m -n mylv vg00
 
 Create a mirror LV with 2 images, and a useable size of 500 MiB.
 This operation requires 2 devices because the log is in memory.
 .br
-.B lvcreate \-\-type mirror \-m1 \-\-mirrorlog core \-L 500m \-n mylv vg00
+.B lvcreate --type mirror -m1 --mirrorlog core -L 500m -n mylv vg00
 
-Create a copy\-on\-write snapshot of an LV:
+Create a copy-on-write snapshot of an LV:
 .br
-.B lvcreate \-\-snapshot \-\-size 100m \-\-name mysnap vg00/mylv
+.B lvcreate --snapshot --size 100m --name mysnap vg00/mylv
 
-Create a copy\-on\-write snapshot with a size sufficient
+Create a copy-on-write snapshot with a size sufficient
 for overwriting 20% of the size of the original LV.
 .br
-.B lvcreate \-s \-l 20%ORIGIN \-n mysnap vg00/mylv
+.B lvcreate -s -l 20%ORIGIN -n mysnap vg00/mylv
 
 Create a sparse LV with 1TiB of virtual space, and actual space just under
 100MiB.
 .br
-.B lvcreate \-\-snapshot \-\-virtualsize 1t \-\-size 100m \-\-name mylv vg00
+.B lvcreate --snapshot --virtualsize 1t --size 100m --name mylv vg00
 
 Create a linear LV with a usable size of 64MiB on specific physical extents.
 .br
-.B lvcreate \-L 64m \-n mylv vg00 /dev/sda:0\-7 /dev/sdb:0\-7
+.B lvcreate -L 64m -n mylv vg00 /dev/sda:0-7 /dev/sdb:0-7
 
 Create a RAID5 LV with a usable size of 5GiB, 3 stripes, a stripe size of
 64KiB, using a total of 4 devices (including one for parity).
 .br
-.B lvcreate \-\-type raid5 \-L 5G \-i 3 \-I 64 \-n mylv vg00
+.B lvcreate --type raid5 -L 5G -i 3 -I 64 -n mylv vg00
 
 Create a RAID5 LV using all of the free space in the VG and spanning all the
 PVs in the VG (note that the command will fail if there are more than 8 PVs in
-the VG, in which case \fB\-i 7\fP must be used to get to the current maximum of
+the VG, in which case \fB-i 7\fP must be used to get to the current maximum of
 8 devices including parity for RaidLVs).
 .br
-.B lvcreate \-\-config allocation/raid_stripe_all_devices=1
+.B lvcreate --config allocation/raid_stripe_all_devices=1
 .RS
-.B \-\-type raid5 \-l 100%FREE \-n mylv vg00
+.B --type raid5 -l 100%FREE -n mylv vg00
 .RE
 
 Create RAID10 LV with a usable size of 5GiB, using 2 stripes, each on
@@ -62,36 +62,36 @@ differently:
 but \fB-m\fP specifies the number of images in addition
 to the first image).
 .br
-.B lvcreate \-\-type raid10 \-L 5G \-i 2 \-m 1 \-n mylv vg00
+.B lvcreate --type raid10 -L 5G -i 2 -m 1 -n mylv vg00
 
 Create a 1TiB thin LV, first creating a new thin pool for it, where
 the thin pool has 100MiB of space, uses 2 stripes, has a 64KiB stripe
 size, and 256KiB chunk size.
 .br
-.B lvcreate \-\-type thin \-\-name mylv \-\-thinpool mypool
+.B lvcreate --type thin --name mylv --thinpool mypool
 .RS
-.B \-V 1t \-L 100m \-i 2 \-I 64 \-c 256 vg00
+.B -V 1t -L 100m -i 2 -I 64 -c 256 vg00
 .RE
 
 Create a thin snapshot of a thin LV (the size option must not be
 used, otherwise a copy-on-write snapshot would be created).
 .br
-.B lvcreate \-\-snapshot \-\-name mysnap vg00/thinvol
+.B lvcreate --snapshot --name mysnap vg00/thinvol
 
 Create a thin snapshot of the read-only inactive LV named "origin"
 which becomes an external origin for the thin snapshot LV.
 .br
-.B lvcreate \-\-snapshot \-\-name mysnap \-\-thinpool mypool vg00/origin
+.B lvcreate --snapshot --name mysnap --thinpool mypool vg00/origin
 
 Create a cache pool from a fast physical device. The cache pool can
 then be used to cache an LV.
 .br
-.B lvcreate \-\-type cache-pool \-L 1G \-n my_cpool vg00 /dev/fast1
+.B lvcreate --type cache-pool -L 1G -n my_cpool vg00 /dev/fast1
 
 Create a cache LV, first creating a new origin LV on a slow physical device,
 then combining the new origin LV with an existing cache pool.
 .br
-.B lvcreate \-\-type cache \-\-cachepool my_cpool
+.B lvcreate --type cache --cachepool my_cpool
 .RS
-.B \-L 100G \-n mylv vg00 /dev/slow1
+.B -L 100G -n mylv vg00 /dev/slow1
 .RE
diff --git a/man/lvextend.8_des b/man/lvextend.8_des
index f1e02d6..eafd247 100644
--- a/man/lvextend.8_des
+++ b/man/lvextend.8_des
@@ -2,11 +2,11 @@ lvextend extends the size of an LV. This requires allocating logical
 extents from the VG's free physical extents. If the extension adds a new
 LV segment, the new segment will use the existing segment type of the LV.
 
-Extending a copy\-on\-write snapshot LV adds space for COW blocks.
+Extending a copy-on-write snapshot LV adds space for COW blocks.
 
 Use \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
 
-In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
-with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB--size\fP \fISize\fP can be replaced
+with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
diff --git a/man/lvextend.8_end b/man/lvextend.8_end
index aebe6d8..af24d4f 100644
--- a/man/lvextend.8_end
+++ b/man/lvextend.8_end
@@ -1,14 +1,14 @@
 .SH EXAMPLES
 Extend the size of an LV by 54MiB, using a specific PV.
 .br
-.B lvextend \-L +54 vg01/lvol10 /dev/sdk3
+.B lvextend -L +54 vg01/lvol10 /dev/sdk3
 
 Extend the size of an LV by the amount of free
 space on PV /dev/sdk3. This is equivalent to specifying
-"\-l +100%PVS" on the command line.
+"-l +100%PVS" on the command line.
 .br
 .B lvextend vg01/lvol01 /dev/sdk3
 
 Extend an LV by 16MiB using specific physical extents.
 .br
-.B lvextend \-L+16m vg01/lvol01 /dev/sda:8\-9 /dev/sdb:8\-9
+.B lvextend -L+16m vg01/lvol01 /dev/sda:8-9 /dev/sdb:8-9
diff --git a/man/lvm-config.8_des b/man/lvm-config.8_des
index 1d36566..046806e 100644
--- a/man/lvm-config.8_des
+++ b/man/lvm-config.8_des
@@ -2,4 +2,4 @@ This command is the same as \fBlvmconfig\fP(8).
 
 lvm config produces formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
-line settings from \-\-config.
+line settings from --config.
diff --git a/man/lvm-dumpconfig.8_des b/man/lvm-dumpconfig.8_des
index 18593fb..3ebe2b3 100644
--- a/man/lvm-dumpconfig.8_des
+++ b/man/lvm-dumpconfig.8_des
@@ -2,4 +2,4 @@ This command is the same as \fBlvmconfig\fP(8).
 
 lvm dumpconfig produces formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
-line settings from \-\-config.
+line settings from --config.
diff --git a/man/lvm-lvpoll.8_end b/man/lvm-lvpoll.8_end
index efd0f18..d38dfd0 100644
--- a/man/lvm-lvpoll.8_end
+++ b/man/lvm-lvpoll.8_end
@@ -8,24 +8,24 @@ To find the name of the pvmove LV that was created by an original
 
 Continue polling a pvmove operation.
 .br
-.B lvm lvpoll \-\-polloperation pvmove vg00/pvmove0
+.B lvm lvpoll --polloperation pvmove vg00/pvmove0
 
 Abort a pvmove operation.
 .br
-.B lvm lvpoll \-\-polloperation pvmove \-\-abort vg00/pvmove0
+.B lvm lvpoll --polloperation pvmove --abort vg00/pvmove0
 
 Continue polling a mirror conversion.
 .br
-.B lvm lvpoll \-\-polloperation convert vg00/lvmirror
+.B lvm lvpoll --polloperation convert vg00/lvmirror
 
 Continue mirror repair.
 .br
-.B lvm lvpoll \-\-polloperation convert vg/damaged_mirror \-\-handlemissingpvs
+.B lvm lvpoll --polloperation convert vg/damaged_mirror --handlemissingpvs
 
 Continue snapshot merge.
 .br
-.B lvm lvpoll \-\-polloperation merge vg/snapshot_old
+.B lvm lvpoll --polloperation merge vg/snapshot_old
 
 Continue thin snapshot merge.
 .br
-.B lvm lvpoll \-\-polloperation merge_thin vg/thin_snapshot
+.B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
diff --git a/man/lvm.8_main b/man/lvm.8_main
index a1da382..977a0fd 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -11,7 +11,7 @@ lvm \(em LVM2 tools
 .
 .SH DESCRIPTION
 .
-lvm provides the command\-line tools for LVM2.  A separate
+lvm provides the command-line tools for LVM2.  A separate
 manual page describes each command in detail.
 .P
 If \fBlvm\fP is invoked with no arguments it presents a readline prompt
@@ -36,9 +36,9 @@ as "vg0/lvol0".  Where a list of VGs is required but is left empty,
 a list of all VGs will be substituted.  Where a list of LVs is required
 but a VG is given, a list of all the LVs in that VG will be substituted.
 So \fBlvdisplay vg0\fP will display all the LVs in "vg0".
-Tags can also be used - see \fB\-\-addtag\fP below.
+Tags can also be used - see \fB--addtag\fP below.
 .P
-One advantage of using the built\-in shell is that configuration
+One advantage of using the built-in shell is that configuration
 information gets cached internally between commands.
 .P
 A file containing a simple script with one command per line
@@ -47,9 +47,9 @@ executed directly if the first line is #! followed by the absolute
 path of \fBlvm\fP.
 .P
 Additional hyphens within option names are ignored.  For example,
-\fB\-\-readonly\fP and \fB\-\-read\-only\fP are both accepted.
+\fB--readonly\fP and \fB--read-only\fP are both accepted.
 .
-.SH BUILT\-IN COMMANDS
+.SH BUILT-IN COMMANDS
 .
 The following commands are built into lvm without links
 normally being created in the filesystem for them.
@@ -60,7 +60,7 @@ normally being created in the filesystem for them.
 The same as \fBlvmconfig\fP(8) below.
 .TP
 .B devtypes
-Display the recognised built\-in block device types.
+Display the recognised built-in block device types.
 .TP
 .B dumpconfig
 The same as \fBlvmconfig\fP(8) below.
@@ -234,7 +234,7 @@ Scan (all disks) for Logical Volumes.
 The following LVM1 commands are not implemented in LVM2:
 .BR lvmchange ", " lvmsadc ", " lvmsar ", " pvdata .
 For performance metrics, use \fBdmstats\fP(8) or to manipulate the kernel
-device\-mapper driver used by LVM2 directly, use \fBdmsetup\fP(8).
+device-mapper driver used by LVM2 directly, use \fBdmsetup\fP(8).
 .
 .SH VALID NAMES
 .
@@ -253,7 +253,7 @@ least one LV that is still present.  This helps to record the ancestry of
 thin snapshots even after some links in the chain have been removed.
 A reference to the historical LV 'lvol1' in VG 'vg00' would be 'vg00/-lvol1'
 or just '-lvol1' if the VG is already set.  (The latter form must be preceded
-by '\-\-' to terminate command line option processing before reaching this
+by '--' to terminate command line option processing before reaching this
 argument.)
 .P
 There are also various reserved names that are used internally by lvm that can
@@ -288,8 +288,8 @@ When VGs with the same name exist, commands operating on all VGs will
 include all of the VGs with the same name.  If the ambiguous VG name is
 specified on the command line, the command will produce an error.  The
 error states that multiple VGs exist with the specified name.  To process
-one of the VGs specifically, the \-\-select option should be used with the
-UUID of the intended VG: '\-\-select vg_uuid=<uuid>'.
+one of the VGs specifically, the --select option should be used with the
+UUID of the intended VG: '--select vg_uuid=<uuid>'.
 
 An exception is if all but one of the VGs with the shared name is foreign
 (see
@@ -313,9 +313,9 @@ those ranges on the specified Physical Volumes are considered.
 
 Then they try each allocation policy in turn, starting with the strictest
 policy (\fBcontiguous\fP) and ending with the allocation policy specified
-using \fB\-\-alloc\fP or set as the default for the particular Logical
+using \fB--alloc\fP or set as the default for the particular Logical
 Volume or Volume Group concerned.  For each policy, working from the
-lowest\-numbered Logical Extent of the empty Logical Volume space that
+lowest-numbered Logical Extent of the empty Logical Volume space that
 needs to be filled, they allocate as much space as possible according to
 the restrictions imposed by the policy.  If more space is needed,
 they move on to the next policy.
@@ -371,7 +371,7 @@ restrictions described above applied to each step leave the tools no
 discretion over the layout.
 
 To view the way the allocation process currently works in any specific
-case, read the debug logging output, for example by adding \fB\-vvvv\fP to
+case, read the debug logging output, for example by adding \fB-vvvv\fP to
 a command.
 .
 .SH LOGICAL VOLUME TYPES
@@ -384,8 +384,8 @@ and thin provisioning (\fBlvmthin\fP(7)) types are examples of this.
 .
 .SH DIAGNOSTICS
 .
-All tools return a status code of zero on success or non\-zero on failure.
-The non\-zero codes distinguish only between the broad categories of
+All tools return a status code of zero on success or non-zero on failure.
+The non-zero codes distinguish only between the broad categories of
 unrecognised commands, problems processing the command line arguments
 and any other failures.  As LVM remains under active development, the
 code used in a specific case occasionally changes between releases.
@@ -409,7 +409,7 @@ File descriptor to use for report output from LVM commands.
 .TP
 .B LVM_COMMAND_PROFILE
 Name of default command profile to use for LVM commands. This profile
-is overriden by direct use of \fB\-\-commandprofile\fP command line option.
+is overriden by direct use of \fB--commandprofile\fP command line option.
 .TP
 .B LVM_RUN_BY_DMEVENTD
 This variable is normally set by dmeventd plugin to inform lvm2 command
@@ -464,7 +464,7 @@ Used to suppress warning messages when the configured locking is known
 to be unavailable.
 .TP
 .B DM_ABORT_ON_INTERNAL_ERRORS
-Abort processing if the code detects a non\-fatal internal error.
+Abort processing if the code detects a non-fatal internal error.
 .TP
 .B DM_DISABLE_UDEV
 Avoid interaction with udev.  LVM will manage the relevant nodes in /dev
@@ -525,7 +525,7 @@ directly.
 .BR lvs (8)
 .BR lvscan (8)
 
-.BR lvm2-activation\-generator (8)
+.BR lvm2-activation-generator (8)
 .BR blkdeactivate (8)
 .BR lvmdump (8)
 
diff --git a/man/lvm.conf.5_main b/man/lvm.conf.5_main
index 0c70299..74526e6 100644
--- a/man/lvm.conf.5_main
+++ b/man/lvm.conf.5_main
@@ -14,7 +14,7 @@ The settings defined in lvm.conf can be overridden by any
 of these extended configuration methods:
 .TP
 .B direct config override on command line
-The \fB\-\-config ConfigurationString\fP command line option takes the
+The \fB--config ConfigurationString\fP command line option takes the
 ConfigurationString as direct string representation of the configuration
 to override the existing configuration. The ConfigurationString is of
 exactly the same format as used in any LVM configuration file.
@@ -34,7 +34,7 @@ The \fBcommand profile\fP is used to override selected configuration
 settings at global LVM command level - it is applied at the very beginning
 of LVM command execution and it is used throughout the whole time of LVM
 command execution. The command profile is applied by using the
-\fB\-\-commandprofile ProfileName\fP command line option that is recognised by
+\fB--commandprofile ProfileName\fP command line option that is recognised by
 all LVM2 commands.
 
 The \fBmetadata profile\fP is used to override selected configuration
@@ -46,11 +46,11 @@ processed, the profile is applied automatically. If Volume Group and
 any of its Logical Volumes have different profiles defined, the profile
 defined for the Logical Volume is preferred. The metadata profile can be
 attached/detached by using the \fBlvchange\fP and \fBvgchange\fP commands
-and their \fB\-\-metadataprofile ProfileName\fP and
-\fB\-\-detachprofile\fP options or the \fB\-\-metadataprofile\fP
+and their \fB--metadataprofile ProfileName\fP and
+\fB--detachprofile\fP options or the \fB--metadataprofile\fP
 option during creation when using \fBvgcreate\fP or \fBlvcreate\fP command.
-The \fBvgs\fP and \fBlvs\fP reporting commands provide \fB\-o vg_profile\fP
-and \fB\-o lv_profile\fP output options to show the metadata profile
+The \fBvgs\fP and \fBlvs\fP reporting commands provide \fB-o vg_profile\fP
+and \fB-o lv_profile\fP output options to show the metadata profile
 currently attached to a Volume Group or a Logical Volume.
 
 The set of options allowed for command profiles is mutually exclusive
@@ -65,8 +65,8 @@ For this purpose, there's the \fBcommand_profile_template.profile\fP
 (for metadata profiles) which contain all settings that are customizable
 by profiles of certain type. Users are encouraged to copy these template
 profiles and edit them as needed. Alternatively, the
-\fBlvmconfig \-\-file <ProfileName.profile> \-\-type profilable\-command <section>\fP
-or \fBlvmconfig \-\-file <ProfileName.profile> \-\-type profilable\-metadata <section>\fP
+\fBlvmconfig --file <ProfileName.profile> --type profilable-command <section>\fP
+or \fBlvmconfig --file <ProfileName.profile> --type profilable-metadata <section>\fP
 can be used to generate a configuration with profilable settings in either
 of the type for given section and save it to new ProfileName.profile
 (if the section is not specified, all profilable settings are reported).
@@ -166,30 +166,30 @@ See the man page
 Command to print a list of all possible config settings, with their
 default values:
 .br
-.B lvmconfig \-\-type default
+.B lvmconfig --type default
 
 Command to print a list of all possible config settings, with their
 default values, and a full description of each as a comment:
 .br
-.B lvmconfig \-\-type default \-\-withcomments
+.B lvmconfig --type default --withcomments
 
 Command to print a list of all possible config settings, with their
-current values (configured, non\-default values are shown):
+current values (configured, non-default values are shown):
 .br
-.B lvmconfig \-\-type current
+.B lvmconfig --type current
 
 Command to print all config settings that have been configured with a
-different value than the default (configured, non\-default values are
+different value than the default (configured, non-default values are
 shown):
 .br
-.B lvmconfig \-\-type diff
+.B lvmconfig --type diff
 
 Command to print a single config setting, with its default value,
 and a full description, where "Section" refers to the config section,
 e.g. global, and "Setting" refers to the name of the specific setting,
 e.g. umask:
 .br
-.B lvmconfig \-\-type default \-\-withcomments Section/Setting
+.B lvmconfig --type default --withcomments Section/Setting
 
 
 .SH FILES
diff --git a/man/lvm2-activation-generator.8_main b/man/lvm2-activation-generator.8_main
index ffd5a63..0563205 100644
--- a/man/lvm2-activation-generator.8_main
+++ b/man/lvm2-activation-generator.8_main
@@ -1,22 +1,22 @@
-.TH "LVM2-ACTIVATION\-GENERATOR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.TH "LVM2-ACTIVATION-GENERATOR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
 .SH "NAME"
-lvm2-activation\-generator \- generator for systemd units to activate LVM2 volumes on boot
+lvm2-activation-generator - generator for systemd units to activate LVM2 volumes on boot
 .SH SYNOPSIS
-.B #SYSTEMD_GENERATOR_DIR#/lvm2-activation\-generator
+.B #SYSTEMD_GENERATOR_DIR#/lvm2-activation-generator
 .sp
 .SH DESCRIPTION
-The lvm2-activation\-generator is called by \fBsystemd\fP(1) on boot
+The lvm2-activation-generator is called by \fBsystemd\fP(1) on boot
 to generate systemd units at runtime to activate LVM2 volumes if
 \fBlvmetad\fP(8) is disabled (global/use_lvmetad=0 \fBlvm.conf\fP(5)
 option is used). Otherwise, if \fBlvmetad\fP(8) is enabled,
-the lvm2-activation\-generator exits immediately without generating
-any systemd units and LVM2 fully relies on event\-based activation
+the lvm2-activation-generator exits immediately without generating
+any systemd units and LVM2 fully relies on event-based activation
 to activate the LVM2 volumes instead using the \fBpvscan\fP(8)
-(pvscan \-\-cache -aay) call that is a part of \fBudev\fP(8) rules.
+(pvscan --cache -aay) call that is a part of \fBudev\fP(8) rules.
 
-These systemd units are generated by lvm2-activation\-generator:
+These systemd units are generated by lvm2-activation-generator:
 .sp
-\fIlvm2-activation\-early.service\fP
+\fIlvm2-activation-early.service\fP
 used for activation of LVM2 volumes that is ordered before systemd's
 special \fBcryptsetup.target\fP to support LVM2 volumes which are not
 layered on top of encrypted devices.
@@ -26,21 +26,21 @@ used for activation of LVM2 volumes that is ordered after systemd's
 special \fBcryptsetup.target\fP to support LVM2 volumes which are
 layered on top of encrypted devices.
 
-\fIlvm2-activation\-net.service\fP
+\fIlvm2-activation-net.service\fP
 used for activation of LVM2 volumes that is ordered after systemd's
-special \fBremote\-fs\-pre.target\fP to support LVM2 volumes which are
+special \fBremote-fs-pre.target\fP to support LVM2 volumes which are
 layered on attached remote devices.
 
 Note that all the underlying devices (Physical Volumes) need to be present
 when the service is run. If the there are any devices presented in the system
 anytime later, any LVM2 volumes on top of such devices need to be activated
 directly by \fBlvchange\fP(8) or \fBvgchange\fP(8). This limitation does
-not exist when using \fBlvmetad\fP(8) and accompanying event\-based activation
+not exist when using \fBlvmetad\fP(8) and accompanying event-based activation
 since such LVM volumes are activated automatically as soon as the Volume Group
 is ready (all the Physical Volumes making up the Volume Group are present
 in the system).
 
-The lvm2-activation\-generator implements the \fBGenerators Specification\fP
+The lvm2-activation-generator implements the \fBGenerators Specification\fP
 as referenced in \fBsystemd\fP(1).
 .sp
 .SH SEE ALSO
diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 6f246dc..3ddb7cd 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -8,7 +8,7 @@ The \fBcache\fP logical volume type uses a small and fast LV to improve
 the performance of a large and slow LV.  It does this by storing the
 frequently used blocks on the faster LV.
 LVM refers to the small fast LV as a \fBcache pool LV\fP.  The large
-slow LV is called the \fBorigin LV\fP.  Due to requirements from dm\-cache
+slow LV is called the \fBorigin LV\fP.  Due to requirements from dm-cache
 (the kernel driver), LVM further splits the cache pool LV into two
 devices - the \fBcache data LV\fP and \fBcache metadata LV\fP.  The cache
 data LV is where copies of data blocks are kept from the
@@ -36,11 +36,11 @@ The primary method for using a cache type logical volume:
 
 Create an LV or identify an existing LV to be the origin LV.
 
-.B lvcreate \-n OriginLV \-L LargeSize VG SlowPVs
+.B lvcreate -n OriginLV -L LargeSize VG SlowPVs
 
 .I Example
 .br
-# lvcreate \-n lvol0 \-L 100G vg
+# lvcreate -n lvol0 -L 100G vg
 
 
 .SS 1. create CacheDataLV
@@ -49,11 +49,11 @@ Create the cache data LV.  This LV will hold data blocks from the
 OriginLV.  The size of this LV is the size of the cache and will be
 reported as the size of the cache pool LV.  
 
-.B lvcreate \-n CacheDataLV \-L CacheSize VG FastPVs
+.B lvcreate -n CacheDataLV -L CacheSize VG FastPVs
 
 .I Example
 .br
-# lvcreate \-n cache0 \-L 10G vg /dev/fast
+# lvcreate -n cache0 -L 10G vg /dev/fast
 
 
 .SS 2. create CacheMetaLV
@@ -62,18 +62,18 @@ Create the cache metadata LV.  This LV will hold cache pool metadata.  The
 size of this LV should be 1000 times smaller than the cache data LV, with
 a minimum size of 8MiB.
 
-.B lvcreate \-n CacheMetaLV \-L MetaSize VG FastPVs
+.B lvcreate -n CacheMetaLV -L MetaSize VG FastPVs
 
 .I Example
 .br
-# lvcreate \-n cache0meta \-L 12M vg /dev/fast
+# lvcreate -n cache0meta -L 12M vg /dev/fast
 
 .nf
 # lvs -a vg
   LV         VG   Attr       LSize   Pool Origin
-  cache0     vg   -wi\-a\-\-\-\-\-  10.00g                                                    
-  cache0meta vg   -wi\-a\-\-\-\-\-  12.00m                                                    
-  lvol0      vg   -wi\-a\-\-\-\-\- 100.00g
+  cache0     vg   -wi-a-----  10.00g                                                    
+  cache0meta vg   -wi-a-----  12.00m                                                    
+  lvol0      vg   -wi-a----- 100.00g
 .fi
 
 
@@ -88,22 +88,22 @@ CacheDataLV is renamed CachePoolLV_cdata and becomes hidden.
 .br
 CacheMetaLV is renamed CachePoolLV_cmeta and becomes hidden.
 
-.B lvconvert \-\-type cache\-pool \-\-poolmetadata VG/CacheMetaLV
+.B lvconvert --type cache-pool --poolmetadata VG/CacheMetaLV
 .RS
 .B VG/CacheDataLV
 .RE
 
 .I Example
 .br
-# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache0meta vg/cache0
+# lvconvert --type cache-pool --poolmetadata vg/cache0meta vg/cache0
 
 .nf
 # lvs -a vg
   LV              VG   Attr       LSize   Pool Origin
-  cache0          vg   Cwi\-\-\-C\-\-\-  10.00g
-  [cache0_cdata]  vg   Cwi\-\-\-\-\-\-\-  10.00g
-  [cache0_cmeta]  vg   ewi\-\-\-\-\-\-\-  12.00m
-  lvol0           vg   -wi\-a\-\-\-\-\- 100.00g
+  cache0          vg   Cwi---C---  10.00g
+  [cache0_cdata]  vg   Cwi-------  10.00g
+  [cache0_cmeta]  vg   ewi-------  12.00m
+  lvol0           vg   -wi-a----- 100.00g
 .fi
 
 
@@ -118,20 +118,20 @@ CacheLV takes the name of OriginLV.
 .br
 OriginLV is renamed OriginLV_corig and becomes hidden.
 
-.B lvconvert \-\-type cache \-\-cachepool VG/CachePoolLV VG/OriginLV
+.B lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
 
 .I Example
 .br
-# lvconvert \-\-type cache \-\-cachepool vg/cache0 vg/lvol0
+# lvconvert --type cache --cachepool vg/cache0 vg/lvol0
 
 .nf
 # lvs -a vg
   LV              VG   Attr       LSize   Pool   Origin
-  cache0          vg   Cwi\-\-\-C\-\-\-  10.00g                                                             
-  [cache0_cdata]  vg   Cwi\-ao\-\-\-\-  10.00g                                                             
-  [cache0_cmeta]  vg   ewi\-ao\-\-\-\-  12.00m                                                             
-  lvol0           vg   Cwi\-a\-C\-\-\- 100.00g cache0 [lvol0_corig]                                        
-  [lvol0_corig]   vg   -wi\-ao\-\-\-\- 100.00g                                                             
+  cache0          vg   Cwi---C---  10.00g                                                             
+  [cache0_cdata]  vg   Cwi-ao----  10.00g                                                             
+  [cache0_cmeta]  vg   ewi-ao----  12.00m                                                             
+  lvol0           vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]                                        
+  [lvol0_corig]   vg   -wi-ao---- 100.00g                                                             
 .fi
 
 
@@ -145,7 +145,7 @@ A cache pool LV can be disconnected from a cache LV, leaving an
 unused cache pool LV, and an uncached origin LV.  This command
 writes back data from the cache pool to the origin LV when necessary.
 
-.B lvconvert \-\-splitcache VG/CacheLV
+.B lvconvert --splitcache VG/CacheLV
 
 .SS Removing a cache pool LV without removing its linked origin LV
 
@@ -159,20 +159,20 @@ then removes the cache pool LV, leaving the uncached origin LV.
 An alternative command that also disconnects the cache pool from the cache
 LV, and deletes the cache pool:
 
-.B lvconvert \-\-uncache VG/CacheLV
+.B lvconvert --uncache VG/CacheLV
 
 .I Example
 .nf
 # lvs vg
   LV     VG   Attr       LSize   Pool   Origin
-  cache0 vg   Cwi\-\-\-C\-\-\-  10.00g
-  lvol0  vg   Cwi\-a\-C\-\-\- 100.00g cache0 [lvol0_corig]
+  cache0 vg   Cwi---C---  10.00g
+  lvol0  vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]
 
 # lvremove vg/cache0
 
 # lvs vg
   LV    VG   Attr       LSize   Pool Origin
-  lvol0 vg   -wi\-a\-\-\-\-\- 100.00g
+  lvol0 vg   -wi-a----- 100.00g
 .fi
 
 .SS Removing a cache LV: both origin LV and the cache pool LV
@@ -193,26 +193,26 @@ LV.
 
 Users who are concerned about the possibility of failures in their fast
 devices that could lead to data loss might consider making their cache
-pool sub\-LVs redundant.
+pool sub-LVs redundant.
 
 .I Example
 .nf
 0. Create an origin LV we wish to cache
-# lvcreate \-L 10G \-n lv1 vg /dev/slow_devs
+# lvcreate -L 10G -n lv1 vg /dev/slow_devs
 
 1. Create a 2-way RAID1 cache data LV
-# lvcreate \-\-type raid1 \-m 1 \-L 1G -n cache1 vg \\
+# lvcreate --type raid1 -m 1 -L 1G -n cache1 vg \\
 	/dev/fast1 /dev/fast2
 
 2. Create a 2-way RAID1 cache metadata LV
-# lvcreate \-\-type raid1 \-m 1 \-L 8M -n cache1meta vg \\
+# lvcreate --type raid1 -m 1 -L 8M -n cache1meta vg \\
 	/dev/fast1 /dev/fast2
 
 3. Create a cache pool LV combining cache data LV and cache metadata LV
-# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache1meta vg/cache1
+# lvconvert --type cache-pool --poolmetadata vg/cache1meta vg/cache1
 
 4. Create a cached LV by combining the cache pool LV and origin LV
-# lvconvert \-\-type cache \-\-cachepool vg/cache1 vg/lv1
+# lvconvert --type cache --cachepool vg/cache1 vg/lv1
 .fi
 
 .SS Cache mode
@@ -229,11 +229,11 @@ from the cache pool back to the origin LV.  This mode will increase
 performance, but the loss of a device associated with the cache pool LV
 can result in lost data.
 
-With the \-\-cachemode option, the cache mode can be set when creating a
+With the --cachemode option, the cache mode can be set when creating a
 cache LV, or changed on an existing cache LV.  The current cache mode of a
 cache LV can be displayed with the cache_mode reporting option:
 
-.B lvs \-o+cache_mode VG/CacheLV
+.B lvs -o+cache_mode VG/CacheLV
 
 .BR lvm.conf (5)
 .B allocation/cache_mode
@@ -243,21 +243,21 @@ defines the default cache mode.
 .I Example
 .nf
 0. Create an origin LV we wish to cache (yours may already exist)
-# lvcreate \-L 10G \-n lv1 vg /dev/slow
+# lvcreate -L 10G -n lv1 vg /dev/slow
 
 1. Create a cache data LV
-# lvcreate \-L 1G \-n cache1 vg /dev/fast
+# lvcreate -L 1G -n cache1 vg /dev/fast
 
 2. Create a cache metadata LV
-# lvcreate \-L 8M \-n cache1meta vg /dev/fast
+# lvcreate -L 8M -n cache1meta vg /dev/fast
 
 3. Create a cache pool LV
-# lvconvert \-\-type cache\-pool \-\-poolmetadata vg/cache1meta vg/cache1
+# lvconvert --type cache-pool --poolmetadata vg/cache1meta vg/cache1
 
 4. Create a cache LV by combining the cache pool LV and origin LV,
    and use the writethrough cache mode.
-# lvconvert \-\-type cache \-\-cachepool vg/cache1 \\
-	\-\-cachemode writethrough vg/lv1
+# lvconvert --type cache --cachepool vg/cache1 \\
+	--cachemode writethrough vg/lv1
 .fi
 
 
@@ -265,7 +265,7 @@ defines the default cache mode.
 
 \&
 
-The cache subsystem has additional per\-LV parameters: the cache policy to
+The cache subsystem has additional per-LV parameters: the cache policy to
 use, and possibly tunable parameters for the cache policy.  Three policies
 are currently available: "smq" is the default policy, "mq" is an older
 implementation, and "cleaner" is used to force the cache to write back
@@ -275,18 +275,18 @@ The "mq" policy has a number of tunable parameters. The defaults are
 chosen to be suitable for the majority of systems, but in special
 circumstances, changing the settings can improve performance.
 
-With the \-\-cachepolicy and \-\-cachesettings options, the cache policy
+With the --cachepolicy and --cachesettings options, the cache policy
 and settings can be set when creating a cache LV, or changed on an
 existing cache LV (both options can be used together).  The current cache
 policy and settings of a cache LV can be displayed with the cache_policy
 and cache_settings reporting options:
 
-.B lvs \-o+cache_policy,cache_settings VG/CacheLV
+.B lvs -o+cache_policy,cache_settings VG/CacheLV
 
 .I Example
 .nf
 Change the cache policy and settings of an existing cache LV.
-# lvchange \-\-cachepolicy mq \-\-cachesettings \\
+# lvchange --cachepolicy mq --cachesettings \\
 	\(aqmigration_threshold=2048 random_threshold=4\(aq vg/lv1
 .fi
 
@@ -306,7 +306,7 @@ defines the default cache settings.
 \&
 
 The size of data blocks managed by a cache pool can be specified with the
-\-\-chunksize option when the cache LV is created.  The default unit
+--chunksize option when the cache LV is created.  The default unit
 is KiB. The value must be a multiple of 32KiB between 32KiB and 1GiB.
 
 Using a chunk size that is too large can result in wasteful use of the
@@ -318,7 +318,7 @@ CPU time searching for chunks, and excessive memory tracking chunks.
 
 Command to display the cache pool LV chunk size:
 .br
-.B lvs \-o+chunksize VG/CacheLV
+.B lvs -o+chunksize VG/CacheLV
 
 .BR lvm.conf (5)
 .B cache_pool_chunk_size
@@ -327,7 +327,7 @@ controls the default chunk size used when creating a cache LV.
 
 The default value is shown by:
 .br
-.B lvmconfig \-\-type default allocation/cache_pool_chunk_size
+.B lvmconfig --type default allocation/cache_pool_chunk_size
 
 
 .SS Spare metadata LV
@@ -349,7 +349,7 @@ the same VG.
 
 .B lvcreate -n CacheDataLV -L CacheSize VG
 .br
-.B lvconvert \-\-type cache\-pool VG/CacheDataLV
+.B lvconvert --type cache-pool VG/CacheDataLV
 
 
 .SS Create a new cache LV without an existing origin LV
@@ -360,9 +360,9 @@ A cache LV can be created using an existing cache pool without an existing
 origin LV.  A new origin LV is created and linked to the cache pool in a
 single step.
 
-.B lvcreate \-\-type cache \-L LargeSize \-n CacheLV
+.B lvcreate --type cache -L LargeSize -n CacheLV
 .RS
-.B \-\-cachepool VG/CachePoolLV VG SlowPVs
+.B --cachepool VG/CachePoolLV VG SlowPVs
 .RE
 
 
@@ -374,7 +374,7 @@ A cache pool LV can be created with a single lvcreate command, rather than
 using lvconvert on existing LVs.  This one command creates a cache data
 LV, a cache metadata LV, and combines the two into a cache pool LV.
 
-.B lvcreate \-\-type cache\-pool \-L CacheSize \-n CachePoolLV VG FastPVs
+.B lvcreate --type cache-pool -L CacheSize -n CachePoolLV VG FastPVs
 
 
 .SS Convert existing LVs to cache types
@@ -390,7 +390,7 @@ may optionally be specified.
 .br
 .B lvcreate -n CacheDataLV -L CacheSize VG
 .br
-.B lvconvert \-\-type cache \-\-cachepool VG/CataDataLV VG/OriginLV
+.B lvconvert --type cache --cachepool VG/CataDataLV VG/OriginLV
 
 This is equivalent to:
 
@@ -398,9 +398,9 @@ This is equivalent to:
 .br
 .B lvcreate -n CacheDataLV -L CacheSize VG
 .br
-.B lvconvert \-\-type cache\-pool VG/CacheDataLV
+.B lvconvert --type cache-pool VG/CacheDataLV
 .br
-.B lvconvert \-\-type cache \-\-cachepool VG/CachePoolLV VG/OriginLV
+.B lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
 
 
 .SH SEE ALSO
diff --git a/man/lvmconf.8_main b/man/lvmconf.8_main
index 5ca80f3..ca66ae6 100644
--- a/man/lvmconf.8_main
+++ b/man/lvmconf.8_main
@@ -4,19 +4,19 @@
 lvmconf \(em LVM configuration modifier
 .SH "SYNOPSIS"
 .B lvmconf
-.RB [ \-\-disable\-cluster ]
-.RB [ \-\-enable\-cluster ]
-.RB [ \-\-enable\-halvm ]
-.RB [ \-\-disable\-halvm ]
-.RB [ \-\-file
+.RB [ --disable-cluster ]
+.RB [ --enable-cluster ]
+.RB [ --enable-halvm ]
+.RB [ --disable-halvm ]
+.RB [ --file
 .RI < configfile >]
-.RB [ \-\-lockinglib
+.RB [ --lockinglib
 .RI < lib >]
-.RB [ \-\-lockinglibdir
+.RB [ --lockinglibdir
 .RI < dir >]
-.RB [ \-\-services ]
-.RB [ \-\-mirrorservice ]
-.RB [ \-\-startstopservices ]
+.RB [ --services ]
+.RB [ --mirrorservice ]
+.RB [ --startstopservices ]
 
 .SH "DESCRIPTION"
 lvmconf is a script that modifies the locking configuration in
@@ -26,42 +26,42 @@ changes in the lvm configuration if needed.
 
 .SH "OPTIONS"
 .TP
-.BR \-\-disable\-cluster
-Set \fBlocking_type\fR to the default non\-clustered type. Also reset
+.BR --disable-cluster
+Set \fBlocking_type\fR to the default non-clustered type. Also reset
 lvmetad use to its default.
 .TP
-.BR \-\-enable\-cluster
+.BR --enable-cluster
 Set \fBlocking_type\fR to the default clustered type on this system.
 Also disable lvmetad use as it is not yet supported in clustered environment.
 .TP
-.BR \-\-disable\-halvm
-Set \fBlocking_type\fR to the default non\-clustered type. Also reset
+.BR --disable-halvm
+Set \fBlocking_type\fR to the default non-clustered type. Also reset
 lvmetad use to its default.
 .TP
-.BR \-\-enable\-halvm
+.BR --enable-halvm
 Set \fBlocking_type\fR suitable for HA LVM use.
 Also disable lvmetad use as it is not yet supported in HA LVM environment.
 .TP
-.BR \-\-file " <" \fIconfigfile >
+.BR --file " <" \fIconfigfile >
 Apply the changes to \fIconfigfile\fP instead of the default
 \fI#DEFAULT_SYS_DIR#/lvm.conf\fP.
 .TP
-.BR \-\-lockinglib " <" \fIlib >
+.BR --lockinglib " <" \fIlib >
 Set external \fBlocking_library\fR locking library to load if an external locking type is used.
 .TP
-.BR \-\-lockinglibdir " <" \fIdir >
+.BR --lockinglibdir " <" \fIdir >
 .TP
-.BR \-\-services
+.BR --services
 In addition to setting the lvm configuration, also enable or disable related Systemd or SysV
 clvmd and lvmetad services. This script does not configure services provided by cluster resource
 agents.
 .TP
-.BR \-\-mirrorservice
-Also enable or disable optional cmirrord service when handling services (applicable only with \-\-services).
+.BR --mirrorservice
+Also enable or disable optional cmirrord service when handling services (applicable only with --services).
 .TP
-.BR \-\-startstopservices
+.BR --startstopservices
 In addition to enabling or disabling related services, start or stop them immediately
-(applicable only with \-\-services).
+(applicable only with --services).
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
 
diff --git a/man/lvmconfig.8_des b/man/lvmconfig.8_des
index 17f9f18..3863d12 100644
--- a/man/lvmconfig.8_des
+++ b/man/lvmconfig.8_des
@@ -1,3 +1,3 @@
 lvmconfig produces formatted output from the LVM configuration tree. The
 sources of the configuration data include \fBlvm.conf\fP(5) and command
-line settings from \-\-config.
+line settings from --config.
diff --git a/man/lvmdbusd.8_main b/man/lvmdbusd.8_main
index 3bf46c1..99a7001 100644
--- a/man/lvmdbusd.8_main
+++ b/man/lvmdbusd.8_main
@@ -2,19 +2,19 @@
 .
 .SH NAME
 .
-lvmdbusd \(em LVM D\-Bus daemon
+lvmdbusd \(em LVM D-Bus daemon
 .
 .SH SYNOPSIS
 .
 .ad l
 .B lvmdbusd
-.RB [ \-\-debug \]
-.RB [ \-\-udev \]
+.RB [ --debug \]
+.RB [ --udev \]
 .ad b
 .
 .SH DESCRIPTION
 .
-lvmdbusd is a service which provides a D\-Bus API to the logical volume manager (LVM).
+lvmdbusd is a service which provides a D-Bus API to the logical volume manager (LVM).
 Run 
 .BR lvmdbusd (8)
 as root.
@@ -22,17 +22,17 @@ as root.
 .SH OPTIONS
 .
 .HP
-.BR \-\-debug 
+.BR --debug 
 .br
 Enable debug statements 
 .
 .HP
-.BR \-\-udev
+.BR --udev
 .br
 Use udev events to trigger updates
 .
 .SH SEE ALSO
 .
 .nh
-.BR dbus\-send (1),
+.BR dbus-send (1),
 .BR lvm (8)
diff --git a/man/lvmdump.8_main b/man/lvmdump.8_main
index d62c736..ec3dbb2 100644
--- a/man/lvmdump.8_main
+++ b/man/lvmdump.8_main
@@ -3,16 +3,16 @@
 lvmdump \(em create lvm2 information dumps for diagnostic purposes
 .SH SYNOPSIS
 .B lvmdump
-.RB [ \-a ]
-.RB [ \-c ]
-.RB [ \-d
+.RB [ -a ]
+.RB [ -c ]
+.RB [ -d
 .IR directory ]
-.RB [ \-h ]
-.RB [ \-l ]
-.RB [ \-m ]
-.RB [ \-p ]
-.RB [ \-s ]
-.RB [ \-u ]
+.RB [ -h ]
+.RB [ -l ]
+.RB [ -m ]
+.RB [ -p ]
+.RB [ -s ]
+.RB [ -u ]
 .SH DESCRIPTION
 lvmdump is a tool to dump various information concerning LVM2.
 By default, it creates a tarball suitable for submission along
@@ -34,69 +34,69 @@ The content of the tarball is as follows:
 .br
 - list of files present /sys/devices/virtual/block
 .br
-- if enabled with \-m, metadata dump will be also included
+- if enabled with -m, metadata dump will be also included
 .br
-- if enabled with \-a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
+- if enabled with -a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
 .br
-- if enabled with \-c, cluster status info
+- if enabled with -c, cluster status info
 .br
-- if enabled with \-l, lvmetad state if running
+- if enabled with -l, lvmetad state if running
 .br
-- if enabled with \-p, lvmpolld state if running
+- if enabled with -p, lvmpolld state if running
 .br
-- if enabled with \-s, system info and context
+- if enabled with -s, system info and context
 .br
-- if enabled with \-u, udev info and context
+- if enabled with -u, udev info and context
 .SH OPTIONS
 .TP
-.B \-a
+.B -a
 Advanced collection.
 \fBWARNING\fR: if lvm is already hung, then this script may hang as well
-if \fB\-a\fR is used.
+if \fB-a\fR is used.
 .TP
-.B \-c
+.B -c
 If clvmd is running, gather cluster data as well.
 .TP
-.B \-d  \fIdirectory
+.B -d  \fIdirectory
 Dump into a directory instead of tarball
 By default, lvmdump will produce a single compressed tarball containing
 all the information. Using this option, it can be instructed to only
 produce the raw dump tree, rooted in \fIdirectory\fP.
 .TP
-.B \-h
+.B -h
 Print help message
 .TP
-.B \-l
+.B -l
 Include \fBlvmetad\fP(8) daemon dump if it is running. The dump contains
 cached information that is currently stored in lvmetad: VG metadata,
 PV metadata and various mappings in between these metadata for quick
 access.
 .TP
-.B \-m
+.B -m
 Gather LVM metadata from the PVs
 This option generates a 1:1 dump of the metadata area from all PVs visible
 to the system, which can cause the dump to increase in size considerably.
 However, the metadata dump may represent a valuable diagnostic resource.
 .TP
-.B \-p
+.B -p
 Include \fBlvmpolld\fP(8) daemon dump if it is running. The dump contains
-all in\-progress operation currently monitored by the daemon and partial
+all in-progress operation currently monitored by the daemon and partial
 history for all yet uncollected results of polling operations already finished
 including reason.
 .TP
-.B \-s
+.B -s
 Gather system info and context. Currently, this encompasses info gathered
 by calling lsblk command and various systemd info and context: overall state
 of systemd units present in the system, more detailed status of units
 controlling LVM functionality and the content of systemd journal for
 current boot.
 .TP
-.B \-u
+.B -u
 Gather udev info and context: /etc/udev/udev.conf file, udev daemon version
-(output of 'udevadm info \-\-version' command), udev rules currently used in the system
+(output of 'udevadm info --version' command), udev rules currently used in the system
 (content of /lib/udev/rules.d and /etc/udev/rules.d directory),
 list of files in /lib/udev directory and dump of current udev
-database content (the output of 'udevadm info \-\-export\-db' command).
+database content (the output of 'udevadm info --export-db' command).
 .SH ENVIRONMENT VARIABLES
 .TP
 \fBLVM_BINARY\fP
diff --git a/man/lvmetad.8_main b/man/lvmetad.8_main
index 16e3d52..31a89cc 100644
--- a/man/lvmetad.8_main
+++ b/man/lvmetad.8_main
@@ -4,18 +4,18 @@ lvmetad \(em LVM metadata cache daemon
 
 .SH SYNOPSIS
 .B lvmetad
-.RB [ \-l
+.RB [ -l
 .IR level [,level...]]
-.RB [ \-p
+.RB [ -p
 .IR pidfile_path ]
-.RB [ \-s
+.RB [ -s
 .IR socket_path ]
-.RB [ \-t
+.RB [ -t
 .IR timeout_value ]
-.RB [ \-f ]
-.RB [ \-h ]
-.RB [ \-V ]
-.RB [ \-? ]
+.RB [ -f ]
+.RB [ -h ]
+.RB [ -V ]
+.RB [ -? ]
 
 .SH DESCRIPTION
 
@@ -26,7 +26,7 @@ the normal work of the system.  lvmetad can be a disadvantage when disk
 event notifications from the system are unreliable.
 
 lvmetad does not read metadata from disks itself.  Instead, it relies on
-an LVM command, like pvscan \-\-cache, to read metadata from disks and
+an LVM command, like pvscan --cache, to read metadata from disks and
 send it to lvmetad to be cached.
 
 New LVM disks that appear on the system must be scanned before lvmetad
@@ -34,8 +34,8 @@ knows about them.  If lvmetad does not know about a disk, then LVM
 commands using lvmetad will also not know about it.  When disks are added
 or removed from the system, lvmetad must be updated.
 
-lvmetad is usually combined with event\-based system services that
-automatically run pvscan \-\-cache on disks added or removed.  This way,
+lvmetad is usually combined with event-based system services that
+automatically run pvscan --cache on disks added or removed.  This way,
 the cache is automatically updated with metadata from new disks when they
 appear.  LVM udev rules and systemd services implement this automation.
 Automatic scanning is usually combined with automatic activation.  For
@@ -44,7 +44,7 @@ more information, see
 
 If lvmetad is started or restarted after disks have been added to the
 system, or if the global_filter has changed, the cache must be updated.
-This can be done by running pvscan \-\-cache, or it will be done
+This can be done by running pvscan --cache, or it will be done
 automatically by the next LVM command that's run.
 
 When lvmetad is not used, LVM commands revert to scanning disks for LVM
@@ -56,7 +56,7 @@ revert to scanning disks.  A warning will also be printed which includes
 the reason why lvmetad is not being used.  The most common reason is the
 existence of duplicate PVs (lvmetad cannot cache data for duplicate PVs.)
 Once duplicates have been resolved, the lvmetad cache is can be updated
-with pvscan \-\-cache and commands will return to using the cache.
+with pvscan --cache and commands will return to using the cache.
 
 Use of lvmetad is enabled/disabled by:
 .br
@@ -65,7 +65,7 @@ Use of lvmetad is enabled/disabled by:
 
 For more information on this setting, see:
 .br
-.B lvmconfig \-\-withcomments global/use_lvmetad
+.B lvmconfig --withcomments global/use_lvmetad
 
 To ignore disks from LVM at the system level, e.g. lvmetad, pvscan use:
 .br
@@ -74,42 +74,42 @@ To ignore disks from LVM at the system level, e.g. lvmetad, pvscan use:
 
 For more information on this setting, see
 .br
-.B lvmconfig \-\-withcomments devices/global_filter
+.B lvmconfig --withcomments devices/global_filter
 
 .SH OPTIONS
 
 To run the daemon in a test environment both the pidfile_path and the
 socket_path should be changed from the defaults.
 .TP
-.B \-f
+.B -f
 Don't fork, but run in the foreground.
 .TP
-.BR \-h ", " \-?
+.BR -h ", " -?
 Show help information.
 .TP
-.B \-l \fIlevels
+.B -l \fIlevels
 Specify the levels of log messages to generate as a comma separated list.
 Messages are logged by syslog.
-Additionally, when \-f is given they are also sent to standard error.
+Additionally, when -f is given they are also sent to standard error.
 Possible levels are: all, fatal, error, warn, info, wire, debug.
 .TP
-.B \-p \fIpidfile_path
-Path to the pidfile. This overrides both the built\-in default
+.B -p \fIpidfile_path
+Path to the pidfile. This overrides both the built-in default
 (#DEFAULT_PID_DIR#/lvmetad.pid) and the environment variable
 \fBLVM_LVMETAD_PIDFILE\fP.  This file is used to prevent more
 than one instance of the daemon running simultaneously.
 .TP
-.B \-s \fIsocket_path
-Path to the socket file. This overrides both the built\-in default
+.B -s \fIsocket_path
+Path to the socket file. This overrides both the built-in default
 (#DEFAULT_RUN_DIR#/lvmetad.socket) and the environment variable
 \fBLVM_LVMETAD_SOCKET\fP.  To communicate successfully with lvmetad,
 all LVM2 processes should use the same socket path.
 .TP
-.B \-t \fItimeout_value
+.B -t \fItimeout_value
 The daemon may shutdown after being idle for the given time (in seconds). When the
 option is omitted or the value given is zero the daemon never shutdowns on idle.
 .TP
-.B \-V
+.B -V
 Display the version of lvmetad daemon.
 .SH ENVIRONMENT VARIABLES
 .TP
diff --git a/man/lvmlockctl.8_main b/man/lvmlockctl.8_main
index fc18fcb..b7ac0ec 100644
--- a/man/lvmlockctl.8_main
+++ b/man/lvmlockctl.8_main
@@ -11,41 +11,41 @@ This command interacts with
 
 lvmlockctl [options]
 
-.B  \-\-help | \-h
+.B  --help | -h
         Show this help information.
 
-.B  \-\-quit | \-q
+.B  --quit | -q
         Tell lvmlockd to quit.
 
-.B  \-\-info | \-i
+.B  --info | -i
         Print lock state information from lvmlockd.
 
-.B  \-\-dump | \-d
+.B  --dump | -d
         Print log buffer from lvmlockd.
 
-.B  \-\-wait | \-w 0|1
+.B  --wait | -w 0|1
         Wait option for other commands.
 
-.B  \-\-force | \-f 0|1
+.B  --force | -f 0|1
         Force option for other commands.
 
-.B  \-\-kill | \-k
+.B  --kill | -k
 .I vgname
         Kill access to the VG when sanlock cannot renew lease.
 
-.B  \-\-drop | \-r
+.B  --drop | -r
 .I vgname
         Clear locks for the VG when it is unused after kill (-k).
 
-.B  \-\-gl\-enable | \-E
+.B  --gl-enable | -E
 .I vgname
         Tell lvmlockd to enable the global lock in a sanlock VG.
 
-.B  \-\-gl\-disable | \-D
+.B  --gl-disable | -D
 .I vgname
         Tell lvmlockd to disable the global lock in a sanlock VG.
 
-.B  \-\-stop\-lockspaces | \-S
+.B  --stop-lockspaces | -S
         Stop all lockspaces.
 
 
@@ -55,7 +55,7 @@ lvmlockctl [options]
 
 This collects and displays lock state from lvmlockd.  The display is
 primitive, incomplete and will change in future version.  To print the raw
-lock state from lvmlockd, combine this option with \-\-dump|-d.
+lock state from lvmlockd, combine this option with --dump|-d.
 
 .SS dump
 
@@ -73,28 +73,28 @@ forcibly deactivate the VG.  For more, see
 .SS drop
 
 This should only be run after a VG has been successfully deactivated
-following an lvmlockctl \-\-kill command.  It clears the stale lockspace
+following an lvmlockctl --kill command.  It clears the stale lockspace
 from lvmlockd.  In the future, this may become automatic along with an
-automatic handling of \-\-kill.  For more, see
+automatic handling of --kill.  For more, see
 .BR lvmlockd (8).
 
-.SS gl\-enable
+.SS gl-enable
 
 This enables the global lock in a sanlock VG.  This is necessary if the VG
 that previously held the global lock is removed.  For more, see
 .BR lvmlockd (8).
 
-.SS gl\-disable
+.SS gl-disable
 
 This disables the global lock in a sanlock VG.  This is necessary if the
 global lock has mistakenly been enabled in more than one VG.  The global
 lock should be disabled in all but one sanlock VG.  For more, see
 .BR lvmlockd (8).
 
-.SS stop\-lockspaces
+.SS stop-lockspaces
 
 This tells lvmlockd to stop all lockspaces.  It can be useful to stop
-lockspaces for VGs that the vgchange \-\-lock\-stop comand can no longer
+lockspaces for VGs that the vgchange --lock-stop comand can no longer
 see, or to stop the dlm global lockspace which is not directly stopped by
 the vgchange command.  The wait and force options can be used with this
 command.
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 6c8f3f0..1a1c2fc 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -33,50 +33,50 @@ dlm: uses network communication and a cluster manager.
 
 lvmlockd [options]
 
-For default settings, see lvmlockd \-h.
+For default settings, see lvmlockd -h.
 
-.B  \-\-help | \-h
+.B  --help | -h
         Show this help information.
 
-.B  \-\-version | \-V
+.B  --version | -V
         Show version of lvmlockd.
 
-.B  \-\-test | \-T
+.B  --test | -T
         Test mode, do not call lock manager.
 
-.B  \-\-foreground | \-f
+.B  --foreground | -f
         Don't fork.
 
-.B  \-\-daemon\-debug | \-D
+.B  --daemon-debug | -D
         Don't fork and print debugging to stdout.
 
-.B  \-\-pid\-file | \-p
+.B  --pid-file | -p
 .I path
         Set path to the pid file.
 
-.B  \-\-socket\-path | \-s
+.B  --socket-path | -s
 .I path
         Set path to the socket to listen on.
 
-.B  \-\-syslog\-priority | \-S err|warning|debug
+.B  --syslog-priority | -S err|warning|debug
         Write log messages from this level up to syslog.
 
-.B  \-\-gl\-type | \-g sanlock|dlm
+.B  --gl-type | -g sanlock|dlm
         Set global lock type to be sanlock or dlm.
 
-.B  \-\-host\-id | \-i
+.B  --host-id | -i
 .I num
         Set the local sanlock host id.
 
-.B  \-\-host\-id\-file | \-F
+.B  --host-id-file | -F
 .I path
         A file containing the local sanlock host_id.
 
-.B  \-\-sanlock\-timeout | \-o
+.B  --sanlock-timeout | -o
 .I seconds
         Override the default sanlock I/O timeout.
 
-.B  \-\-adopt | \-A 0|1
+.B  --adopt | -A 0|1
         Adopt locks from a previous instance of lvmlockd.
 
 
@@ -84,7 +84,7 @@ For default settings, see lvmlockd \-h.
 
 .SS Initial set up
 
-Using LVM with lvmlockd for the first time includes some one\-time set up
+Using LVM with lvmlockd for the first time includes some one-time set up
 steps:
 
 .SS 1. choose a lock manager
@@ -111,7 +111,7 @@ use_lvmlockd = 1
 
 .I sanlock
 .br
-Assign each host a unique host_id in the range 1\-2000 by setting
+Assign each host a unique host_id in the range 1-2000 by setting
 .br
 /etc/lvm/lvmlocal.conf local/host_id
 
@@ -133,7 +133,7 @@ systemctl start corosync dlm
 
 .SS 5. create VG on shared devices
 
-vgcreate \-\-shared <vgname> <devices>
+vgcreate --shared <vgname> <devices>
 
 The shared option sets the VG lock type to sanlock or dlm depending on
 which lock manager is running.  LVM commands will perform locking for the
@@ -141,7 +141,7 @@ VG using lvmlockd.  lvmlockd will use the chosen lock manager.
 
 .SS 6. start VG on all hosts
 
-vgchange \-\-lock\-start
+vgchange --lock-start
 
 lvmlockd requires shared VGs to be started before they are used.  This is
 a lock manager operation to start (join) the VG lockspace, and it may take
@@ -156,7 +156,7 @@ LVs in a shared VG.
 
 An LV activated exclusively on one host cannot be activated on another.
 When multiple hosts need to use the same LV concurrently, the LV can be
-activated with a shared lock (see lvchange options \-aey vs \-asy.)
+activated with a shared lock (see lvchange options -aey vs -asy.)
 (Shared locks are disallowed for certain LV types that cannot be used from
 multiple hosts.)
 
@@ -177,7 +177,7 @@ start lvmlockd
 start lock manager
 .br
 \[bu]
-vgchange \-\-lock\-start
+vgchange --lock-start
 .br
 \[bu]
 activate LVs in shared VGs
@@ -189,7 +189,7 @@ The shut down sequence is the reverse:
 deactivate LVs in shared VGs
 .br
 \[bu]
-vgchange \-\-lock\-stop
+vgchange --lock-stop
 .br
 \[bu]
 stop lock manager
@@ -227,7 +227,7 @@ activate the VG will fail without the necessary locks.
 
 A "local VG" is meant to be used by a single host.  It has no lock type or
 lock type "none".  LVM commands and lvmlockd do not perform locking for
-these VGs.  A local VG typically exists on local (non\-shared) devices and
+these VGs.  A local VG typically exists on local (non-shared) devices and
 cannot be used concurrently from different hosts.
 
 If a local VG does exist on shared devices, it should be owned by a single
@@ -252,8 +252,8 @@ using lvmlockd.  From a host not using lvmlockd, visible lockd VGs are
 ignored in the same way as foreign VGs (see
 .BR lvmsystemid (7).)
 
-The \-\-shared option for reporting and display commands causes lockd VGs
-to be displayed on a host not using lvmlockd, like the \-\-foreign option
+The --shared option for reporting and display commands causes lockd VGs
+to be displayed on a host not using lvmlockd, like the --foreign option
 does for foreign VGs.
 
 
@@ -275,7 +275,7 @@ Creates a clvm VG when clvm is configured.
 
 .P
 
-.B vgcreate \-\-shared <vgname> <devices>
+.B vgcreate --shared <vgname> <devices>
 .IP \[bu] 2
 Requires lvmlockd to be configured and running.
 .IP \[bu] 2
@@ -288,7 +288,7 @@ lvmlockd obtains locks from the selected lock manager.
 
 .P
 
-.B vgcreate \-c|\-\-clustered y <vgname> <devices>
+.B vgcreate -c|--clustered y <vgname> <devices>
 .IP \[bu] 2
 Requires clvm to be configured and running.
 .IP \[bu] 2
@@ -343,29 +343,29 @@ global lock will be available, and LVM will be fully operational.
 
 When a new lockd VG is created, its lockspace is automatically started on
 the host that creates it.  Other hosts need to run 'vgchange
-\-\-lock\-start' to start the new VG before they can use it.
+--lock-start' to start the new VG before they can use it.
 
 From the 'vgs' command, lockd VGs are indicated by "s" (for shared) in the
 sixth attr field.  The specific lock type and lock args for a lockd VG can
-be displayed with 'vgs \-o+locktype,lockargs'.
+be displayed with 'vgs -o+locktype,lockargs'.
 
 lockd VGs need to be "started" and "stopped", unlike other types of VGs.
 See the following section for a full description of starting and stopping.
 
 vgremove of a lockd VG will fail if other hosts have the VG started.
-Run vgchange \-\-lock\-stop <vgname> on all other hosts before vgremove.
+Run vgchange --lock-stop <vgname> on all other hosts before vgremove.
 (It may take several seconds before vgremove recognizes that all hosts
 have stopped a sanlock VG.)
 
 .SS starting and stopping VGs
 
-Starting a lockd VG (vgchange \-\-lock\-start) causes the lock manager to
+Starting a lockd VG (vgchange --lock-start) causes the lock manager to
 start (join) the lockspace for the VG on the host where it is run.  This
 makes locks for the VG available to LVM commands on the host.  Before a VG
 is started, only LVM commands that read/display the VG are allowed to
 continue without locks (and with a warning).
 
-Stopping a lockd VG (vgchange \-\-lock\-stop) causes the lock manager to
+Stopping a lockd VG (vgchange --lock-stop) causes the lock manager to
 stop (leave) the lockspace for the VG on the host where it is run.  This
 makes locks for the VG inaccessible to the host.  A VG cannot be stopped
 while it has active LVs.
@@ -390,24 +390,24 @@ A lockd VG can be stopped if all LVs are deactivated.
 
 All lockd VGs can be started/stopped using:
 .br
-vgchange \-\-lock\-start
+vgchange --lock-start
 .br
-vgchange \-\-lock\-stop
+vgchange --lock-stop
 
 
 Individual VGs can be started/stopped using:
 .br
-vgchange \-\-lock\-start <vgname> ...
+vgchange --lock-start <vgname> ...
 .br
-vgchange \-\-lock\-stop <vgname> ...
+vgchange --lock-stop <vgname> ...
 
 To make vgchange not wait for start to complete:
 .br
-vgchange \-\-lock\-start \-\-lock\-opt nowait ...
+vgchange --lock-start --lock-opt nowait ...
 
 lvmlockd can be asked directly to stop all lockspaces:
 .br
-lvmlockctl \-\-stop\-lockspaces
+lvmlockctl --stop-lockspaces
 
 To start only selected lockd VGs, use the lvm.conf
 activation/lock_start_list.  When defined, only VG names in this list are
@@ -429,7 +429,7 @@ Scripts or programs on a host that automatically start VGs will use the
 "auto" option to indicate that the command is being run automatically by
 the system:
 
-vgchange \-\-lock\-start \-\-lock\-opt auto [<vgname> ...]
+vgchange --lock-start --lock-opt auto [<vgname> ...]
 
 Without any additional configuration, including the "auto" option has no
 effect; all VGs are started unless restricted by lock_start_list.
@@ -545,7 +545,7 @@ If the situation arises where more than one sanlock VG contains a global
 lock, the global lock should be manually disabled in all but one of them
 with the command:
 
-lvmlockctl \-\-gl\-disable <vgname>
+lvmlockctl --gl-disable <vgname>
 
 (The one VG with the global lock enabled must be visible to all hosts.)
 
@@ -555,7 +555,7 @@ and subsequent LVM commands will fail to acquire it.  In this case, the
 global lock needs to be manually enabled in one of the remaining sanlock
 VGs with the command:
 
-lvmlockctl \-\-gl\-enable <vgname>
+lvmlockctl --gl-enable <vgname>
 
 A small sanlock VG dedicated to holding the global lock can avoid the case
 where the GL lock must be manually enabled after a vgremove.
@@ -593,7 +593,7 @@ cannot be acquired, the LV is not activated and an error is reported.
 This would happen if the LV is active exclusively on another host.  If the
 LV type prohibits shared access, such as a snapshot, the command will
 report an error and fail.
-The shared mode is intended for a multi\-host/cluster application or
+The shared mode is intended for a multi-host/cluster application or
 file system.
 LV types that cannot be used concurrently
 from multiple hosts include thin, cache, raid, mirror, and snapshot.
@@ -638,18 +638,18 @@ acquired by other hosts.  The VG must be forcibly deactivated on the host
 with the expiring lease before other hosts can acquire its locks.
 
 When the sanlock daemon detects that the lease storage is lost, it runs
-the command lvmlockctl \-\-kill <vgname>.  This command emits a syslog
+the command lvmlockctl --kill <vgname>.  This command emits a syslog
 message stating that lease storage is lost for the VG and LVs must be
 immediately deactivated.
 
 If no LVs are active in the VG, then the lockspace with an expiring lease
 will be removed, and errors will be reported when trying to use the VG.
-Use the lvmlockctl \-\-drop command to clear the stale lockspace from
+Use the lvmlockctl --drop command to clear the stale lockspace from
 lvmlockd.
 
 If the VG has active LVs when the lock storage is lost, the LVs must be
 quickly deactivated before the lockspace lease expires.  After all LVs are
-deactivated, run lvmlockctl \-\-drop <vgname> to clear the expiring
+deactivated, run lvmlockctl --drop <vgname> to clear the expiring
 lockspace from lvmlockd.  If all LVs in the VG are not deactivated within
 about 40 seconds, sanlock will reset the host using the local watchdog.
 The machine reset is effectively a severe form of "deactivating" LVs
@@ -687,12 +687,12 @@ original cluster:
 .IP \[bu] 2
 Stop the VG on all hosts:
 .br
-vgchange \-\-lock\-stop <vgname>
+vgchange --lock-stop <vgname>
 
 .IP \[bu] 2
 Change the VG lock type to none:
 .br
-vgchange \-\-lock\-type none <vgname>
+vgchange --lock-type none <vgname>
 
 .IP \[bu] 2
 Change the dlm cluster name on the host or move the VG to the new cluster.
@@ -704,12 +704,12 @@ cat /sys/kernel/config/dlm/cluster/cluster_name
 .IP \[bu] 2
 Change the VG lock type back to dlm which sets the new cluster name:
 .br
-vgchange \-\-lock\-type dlm <vgname>
+vgchange --lock-type dlm <vgname>
 
 .IP \[bu] 2
 Start the VG on hosts to use it:
 .br
-vgchange \-\-lock\-start <vgname>
+vgchange --lock-start <vgname>
 
 .P
 
@@ -728,17 +728,17 @@ cat /sys/kernel/config/dlm/cluster/cluster_name
 .IP \[bu] 2
 Change the VG lock type to none:
 .br
-vgchange \-\-lock\-type none \-\-force <vgname>
+vgchange --lock-type none --force <vgname>
 
 .IP \[bu] 2
 Change the VG lock type back to dlm which sets the new cluster name:
 .br
-vgchange \-\-lock\-type dlm <vgname>
+vgchange --lock-type dlm <vgname>
 
 .IP \[bu] 2
 Start the VG on hosts to use it:
 .br
-vgchange \-\-lock\-start <vgname>
+vgchange --lock-start <vgname>
 
 
 .SS changing a local VG to a lockd VG
@@ -749,18 +749,18 @@ lvmlockd must be configured and running as described in USAGE.
 
 Change a local VG to a lockd VG with the command:
 .br
-vgchange \-\-lock\-type sanlock|dlm <vgname>
+vgchange --lock-type sanlock|dlm <vgname>
 
 Start the VG on hosts to use it:
 .br
-vgchange \-\-lock\-start <vgname>
+vgchange --lock-start <vgname>
 
 
 .SS changing a lockd VG to a local VG
 
 Stop the lockd VG on all hosts, then run:
 .br
-vgchange \-\-lock\-type none <vgname>
+vgchange --lock-type none <vgname>
 
 To change a VG from one lockd type to another (i.e. between sanlock and
 dlm), first change it to a local VG, then to the new type.
@@ -773,15 +773,15 @@ All LVs must be inactive to change the lock type.
 First change the clvm VG to a local VG.  Within a running clvm cluster,
 change a clvm VG to a local VG with the command:
 
-vgchange \-cn <vgname>
+vgchange -cn <vgname>
 
 If the clvm cluster is no longer running on any nodes, then extra options
 can be used to forcibly make the VG local.  Caution: this is only safe if
 all nodes have stopped using the VG:
 
-vgchange \-\-config 'global/locking_type=0 global/use_lvmlockd=0'
+vgchange --config 'global/locking_type=0 global/use_lvmlockd=0'
 .RS
-\-cn <vgname>
+-cn <vgname>
 .RE
 
 After the VG is local, follow the steps described in "changing a local VG
@@ -830,7 +830,7 @@ lvm.conf must be configured to use either lvmlockd (use_lvmlockd=1) or
 clvmd (locking_type=3), but not both.
 
 .IP \[bu] 2
-vgcreate \-\-shared creates a lockd VG, and vgcreate \-\-clustered y
+vgcreate --shared creates a lockd VG, and vgcreate --clustered y
 creates a clvm VG.
 
 .IP \[bu] 2
@@ -839,7 +839,7 @@ need for network clustering.
 
 .IP \[bu] 2
 lvmlockd defaults to the exclusive activation mode whenever the activation
-mode is unspecified, i.e. \-ay means \-aey, not \-asy.
+mode is unspecified, i.e. -ay means -aey, not -asy.
 
 .IP \[bu] 2
 lvmlockd commands always apply to the local host, and never have an effect
@@ -856,13 +856,13 @@ lvmlockd saves the cluster name for a lockd VG using dlm.  Only hosts in
 the matching cluster can use the VG.
 
 .IP \[bu] 2
-lvmlockd requires starting/stopping lockd VGs with vgchange \-\-lock\-start
-and \-\-lock\-stop.
+lvmlockd requires starting/stopping lockd VGs with vgchange --lock-start
+and --lock-stop.
 
 .IP \[bu] 2
 vgremove of a sanlock VG may fail indicating that all hosts have not
 stopped the VG lockspace.  Stop the VG on all hosts using vgchange
-\-\-lock\-stop.
+--lock-stop.
 
 .IP \[bu] 2
 vgreduce or pvmove of a PV in a sanlock VG will fail if it holds the
diff --git a/man/lvmpolld.8_main b/man/lvmpolld.8_main
index c5cbce4..4fe1490 100644
--- a/man/lvmpolld.8_main
+++ b/man/lvmpolld.8_main
@@ -3,22 +3,22 @@
 lvmpolld \(em LVM poll daemon
 .SH SYNOPSIS
 .B lvmpolld
-.RB [ \-l | \-\-log
+.RB [ -l | --log
 .RI { all | wire | debug }]
-.RB [ \-p | \-\-pidfile
+.RB [ -p | --pidfile
 .IR pidfile_path ]
-.RB [ \-s | \-\-socket
+.RB [ -s | --socket
 .IR socket_path ]
-.RB [ \-B | \-\-binary
+.RB [ -B | --binary
 .IR lvm_binary_path ]
-.RB [ \-t | \-\-timeout
+.RB [ -t | --timeout
 .IR timeout_value ]
-.RB [ \-f | \-\-foreground ]
-.RB [ \-h | \-\-help ]
-.RB [ \-V | \-\-version ]
+.RB [ -f | --foreground ]
+.RB [ -h | --help ]
+.RB [ -V | --version ]
 
 .B lvmpolld
-.RB [ \-\-dump ]
+.RB [ --dump ]
 .SH DESCRIPTION
 lvmpolld is polling daemon for LVM. The daemon receives requests for polling
 of already initialised operations originating in LVM2 command line tool.
@@ -33,48 +33,48 @@ external factors.
 lvmpolld is used by LVM only if it is enabled in \fBlvm.conf\fP(5) by
 specifying the \fBglobal/use_lvmpolld\fP setting. If this is not defined in the
 LVM configuration explicitly then default setting is used instead (see the
-output of \fBlvmconfig \-\-type default global/use_lvmpolld\fP command).
+output of \fBlvmconfig --type default global/use_lvmpolld\fP command).
 .SH OPTIONS
 
 To run the daemon in a test environment both the pidfile_path and the
 socket_path should be changed from the defaults.
 .TP
-.BR \-f ", " \-\-foreground
+.BR -f ", " --foreground
 Don't fork, but run in the foreground.
 .TP
-.BR \-h ", " \-\-help
+.BR -h ", " --help
 Show help information.
 .TP
-.IR \fB\-l\fP ", " \fB\-\-log\fP " {" all | wire | debug }
+.IR \fB-l\fP ", " \fB--log\fP " {" all | wire | debug }
 Select the type of log messages to generate.
 Messages are logged by syslog.
-Additionally, when \-f is given they are also sent to standard error.
+Additionally, when -f is given they are also sent to standard error.
 There are two classes of messages: wire and debug. Selecting 'all' supplies both
-and is equivalent to a comma\-separated list \-l wire,debug.
+and is equivalent to a comma-separated list -l wire,debug.
 .TP
-.BR \-p ", " \-\-pidfile " " \fIpidfile_path
-Path to the pidfile. This overrides both the built\-in default
+.BR -p ", " --pidfile " " \fIpidfile_path
+Path to the pidfile. This overrides both the built-in default
 (#DEFAULT_PID_DIR#/lvmpolld.pid) and the environment variable
 \fBLVM_LVMPOLLD_PIDFILE\fP.  This file is used to prevent more
 than one instance of the daemon running simultaneously.
 .TP
-.BR \-s ", " \-\-socket " " \fIsocket_path
-Path to the socket file. This overrides both the built\-in default
+.BR -s ", " --socket " " \fIsocket_path
+Path to the socket file. This overrides both the built-in default
 (#DEFAULT_RUN_DIR#/lvmpolld.socket) and the environment variable
 \fBLVM_LVMPOLLD_SOCKET\fP.
 .TP
-.BR \-t ", " \-\-timeout " " \fItimeout_value
+.BR -t ", " --timeout " " \fItimeout_value
 The daemon may shutdown after being idle for the given time (in seconds). When the
 option is omitted or the value given is zero the daemon never shutdowns on idle.
 .TP
-.BR \-B ", " \-\-binary " " \fIlvm_binary_path
+.BR -B ", " --binary " " \fIlvm_binary_path
 Optional path to alternative LVM binary (default: #LVM_PATH#). Use for
 testing purposes only.
 .TP
-.BR \-V ", " \-\-version
+.BR -V ", " --version
 Display the version of lvmpolld daemon.
 .TP
-.B \-\-dump
+.B --dump
 Contact the running lvmpolld daemon to obtain the complete state and print it
 out in a raw format.
 .SH ENVIRONMENT VARIABLES
diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 98630f0..3cbc84b 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -31,12 +31,12 @@ The LV type corresponds to a RAID level.
 The basic RAID levels that can be used are:
 .B raid0, raid1, raid4, raid5, raid6, raid10.
 
-.B lvcreate \-\-type
+.B lvcreate --type
 .I RaidLevel
 [\fIOPTIONS\fP]
-.B \-\-name
+.B --name
 .I Name
-.B \-\-size
+.B --size
 .I Size
 .I VG
 [\fIPVs\fP]
@@ -58,17 +58,17 @@ Also called striping, raid0 spreads LV data across multiple devices in
 units of stripe size.  This is used to increase performance.  LV data will
 be lost if any of the devices fail.
 
-.B lvcreate \-\-type raid0
-[\fB\-\-stripes\fP \fINumber\fP \fB\-\-stripesize\fP \fISize\fP]
+.B lvcreate --type raid0
+[\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
 \fIVG\fP
 [\fIPVs\fP]
 
 .HP
-.B \-\-stripes
+.B --stripes
 specifies the number of devices to spread the LV across.
 
 .HP
-.B \-\-stripesize
+.B --stripesize
 specifies the size of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
@@ -85,15 +85,15 @@ Also called mirroring, raid1 uses multiple devices to duplicate LV data.
 The LV data remains available if all but one of the devices fail.
 The minimum number of devices (i.e. sub LV pairs) required is 2.
 
-.B lvcreate \-\-type raid1
-[\fB\-\-mirrors\fP \fINumber\fP]
+.B lvcreate --type raid1
+[\fB--mirrors\fP \fINumber\fP]
 \fIVG\fP
 [\fIPVs\fP]
 
 .HP
-.B \-\-mirrors
+.B --mirrors
 specifies the number of mirror images in addition to the original LV
-image, e.g. \-\-mirrors 1 means there are two images of the data, the
+image, e.g. --mirrors 1 means there are two images of the data, the
 original and one mirror image.
 .P
 
@@ -109,20 +109,20 @@ storing parity blocks.  The LV data remains available if one device fails.  The
 parity is used to recalculate data that is lost from a single device.  The
 minimum number of devices required is 3.
 
-.B lvcreate \-\-type raid4
-[\fB\-\-stripes\fP \fINumber\fP \fB\-\-stripesize\fP \fISize\fP]
+.B lvcreate --type raid4
+[\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
 \fIVG\fP
 [\fIPVs\fP]
 
 .HP
-.B \-\-stripes
+.B --stripes
 specifies the number of devices to use for LV data.  This does not include
 the extra device lvm adds for storing parity blocks.  A raid4 LV with
 \fINumber\fP stripes requires \fINumber\fP+1 devices.  \fINumber\fP must
 be 2 or more.
 
 .HP
-.B \-\-stripesize
+.B --stripesize
 specifies the size of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
@@ -130,7 +130,7 @@ data that is written to one device before moving to the next.
 \fIPVs\fP specifies the devices to use.  If not specified, lvm will choose
 \fINumber\fP+1 separate devices.
 
-raid4 is called non\-rotating parity because the parity blocks are always
+raid4 is called non-rotating parity because the parity blocks are always
 stored on the same device.
 
 .SS raid5
@@ -143,20 +143,20 @@ a rotating pattern for performance reasons.  The LV data remains available
 if one device fails.  The parity is used to recalculate data that is lost
 from a single device.  The minimum number of devices required is 3.
 
-.B lvcreate \-\-type raid5
-[\fB\-\-stripes\fP \fINumber\fP \fB\-\-stripesize\fP \fISize\fP]
+.B lvcreate --type raid5
+[\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
 \fIVG\fP
 [\fIPVs\fP]
 
 .HP
-.B \-\-stripes
+.B --stripes
 specifies the number of devices to use for LV data.  This does not include
 the extra device lvm adds for storing parity blocks.  A raid5 LV with
 \fINumber\fP stripes requires \fINumber\fP+1 devices.  \fINumber\fP must
 be 2 or more.
 
 .HP
-.B \-\-stripesize
+.B --stripesize
 specifies the size of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
@@ -165,7 +165,7 @@ data that is written to one device before moving to the next.
 \fINumber\fP+1 separate devices.
 
 raid5 is called rotating parity because the parity blocks are placed on
-different devices in a round\-robin sequence.  There are variations of
+different devices in a round-robin sequence.  There are variations of
 raid5 with different algorithms for placing the parity blocks.  The
 default variant is raid5_ls (raid5 left symmetric, which is a rotating
 parity 0 with data restart.)  See \fBRAID5 variants\fP below.
@@ -181,20 +181,20 @@ LV data remains available if up to two devices fail.  The parity is used
 to recalculate data that is lost from one or two devices.  The minimum
 number of devices required is 5.
 
-.B lvcreate \-\-type raid6
-[\fB\-\-stripes\fP \fINumber\fP \fB\-\-stripesize\fP \fISize\fP]
+.B lvcreate --type raid6
+[\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
 \fIVG\fP
 [\fIPVs\fP]
 
 .HP
-.B \-\-stripes
+.B --stripes
 specifies the number of devices to use for LV data.  This does not include
 the extra two devices lvm adds for storing parity blocks.  A raid6 LV with
 \fINumber\fP stripes requires \fINumber\fP+2 devices.  \fINumber\fP must be
 3 or more.
 
 .HP
-.B \-\-stripesize
+.B --stripesize
 specifies the size of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
@@ -215,24 +215,24 @@ raid10 is a combination of raid1 and raid0, striping data across mirrored
 devices.  LV data remains available if one or more devices remains in each
 mirror set.  The minimum number of devices required is 4.
 
-.B lvcreate \-\-type raid10
+.B lvcreate --type raid10
 .RS
-[\fB\-\-mirrors\fP \fINumberMirrors\fP]
+[\fB--mirrors\fP \fINumberMirrors\fP]
 .br
-[\fB\-\-stripes\fP \fINumberStripes\fP \fB\-\-stripesize\fP \fISize\fP]
+[\fB--stripes\fP \fINumberStripes\fP \fB--stripesize\fP \fISize\fP]
 .br
 \fIVG\fP
 [\fIPVs\fP]
 .RE
 
 .HP
-.B \-\-mirrors
+.B --mirrors
 specifies the number of mirror images within each stripe.  e.g.
-\-\-mirrors 1 means there are two images of the data, the original and one
+--mirrors 1 means there are two images of the data, the original and one
 mirror image.
 
 .HP
-.B \-\-stripes
+.B --stripes
 specifies the total number of devices to use in all raid1 images (not the
 number of raid1 devices to spread the LV across, even though that is the
 effective result).  The number of devices in each raid1 mirror will be
@@ -240,7 +240,7 @@ NumberStripes/(NumberMirrors+1), e.g. mirrors 1 and stripes 4 will stripe
 data across two raid1 mirrors, where each mirror is devices.
 
 .HP
-.B \-\-stripesize
+.B --stripesize
 specifies the size of each stripe in kilobytes.  This is the amount of
 data that is written to one device before moving to the next.
 .P
@@ -296,17 +296,17 @@ Scrubbing assumes that RAID metadata and bitmaps may be inaccurate, so it
 verifies all RAID metadata, LV data, and parity blocks.  Scrubbing can
 find inconsistencies caused by hardware errors or degradation.  These
 kinds of problems may be undetected by automatic synchronization which
-excludes areas outside of the RAID write\-intent bitmap.
+excludes areas outside of the RAID write-intent bitmap.
 
 The command to scrub a RAID LV can operate in two different modes:
 
-.B lvchange \-\-syncaction
+.B lvchange --syncaction
 .BR check | repair
 .IR VG / LV
 
 .HP
 .B check
-Check mode is read\-only and only detects inconsistent areas in the RAID
+Check mode is read-only and only detects inconsistent areas in the RAID
 LV, it does not correct them.
 
 .HP
@@ -320,7 +320,7 @@ Scrubbing can consume a lot of bandwidth and slow down application I/O on
 the RAID LV.  To control the I/O rate used for scrubbing, use:
 
 .HP
-.B \-\-maxrecoveryrate
+.B --maxrecoveryrate
 .BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
 .br
 Sets the maximum recovery rate for a RAID LV.  \fIRate\fP is specified as
@@ -329,7 +329,7 @@ then KiB/sec/device is assumed.  Setting the recovery rate to \fB0\fP
 means it will be unbounded.
 
 .HP
-.BR \-\-minrecoveryrate
+.BR --minrecoveryrate
 .BR \fIRate [ b | B | s | S | k | K | m | M | g | G ]
 .br
 Sets the minimum recovery rate for a RAID LV.  \fIRate\fP is specified as
@@ -355,7 +355,7 @@ Also, if mismatches were found, the lvs attr field will display the letter
 .nf
 # lvs -o name,vgname,segtype,attr vg/lvol0
   LV    VG   Type  Attr
-  lvol0 vg   raid1 Rwi\-a\-r\-m\-
+  lvol0 vg   raid1 Rwi-a-r-m-
 .fi
 
 
@@ -371,7 +371,7 @@ not know which data is correct.  The result may be consistent but
 incorrect data.  When two different blocks of data must be made
 consistent, it chooses the block from the device that would be used during
 RAID intialization.  However, if the PV holding corrupt data is known,
-lvchange \-\-rebuild can be used in place of scrubbing to reconstruct the
+lvchange --rebuild can be used in place of scrubbing to reconstruct the
 data on the bad device.
 
 Future developments might include:
@@ -381,7 +381,7 @@ Allowing a user to choose the correct version of data during repair.
 Using a majority of devices to determine the correct version of data to
 use in a 3-way RAID1 or RAID6 LV.
 
-Using a checksumming device to pin\-point when and where an error occurs,
+Using a checksumming device to pin-point when and where an error occurs,
 allowing it to be rewritten.
 
 
@@ -390,7 +390,7 @@ allowing it to be rewritten.
 An LV is often a combination of other hidden LVs called SubLVs.  The
 SubLVs either use physical devices, or are built from other SubLVs
 themselves.  SubLVs hold LV data blocks, RAID parity blocks, and RAID
-metadata.  SubLVs are generally hidden, so the lvs \-a option is required
+metadata.  SubLVs are generally hidden, so the lvs -a option is required
 to display them:
 
 .B lvs -a -o name,segtype,devices
@@ -423,7 +423,7 @@ Each rimage SubLV holds a portion of LV data.  No parity is used.
 No RAID metadata is used.
 
 .nf
-lvcreate \-\-type raid0 \-\-stripes 2 \-\-name lvr0 ...
+lvcreate --type raid0 --stripes 2 --name lvr0 ...
 
 lvs -a -o name,segtype,devices
   lvr0            raid0  lvr0_rimage_0(0),lvr0_rimage_1(0)
@@ -437,7 +437,7 @@ Each rimage SubLV holds a complete copy of LV data.  No parity is used.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate \-\-type raid1 \-\-mirrors 1 \-\-name lvr1 ...
+lvcreate --type raid1 --mirrors 1 --name lvr1 ...
 
 lvs -a -o name,segtype,devices
   lvr1            raid1  lvr1_rimage_0(0),lvr1_rimage_1(0)
@@ -453,7 +453,7 @@ Two rimage SubLVs each hold a portion of LV data and one rimage SubLV
 holds parity.  Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate \-\-type raid4 \-\-stripes 2 \-\-name lvr4 ...
+lvcreate --type raid4 --stripes 2 --name lvr4 ...
 
 lvs -a -o name,segtype,devices
   lvr4            raid4  lvr4_rimage_0(0),\\
@@ -473,7 +473,7 @@ Three rimage SubLVs each hold a portion of LV data and parity.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate \-\-type raid5 \-\-stripes 2 \-\-name lvr5 ...
+lvcreate --type raid5 --stripes 2 --name lvr5 ...
 
 lvs -a -o name,segtype,devices
   lvr5            raid5  lvr5_rimage_0(0),\\
@@ -493,7 +493,7 @@ Six rimage SubLVs each hold a portion of LV data and parity.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate \-\-type raid6 \-\-stripes 3 \-\-name lvr6
+lvcreate --type raid6 --stripes 3 --name lvr6
 
 lvs -a -o name,segtype,devices
   lvr6            raid6  lvr6_rimage_0(0),\\
@@ -521,7 +521,7 @@ Four rimage SubLVs each hold a portion of LV data.  No parity is used.
 Each rmeta SubLV holds RAID metadata.
 
 .nf
-lvcreate \-\-type raid10 \-\-stripes 2 \-\-mirrors 1 \-\-name lvr10
+lvcreate --type raid10 --stripes 2 --mirrors 1 --name lvr10
 
 lvs -a -o name,segtype,devices
   lvr10            raid10 lvr10_rimage_0(0),\\
@@ -568,7 +568,7 @@ is composed of a raid1 set, without LV data loss.
 
 .P
 
-If a RAID LV is missing devices, or has other device\-related problems, lvs
+If a RAID LV is missing devices, or has other device-related problems, lvs
 reports this in the health_status (and attr) fields:
 
 .B lvs -o name,lv_health_status
@@ -596,11 +596,11 @@ See
 Most commands will also print a warning if a device is missing, e.g.
 .br
 .nf
-WARNING: Device for PV uItL3Z\-wBME\-DQy0-... not found or rejected ...
+WARNING: Device for PV uItL3Z-wBME-DQy0-... not found or rejected ...
 .fi
 
 This warning will go away if the device returns or is removed from the
-VG (see \fBvgreduce \-\-removemissing\fP).
+VG (see \fBvgreduce --removemissing\fP).
 
 
 .SS Activating an LV with missing devices
@@ -608,7 +608,7 @@ VG (see \fBvgreduce \-\-removemissing\fP).
 A RAID LV that is missing devices may be activated or not, depending on
 the "activation mode" used in lvchange:
 
-.B lvchange \-ay \-\-activationmode
+.B lvchange -ay --activationmode
 .RB { complete | degraded | partial }
 .IR VG / LV
 
@@ -634,32 +634,32 @@ controls the activation mode when not specified by the command.
 
 The default value is printed by:
 .nf
-lvmconfig \-\-type default activation/activation_mode
+lvmconfig --type default activation/activation_mode
 .fi
 
 .SS Replacing Devices
 
 Devices in a RAID LV can be replaced by other devices in the VG.  When
 replacing devices that are no longer visible on the system, use lvconvert
-\-\-repair.  When replacing devices that are still visible, use lvconvert
-\-\-replace.  The repair command will attempt to restore the same number
+--repair.  When replacing devices that are still visible, use lvconvert
+--replace.  The repair command will attempt to restore the same number
 of data LVs that were previously in the LV.  The replace option can be
 repeated to replace multiple PVs.  Replacement devices can be optionally
 listed with either option.
 
-.B lvconvert \-\-repair
+.B lvconvert --repair
 .IR VG / LV
 [\fINewPVs\fP]
 
-.B lvconvert \-\-replace
+.B lvconvert --replace
 \fIOldPV\fP
 .IR VG / LV
 [\fINewPV\fP]
 
 .B lvconvert
-.B \-\-replace
+.B --replace
 \fIOldPV1\fP
-.B \-\-replace
+.B --replace
 \fIOldPV2\fP
 ...
 .IR VG / LV
@@ -677,24 +677,24 @@ Restoring a device will usually require at least partial synchronization
 in the RAID LV operating in degraded mode until it is reactivated.  Use
 the lvchange command to refresh an LV:
 
-.B lvchange \-\-refresh
+.B lvchange --refresh
 .IR VG / LV
 
 .nf
 # lvs -o name,vgname,segtype,attr,size vg
   LV    VG   Type  Attr       LSize
-  raid1 vg   raid1 Rwi\-a\-r\-r\- 100.00g
+  raid1 vg   raid1 Rwi-a-r-r- 100.00g
 
-# lvchange \-\-refresh vg/raid1
+# lvchange --refresh vg/raid1
 
 # lvs -o name,vgname,segtype,attr,size vg
   LV    VG   Type  Attr       LSize
-  raid1 vg   raid1 Rwi\-a\-r\-\-\- 100.00g
+  raid1 vg   raid1 Rwi-a-r--- 100.00g
 .fi
 
 .SS Automatic repair
 
-If a device in a RAID LV fails, device\-mapper in the kernel notifies the
+If a device in a RAID LV fails, device-mapper in the kernel notifies the
 .BR dmeventd (8)
 monitoring process (see \fBMonitoring\fP).
 dmeventd can be configured to automatically respond using:
@@ -719,7 +719,7 @@ synchronization is started.
 
 The specific command run by dmeventd to warn or repair is:
 .br
-.B lvconvert \-\-repair \-\-use\-policies
+.B lvconvert --repair --use-policies
 .IR VG / LV
 
 
@@ -735,7 +735,7 @@ This should be rare, and can be detected (see \fBScrubbing\fP).
 If specific PVs in a RAID LV are known to have corrupt data, the data on
 those PVs can be reconstructed with:
 
-.B lvchange \-\-rebuild PV
+.B lvchange --rebuild PV
 .IR VG / LV
 
 The rebuild option can be repeated with different PVs to replace the data
@@ -746,7 +746,7 @@ on multiple PVs.
 
 When a RAID LV is activated the \fBdmeventd\fP(8) process is started to
 monitor the health of the LV.  Various events detected in the kernel can
-cause a notification to be sent from device\-mapper to the monitoring
+cause a notification to be sent from device-mapper to the monitoring
 process, including device failures and synchronization completion (e.g.
 for initialization or scrubbing).
 
@@ -781,7 +781,7 @@ A RAID1 LV can be tuned so that certain devices are avoided for reading
 while all devices are still written to.
 
 .B lvchange
-.BR \-\- [ raid ] writemostly
+.BR -- [ raid ] writemostly
 .BR \fIPhysicalVolume [ : { y | n | t }]
 .IR VG / LV
 
@@ -808,7 +808,7 @@ further writes become synchronous.  When synchronous, a write to the LV
 will not complete until writes to all the mirror images are complete.
 
 .B lvchange
-.BR \-\- [ raid ] writebehind
+.BR -- [ raid ] writebehind
 .IR IOCount
 .IR VG / LV
 
@@ -827,7 +827,7 @@ raid5 to raid6.  Changing the RAID level is usually done to increase or
 decrease resilience to device failures or to restripe LVs.  This is done
 using lvconvert and specifying the new RAID level as the LV type:
 
-.B lvconvert \-\-type
+.B lvconvert --type
 .I RaidLevel
 \fIVG\fP/\fILV\fP
 [\fIPVs\fP]
@@ -850,7 +850,7 @@ striped volume results in raid4/5/6.
 .P
 
 Unnatural conversions that are not recommended include converting between
-striped and non\-striped types.  This is because file systems often
+striped and non-striped types.  This is because file systems often
 optimize I/O patterns based on device striping values.  If those values
 change, it can decrease performance.
 
@@ -865,7 +865,7 @@ blocks to a new image on a new device.  Converting to a parity RAID level
 requires reading all LV data blocks, calculating parity, and writing the
 new parity blocks.  Synchronization can take a long time and degrade
 performance (rate controls also apply to conversion, see
-\fB\-\-maxrecoveryrate\fP.)
+\fB--maxrecoveryrate\fP.)
 
 Warning: though it is possible to create \fBstriped\fP LVs  with up to 128 stripes,
 a maximum of 64 stripes can be converted to \fBraid0\fP, 63 to \fBraid4/5\fP and
@@ -906,7 +906,7 @@ between striped/raid0 and raid10.
   LV   Type   LSize
   lv   linear 300.00g
 
-# lvconvert \-\-type raid1 \-\-mirrors 1 vg/lv
+# lvconvert --type raid1 --mirrors 1 vg/lv
 
 # lvs -a -o name,segtype,size vg
   LV            Type   LSize
@@ -938,7 +938,7 @@ between striped and raid4.
   LV   Type   LSize
   lv   linear 300.00g
 
-# lvconvert \-\-type raid1 \-\-mirrors 1 vg/lv
+# lvconvert --type raid1 --mirrors 1 vg/lv
 
 # lvs -a -o name,segtype,size vg
   LV            Type   LSize
@@ -959,7 +959,7 @@ between striped and raid4.
   [lv_mimage_1] linear 100.00g
   [lv_mlog]     linear   3.00m
 
-# lvconvert \-\-type raid1 vg/lv
+# lvconvert --type raid1 vg/lv
 
 # lvs -a -o name,segtype,size vg
   LV            Type   LSize
@@ -980,7 +980,7 @@ Start with a linear LV:
 Convert the linear LV to raid1 with three images
 (original linear image plus 2 mirror images):
 
-# lvconvert \-\-type raid1 \-\-mirrors 2 vg/lv
+# lvconvert --type raid1 --mirrors 2 vg/lv
 .fi
 
 4. Converting an LV from \fBstriped\fP (with 4 stripes) to \fBraid6_nc\fP.
@@ -988,11 +988,11 @@ Convert the linear LV to raid1 with three images
 .nf
 Start with a striped LV:
 
-# lvcreate \-\-stripes 4 -L64M -n lv vg
+# lvcreate --stripes 4 -L64M -n lv vg
 
 Convert the striped LV to raid6_n_6:
 
-# lvconvert \-\-type raid6 vg/lv
+# lvconvert --type raid6 vg/lv
 
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
   LV            Type      Cpy%Sync #Cpy
@@ -1061,7 +1061,7 @@ traditional RAID6.
   [lv_rmeta_4]  linear
   [lv_rmeta_5]  linear
 
-# lvconvert \-\-type raid6_nr vg/lv
+# lvconvert --type raid6_nr vg/lv
 
 # lvs -a -o lv_name,segtype,sync_percent,data_copies
   LV            Type     Cpy%Sync #Cpy
@@ -1085,7 +1085,7 @@ traditional RAID6.
 .fi
 
 The DataLVs are larger (additional segment in each) which provides space
-for out\-of\-place reshaping.  The result is:
+for out-of-place reshaping.  The result is:
 
 .nf
 # lvs -a -o lv_name,segtype,seg_pe_ranges,dataoffset
@@ -1106,15 +1106,15 @@ for out\-of\-place reshaping.  The result is:
   [lv_rmeta_3]  linear   /dev/sdac:0-0
 .fi
 
-All segments with PE ranges '33-33' provide the out\-of\-place reshape space.
+All segments with PE ranges '33-33' provide the out-of-place reshape space.
 The dataoffset column shows that the data was moved from initial offset 0 to
 2048 sectors on each component DataLV.
 
 For performance reasons the raid6_nr RaidLV can be restriped.
-Convert it from 3-way striped to 5-way\-striped.
+Convert it from 3-way striped to 5-way-striped.
 
 .nf
-# lvconvert \-\-stripes 5 -y tb/lv
+# lvconvert --stripes 5 -y tb/lv
   Using default stripesize 64.00 KiB.
   WARNING: Adding stripes to active logical volume tb/lv will grow it from 99 to 165 extents!
   Run "lvresize -l99 tb/lv" to shrink it or use the additional capacity.
@@ -1122,67 +1122,67 @@ Convert it from 3-way striped to 5-way\-striped.
 
 # lvs
   LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
-  root fedora -wi\-ao\-\-\-\-  15.00g
-  swap fedora -wi\-ao\-\-\-\-   3.99g
-  lv   tb     rwi\-a\-r\-s\- 652.00m                                    52.94
+  root fedora -wi-ao----  15.00g
+  swap fedora -wi-ao----   3.99g
+  lv   tb     rwi-a-r-s- 652.00m                                    52.94
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV            Attr       Type     PE Ranges                                                                                   DOff
-  lv            rwi\-a\-r\-\-\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
-  [lv_rimage_0] iwi\-aor\-\-\- linear   /dev/sda:0-32                                                                               0
-  [lv_rimage_0] iwi\-aor\-\-\- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi\-aor\-\-\- linear   /dev/sdaa:0-32                                                                              0
-  [lv_rimage_1] iwi\-aor\-\-\- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi\-aor\-\-\- linear   /dev/sdab:0-32                                                                              0
-  [lv_rimage_2] iwi\-aor\-\-\- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi\-aor\-\-\- linear   /dev/sdac:1-34                                                                              0
-  [lv_rimage_4] iwi\-aor\-\-\- linear   /dev/sdad:1-34                                                                              0
-  [lv_rimage_5] iwi\-aor\-\-\- linear   /dev/sdae:1-34                                                                              0
-  [lv_rimage_6] iwi\-aor\-\-\- linear   /dev/sdaf:1-34                                                                              0
-  [lv_rmeta_0]  ewi\-aor\-\-\- linear   /dev/sda:33-33
-  [lv_rmeta_1]  ewi\-aor\-\-\- linear   /dev/sdaa:33-33
-  [lv_rmeta_2]  ewi\-aor\-\-\- linear   /dev/sdab:33-33
-  [lv_rmeta_3]  ewi\-aor\-\-\- linear   /dev/sdac:0-0
-  [lv_rmeta_4]  ewi\-aor\-\-\- linear   /dev/sdad:0-0
-  [lv_rmeta_5]  ewi\-aor\-\-\- linear   /dev/sdae:0-0
-  [lv_rmeta_6]  ewi\-aor\-\-\- linear   /dev/sdaf:0-0
+  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                                               0
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                                              0
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                                              0
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
+  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                                              0
+  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                                              0
+  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                                              0
+  [lv_rimage_6] iwi-aor--- linear   /dev/sdaf:1-34                                                                              0
+  [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
+  [lv_rmeta_6]  ewi-aor--- linear   /dev/sdaf:0-0
 .fi
 
 Stripes also can be removed from raid5 and 6.
-Convert the 5-way striped raid6_nr LV to 4-way\-striped.
+Convert the 5-way striped raid6_nr LV to 4-way-striped.
 The force option needs to be used, because removing stripes
 (i.e. image SubLVs) from a RaidLV will shrink its size.
 
 .nf
-# lvconvert \-\-stripes 4 \-\-force -y tb/lv
+# lvconvert --stripes 4 --force -y tb/lv
   Using default stripesize 64.00 KiB.
   WARNING: Removing stripes from active logical volume tb/lv will shrink it from 660.00 MiB to 528.00 MiB!
   THIS MAY DESTROY (PARTS OF) YOUR DATA!
   If that leaves the logical volume larger than 206 extents due to stripe rounding,
   you may want to grow the content afterwards (filesystem etc.)
-  WARNING: too remove freed stripes after the conversion has finished, you have to run "lvconvert \-\-stripes 4 tb/lv"
+  WARNING: too remove freed stripes after the conversion has finished, you have to run "lvconvert --stripes 4 tb/lv"
   Logical volume tb/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV            Attr       Type     PE Ranges                                                                                   DOff
-  lv            rwi\-a\-r\-s\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
-  [lv_rimage_0] Iwi\-aor\-\-\- linear   /dev/sda:0-32                                                                               0
-  [lv_rimage_0] Iwi\-aor\-\-\- linear   /dev/sda:34-34
-  [lv_rimage_1] Iwi\-aor\-\-\- linear   /dev/sdaa:0-32                                                                              0
-  [lv_rimage_1] Iwi\-aor\-\-\- linear   /dev/sdaa:34-34
-  [lv_rimage_2] Iwi\-aor\-\-\- linear   /dev/sdab:0-32                                                                              0
-  [lv_rimage_2] Iwi\-aor\-\-\- linear   /dev/sdab:34-34
-  [lv_rimage_3] Iwi\-aor\-\-\- linear   /dev/sdac:1-34                                                                              0
-  [lv_rimage_4] Iwi\-aor\-\-\- linear   /dev/sdad:1-34                                                                              0
-  [lv_rimage_5] Iwi\-aor\-\-\- linear   /dev/sdae:1-34                                                                              0
-  [lv_rimage_6] Iwi\-aor\-R\- linear   /dev/sdaf:1-34                                                                              0
-  [lv_rmeta_0]  ewi\-aor\-\-\- linear   /dev/sda:33-33
-  [lv_rmeta_1]  ewi\-aor\-\-\- linear   /dev/sdaa:33-33
-  [lv_rmeta_2]  ewi\-aor\-\-\- linear   /dev/sdab:33-33
-  [lv_rmeta_3]  ewi\-aor\-\-\- linear   /dev/sdac:0-0
-  [lv_rmeta_4]  ewi\-aor\-\-\- linear   /dev/sdad:0-0
-  [lv_rmeta_5]  ewi\-aor\-\-\- linear   /dev/sdae:0-0
-  [lv_rmeta_6]  ewi\-aor\-R\- linear   /dev/sdaf:0-0
+  lv            rwi-a-r-s- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33    0
+  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:0-32                                                                               0
+  [lv_rimage_0] Iwi-aor--- linear   /dev/sda:34-34
+  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:0-32                                                                              0
+  [lv_rimage_1] Iwi-aor--- linear   /dev/sdaa:34-34
+  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:0-32                                                                              0
+  [lv_rimage_2] Iwi-aor--- linear   /dev/sdab:34-34
+  [lv_rimage_3] Iwi-aor--- linear   /dev/sdac:1-34                                                                              0
+  [lv_rimage_4] Iwi-aor--- linear   /dev/sdad:1-34                                                                              0
+  [lv_rimage_5] Iwi-aor--- linear   /dev/sdae:1-34                                                                              0
+  [lv_rimage_6] Iwi-aor-R- linear   /dev/sdaf:1-34                                                                              0
+  [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
+  [lv_rmeta_6]  ewi-aor-R- linear   /dev/sdaf:0-0
 .fi
 
 The 's' in column 9 of the attribute field shows the RaidLV is still reshaping.
@@ -1191,7 +1191,7 @@ The 'R' in the same column of the attribute field shows the freed image Sub LVs
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type     PE Ranges                                                                                DOff
-  lv   rwi\-a\-r\-R\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 lv_rimage_6:0-33 8192
 .fi
 
 Now that the reshape is finished the 'R' atribute on the RaidLV shows images can be removed.
@@ -1199,87 +1199,87 @@ Now that the reshape is finished the 'R' atribute on the RaidLV shows images can
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type     PE Ranges                                                                                 DOff
-  lv   rwi\-a\-r\-R\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ...  lv_rimage_5:0-33 lv_rimage_6:0-33 8192
+  lv   rwi-a-r-R- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ...  lv_rimage_5:0-33 lv_rimage_6:0-33 8192
 .fi
 
-This is achieved by repeating the command ("lvconvert \-\-stripes 4 tb/lv" would be sufficient).
+This is achieved by repeating the command ("lvconvert --stripes 4 tb/lv" would be sufficient).
 
 .nf
-# lvconvert \-\-stripes 4 \-\-force -y tb/lv
+# lvconvert --stripes 4 --force -y tb/lv
   Using default stripesize 64.00 KiB.
   Logical volume tb/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV            Attr       Type     PE Ranges                                                               DOff
-  lv            rwi\-a\-r\-\-\- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 8192
-  [lv_rimage_0] iwi\-aor\-\-\- linear   /dev/sda:0-32                                                           8192
-  [lv_rimage_0] iwi\-aor\-\-\- linear   /dev/sda:34-34
-  [lv_rimage_1] iwi\-aor\-\-\- linear   /dev/sdaa:0-32                                                          8192
-  [lv_rimage_1] iwi\-aor\-\-\- linear   /dev/sdaa:34-34
-  [lv_rimage_2] iwi\-aor\-\-\- linear   /dev/sdab:0-32                                                          8192
-  [lv_rimage_2] iwi\-aor\-\-\- linear   /dev/sdab:34-34
-  [lv_rimage_3] iwi\-aor\-\-\- linear   /dev/sdac:1-34                                                          8192
-  [lv_rimage_4] iwi\-aor\-\-\- linear   /dev/sdad:1-34                                                          8192
-  [lv_rimage_5] iwi\-aor\-\-\- linear   /dev/sdae:1-34                                                          8192
-  [lv_rmeta_0]  ewi\-aor\-\-\- linear   /dev/sda:33-33
-  [lv_rmeta_1]  ewi\-aor\-\-\- linear   /dev/sdaa:33-33
-  [lv_rmeta_2]  ewi\-aor\-\-\- linear   /dev/sdab:33-33
-  [lv_rmeta_3]  ewi\-aor\-\-\- linear   /dev/sdac:0-0
-  [lv_rmeta_4]  ewi\-aor\-\-\- linear   /dev/sdad:0-0
-  [lv_rmeta_5]  ewi\-aor\-\-\- linear   /dev/sdae:0-0
+  lv            rwi-a-r--- raid6_nr lv_rimage_0:0-33 lv_rimage_1:0-33 lv_rimage_2:0-33 ... lv_rimage_5:0-33 8192
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:0-32                                                           8192
+  [lv_rimage_0] iwi-aor--- linear   /dev/sda:34-34
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:0-32                                                          8192
+  [lv_rimage_1] iwi-aor--- linear   /dev/sdaa:34-34
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:0-32                                                          8192
+  [lv_rimage_2] iwi-aor--- linear   /dev/sdab:34-34
+  [lv_rimage_3] iwi-aor--- linear   /dev/sdac:1-34                                                          8192
+  [lv_rimage_4] iwi-aor--- linear   /dev/sdad:1-34                                                          8192
+  [lv_rimage_5] iwi-aor--- linear   /dev/sdae:1-34                                                          8192
+  [lv_rmeta_0]  ewi-aor--- linear   /dev/sda:33-33
+  [lv_rmeta_1]  ewi-aor--- linear   /dev/sdaa:33-33
+  [lv_rmeta_2]  ewi-aor--- linear   /dev/sdab:33-33
+  [lv_rmeta_3]  ewi-aor--- linear   /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor--- linear   /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor--- linear   /dev/sdae:0-0
 
 # lvs -a -o lv_name,attr,segtype,reshapelen tb
   LV            Attr       Type     RSize
-  lv            rwi\-a\-r\-\-\- raid6_nr 24.00m
-  [lv_rimage_0] iwi\-aor\-\-\- linear    4.00m
-  [lv_rimage_0] iwi\-aor\-\-\- linear
-  [lv_rimage_1] iwi\-aor\-\-\- linear    4.00m
-  [lv_rimage_1] iwi\-aor\-\-\- linear
-  [lv_rimage_2] iwi\-aor\-\-\- linear    4.00m
-  [lv_rimage_2] iwi\-aor\-\-\- linear
-  [lv_rimage_3] iwi\-aor\-\-\- linear    4.00m
-  [lv_rimage_4] iwi\-aor\-\-\- linear    4.00m
-  [lv_rimage_5] iwi\-aor\-\-\- linear    4.00m
-  [lv_rmeta_0]  ewi\-aor\-\-\- linear
-  [lv_rmeta_1]  ewi\-aor\-\-\- linear
-  [lv_rmeta_2]  ewi\-aor\-\-\- linear
-  [lv_rmeta_3]  ewi\-aor\-\-\- linear
-  [lv_rmeta_4]  ewi\-aor\-\-\- linear
-  [lv_rmeta_5]  ewi\-aor\-\-\- linear
+  lv            rwi-a-r--- raid6_nr 24.00m
+  [lv_rimage_0] iwi-aor--- linear    4.00m
+  [lv_rimage_0] iwi-aor--- linear
+  [lv_rimage_1] iwi-aor--- linear    4.00m
+  [lv_rimage_1] iwi-aor--- linear
+  [lv_rimage_2] iwi-aor--- linear    4.00m
+  [lv_rimage_2] iwi-aor--- linear
+  [lv_rimage_3] iwi-aor--- linear    4.00m
+  [lv_rimage_4] iwi-aor--- linear    4.00m
+  [lv_rimage_5] iwi-aor--- linear    4.00m
+  [lv_rmeta_0]  ewi-aor--- linear
+  [lv_rmeta_1]  ewi-aor--- linear
+  [lv_rmeta_2]  ewi-aor--- linear
+  [lv_rmeta_3]  ewi-aor--- linear
+  [lv_rmeta_4]  ewi-aor--- linear
+  [lv_rmeta_5]  ewi-aor--- linear
 .fi
 
 If the reshape space shall be removed any lvconvert command not changing the layout can be used:
 
 .nf
-# lvconvert \-\-stripes 4 tb/lv
+# lvconvert --stripes 4 tb/lv
   Using default stripesize 64.00 KiB.
   No change in RAID LV tb/lv layout, freeing reshape space.
   Logical volume tb/lv successfully converted.
 
 # lvs -a -o lv_name,attr,segtype,reshapelen tb
   LV            Attr       Type     RSize
-  lv            rwi\-a\-r\-\-\- raid6_nr    0
-  [lv_rimage_0] iwi\-aor\-\-\- linear      0
-  [lv_rimage_0] iwi\-aor\-\-\- linear
-  [lv_rimage_1] iwi\-aor\-\-\- linear      0
-  [lv_rimage_1] iwi\-aor\-\-\- linear
-  [lv_rimage_2] iwi\-aor\-\-\- linear      0
-  [lv_rimage_2] iwi\-aor\-\-\- linear
-  [lv_rimage_3] iwi\-aor\-\-\- linear      0
-  [lv_rimage_4] iwi\-aor\-\-\- linear      0
-  [lv_rimage_5] iwi\-aor\-\-\- linear      0
-  [lv_rmeta_0]  ewi\-aor\-\-\- linear
-  [lv_rmeta_1]  ewi\-aor\-\-\- linear
-  [lv_rmeta_2]  ewi\-aor\-\-\- linear
-  [lv_rmeta_3]  ewi\-aor\-\-\- linear
-  [lv_rmeta_4]  ewi\-aor\-\-\- linear
-  [lv_rmeta_5]  ewi\-aor\-\-\- linear
+  lv            rwi-a-r--- raid6_nr    0
+  [lv_rimage_0] iwi-aor--- linear      0
+  [lv_rimage_0] iwi-aor--- linear
+  [lv_rimage_1] iwi-aor--- linear      0
+  [lv_rimage_1] iwi-aor--- linear
+  [lv_rimage_2] iwi-aor--- linear      0
+  [lv_rimage_2] iwi-aor--- linear
+  [lv_rimage_3] iwi-aor--- linear      0
+  [lv_rimage_4] iwi-aor--- linear      0
+  [lv_rimage_5] iwi-aor--- linear      0
+  [lv_rmeta_0]  ewi-aor--- linear
+  [lv_rmeta_1]  ewi-aor--- linear
+  [lv_rmeta_2]  ewi-aor--- linear
+  [lv_rmeta_3]  ewi-aor--- linear
+  [lv_rmeta_4]  ewi-aor--- linear
+  [lv_rmeta_5]  ewi-aor--- linear
 .fi
 
 In case the RaidLV should be converted to striped:
 
 .nf
-# lvconvert \-\-type striped tb/lv
+# lvconvert --type striped tb/lv
   Unable to convert LV tb/lv from raid6_nr to striped.
   Converting tb/lv from raid6_nr is directly possible to the following layouts:
     raid6_nc
@@ -1290,55 +1290,55 @@ In case the RaidLV should be converted to striped:
     raid6_rs_6
     raid6_n_6
 
-# lvconvert \-\-type raid6_n_6
+# lvconvert --type raid6_n_6
   Using default stripesize 64.00 KiB.
   Converting raid6_nr LV tb/lv to raid6_n_6.
 Are you sure you want to convert raid6_nr LV tb/lv? [y/n]: y
   Logical volume tb/lv successfully converted.
 
-# lvconvert -y \-\-type striped tb/lv
+# lvconvert -y --type striped tb/lv
   Logical volume tb/lv successfully converted.
 
 [root at vm46 ~]# lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type    PE Ranges                                                      DOff
-  lv   -wi\-a\-\-\-\-\- striped /dev/sda:2-32 /dev/sdaa:2-32 /dev/sdab:2-32 /dev/sdac:3-33
-  lv   -wi\-a\-\-\-\-\- striped /dev/sda:34-35 /dev/sdaa:34-35 /dev/sdab:34-35 /dev/sdac:34-35
+  lv   -wi-a----- striped /dev/sda:2-32 /dev/sdaa:2-32 /dev/sdab:2-32 /dev/sdac:3-33
+  lv   -wi-a----- striped /dev/sda:34-35 /dev/sdaa:34-35 /dev/sdab:34-35 /dev/sdac:34-35
 .fi
 
 From striped we can convert to raid10
 
 .nf
-# lvconvert -y \-\-type raid10 tb/lv
+# lvconvert -y --type raid10 tb/lv
   Using default stripesize 64.00 KiB.
   Logical volume tb/lv successfully converted.
 
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   LV   Attr       Type   PE Ranges                                                                                   DOff
-  lv   rwi\-a\-r\-\-\- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  lv   rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
 
 # lvs -a -o lv_name,attr,segtype,seg_pe_ranges,dataoffset tb
   WARNING: Cannot find matching striped segment for tb/lv_rimage_3.
   LV            Attr       Type   PE Ranges                                                                                   DOff
-  lv            rwi\-a\-r\-\-\- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
-  [lv_rimage_0] iwi\-aor\-\-\- linear /dev/sda:2-32                                                                                                                              0
-  [lv_rimage_0] iwi\-aor\-\-\- linear /dev/sda:34-35
-  [lv_rimage_1] iwi\-aor\-\-\- linear /dev/sdaa:2-32                                                                                                                             0
-  [lv_rimage_1] iwi\-aor\-\-\- linear /dev/sdaa:34-35
-  [lv_rimage_2] iwi\-aor\-\-\- linear /dev/sdab:2-32                                                                                                                             0
-  [lv_rimage_2] iwi\-aor\-\-\- linear /dev/sdab:34-35
-  [lv_rimage_3] iwi\-XXr\-\-\- linear /dev/sdac:3-35                                                                                                                             0
-  [lv_rimage_4] iwi\-aor\-\-\- linear /dev/sdad:1-33                                                                                                                             0
-  [lv_rimage_5] iwi\-aor\-\-\- linear /dev/sdae:1-33                                                                                                                             0
-  [lv_rimage_6] iwi\-aor\-\-\- linear /dev/sdaf:1-33                                                                                                                             0
-  [lv_rimage_7] iwi\-aor\-\-\- linear /dev/sdag:1-33                                                                                                                             0
-  [lv_rmeta_0]  ewi\-aor\-\-\- linear /dev/sda:0-0
-  [lv_rmeta_1]  ewi\-aor\-\-\- linear /dev/sdaa:0-0
-  [lv_rmeta_2]  ewi\-aor\-\-\- linear /dev/sdab:0-0
-  [lv_rmeta_3]  ewi\-aor\-\-\- linear /dev/sdac:0-0
-  [lv_rmeta_4]  ewi\-aor\-\-\- linear /dev/sdad:0-0
-  [lv_rmeta_5]  ewi\-aor\-\-\- linear /dev/sdae:0-0
-  [lv_rmeta_6]  ewi\-aor\-\-\- linear /dev/sdaf:0-0
-  [lv_rmeta_7]  ewi\-aor\-\-\- linear /dev/sdag:0-0
+  lv            rwi-a-r--- raid10 lv_rimage_0:0-32 lv_rimage_4:0-32 lv_rimage_1:0-32 ... lv_rimage_3:0-32 lv_rimage_7:0-32    0
+  [lv_rimage_0] iwi-aor--- linear /dev/sda:2-32                                                                                                                              0
+  [lv_rimage_0] iwi-aor--- linear /dev/sda:34-35
+  [lv_rimage_1] iwi-aor--- linear /dev/sdaa:2-32                                                                                                                             0
+  [lv_rimage_1] iwi-aor--- linear /dev/sdaa:34-35
+  [lv_rimage_2] iwi-aor--- linear /dev/sdab:2-32                                                                                                                             0
+  [lv_rimage_2] iwi-aor--- linear /dev/sdab:34-35
+  [lv_rimage_3] iwi-XXr--- linear /dev/sdac:3-35                                                                                                                             0
+  [lv_rimage_4] iwi-aor--- linear /dev/sdad:1-33                                                                                                                             0
+  [lv_rimage_5] iwi-aor--- linear /dev/sdae:1-33                                                                                                                             0
+  [lv_rimage_6] iwi-aor--- linear /dev/sdaf:1-33                                                                                                                             0
+  [lv_rimage_7] iwi-aor--- linear /dev/sdag:1-33                                                                                                                             0
+  [lv_rmeta_0]  ewi-aor--- linear /dev/sda:0-0
+  [lv_rmeta_1]  ewi-aor--- linear /dev/sdaa:0-0
+  [lv_rmeta_2]  ewi-aor--- linear /dev/sdab:0-0
+  [lv_rmeta_3]  ewi-aor--- linear /dev/sdac:0-0
+  [lv_rmeta_4]  ewi-aor--- linear /dev/sdad:0-0
+  [lv_rmeta_5]  ewi-aor--- linear /dev/sdae:0-0
+  [lv_rmeta_6]  ewi-aor--- linear /dev/sdaf:0-0
+  [lv_rmeta_7]  ewi-aor--- linear /dev/sdag:0-0
 .fi
 
 raid10 allows to add stripes but can't remove them.
@@ -1353,7 +1353,7 @@ We start with the linear LV.
 .nf
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV   Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
-  lv   -wi\-a\-\-\-\-\- 128.00m linear              1     0        /dev/sda(0)
+  lv   -wi-a----- 128.00m linear              1     0        /dev/sda(0)
 .fi
 
 Then convert it to a 2-way raid1.
@@ -1364,11 +1364,11 @@ Then convert it to a 2-way raid1.
 
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV            Attr       LSize   Type   Cpy%Sync #DStr Stripe RSize Devices
-  lv            rwi\-a\-r\-\-\- 128.00m raid1  100.00       2     0        lv_rimage_0(0),lv_rimage_1(0)
-  [lv_rimage_0] iwi\-aor\-\-\- 128.00m linear              1     0        /dev/sda(0)
-  [lv_rimage_1] iwi\-aor\-\-\- 128.00m linear              1     0        /dev/sdhx(1)
-  [lv_rmeta_0]  ewi\-aor\-\-\-   4.00m linear              1     0        /dev/sda(32)
-  [lv_rmeta_1]  ewi\-aor\-\-\-   4.00m linear              1     0        /dev/sdhx(0)
+  lv            rwi-a-r--- 128.00m raid1  100.00       2     0        lv_rimage_0(0),lv_rimage_1(0)
+  [lv_rimage_0] iwi-aor--- 128.00m linear              1     0        /dev/sda(0)
+  [lv_rimage_1] iwi-aor--- 128.00m linear              1     0        /dev/sdhx(1)
+  [lv_rmeta_0]  ewi-aor---   4.00m linear              1     0        /dev/sda(32)
+  [lv_rmeta_1]  ewi-aor---   4.00m linear              1     0        /dev/sdhx(0)
 .fi
 
 Once the raid1 LV is fully synchronized we convert it to raid5_n (only 2-way raid1
@@ -1377,17 +1377,17 @@ SubLVs at the end and can be converted to striped directly without any additiona
 conversion.
 
 .nf
-# lvconvert -y \-\-ty raid5_n vg/lv
+# lvconvert -y --ty raid5_n vg/lv
   Using default stripesize 64.00 KiB.
   Logical volume vg/lv successfully converted.
 
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe RSize Devices
-  lv            rwi\-a\-r\-\-\- 128.00m raid5_n 100.00       1 64.00k     0 lv_rimage_0(0),lv_rimage_1(0)
-  [lv_rimage_0] iwi\-aor\-\-\- 128.00m linear               1     0      0 /dev/sda(0)
-  [lv_rimage_1] iwi\-aor\-\-\- 128.00m linear               1     0      0 /dev/sdhx(1)
-  [lv_rmeta_0]  ewi\-aor\-\-\-   4.00m linear               1     0        /dev/sda(32)
-  [lv_rmeta_1]  ewi\-aor\-\-\-   4.00m linear               1     0        /dev/sdhx(0)
+  lv            rwi-a-r--- 128.00m raid5_n 100.00       1 64.00k     0 lv_rimage_0(0),lv_rimage_1(0)
+  [lv_rimage_0] iwi-aor--- 128.00m linear               1     0      0 /dev/sda(0)
+  [lv_rimage_1] iwi-aor--- 128.00m linear               1     0      0 /dev/sdhx(1)
+  [lv_rmeta_0]  ewi-aor---   4.00m linear               1     0        /dev/sda(32)
+  [lv_rmeta_1]  ewi-aor---   4.00m linear               1     0        /dev/sdhx(0)
 .fi
 
 Now we'll change the number of data stripes from 1 to 5 and request 128K stripe size
@@ -1396,7 +1396,7 @@ to the one given).  That additonal space can be used by e.g. growing any contain
 or the LV can be reduced in size after the reshaping conversion has finished.
 
 .nf
-# lvconvert \-\-yes \-\-stripesize 128k \-\-stripes 5 vg/lv
+# lvconvert --yes --stripesize 128k --stripes 5 vg/lv
   Converting stripesize 64.00 KiB of raid5_n LV vg/lv to 128.00 KiB.
   WARNING: Adding stripes to active logical volume vg/lv will grow it from 32 to 160 extents!
   Run "lvresize -l32 vg/lv" to shrink it or use the additional capacity.
@@ -1404,46 +1404,46 @@ or the LV can be reduced in size after the reshaping conversion has finished.
 
 # lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg
   LV            Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
-  lv            rwi\-a\-r\-\-\- 640.00m raid5_n 100.00       5 128.00k     6 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0),lv_rimage_3(0),lv_rimage_4(0),lv_rimage_5(0)
-  [lv_rimage_0] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sda(33)
-  [lv_rimage_0] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sda(0)
-  [lv_rimage_1] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdhx(33)
-  [lv_rimage_1] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdhx(1)
-  [lv_rimage_2] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdhw(33)
-  [lv_rimage_2] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdhw(1)
-  [lv_rimage_3] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdhv(33)
-  [lv_rimage_3] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdhv(1)
-  [lv_rimage_4] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdhu(33)
-  [lv_rimage_4] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdhu(1)
-  [lv_rimage_5] iwi\-aor\-\-\- 132.00m linear               1      0      1 /dev/sdht(33)
-  [lv_rimage_5] iwi\-aor\-\-\- 132.00m linear               1      0        /dev/sdht(1)
-  [lv_rmeta_0]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sda(32)
-  [lv_rmeta_1]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdhx(0)
-  [lv_rmeta_2]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdhw(0)
-  [lv_rmeta_3]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdhv(0)
-  [lv_rmeta_4]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdhu(0)
-  [lv_rmeta_5]  ewi\-aor\-\-\-   4.00m linear               1      0        /dev/sdht(0)
+  lv            rwi-a-r--- 640.00m raid5_n 100.00       5 128.00k     6 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0),lv_rimage_3(0),lv_rimage_4(0),lv_rimage_5(0)
+  [lv_rimage_0] iwi-aor--- 132.00m linear               1      0      1 /dev/sda(33)
+  [lv_rimage_0] iwi-aor--- 132.00m linear               1      0        /dev/sda(0)
+  [lv_rimage_1] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhx(33)
+  [lv_rimage_1] iwi-aor--- 132.00m linear               1      0        /dev/sdhx(1)
+  [lv_rimage_2] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhw(33)
+  [lv_rimage_2] iwi-aor--- 132.00m linear               1      0        /dev/sdhw(1)
+  [lv_rimage_3] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhv(33)
+  [lv_rimage_3] iwi-aor--- 132.00m linear               1      0        /dev/sdhv(1)
+  [lv_rimage_4] iwi-aor--- 132.00m linear               1      0      1 /dev/sdhu(33)
+  [lv_rimage_4] iwi-aor--- 132.00m linear               1      0        /dev/sdhu(1)
+  [lv_rimage_5] iwi-aor--- 132.00m linear               1      0      1 /dev/sdht(33)
+  [lv_rimage_5] iwi-aor--- 132.00m linear               1      0        /dev/sdht(1)
+  [lv_rmeta_0]  ewi-aor---   4.00m linear               1      0        /dev/sda(32)
+  [lv_rmeta_1]  ewi-aor---   4.00m linear               1      0        /dev/sdhx(0)
+  [lv_rmeta_2]  ewi-aor---   4.00m linear               1      0        /dev/sdhw(0)
+  [lv_rmeta_3]  ewi-aor---   4.00m linear               1      0        /dev/sdhv(0)
+  [lv_rmeta_4]  ewi-aor---   4.00m linear               1      0        /dev/sdhu(0)
+  [lv_rmeta_5]  ewi-aor---   4.00m linear               1      0        /dev/sdht(0)
 .fi
 
 Once the conversion has finished we can can convert to striped.
 
 .nf
-[root at vm46 ~]# lvconvert -y \-\-ty striped vg/lv
+[root at vm46 ~]# lvconvert -y --ty striped vg/lv
   Logical volume vg/lv successfully converted.
 
 [root at vm46 ~]# lvs -aoname,attr,size,segtype,syncpercent,datastripes,stripesize,reshapelenle,devices vg|sed 's/  *$//'
   LV   Attr       LSize   Type    Cpy%Sync #DStr Stripe  RSize Devices
-  lv   -wi\-a\-\-\-\-\- 640.00m striped              5 128.00k       /dev/sda(33),/dev/sdhx(33),/dev/sdhw(33),/dev/sdhv(33),/dev/sdhu(33)
-  lv   -wi\-a\-\-\-\-\- 640.00m striped              5 128.00k       /dev/sda(0),/dev/sdhx(1),/dev/sdhw(1),/dev/sdhv(1),/dev/sdhu(1)
+  lv   -wi-a----- 640.00m striped              5 128.00k       /dev/sda(33),/dev/sdhx(33),/dev/sdhw(33),/dev/sdhv(33),/dev/sdhu(33)
+  lv   -wi-a----- 640.00m striped              5 128.00k       /dev/sda(0),/dev/sdhx(1),/dev/sdhw(1),/dev/sdhv(1),/dev/sdhu(1)
 .fi
 
 Reversing these steps wil convert a given striped LV to linear.
 
 Mind the fact that stripes are removed thus the capacity of the RaidLV will shrink.
 
-"lvconvert \-\-stripes 1 vg/lv" for converting to 1 stripe will inform upfront about
+"lvconvert --stripes 1 vg/lv" for converting to 1 stripe will inform upfront about
 the reduced size to allow for resizing the content or growing the RaidLV before
-actually converting to 1 stripe.  The \fB\-\-force\fP option is needed to
+actually converting to 1 stripe.  The \fB--force\fP option is needed to
 allow stripe removing conversions to prevent data loss.
 
 Of course any interim step can be the intended last one (e.g. striped -> raid1).
@@ -1554,7 +1554,7 @@ raid6_n_6
 RAID6 N continue
 .br
 \[bu]
-Fixed P\-Syndrome N\-1 and Q\-Syndrome N with striped data
+Fixed P-Syndrome N-1 and Q-Syndrome N with striped data
 .br
 \[bu]
 Used for RAID Takeover
@@ -1565,7 +1565,7 @@ raid6_ls_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_ls for N\-1 disks with fixed Q\-Syndrome N
+Same as raid5_ls for N-1 disks with fixed Q-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover
@@ -1576,7 +1576,7 @@ raid6_la_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_la for N\-1 disks with fixed Q\-Syndrome N
+Same as raid5_la for N-1 disks with fixed Q-Syndrome N
 .br
 \[bu]
 Used forRAID Takeover
@@ -1587,7 +1587,7 @@ raid6_rs_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_rs for N\-1 disks with fixed Q\-Syndrome N
+Same as raid5_rs for N-1 disks with fixed Q-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover
@@ -1598,7 +1598,7 @@ raid6_ra_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_ra for N\-1 disks with fixed Q\-Syndrome N
+Same as raid5_ra for N-1 disks with fixed Q-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover
@@ -1607,7 +1607,7 @@ Used for RAID Takeover
 .ig
 .SH RAID Duplication
 
-RAID LV conversion (takeover or reshaping) can be done out\-of\-place by
+RAID LV conversion (takeover or reshaping) can be done out-of-place by
 copying the LV data onto new devices while changing the RAID properties.
 Copying avoids modifying the original LV but requires additional devices.
 Once the LV data has been copied/converted onto the new devices, there are
@@ -1626,23 +1626,23 @@ LV, leaving the original RAID LV unchanged on its original devices.
 
 The command to start duplication is:
 
-.B lvconvert \-\-type
+.B lvconvert --type
 .I RaidLevel
-[\fB\-\-stripes\fP \fINumber\fP \fB\-\-stripesize\fP \fISize\fP]
+[\fB--stripes\fP \fINumber\fP \fB--stripesize\fP \fISize\fP]
 .RS
-.B \-\-duplicate
+.B --duplicate
 .IR VG / LV
 [\fIPVs\fP]
 .RE
 
 .HP
-.B \-\-duplicate
+.B --duplicate
 .br
-Specifies that the LV conversion should be done out\-of\-place, copying
+Specifies that the LV conversion should be done out-of-place, copying
 LV data to new devices while converting.
 
 .HP
-.BR \-\-type , \-\-stripes , \-\-stripesize
+.BR --type , --stripes , --stripesize
 .br
 Specifies the RAID properties to use when creating the copy.
 
@@ -1678,16 +1678,16 @@ devices (SubLV 0) or the new devices (SubLV 1).
 To make the RAID LV use the data on the old devices, and drop the copy on
 the new devices, specify the name of SubLV 0 (suffix _dup_0):
 
-.B lvconvert \-\-unduplicate
-.BI \-\-name
+.B lvconvert --unduplicate
+.BI --name
 .IB LV _dup_0
 .IR VG / LV
 
 To make the RAID LV use the data copy on the new devices, and drop the old
 devices, specify the name of SubLV 1 (suffix _dup_1):
 
-.B lvconvert \-\-unduplicate
-.BI \-\-name
+.B lvconvert --unduplicate
+.BI --name
 .IB LV _dup_1
 .IR VG / LV
 
@@ -1704,9 +1704,9 @@ TODO
 
 .SH History
 
-The 2.6.38-rc1 version of the Linux kernel introduced a device\-mapper
+The 2.6.38-rc1 version of the Linux kernel introduced a device-mapper
 target to interface with the software RAID (MD) personalities.  This
-provided device\-mapper with RAID 4/5/6 capabilities and a larger
+provided device-mapper with RAID 4/5/6 capabilities and a larger
 development community.  Later, support for RAID1, RAID10, and RAID1E (RAID
 10 variants) were added.  Support for these new kernel RAID targets was
 added to LVM version 2.02.87.  The capabilities of the LVM \fBraid1\fP
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index e2fa812..7a26401 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -12,16 +12,16 @@ options to customize report and filter the report's output.
 
 Based on functionality, commands which make use of the reporting infrastructure
 are divided in two groups:
-.IP \fBReport\-oriented commands\fP
+.IP \fBReport-oriented commands\fP
 These commands inform about current LVM state and their primary role is to
 display this information in compendious way. To make a distinction, we will
-name this report as \fBmain report\fP. The set of report\-only commands include:
+name this report as \fBmain report\fP. The set of report-only commands include:
 pvs, vgs, lvs, pvdisplay, vgdisplay, lvdisplay, lvm devtypes, lvm fullreport.
 For further information about main report, see \fBmain report specifics\fP.
-.IP \fBProcessing\-oriented commands\fP
+.IP \fBProcessing-oriented commands\fP
 These commands are responsible for changing LVM state and they do not contain
-any main report as identified for report\-oriented commands, they only perform
-some kind of processing. The set of processing\-oriented commands includes:
+any main report as identified for report-oriented commands, they only perform
+some kind of processing. The set of processing-oriented commands includes:
 pvcreate, vgcreate, lvcreate, pvchange, vgchange, lvchange, pvremove, vgremove,
 lvremove, pvresize, vgextend, vgreduce, lvextend, lvreduce, lvresize, lvrename,
 pvscan, vgscan, lvscan, pvmove, vgcfgbackup, vgck, vgconvert, vgexport,
@@ -29,9 +29,9 @@ vgimport, vgmknodes.
 
 .RE
 If enabled, so called \fBlog report\fP is either displayed solely
-(for processing\-oriented commands) or in addition to main report
-(for report\-oriented commands). The log report contains a log of operations,
-messages and per\-object status with complete object identification collected
+(for processing-oriented commands) or in addition to main report
+(for report-oriented commands). The log report contains a log of operations,
+messages and per-object status with complete object identification collected
 during LVM command execution. See \fBlog report specifics\fP for more
 information about this report type.
 
@@ -108,7 +108,7 @@ report/buffered
 
 This document does not describe these settings in more detail - if you need
 detailed information, including values which are accepted for the settings,
-please run \fBlvmconfig \-\-type default \-\-withcomments <setting>\fP. There are
+please run \fBlvmconfig --type default --withcomments <setting>\fP. There are
 more configuration settings in addition to the common set listed above, but
 they are specific to either \fBmain report\fP or \fBlog report\fP,
 see \fBmain report specifics\fP and \fBlog report specifics\fP for
@@ -125,25 +125,25 @@ or further specify the report configuration.
 Definition of the set set of fields to use
 .RS
 .IP - 3
-\-\-options|-o FieldSet
+--options|-o FieldSet
 .br
 Field set to use. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuratin settings that this option overrides.
 .IP - 3
-\-\-options|-o+ FieldSet
+--options|-o+ FieldSet
 .br
 Fields to include to current field set. See \fBmain report specifics\fP\ and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option extends.
 .IP - 3
-\-\-options|-o\- FieldSet
+--options|-o- FieldSet
 .br
 Fields to exclude from current field set. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option reduces.
 .IP - 3
-\-\-options|-o# FieldSet
+--options|-o# FieldSet
 .br
 Compaction of unused fields. Overrides report/compact_output_cols configuration
 setting.
@@ -153,13 +153,13 @@ setting.
 Sorting
 .RS
 .IP - 3
-\-\-sort|-O+ FieldSet
+--sort|-O+ FieldSet
 .br
 Fields to sort by in ascending order. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
 global configuration settings that this option overrides.
 .IP - 3
-\-\-sort|-O\- FieldSet
+--sort|-O- FieldSet
 .br
 Fields to sort by in descending order. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about fields sets configured with
@@ -170,7 +170,7 @@ global configuration settings that this options overrides.
 Selection
 .RS
 .IP - 3
-\-\-select|-S Selection
+--select|-S Selection
 .br
 Define selection criteria for report output. For \fBlog report\fP, this also
 overrides log/command_log_selection configuration setting, see also
@@ -181,43 +181,43 @@ overrides log/command_log_selection configuration setting, see also
 Changing output format and composition
 .RS
 .IP - 3
-\-\-reportformat
+--reportformat
 .br
 Overrides report/output_format configuration setting.
 .IP - 3
-\-\-aligned
+--aligned
 .br
 Overrides report/aligned configuration setting.
 .IP - 3
-\-\-binary
+--binary
 .br
 Overrides report/binary_values_as_numeric configuration setting.
 .IP - 3
-\-\-nameprefixes
+--nameprefixes
 .br
 Overrides report/prefixes configuration setting.
 .IP - 3
-\-\-noheadings
+--noheadings
 .br
 Overrides report/noheadings configuration setting.
 .IP - 3
-\-\-nosuffix
+--nosuffix
 .br
 Overrides global/suffix configuration setting.
 .IP - 3
-\-\-rows
+--rows
 .br
 Overrides report/columns_as_rows configuration setting.
 .IP - 3
-\-\-separator
+--separator
 .br
 Overrides report/separator configuration setting.
 .IP - 3
-\-\-units
+--units
 .br
 Overrides global/units configuration setting.
 .IP - 3
-\-\-unquoted
+--unquoted
 .br
 Overrides report/quoted configuration setting.
 .RE
@@ -226,19 +226,19 @@ Overrides report/quoted configuration setting.
 Special options
 .RS
 .IP - 3
-\-\-configreport \fBReportName\fP
+--configreport \fBReportName\fP
 .br
-This defines the \fBReportName\fP for which any subsequent -o|\-\-columns,
--O|\-\-sort or -S|\-\-select applies to. See also \fBmain report specifics\fP
+This defines the \fBReportName\fP for which any subsequent -o|--columns,
+-O|--sort or -S|--select applies to. See also \fBmain report specifics\fP
 and \fBlog report specifics\fP for possible \fBReportName\fP values.
 .IP - 3
-\-\-logonly
+--logonly
 .br
 When an LVM command contains both \fBmain report\fP and \fBlog report\fP,
 this option suppresses the \fBmain report\fP output and it causes the
 \fBlog report\fP output to be displayed only.
 .IP - 3
-\-\-unbuffered
+--unbuffered
 .br
 Overrides report/bufffered configuration setting.
 .RE
@@ -249,7 +249,7 @@ Overrides report/bufffered configuration setting.
 
 The \fBFieldSet\fP mentioned in the lists above is a set of field names where
 each field name is delimited by "," character. Field set definition, sorting
-and selection may be repeated on command line (-o+/-o\- includes/excludes fields
+and selection may be repeated on command line (-o+/-o- includes/excludes fields
 to/from current list, for all the other repeatable options, the last value
 typed for the option on the command line is used). The \fBSelection\fP
 is a string with \fBselection criteria\fP, see also \fBSelection\fP paragraph
@@ -276,7 +276,7 @@ report/pvs_sort
 .RE
 
 .IP \[bu] 3
-\fBpvseg\fP representing report about Physical Volume Segments (\fBpvs \-\-segments\fP)
+\fBpvseg\fP representing report about Physical Volume Segments (\fBpvs --segments\fP)
 .RS
 .IP - 3
 report/pvseg_cols
@@ -303,7 +303,7 @@ report/lvs_sort
 .RE
 
 .IP \[bu] 3
-\fBseg\fP representing report about Logical Volume Segments (\fBlvs \-\-segments\fP)
+\fBseg\fP representing report about Logical Volume Segments (\fBlvs --segments\fP)
 .RS
 .IP - 3
 report/segs_cols
@@ -355,10 +355,10 @@ groups are combined together. Some of these combinations are not allowed in
 which case LVM will issue an error.
 
 For all main report subtypes except \fBfull\fP, it's not necessary to use
-\fB\-\-configreport ReportName\fP to denote which report any subsequent
-\fB\-o, -O or -S\fP option applies to as they always apply to the single main
+\fB--configreport ReportName\fP to denote which report any subsequent
+\fB-o, -O or -S\fP option applies to as they always apply to the single main
 report type. Currently, \fBlvm fullreport\fP is the only command that
-includes more than one \fBmain report\fP subtype. Therefore, the \-\-configreport
+includes more than one \fBmain report\fP subtype. Therefore, the --configreport
 is particularly suitable for the full report if you need to configure each of
 its subreports in a different way.
 
@@ -387,20 +387,20 @@ log/command_log_selection
 
 .RE
 
-You always need to use \fB\-\-configreport log\fP together with \fB\-o|\-\-options,
--O|\-\-sort or -S|\-\-selection\fP to override configuration settings directly on
+You always need to use \fB--configreport log\fP together with \fB-o|--options,
+-O|--sort or -S|--selection\fP to override configuration settings directly on
 command line for \fBlog report\fP. When compared to \fBmain report\fP, in
 addition to usual configuration settings for report fields and sorting, the
 \fBlog report\fP has also configuration option for selection -
 \fBreport/command_log_selection\fP. This configuration setting is provided for
-convenience so it's not necessary to use \fB\-S|\-\-select\fP on command line
+convenience so it's not necessary to use \fB-S|--select\fP on command line
 each time an LVM command is executed and we need the same selection criteria
 to be applied for \fBlog report\fP. Default selection criteria used for
 \fBlog report\fP are
 \fBlog/command_log_selection="!(log_type=status && message=success)"\fP.
 This means that, by default, \fBlog report\fP doesn't display status messages
 about successful operation and it displays only rows with error, warning,
-print\-type messages and messages about failure states (for more information,
+print-type messages and messages about failure states (for more information,
 see \fBlog report content\fP below).
 
 .B Log report coverage
@@ -411,7 +411,7 @@ entities are iterated and processed one by one. It does not cover any command
 initialization nor command finalization stage. If there is any message issued
 out of log report's coverage range, such message goes directly to output,
 bypassing the \fBlog report\fP. By default, that is \fBstandard error output\fP
-for error and warning messages and \fBstandard output\fP for common print\-like
+for error and warning messages and \fBstandard output\fP for common print-like
 messages.
 
 When running LVM commands in \fBLVM shell\fP, the log report covers the whole
@@ -430,7 +430,7 @@ For these reasons and for completeness, it's not possible to rely fully on
 \fBlog report\fP as the only indicator of LVM command's status and the only
 place where all messages issued during LVM command execution are collected.
 You always need to check whether the command has not failed out of log
-report's range by checking the non\-report output too.
+report's range by checking the non-report output too.
 
 To help with this, LVM can separate output which you can then redirect to
 any \fBcustom file descriptor\fP that you prepare before running an LVM
@@ -441,7 +441,7 @@ descriptor numbers. See also \fBLVM_OUT_FD\fP, \fBLVM_ERR_FD\fP and
 man page.
 
 Also note that, by default, reports use the same file descriptor as
-common print\-like messages, which is \fBstandard output\fP. If you plan to
+common print-like messages, which is \fBstandard output\fP. If you plan to
 use \fBlog report\fP in your scripts or any external tool, you should use
 \fBLVM_OUT_FD\fP, \fBLVM_ERR_FD\fP and \fBLVM_REPORT_FD\fP to separate all
 output types to different file descriptors. For example, with bash, that
@@ -572,13 +572,13 @@ Rreturn code associated with current item.
 .RE
 
 
-You can also run \fB<lvm_command> \-\-configreport log -o help\fP to
+You can also run \fB<lvm_command> --configreport log -o help\fP to
 to display complete list of fields that you may use for the \fBlog report\fP.
 
 .SH Selection
 Selection is used for a report to display only rows that match
 \fBselection criteria\fP. All rows are displayed with the additional
-\fBselected\fP field (\fB\-o selected\fP) displaying 1 if the row matches the
+\fBselected\fP field (\fB-o selected\fP) displaying 1 if the row matches the
 \fISelection\fP and 0 otherwise. The \fBselection criteria\fP are a set of
 \fBstatements\fP combined by \fBlogical and grouping operators\fP.
 The \fBstatement\fP consists of a \fBfield\fP name for which a set of valid
@@ -668,7 +668,7 @@ criteria)
 \fBnumber\fP for integer value
 .IP \[bu] 3
 \fBsize\fP for integer or floating point number with size unit suffix
-(see also \fBlvcreate\fP(8) man page and description for "-L|\-\-size"
+(see also \fBlvcreate\fP(8) man page and description for "-L|--size"
 option for the list of recognized suffixes)
 .IP \[bu] 3
 \fBpercent\fP for floating point number with or without "%" suffix
@@ -708,9 +708,9 @@ demonstrating time expressions in selection criteria, see \fBEXAMPLES\fP section
 date
 .RS
 .IP
-YYYY\-MM\-DD
+YYYY-MM-DD
 .IP
-YYYY\-MM, auto DD=1
+YYYY-MM, auto DD=1
 .IP
 YYYY, auto MM=01 and DD=01
 .RE
@@ -735,7 +735,7 @@ timezone
 +hh or -hh
 .RE
 
-The full date/time specification is YYYY\-MM\-DD hh:mm:ss. Users are able
+The full date/time specification is YYYY-MM-DD hh:mm:ss. Users are able
 to leave date/time parts from right to left. Whenever these parts are left out,
 a range is assumed automatically with second granularity. For example:
 
@@ -795,12 +795,12 @@ month names ("January" - "December" or abbreviated as "Jan" - "Dec")
 .IP
 .BR VALUE " = " [VALUE " log_op " VALUE]
 .br
-For list\-based types: string list. Matches strictly.
+For list-based types: string list. Matches strictly.
 The log_op must always be of one type within the whole list value.
 .IP
 .BR VALUE " = " {VALUE " log_op " VALUE}
 .br
-For list\-based types: string list. Matches a subset.
+For list-based types: string list. Matches a subset.
 The log_op must always be of one type within the whole list value.
 .IP
 .BR VALUE " = " value
@@ -818,7 +818,7 @@ including all configuration related to reporting. We will use it throughout
 examples below to display current configuration.
 
 .nf
-# lvmconfig \-\-type full global/units global/suffix \\
+# lvmconfig --type full global/units global/suffix \\
    report/output_format  report/compact_output \\
    report/compact_output_cols report/aligned \\
    report/headings report/separator \\
@@ -840,7 +840,7 @@ prefixes=0
 quoted=1
 columns_as_rows=0
 binary_values_as_numeric=0
-time_format="%Y\-%m\-%d %T %z"
+time_format="%Y-%m-%d %T %z"
 mark_hidden_devices=1
 two_word_unknown_device=0
 buffered=1
@@ -854,7 +854,7 @@ type is configured with configuration settings as we already mentioned in
 \fBmain report specifics\fP section in this man page.
 
 .nf
-# lvmconfig \-\-type full report/pvs_cols report/pvs_sort \\
+# lvmconfig --type full report/pvs_cols report/pvs_sort \\
    report/pvsegs_cols report/pvsegs_sort report/vgs_cols \\
    report/vgs_sort report/lvs_cols report/lvs_sort \\
    report/segs_cols report/segs_sort
@@ -875,32 +875,32 @@ segs_sort="vg_name,lv_name,seg_start"
 .nf
 # pvs
   PV         VG Fmt  Attr PSize   PFree 
-  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m
-  /dev/sdb   vg lvm2 a\-\-  100.00m 92.00m
+  /dev/sda   vg lvm2 a--  100.00m 88.00m
+  /dev/sdb   vg lvm2 a--  100.00m 92.00m
 
-# pvs \-\-segments
+# pvs --segments
   PV         VG Fmt  Attr PSize   PFree  Start SSize
-  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m     0     1
-  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m     1     1
-  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m     2     1
-  /dev/sda   vg lvm2 a\-\-  100.00m 88.00m     3    22
-  /dev/sdb   vg lvm2 a\-\-  100.00m 92.00m     0     1
-  /dev/sdb   vg lvm2 a\-\-  100.00m 92.00m     1     1
-  /dev/sdb   vg lvm2 a\-\-  100.00m 92.00m     2    23
+  /dev/sda   vg lvm2 a--  100.00m 88.00m     0     1
+  /dev/sda   vg lvm2 a--  100.00m 88.00m     1     1
+  /dev/sda   vg lvm2 a--  100.00m 88.00m     2     1
+  /dev/sda   vg lvm2 a--  100.00m 88.00m     3    22
+  /dev/sdb   vg lvm2 a--  100.00m 92.00m     0     1
+  /dev/sdb   vg lvm2 a--  100.00m 92.00m     1     1
+  /dev/sdb   vg lvm2 a--  100.00m 92.00m     2    23
 
 # vgs
   VG #PV #LV #SN Attr   VSize   VFree  
-  vg   2   2   0 wz\-\-n\- 200.00m 180.00m
+  vg   2   2   0 wz--n- 200.00m 180.00m
 
 # lvs
   LV    VG Attr       LSize Pool Origin Move Log Cpy%Sync Convert
-  lvol0 vg -wi\-a\-\-\-\-\- 4.00m                                    
-  lvol1 vg rwi\-a\-r\-\-\- 4.00m                      100.00          
+  lvol0 vg -wi-a----- 4.00m                                    
+  lvol1 vg rwi-a-r--- 4.00m                      100.00          
 
-# lvs \-\-segments
+# lvs --segments
   LV    VG Attr       #Str Type   SSize
-  lvol0 vg -wi\-a\-\-\-\-\-    1 linear 4.00m
-  lvol1 vg rwi\-a\-r\-\-\-    2 raid1  4.00m
+  lvol0 vg -wi-a-----    1 linear 4.00m
+  lvol1 vg rwi-a-r---    2 raid1  4.00m
 .fi
 
 We will use \fBreport/lvs_cols\fP and \fBreport/lvs_sort\fP configuration
@@ -911,7 +911,7 @@ Also note that in the example below, we don't display the "lv_time" field
 even though we're using it for sorting - this is allowed.
 
 .nf
-# lvmconfig \-\-type full report/lvs_cols report/lvs_sort
+# lvmconfig --type full report/lvs_cols report/lvs_sort
 lvs_cols="lv_name,lv_size,origin,pool_lv,copy_percent"
 lvs_sort="-lv_time"
 
@@ -921,7 +921,7 @@ lvs_sort="-lv_time"
   lvol0 4.00m  
 .fi
 
-You can use \fB\-o|\-\-options\fP command line option to override current
+You can use \fB-o|--options\fP command line option to override current
 configuration directly on command line.
 
 .nf
@@ -935,12 +935,12 @@ configuration directly on command line.
   lvol1 4.00m             100.00   raid,raid1
   lvol0 4.00m                      linear    
 
-# lvs -o\-origin
+# lvs -o-origin
   LV    LSize Pool Cpy%Sync
   lvol1 4.00m      100.00  
   lvol0 4.00m              
 
-# lvs -o lv_name,lv_size,origin -o+lv_layout -o\-origin -O lv_name
+# lvs -o lv_name,lv_size,origin -o+lv_layout -o-origin -O lv_name
   LV    LSize Layout    
   lvol0 4.00m linear    
   lvol1 4.00m raid,raid1
@@ -956,7 +956,7 @@ This way, it's possible to configure different sets of fields to display
 and to sort by for individual reports as well as the full report.
 
 .nf
-# lvmconfig \-\-type full report/pvs_cols_full \\
+# lvmconfig --type full report/pvs_cols_full \\
    report/pvs_sort_full report/pvsegs_cols_full \\
    report/pvsegs_sort_full report/vgs_cols_full \\
    report/vgs_sort_full report/lvs_cols_full \\
@@ -1007,7 +1007,7 @@ output. To enable this feature and to compact all fields, use
 \fBreport/compact_output=1\fP in your configuration.
 
 .nf
-# lvmconfig \-\-type full report/compact_output
+# lvmconfig --type full report/compact_output
 compact_output=1
 
 # lvs
@@ -1021,11 +1021,11 @@ compact_output=1
 .fi
 
 Alternatively, you can define which fields should be compacted by configuring
-\fBreport/compact_output_cols\fP configuration setting (or \fB\-o|\-\-options #\fP
+\fBreport/compact_output_cols\fP configuration setting (or \fB-o|--options #\fP
 command line option).
 
 .nf
-# lvmconfig \-\-type full report/compact_output report/compact_output_cols
+# lvmconfig --type full report/compact_output report/compact_output_cols
 compact_output=0
 compact_output_cols="origin"
 
@@ -1048,85 +1048,85 @@ We will use \fBreport/compact_output=1\fP for subsequent examples.
 
 .SS Further formatting options
 
-By default, LVM displays sizes in reports in human\-readable form which means
+By default, LVM displays sizes in reports in human-readable form which means
 that the most suitable unit is used so it's easy to read. You can use
-\fBreport/units\fP configuration setting (or \fB\-\-units\fP option directly
+\fBreport/units\fP configuration setting (or \fB--units\fP option directly
 on command line) and \fBreport/suffix\fP
-configuration setting (or \fB\-\-nosuffix\fP command line option) to change this.
+configuration setting (or \fB--nosuffix\fP command line option) to change this.
 
 .nf
-# lvs \-\-units b \-\-nosuffix
+# lvs --units b --nosuffix
   LV    LSize   Cpy%Sync
   lvol1 4194304 100.00  
   lvol0 4194304    
 .fi
 
 If you want to configure whether report headings are displayed or not, use
-\fBreport/headings\fP configuration settings (or \fB\-\-noheadings\fP command
+\fBreport/headings\fP configuration settings (or \fB--noheadings\fP command
 line option).
 
 .nf
-# lvs \-\-noheadings
+# lvs --noheadings
   lvol1 4.00m 100.00  
   lvol0 4.00m     
 .fi
 
 In some cases, it may be useful to display report content as key=value pairs
 where key here is actually the field name. Use \fBreport/prefixes\fP
-configuration setting (or \fB\-\-nameprefixes\fP command line option) to switch
+configuration setting (or \fB--nameprefixes\fP command line option) to switch
 between standard output and the key=value output. The key=value pair is the
 output that is suitable for use in scripts and for other tools to parse easily.
 Usually, you also don't want to display headings with the output that has these
 key=value pairs.
 
 .nf
-# lvs \-\-noheadings \-\-nameprefixes
+# lvs --noheadings --nameprefixes
   LVM2_LV_NAME='lvol1' LVM2_LV_SIZE='4.00m' LVM2_COPY_PERCENT='100.00'
   LVM2_LV_NAME='lvol0' LVM2_LV_SIZE='4.00m' LVM2_COPY_PERCENT=''
 .fi
 
 To define whether quotation marks in key=value pairs should be used or not,
-use \fBreport/quoted\fP configuration setting (or \fB\-\-unquoted\fP command
+use \fBreport/quoted\fP configuration setting (or \fB--unquoted\fP command
 line option).
 
 .nf
-# lvs \-\-noheadings \-\-nameprefixes \-\-unquoted
+# lvs --noheadings --nameprefixes --unquoted
   LVM2_LV_NAME=lvol1 LVM2_LV_SIZE=4.00m LVM2_COPY_PERCENT=100.00
   LVM2_LV_NAME=lvol0 LVM2_LV_SIZE=4.00m LVM2_COPY_PERCENT=
 .fi
 
 For easier parsing, you can even transpose the report so each column now
 becomes a row in the output. This is done with \fBreport/output_as_rows\fP
-configuration setting (or \fB\-\-rows\fP command line option).
+configuration setting (or \fB--rows\fP command line option).
 
 .nf
-# lvs \-\-noheadings \-\-nameprefixes \-\-unquoted \-\-rows
+# lvs --noheadings --nameprefixes --unquoted --rows
   LVM2_LV_NAME=lvol1 LVM2_LV_NAME=lvol0
   LVM2_LV_SIZE=4.00m LVM2_LV_SIZE=4.00m
   LVM2_COPY_PERCENT=100.00 LVM2_COPY_PERCENT=
 .fi
 
-Use \fBreport/separator\fP configuration setting (or \fB\-\-separator\fP command
+Use \fBreport/separator\fP configuration setting (or \fB--separator\fP command
 line option) to define your own field separator to use.
 
 .nf
-# lvs \-\-noheadings \-\-nameprefixes \-\-unquoted \-\-separator " | "
+# lvs --noheadings --nameprefixes --unquoted --separator " | "
   LVM2_LV_NAME=lvol1 | LVM2_LV_SIZE=4.00m | LVM2_COPY_PERCENT=100.00
   LVM2_LV_NAME=lvol0 | LVM2_LV_SIZE=4.00m | LVM2_COPY_PERCENT=
 .fi
 
 If you are using your own separator, the columns in the output are not aligned
-by default. Use \fBreport/aligned\fP configuration setting (or \fB\-\-aligned\fP
+by default. Use \fBreport/aligned\fP configuration setting (or \fB--aligned\fP
 command line option) for LVM to add extra spaces in report to align the output
 properly.
 
 .nf
-# lvs \-\-separator " | "
+# lvs --separator " | "
   LV | LSize | Cpy%Sync
   lvol1 | 4.00m | 100.00
   lvol0 | 4.00m | 
 
-# lvs \-\-separator " | " \-\-aligned
+# lvs --separator " | " --aligned
   LV    | LSize | Cpy%Sync
   lvol1 | 4.00m | 100.00  
   lvol0 | 4.00m |         
@@ -1148,7 +1148,7 @@ separator, use \fBreport/list_item_separator\fP configuration setting its
 definition.
 
 .nf
-# lvmconfig \-\-type full report/list_item_separator
+# lvmconfig --type full report/list_item_separator
 list_item_separator=";"
 
 # lvs -o+tags
@@ -1165,8 +1165,8 @@ Format for any of time values displayed in reports can be configured with
 and time is displayed, including timezone.
 
 .nf
-# lvmconfig \-\-type full report/time_format
-time_format="%Y\-%m\-%d %T %z"
+# lvmconfig --type full report/time_format
+time_format="%Y-%m-%d %T %z"
 
 # lvs -o+time
   LV    LSize Cpy%Sync CTime                     
@@ -1176,22 +1176,22 @@ time_format="%Y\-%m\-%d %T %z"
 
 We can change time format in similar way as we do when using \fBdate\fP(1)
 command or \fBstrftime\fP(3) function
-(\fBlvmconfig \-\-type default \-\-withcomments report/time_format\fP will
+(\fBlvmconfig --type default --withcomments report/time_format\fP will
 give you complete list of available formatting options). In the example
 below, we decided to use %s for number of seconds since Epoch (1970-01-01 UTC).
 
 .nf
-# lvmconfig \-\-type full report/time_format
+# lvmconfig --type full report/time_format
 time_format="%s"
 
 # lvs
   LV    Attr       LSize Cpy%Sync LV Tags   CTime                     
-  lvol1 rwi\-a\-r\-\-\- 4.00m 100.00             1472468016                
-  lvol0 -wi\-a\-\-\-\-\- 4.00m          tagA,tagB 1472458517     
+  lvol1 rwi-a-r--- 4.00m 100.00             1472468016                
+  lvol0 -wi-a----- 4.00m          tagA,tagB 1472458517     
 .fi
 
 The \fBlvs\fP does not display hidden LVs by default - to include these LVs
-in the output, you need to use \fB\-a|\-\-all\fP command line option. Names for
+in the output, you need to use \fB-a|--all\fP command line option. Names for
 these hidden LVs are displayed within square brackets.
 
 .nf
@@ -1209,7 +1209,7 @@ You can configure LVM to display the square brackets for hidden LVs or not with
 \fBreport/mark_hidden_devices\fP configuration setting.
 
 .nf
-# lvmconfig \-\-type full report/mark_hidden_devices
+# lvmconfig --type full report/mark_hidden_devices
 mark_hidden_devices=0
 
 # lvs -a
@@ -1254,7 +1254,7 @@ We can change the way how these binary values are displayed with
 \fBreport/binary_values_as_numeric\fP configuration setting.
 
 .nf
-# lvmconfig \-\-type full report/binary_values_as_numeric
+# lvmconfig --type full report/binary_values_as_numeric
 binary_values_as_numeric=1
 
 # lvs -o+lv_active_locally
@@ -1266,12 +1266,12 @@ binary_values_as_numeric=1
 .SS Changing output format
 
 LVM can output reports in different formats - use \fBreport/output_format\fP
-configuration setting (or \fB\-\-reportformat\fP command line option) to swith
+configuration setting (or \fB--reportformat\fP command line option) to swith
 the report output format. Currently, LVM supports \fB"basic"\fP (all the examples
 we used above used this format) and \fB"JSON"\fP output format.
 
 .nf
-# lvs -o lv_name,lv_size \-\-reportformat json
+# lvs -o lv_name,lv_size --reportformat json
   {
       "report": [
           {
@@ -1286,9 +1286,9 @@ we used above used this format) and \fB"JSON"\fP output format.
 
 Note that some configuration settings and command line options have no
 effect with certain report formats. For example, with \fBJSON\fP output,
-it doesn't have any meaning to use \fBreport/aligned\fP (\fB\-\-aligned\fP),
-\fBreport/noheadings\fP (\fB\-\-noheadings\fP), \fBreport/columns_as_rows\fP
-(\fB\-\-rows\fP) or \fBreport/buffered\fP (\fB\-\-unbuffered\fP). All these
+it doesn't have any meaning to use \fBreport/aligned\fP (\fB--aligned\fP),
+\fBreport/noheadings\fP (\fB--noheadings\fP), \fBreport/columns_as_rows\fP
+(\fB--rows\fP) or \fBreport/buffered\fP (\fB--unbuffered\fP). All these
 configuration settings and command line options are ignored if using the
 \fBJSON\fP report output format.
 
@@ -1315,7 +1315,7 @@ look at the bottom of the help output, you can see section about
 # lvs -S help
  ...
 Selection operators
-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-
+-------------------
 Comparison operators:
    =~  - Matching regular expression. [regex]
    !~  - Not matching regular expression. [regex]
@@ -1384,16 +1384,16 @@ together.
   lvol2 8.00m       
 .fi
 
-You can also use selection together with processing\-oriented commands.
+You can also use selection together with processing-oriented commands.
 
 .nf
-# lvchange \-\-addtag test -S 'size < 5000k'
+# lvchange --addtag test -S 'size < 5000k'
   Logical volume vg/lvol1 changed.
   Logical volume vg/lvol0 changed.
   Logical volume vg/lvol3 changed.
   Logical volume vg/lvol4 changed.
 
-# lvchange \-\-deltag test -S 'tags = test'
+# lvchange --deltag test -S 'tags = test'
   Logical volume vg/lvol1 changed.
   Logical volume vg/lvol0 changed.
   Logical volume vg/lvol3 changed.
@@ -1534,7 +1534,7 @@ Time operators have synonyms: ">=" for since, "<=" for until,
 Example below demonstrates using absolute time expression.
 
 .nf
-# lvs -o name,time \-\-config report/time_format="%s"
+# lvs -o name,time --config report/time_format="%s"
   LV    CTime                     
   lvol4 1473433064                
   lvol3 1473433008                
@@ -1593,15 +1593,15 @@ Examples below demonstrates using freeform time expressions.
 .SS Command log reporting
 
 As described in \fBcategorization based on reporting facility\fP section
-at the beginning of this document, both \fBreport\-oriented\fP and
-\fBprocessing\-oriented\fP LVM commands can report the command log if
+at the beginning of this document, both \fBreport-oriented\fP and
+\fBprocessing-oriented\fP LVM commands can report the command log if
 this is enabled with \fBlog/report_command_log\fP configuration setting.
 Just like any other report, we can set the set of fields to display
 (\fBlog/command_log_cols\fP) and to sort by (\fBlog/command_log_sort\fP)
 for this report.
 
 .nf
-# lvmconfig \-\-type full log/report_command_log log/command_log_cols \\
+# lvmconfig --type full log/report_command_log log/command_log_cols \\
    log/command_log_sort log/command_log_selection
 report_command_log=1
 command_log_cols="log_seq_num,log_type,log_context,log_object_type,
@@ -1631,7 +1631,7 @@ log report in the example below where we can see that both LVs lvol0 and
 lvol1 were successfully processed as well as the VG vg they are part of.
 
 .nf
-# lvmconfig \-\-type full log/command_log_selection
+# lvmconfig --type full log/command_log_selection
 command_log_selection="all"
 
 # lvs
@@ -1659,11 +1659,11 @@ command_log_selection="all"
 .SS Handling multiple reports per single command
 
 To configure the log report directly on command line, we need to use
-\fB\-\-configreport\fP option before we start any \fB\-o|\-\-options\fP,
-\fB\-O|\-\-sort\fP or \fB\-S|\-\-select\fP that is targeted for log report.
+\fB--configreport\fP option before we start any \fB-o|--options\fP,
+\fB-O|--sort\fP or \fB-S|--select\fP that is targeted for log report.
 
 .nf
-# lvs -o lv_name,lv_size \-\-configreport log -o log_object_type, \\
+# lvs -o lv_name,lv_size --configreport log -o log_object_type, \\
    log_object_name,log_message,log_ret_code
   Logical Volume
   ==============
@@ -1680,7 +1680,7 @@ To configure the log report directly on command line, we need to use
 .fi
 
 The \fBlvm fullreport\fP, with or without log report, consists of several
-reports - the \fB\-\-configreport\fP is also used to target particular
+reports - the \fB--configreport\fP is also used to target particular
 subreport here.
 
 Below is an extended example with \fBlvm fullreport\fP to illustrate
@@ -1693,12 +1693,12 @@ having "sda" in its name. Also, for the log subreport we define ordering
 to be based on "log_object_type" field.
 
 .nf
-# lvm fullreport \-\-reportformat json \\
-   \-\-configreport vg -o vg_name,vg_size \\
-   \-\-configreport pvseg -o pv_name,pvseg_start \\
+# lvm fullreport --reportformat json \\
+   --configreport vg -o vg_name,vg_size \\
+   --configreport pvseg -o pv_name,pvseg_start \\
                         -S 'pv_name=~sda' \\
-   \-\-configreport seg -o lv_name,seg_start \\
-   \-\-configreport log -o log_object_type,log_object_name \\
+   --configreport seg -o lv_name,seg_start \\
+   --configreport log -o log_object_type,log_object_name \\
                       -O log_object_type \\
                       -S 'log_object_name=lvol0 || \\
                           log_object_name=~sda'
diff --git a/man/lvmsadc.8_main b/man/lvmsadc.8_main
index 43d24af..c2781b8 100644
--- a/man/lvmsadc.8_main
+++ b/man/lvmsadc.8_main
@@ -4,7 +4,7 @@ lvmsadc \(em LVM system activity data collector
 .SH "SYNOPSIS"
 .B lvmsadc
 .SH "DESCRIPTION"
-lvmsadc is not supported under LVM2. The device\-mapper statistics
+lvmsadc is not supported under LVM2. The device-mapper statistics
 facility provides similar performance metrics using the \fBdmstats(8)\fP
 command.
 .SH "SEE ALSO"
diff --git a/man/lvmsar.8_main b/man/lvmsar.8_main
index 765d8e7..0bbcbf3 100644
--- a/man/lvmsar.8_main
+++ b/man/lvmsar.8_main
@@ -4,7 +4,7 @@ lvmsar \(em LVM system activity reporter
 .SH "SYNOPSIS"
 .B lvmsar
 .SH "DESCRIPTION"
-lvmsar is not supported under LVM2. The device\-mapper statistics
+lvmsar is not supported under LVM2. The device-mapper statistics
 facility provides similar performance metrics using the \fBdmstats(8)\fP
 command.
 .SH "SEE ALSO"
diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index e773ebf..3aea996 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -15,12 +15,12 @@ from accidental use by other hosts.
 The system_id is not a dynamic property, and can only be changed in very
 limited circumstances (see vgexport and vgimport).  Even limited changes
 to the VG system_id are not perfectly reflected across hosts.  A more
-coherent view of shared storage requires using an inter\-host locking
+coherent view of shared storage requires using an inter-host locking
 system to coordinate access and update caches.
 
 The system_id is a string uniquely identifying a host.  It can be manually
 set to a custom value or it can be assigned automatically by lvm using a
-unique identifier already available on the host, e.g. machine\-id or uname.
+unique identifier already available on the host, e.g. machine-id or uname.
 
 In vgcreate, the local system_id is saved in the new VG metadata.  The
 local host owns the new VG, and other hosts cannot use it.
@@ -53,7 +53,7 @@ command 'vgs -o+systemid'
 A VG will not have a system_id if it was created before this feature was
 added to lvm, or if it was created by a host that did not have a system_id
 defined.  A system_id can be assigned to these VGs by using vgchange
-\-\-systemid (see below).
+--systemid (see below).
 
 .IP \[bu] 2
 Two hosts should not be assigned the same system_id.  Doing so defeats
@@ -72,7 +72,7 @@ A host using an old version of lvm without the system_id feature will not
 recognize a new system_id in VGs from other hosts.  Even though the old
 version of lvm is not blocked from reading a VG with a system_id, it is
 blocked from writing to the VG (or its LVs).  The new system_id changes
-the write mode of a VG, making it appear read\-only to previous lvm
+the write mode of a VG, making it appear read-only to previous lvm
 versions.
 
 This also means that if a host downgrades its version of lvm, it would
@@ -144,12 +144,12 @@ global {
 .B machineid
 .br
 
-The content of /etc/machine\-id is used as the system_id if available.
+The content of /etc/machine-id is used as the system_id if available.
 See
-.BR machine\-id (5)
+.BR machine-id (5)
 and
-.BR systemd\-machine\-id\-setup (1)
-to check if machine\-id is available on the host.
+.BR systemd-machine-id-setup (1)
+to check if machine-id is available on the host.
 
 .I lvm.conf
 .nf
@@ -239,7 +239,7 @@ local {
 In vgcreate, the host running the command assigns its own system_id to the
 new VG.  To override this and set another system_id:
 
-.B vgcreate \-\-systemid
+.B vgcreate --systemid
 .I SystemID VG Devices
 
 Overriding the system_id makes it possible for a host to create a VG that
@@ -247,7 +247,7 @@ it may not be able to use.  Another host with a system_id matching the one
 specified may not recognize the new VG without manually rescanning
 devices.
 
-If the \-\-systemid argument is an empty string (""), the VG is created with
+If the --systemid argument is an empty string (""), the VG is created with
 no system_id, making it accessible to other hosts (see warnings above.)
 
 .SS report/display
@@ -255,11 +255,11 @@ no system_id, making it accessible to other hosts (see warnings above.)
 The system_id of a VG is displayed with the "systemid" reporting option.
 
 Report/display commands ignore foreign VGs by default.  To report foreign
-VGs, the \-\-foreign option can be used.  This causes the VGs to be read
+VGs, the --foreign option can be used.  This causes the VGs to be read
 from disk.  Because lvmetad caching is not used, this option can cause
 poor performance.
 
-.B vgs \-\-foreign -o+systemid
+.B vgs --foreign -o+systemid
 
 When a host with no system_id sees foreign VGs, it warns about them as
 they are skipped.  The host should be assigned a system_id, after which
@@ -271,7 +271,7 @@ vgexport clears the system_id.
 
 Other hosts will continue to see a newly exported VG as foreign because of
 local caching (when lvmetad is used).  Manually updating the local lvmetad
-cache with pvscan \-\-cache will allow a host to recognize the newly
+cache with pvscan --cache will allow a host to recognize the newly
 exported VG.
 
 vgimport sets the VG system_id to the local system_id as determined by
@@ -280,7 +280,7 @@ newly exported VGs.
 
 After vgimport, the exporting host will continue to see the VG as
 exported, and not owned by the new host.  Manually updating the local
-cache with pvscan \-\-cache will allow a host to recognize the newly
+cache with pvscan --cache will allow a host to recognize the newly
 imported VG as foreign.
 
 .SS vgchange
@@ -288,7 +288,7 @@ imported VG as foreign.
 A host can change the system_id of its own VGs, but the command requires
 confirmation because the host may lose access to the VG being changed:
 
-.B vgchange \-\-systemid
+.B vgchange --systemid
 .I SystemID VG
 
 The system_id can be removed from a VG by specifying an empty string ("")
@@ -340,7 +340,7 @@ orphan.  Nothing would automatically prevent the other hosts from using
 the newly allocated PV and corrupting it.  If the other hosts run a
 command to rescan devices, and update lvmetad, they would then recognize
 that the PV has been used by another host.  A command that rescans devices
-could be pvscan \-\-cache, or vgs \-\-foreign.
+could be pvscan --cache, or vgs --foreign.
 
 .SH SEE ALSO
 .BR vgcreate (8),
@@ -348,7 +348,7 @@ could be pvscan \-\-cache, or vgs \-\-foreign.
 .BR vgimport (8),
 .BR vgexport (8),
 .BR lvm.conf (5),
-.BR machine\-id (5),
+.BR machine-id (5),
 .BR uname (2),
 .BR vgs (8)
 
diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index cefe943..a6c8123 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -99,26 +99,26 @@ The primary method for using lvm thin provisioning:
 
 Create an LV that will hold thin pool data.
 
-.B lvcreate \-n ThinDataLV \-L LargeSize VG
+.B lvcreate -n ThinDataLV -L LargeSize VG
 
 .I Example
 .br
-# lvcreate \-n pool0 \-L 10G vg
+# lvcreate -n pool0 -L 10G vg
 
 .SS 2. create ThinMetaLV
 
 Create an LV that will hold thin pool metadata.
 
-.B lvcreate \-n ThinMetaLV \-L SmallSize VG
+.B lvcreate -n ThinMetaLV -L SmallSize VG
 
 .I Example
 .br
-# lvcreate \-n pool0meta \-L 1G vg
+# lvcreate -n pool0meta -L 1G vg
 
 # lvs
   LV        VG Attr       LSize
-  pool0     vg -wi\-a\-\-\-\-\- 10.00g
-  pool0meta vg -wi\-a\-\-\-\-\- 1.00g
+  pool0     vg -wi-a----- 10.00g
+  pool0meta vg -wi-a----- 1.00g
 
 .SS 3. create ThinPoolLV
 
@@ -129,21 +129,21 @@ ThinMetaLV is renamed to hidden ThinPoolLV_tmeta.
 The new ThinPoolLV takes the previous name of ThinDataLV.
 .fi
 
-.B lvconvert \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B lvconvert --type thin-pool --poolmetadata VG/ThinMetaLV VG/ThinDataLV
 
 .I Example
 .br
-# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
+# lvconvert --type thin-pool --poolmetadata vg/pool0meta vg/pool0
 
 # lvs vg/pool0
   LV    VG Attr       LSize  Pool Origin Data% Meta%
-  pool0 vg twi\-a\-tz\-\- 10.00g      0.00   0.00
+  pool0 vg twi-a-tz-- 10.00g      0.00   0.00
 
-# lvs \-a
+# lvs -a
   LV            VG Attr       LSize
-  pool0         vg twi\-a\-tz\-\- 10.00g
-  [pool0_tdata] vg Twi\-ao\-\-\-\- 10.00g
-  [pool0_tmeta] vg ewi\-ao\-\-\-\- 1.00g
+  pool0         vg twi-a-tz-- 10.00g
+  [pool0_tdata] vg Twi-ao---- 10.00g
+  [pool0_tmeta] vg ewi-ao---- 1.00g
 
 .SS 4. create ThinLV
 
@@ -152,81 +152,81 @@ Create a new thin LV from the thin pool LV.
 The thin LV is created with a virtual size.
 Multiple new thin LVs may be created in the thin pool.
 Thin LV names must be unique in the VG.
-The '\-\-type thin' option is inferred from the virtual size option.
-The \-\-thinpool argument specifies which thin pool will
+The '--type thin' option is inferred from the virtual size option.
+The --thinpool argument specifies which thin pool will
 contain the ThinLV.
 .fi
 
-.B lvcreate \-n ThinLV \-V VirtualSize \-\-thinpool ThinPoolLV VG
+.B lvcreate -n ThinLV -V VirtualSize --thinpool ThinPoolLV VG
 
 .I Example
 .br
 Create a thin LV in a thin pool:
 .br
-# lvcreate \-n thin1 \-V 1T \-\-thinpool pool0 vg
+# lvcreate -n thin1 -V 1T --thinpool pool0 vg
 
 Create another thin LV in the same thin pool:
 .br
-# lvcreate \-n thin2 \-V 1T \-\-thinpool pool0 vg
+# lvcreate -n thin2 -V 1T --thinpool pool0 vg
 
 # lvs vg/thin1 vg/thin2
   LV    VG Attr       LSize Pool  Origin Data%
-  thin1 vg Vwi\-a\-tz\-\- 1.00t pool0        0.00
-  thin2 vg Vwi\-a\-tz\-\- 1.00t pool0        0.00
+  thin1 vg Vwi-a-tz-- 1.00t pool0        0.00
+  thin2 vg Vwi-a-tz-- 1.00t pool0        0.00
 
 .SS 5. create SnapLV
 
 Create snapshots of an existing ThinLV or SnapLV.
 .br
 Do not specify
-.BR \-L ", " \-\-size
+.BR -L ", " --size
 when creating a thin snapshot.
 .br
 A size argument will cause an old COW snapshot to be created.
 
-.B lvcreate \-n SnapLV \-\-snapshot VG/ThinLV
+.B lvcreate -n SnapLV --snapshot VG/ThinLV
 .br
-.B lvcreate \-n SnapLV \-\-snapshot VG/PrevSnapLV
+.B lvcreate -n SnapLV --snapshot VG/PrevSnapLV
 
 .I Example
 .br
 Create first snapshot of an existing ThinLV:
 .br
-# lvcreate \-n thin1s1 \-s vg/thin1
+# lvcreate -n thin1s1 -s vg/thin1
 
 Create second snapshot of the same ThinLV:
 .br
-# lvcreate \-n thin1s2 \-s vg/thin1
+# lvcreate -n thin1s2 -s vg/thin1
 
 Create a snapshot of the first snapshot:
 .br
-# lvcreate \-n thin1s1s1 \-s vg/thin1s1
+# lvcreate -n thin1s1s1 -s vg/thin1s1
 
 # lvs vg/thin1s1 vg/thin1s2 vg/thin1s1s1
   LV        VG Attr       LSize Pool  Origin
-  thin1s1   vg Vwi\-\-\-tz\-k 1.00t pool0 thin1
-  thin1s2   vg Vwi\-\-\-tz\-k 1.00t pool0 thin1
-  thin1s1s1 vg Vwi\-\-\-tz\-k 1.00t pool0 thin1s1
+  thin1s1   vg Vwi---tz-k 1.00t pool0 thin1
+  thin1s2   vg Vwi---tz-k 1.00t pool0 thin1
+  thin1s1s1 vg Vwi---tz-k 1.00t pool0 thin1s1
 
 .SS 6. activate SnapLV
 
 Thin snapshots are created with the persistent "activation skip"
-flag, indicated by the "k" attribute.  Use \-K with lvchange
+flag, indicated by the "k" attribute.  Use -K with lvchange
 or vgchange to activate thin snapshots with the "k" attribute.
 
-.B lvchange \-ay \-K VG/SnapLV
+.B lvchange -ay -K VG/SnapLV
 
 .I Example
 .br
-# lvchange \-ay \-K vg/thin1s1
+# lvchange -ay -K vg/thin1s1
 
 # lvs vg/thin1s1
   LV      VG Attr       LSize Pool  Origin
-  thin1s1 vg Vwi\-a\-tz\-k 1.00t pool0 thin1
+  thin1s1 vg Vwi-a-tz-k 1.00t pool0 thin1
 
 .SH Thin Topics
 
-.B Alternate syntax for specifying type thin\-pool
+.B Alternate syntax for specifying type thin-pool
 .br
 .B Automatic pool metadata LV
 .br
@@ -286,20 +286,20 @@ A thin data LV can be converted to a thin pool LV without specifying a
 thin pool metadata LV.  LVM automatically creates a metadata LV from the
 same VG.
 
-.B lvcreate \-n ThinDataLV \-L LargeSize VG
+.B lvcreate -n ThinDataLV -L LargeSize VG
 .br
-.B lvconvert \-\-type thin\-pool VG/ThinDataLV
+.B lvconvert --type thin-pool VG/ThinDataLV
 
 .I Example
 .br
 .nf
-# lvcreate \-n pool0 \-L 10G vg
-# lvconvert \-\-type thin\-pool vg/pool0
+# lvcreate -n pool0 -L 10G vg
+# lvconvert --type thin-pool vg/pool0
 
-# lvs \-a
-  pool0           vg          twi\-a\-tz\-\-  10.00g
-  [pool0_tdata]   vg          Twi\-ao\-\-\-\-  10.00g
-  [pool0_tmeta]   vg          ewi\-ao\-\-\-\-  16.00m
+# lvs -a
+  pool0           vg          twi-a-tz--  10.00g
+  [pool0_tdata]   vg          Twi-ao----  10.00g
+  [pool0_tmeta]   vg          ewi-ao----  16.00m
 .fi
 
 
@@ -312,18 +312,18 @@ separate physical devices.  To do that, specify the device name(s)
 at the end of the lvcreate line.  It can be especially helpful
 to use fast devices for the metadata LV.
 
-.B lvcreate \-n ThinDataLV \-L LargeSize VG LargePV
+.B lvcreate -n ThinDataLV -L LargeSize VG LargePV
 .br
-.B lvcreate \-n ThinMetaLV \-L SmallSize VG SmallPV
+.B lvcreate -n ThinMetaLV -L SmallSize VG SmallPV
 .br
-.B lvconvert \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B lvconvert --type thin-pool --poolmetadata VG/ThinMetaLV VG/ThinDataLV
 
 .I Example
 .br
 .nf
-# lvcreate \-n pool0 \-L 10G vg /dev/sdA
-# lvcreate \-n pool0meta \-L 1G vg /dev/sdB
-# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
+# lvcreate -n pool0 -L 10G vg /dev/sdA
+# lvcreate -n pool0meta -L 1G vg /dev/sdB
+# lvconvert --type thin-pool --poolmetadata vg/pool0meta vg/pool0
 .fi
 
 .BR lvm.conf (5)
@@ -340,18 +340,18 @@ controls the default PV usage for thin pool creation.
 To tolerate device failures, use raid for the pool data LV and
 pool metadata LV.  This is especially recommended for pool metadata LVs.
 
-.B lvcreate \-\-type raid1 \-m 1 \-n ThinMetaLV \-L SmallSize VG PVA PVB
+.B lvcreate --type raid1 -m 1 -n ThinMetaLV -L SmallSize VG PVA PVB
 .br
-.B lvcreate \-\-type raid1 \-m 1 \-n ThinDataLV \-L LargeSize VG PVC PVD
+.B lvcreate --type raid1 -m 1 -n ThinDataLV -L LargeSize VG PVC PVD
 .br
-.B lvconvert \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B lvconvert --type thin-pool --poolmetadata VG/ThinMetaLV VG/ThinDataLV
 
 .I Example
 .br
 .nf
-# lvcreate \-\-type raid1 \-m 1 \-n pool0 \-L 10G vg /dev/sdA /dev/sdB
-# lvcreate \-\-type raid1 \-m 1 \-n pool0meta \-L 1G vg /dev/sdC /dev/sdD
-# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
+# lvcreate --type raid1 -m 1 -n pool0 -L 10G vg /dev/sdA /dev/sdB
+# lvcreate --type raid1 -m 1 -n pool0meta -L 1G vg /dev/sdC /dev/sdD
+# lvconvert --type thin-pool --poolmetadata vg/pool0meta vg/pool0
 .fi
 
 
@@ -361,7 +361,7 @@ pool metadata LV.  This is especially recommended for pool metadata LVs.
 
 The first time a thin pool LV is created, lvm will create a spare
 metadata LV in the VG.  This behavior can be controlled with the
-option \-\-poolmetadataspare y|n.  (Future thin pool creations will
+option --poolmetadataspare y|n.  (Future thin pool creations will
 also attempt to create the pmspare LV if none exists.)
 
 To create the pmspare ("pool metadata spare") LV, lvm first creates
@@ -376,15 +376,15 @@ explicitly.
 .I Example
 .br
 .nf
-# lvcreate \-n pool0 \-L 10G vg
-# lvcreate \-n pool0meta \-L 1G vg
-# lvconvert \-\-type thin\-pool \-\-poolmetadata vg/pool0meta vg/pool0
-
-# lvs \-a
-  [lvol0_pmspare] vg          ewi\-\-\-\-\-\-\-
-  pool0           vg          twi\-\-\-tz\-\-
-  [pool0_tdata]   vg          Twi\-\-\-\-\-\-\-
-  [pool0_tmeta]   vg          ewi\-\-\-\-\-\-\-
+# lvcreate -n pool0 -L 10G vg
+# lvcreate -n pool0meta -L 1G vg
+# lvconvert --type thin-pool --poolmetadata vg/pool0meta vg/pool0
+
+# lvs -a
+  [lvol0_pmspare] vg          ewi-------
+  pool0           vg          twi---tz--
+  [pool0_tdata]   vg          Twi-------
+  [pool0_tmeta]   vg          ewi-------
 .fi
 
 The "Metadata check and repair" section describes the use of
@@ -424,7 +424,7 @@ details of damaged thin metadata to get the best advice on recovery.
 
 Command to repair a thin pool:
 .br
-.B lvconvert \-\-repair VG/ThinPoolLV
+.B lvconvert --repair VG/ThinPoolLV
 
 Repair performs the following steps:
 
@@ -452,7 +452,7 @@ If metadata is manually restored with thin_repair directly,
 the pool metadata LV can be manually swapped with another LV
 containing new metadata:
 
-.B lvconvert \-\-thinpool VG/ThinPoolLV \-\-poolmetadata VG/NewThinMetaLV
+.B lvconvert --thinpool VG/ThinPoolLV --poolmetadata VG/NewThinMetaLV
 
 
 .SS Activation of thin snapshots
@@ -466,7 +466,7 @@ displayed by lvs:
 .nf
 # lvs vg/thin1s1
   LV         VG  Attr       LSize Pool  Origin
-  thin1s1    vg  Vwi\-\-\-tz\-k 1.00t pool0 thin1
+  thin1s1    vg  Vwi---tz-k 1.00t pool0 thin1
 .fi
 
 This flag causes the snapshot LV to be skipped, i.e. not activated,
@@ -474,29 +474,29 @@ by normal activation commands.  The skipping behavior does not
 apply to deactivation commands.
 
 A snapshot LV with the "k" attribute can be activated using
-the \-K (or \-\-ignoreactivationskip) option in addition to the
-standard \-ay (or \-\-activate y) option.
+the -K (or --ignoreactivationskip) option in addition to the
+standard -ay (or --activate y) option.
 
 Command to activate a thin snapshot LV:
 .br
-.B lvchange \-ay \-K VG/SnapLV
+.B lvchange -ay -K VG/SnapLV
 
 The persistent "activation skip" flag can be turned off during
-lvcreate, or later with lvchange using the \-kn
-(or \-\-setactivationskip n) option.
-It can be turned on again with \-ky (or \-\-setactivationskip y).
+lvcreate, or later with lvchange using the -kn
+(or --setactivationskip n) option.
+It can be turned on again with -ky (or --setactivationskip y).
 
 When the "activation skip" flag is removed, normal activation
-commands will activate the LV, and the \-K activation option is
+commands will activate the LV, and the -K activation option is
 not needed.
 
 Command to create snapshot LV without the activation skip flag:
 .br
-.B lvcreate \-kn \-n SnapLV \-s VG/ThinLV
+.B lvcreate -kn -n SnapLV -s VG/ThinLV
 
 Command to remove the activation skip flag from a snapshot LV:
 .br
-.B lvchange \-kn VG/SnapLV
+.B lvchange -kn VG/SnapLV
 
 .BR lvm.conf (5)
 .B auto_set_activation_skip
@@ -531,7 +531,7 @@ the thin pool LV.
 
 Command to extend thin pool data space:
 .br
-.B lvextend \-L Size VG/ThinPoolLV
+.B lvextend -L Size VG/ThinPoolLV
 
 .I Example
 .br
@@ -539,15 +539,15 @@ Command to extend thin pool data space:
 1. A thin pool LV is using 26.96% of its data blocks.
 # lvs
   LV    VG           Attr       LSize   Pool  Origin Data%
-  pool0 vg           twi\-a\-tz\-\-  10.00g               26.96
+  pool0 vg           twi-a-tz--  10.00g               26.96
 
 2. Double the amount of physical space in the thin pool LV.
-# lvextend \-L+10G vg/pool0
+# lvextend -L+10G vg/pool0
 
 3. The percentage of used data blocks is half the previous value.
 # lvs
   LV    VG           Attr       LSize   Pool  Origin Data%
-  pool0 vg           twi\-a\-tz\-\-  20.00g               13.48
+  pool0 vg           twi-a-tz--  20.00g               13.48
 .fi
 
 Other methods of increasing free data space in a thin pool LV
@@ -560,38 +560,38 @@ fstrim on the file system using a thin LV.
 \&
 
 The available metadata space in a thin pool LV can be displayed
-with the lvs \-o+metadata_percent command.
+with the lvs -o+metadata_percent command.
 
 Command to extend thin pool metadata space:
 .br
-.B lvextend \-\-poolmetadatasize Size VG/ThinPoolLV
+.B lvextend --poolmetadatasize Size VG/ThinPoolLV
 
 .I Example
 .br
 1. A thin pool LV is using 12.40% of its metadata blocks.
 .nf
-# lvs \-oname,size,data_percent,metadata_percent vg/pool0
+# lvs -oname,size,data_percent,metadata_percent vg/pool0
   LV    LSize   Data%  Meta%
   pool0  20.00g  13.48  12.40
 .fi
 
 2. Display a thin pool LV with its component thin data LV and thin metadata LV.
 .nf
-# lvs \-a \-oname,attr,size vg
+# lvs -a -oname,attr,size vg
   LV              Attr       LSize
-  pool0           twi\-a\-tz\-\-  20.00g
-  [pool0_tdata]   Twi\-ao\-\-\-\-  20.00g
-  [pool0_tmeta]   ewi\-ao\-\-\-\-  12.00m
+  pool0           twi-a-tz--  20.00g
+  [pool0_tdata]   Twi-ao----  20.00g
+  [pool0_tmeta]   ewi-ao----  12.00m
 .fi
 
 3. Double the amount of physical space in the thin metadata LV.
 .nf
-# lvextend \-\-poolmetadatasize +12M vg/pool0
+# lvextend --poolmetadatasize +12M vg/pool0
 .fi
 
 4. The percentage of used metadata blocks is half the previous value.
 .nf
-# lvs \-a \-oname,size,data_percent,metadata_percent vg
+# lvs -a -oname,size,data_percent,metadata_percent vg
   LV              LSize   Data%  Meta%
   pool0            20.00g  13.48   6.20
   [pool0_tdata]    20.00g
@@ -619,38 +619,38 @@ of the file system by 1%.  Removing the 1G file restores the virtual
 thin pool.  The fstrim command restores the physical space to the thin pool.
 
 .nf
-# lvs \-a \-oname,attr,size,pool_lv,origin,data_percent,metadata_percent vg
+# lvs -a -oname,attr,size,pool_lv,origin,data_percent,metadata_percent vg
 LV              Attr       LSize   Pool  Origin Data%  Meta%
-pool0           twi\-a\-tz\-\-  10.00g               47.01  21.03
-thin1           Vwi\-aotz\-\- 100.00g pool0          2.70
+pool0           twi-a-tz--  10.00g               47.01  21.03
+thin1           Vwi-aotz-- 100.00g pool0          2.70
 
-# df \-h /mnt/X
+# df -h /mnt/X
 Filesystem            Size  Used Avail Use% Mounted on
-/dev/mapper/vg\-thin1   99G  1.1G   93G   2% /mnt/X
+/dev/mapper/vg-thin1   99G  1.1G   93G   2% /mnt/X
 
 # dd if=/dev/zero of=/mnt/X/1Gfile bs=4096 count=262144; sync
 
 # lvs
-pool0           vg   twi\-a\-tz\-\-  10.00g               57.01  25.26
-thin1           vg   Vwi\-aotz\-\- 100.00g pool0          3.70
+pool0           vg   twi-a-tz--  10.00g               57.01  25.26
+thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
 
-# df \-h /mnt/X
-/dev/mapper/vg\-thin1   99G  2.1G   92G   3% /mnt/X
+# df -h /mnt/X
+/dev/mapper/vg-thin1   99G  2.1G   92G   3% /mnt/X
 
 # rm /mnt/X/1Gfile
 
 # lvs
-pool0           vg   twi\-a\-tz\-\-  10.00g               57.01  25.26
-thin1           vg   Vwi\-aotz\-\- 100.00g pool0          3.70
+pool0           vg   twi-a-tz--  10.00g               57.01  25.26
+thin1           vg   Vwi-aotz-- 100.00g pool0          3.70
 
-# df \-h /mnt/X
-/dev/mapper/vg\-thin1   99G  1.1G   93G   2% /mnt/X
+# df -h /mnt/X
+/dev/mapper/vg-thin1   99G  1.1G   93G   2% /mnt/X
 
-# fstrim \-v /mnt/X
+# fstrim -v /mnt/X
 
 # lvs
-pool0           vg   twi\-a\-tz\-\-  10.00g               47.01  21.03
-thin1           vg   Vwi\-aotz\-\- 100.00g pool0          2.70
+pool0           vg   twi-a-tz--  10.00g               47.01  21.03
+thin1           vg   Vwi-aotz-- 100.00g pool0          2.70
 .fi
 
 The "Discard" section covers an option for automatically freeing data
@@ -673,7 +673,7 @@ default.
 
 Command to start or stop dmeventd monitoring a thin pool LV:
 .br
-.B lvchange \-\-monitor {y|n} VG/ThinPoolLV
+.B lvchange --monitor {y|n} VG/ThinPoolLV
 
 The current dmeventd monitoring status of a thin pool LV can be displayed
 with the command lvs -o+seg_monitor.
@@ -714,7 +714,7 @@ lvm.conf monitoring setting.
 
 .IP \[bu]
 To activate or create a thin pool LV without interacting with dmeventd,
-the \-\-ignoremonitoring option can be used.  With this option, the command
+the --ignoremonitoring option can be used.  With this option, the command
 will not ask dmeventd to monitor the thin pool LV.
 
 .IP \[bu]
@@ -740,14 +740,14 @@ is all used (see the section "Automatically extend thin pool LV").  If
 thin pool data space is already exhausted, it can still be extended (see
 the section "Manually manage free data space of thin pool LV".)
 
-The behavior of a full thin pool is configurable with the \-\-errorwhenfull
+The behavior of a full thin pool is configurable with the --errorwhenfull
 y|n option to lvcreate or lvchange.  The errorwhenfull setting applies
 only to writes; reading thin LVs can continue even when data space is
 exhausted.
 
 Command to change the handling of a full thin pool:
 .br
-.B lvchange \-\-errorwhenfull {y|n} VG/ThinPoolLV
+.B lvchange --errorwhenfull {y|n} VG/ThinPoolLV
 
 .BR lvm.conf (5)
 .B error_when_full
@@ -773,11 +773,11 @@ return to normal operation.
 While waiting to be extended, the thin pool will queue writes for up to 60
 seconds (the default).  If data space has not been extended after this
 time, the queued writes will return an error to the caller, e.g. the file
-system.  This can result in file system corruption for non\-journaled file
+system.  This can result in file system corruption for non-journaled file
 systems that may require fsck.  When a thin pool returns errors for writes
 to a thin LV, any file system is subject to losing unsynced user data.
 
-The 60 second timeout can be changed or disabled with the dm\-thin\-pool
+The 60 second timeout can be changed or disabled with the dm-thin-pool
 kernel module option
 .B no_space_timeout.
 This option sets the number of seconds that thin pools will queue writes.
@@ -799,7 +799,7 @@ the thin pool LV:
 .nf
 # lvs vg/pool0
   LV     VG           Attr       LSize   Pool  Origin Data%
-  pool0  vg           twi\-a\-tz\-\- 512.00m              100.00
+  pool0  vg           twi-a-tz-- 512.00m              100.00
 .fi
 
 .I causes
@@ -836,7 +836,7 @@ When metadata space is exhausted, the lvs command displays 100 under Meta%
 for the thin pool LV:
 
 .nf
-# lvs \-o lv_name,size,data_percent,metadata_percent vg/pool0
+# lvs -o lv_name,size,data_percent,metadata_percent vg/pool0
   LV    LSize Data%  Meta%
   pool0              100.00
 .fi
@@ -850,11 +850,11 @@ repair.
 
 1. Deactivate the thin pool LV, or reboot the system if this is not possible.
 
-2. Repair thin pool with lvconvert \-\-repair.
+2. Repair thin pool with lvconvert --repair.
 .br
    See "Metadata check and repair".
 
-3. Extend pool metadata space with lvextend \-\-poolmetadatasize.
+3. Extend pool metadata space with lvextend --poolmetadatasize.
 .br
    See "Manually manage free metadata space of a thin pool LV".
 
@@ -872,7 +872,7 @@ these presets.  (See "Automatically extend thin pool LV".)
 
 Command to extend a thin pool data LV using presets:
 .br
-.B lvextend \-\-use\-policies VG/ThinPoolLV
+.B lvextend --use-policies VG/ThinPoolLV
 
 The command uses these settings:
 
@@ -888,12 +888,12 @@ autoextend the LV by this much additional space.
 
 To see the default values of these settings, run:
 
-.B lvmconfig \-\-type default \-\-withcomment
+.B lvmconfig --type default --withcomment
 .RS
 .B activation/thin_pool_autoextend_threshold
 .RE
 
-.B lvmconfig \-\-type default \-\-withcomment
+.B lvmconfig --type default --withcomment
 .RS
 .B activation/thin_pool_autoextend_percent
 .RE
@@ -901,7 +901,7 @@ To see the default values of these settings, run:
 To change these values globally, edit
 .BR lvm.conf (5).
 
-To change these values on a per\-VG or per\-LV basis, attach a "profile" to
+To change these values on a per-VG or per-LV basis, attach a "profile" to
 the VG or LV.  A profile is a collection of config settings, saved in a
 local text file (using the lvm.conf format).  lvm looks for profiles in
 the profile_dir directory, e.g. /etc/lvm/profile/.  Once attached to a VG
@@ -919,12 +919,12 @@ For the profile_dir location, run:
 .IP \[bu] 2
 Attach the profile to an LV, using the command:
 .br
-.B lvchange \-\-metadataprofile ProfileName VG/ThinPoolLV
+.B lvchange --metadataprofile ProfileName VG/ThinPoolLV
 
 .IP \[bu] 2
 Extend the LV using the profile settings:
 .br
-.B lvextend \-\-use\-policies VG/ThinPoolLV
+.B lvextend --use-policies VG/ThinPoolLV
 
 .P
 
@@ -940,9 +940,9 @@ activation {
         thin_pool_autoextend_percent=10
 }
 
-# lvchange \-\-metadataprofile pool0extend vg/pool0
+# lvchange --metadataprofile pool0extend vg/pool0
 
-# lvextend \-\-use\-policies vg/pool0
+# lvextend --use-policies vg/pool0
 .fi
 
 .I Notes
@@ -954,7 +954,7 @@ file with the profile also needs to be moved.
 .IP \[bu] 2
 Only certain settings can be used in a VG or LV profile, see:
 .br
-.B lvmconfig \-\-type profilable\-metadata.
+.B lvmconfig --type profilable-metadata.
 
 .IP \[bu] 2
 An LV without a profile of its own will inherit the VG profile.
@@ -962,14 +962,14 @@ An LV without a profile of its own will inherit the VG profile.
 .IP \[bu] 2
 Remove a profile from an LV using the command:
 .br
-.B lvchange \-\-detachprofile VG/ThinPoolLV.
+.B lvchange --detachprofile VG/ThinPoolLV.
 
 .IP \[bu] 2
 Commands can also have profiles applied to them.  The settings that can be
 applied to a command are different than the settings that can be applied
-to a VG or LV.  See lvmconfig \-\-type profilable\-command.  To apply a
+to a VG or LV.  See lvmconfig --type profilable-command.  To apply a
 profile to a command, write a profile, save it in the profile directory,
-and run the command using the option: \-\-commandprofile ProfileName.
+and run the command using the option: --commandprofile ProfileName.
 
 
 .SS Zeroing
@@ -978,20 +978,20 @@ and run the command using the option: \-\-commandprofile ProfileName.
 
 When a thin pool provisions a new data block for a thin LV, the
 new block is first overwritten with zeros.  The zeroing mode is
-indicated by the "z" attribute displayed by lvs.  The option \-Z
-(or \-\-zero) can be added to commands to specify the zeroing mode.
+indicated by the "z" attribute displayed by lvs.  The option -Z
+(or --zero) can be added to commands to specify the zeroing mode.
 
 Command to set the zeroing mode when creating a thin pool LV:
 .br
-.B lvconvert \-\-type thin\-pool \-Z{y|n}
+.B lvconvert --type thin-pool -Z{y|n}
 .br
 .RS
-.B \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B --poolmetadata VG/ThinMetaLV VG/ThinDataLV
 .RE
 
 Command to change the zeroing mode of an existing thin pool LV:
 .br
-.B lvchange \-Z{y|n} VG/ThinPoolLV
+.B lvchange -Z{y|n} VG/ThinPoolLV
 
 If zeroing mode is changed from "n" to "y", previously provisioned
 blocks are not zeroed.
@@ -1024,27 +1024,27 @@ mode.
 
 Command to display the current discard mode of a thin pool LV:
 .br
-.B lvs \-o+discards VG/ThinPoolLV
+.B lvs -o+discards VG/ThinPoolLV
 
 Command to set the discard mode when creating a thin pool LV:
 .br
-.B lvconvert \-\-discards {ignore|nopassdown|passdown}
+.B lvconvert --discards {ignore|nopassdown|passdown}
 .br
 .RS
-.B \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
+.B --type thin-pool --poolmetadata VG/ThinMetaLV VG/ThinDataLV
 .RE
 
 Command to change the discard mode of an existing thin pool LV:
 .br
-.B lvchange \-\-discards {ignore|nopassdown|passdown} VG/ThinPoolLV
+.B lvchange --discards {ignore|nopassdown|passdown} VG/ThinPoolLV
 
 .I Example
 .br
 .nf
-# lvs \-o name,discards vg/pool0
+# lvs -o name,discards vg/pool0
 pool0 passdown
 
-# lvchange \-\-discards ignore vg/pool0
+# lvchange --discards ignore vg/pool0
 .fi
 
 .BR lvm.conf (5)
@@ -1058,7 +1058,7 @@ controls the default discards mode used when creating a thin pool.
 \&
 
 The size of data blocks managed by a thin pool can be specified with the
-\-\-chunksize option when the thin pool LV is created.  The default unit
+--chunksize option when the thin pool LV is created.  The default unit
 is KiB. The value must be a multiple of 64KiB between 64KiB and 1GiB.
 
 When a thin pool is used primarily for the thin provisioning feature, a
@@ -1067,12 +1067,12 @@ reduces copying time and consumes less space.
 
 Command to display the thin pool LV chunk size:
 .br
-.B lvs \-o+chunksize VG/ThinPoolLV
+.B lvs -o+chunksize VG/ThinPoolLV
 
 .I Example
 .br
 .nf
-# lvs \-o name,chunksize
+# lvs -o name,chunksize
   pool0 64.00k
 .fi
 
@@ -1083,7 +1083,7 @@ controls the default chunk size used when creating a thin pool.
 
 The default value is shown by:
 .br
-.B lvmconfig \-\-type default allocation/thin_pool_chunk_size
+.B lvmconfig --type default allocation/thin_pool_chunk_size
 
 
 .SS Size of pool metadata LV
@@ -1096,10 +1096,10 @@ need a larger metadata LV.  Thin pool metadata LV sizes can be from 2MiB
 to 16GiB.
 
 When using lvcreate to create what will become a thin metadata LV, the
-size is specified with the \-L|\-\-size option.
+size is specified with the -L|--size option.
 
 When an LVM command automatically creates a thin metadata LV, the size is
-specified with the \-\-poolmetadatasize option.  When this option is not
+specified with the --poolmetadatasize option.  When this option is not
 given, LVM automatically chooses a size based on the data size and chunk
 size.
 
@@ -1119,19 +1119,19 @@ to take thin snapshots of external, read only LVs.  Writes to the
 snapshot are stored in the thin pool, and the external LV is used
 to read unwritten parts of the thin snapshot.
 
-.B lvcreate \-n SnapLV \-s VG/ExternalOriginLV \-\-thinpool VG/ThinPoolLV
+.B lvcreate -n SnapLV -s VG/ExternalOriginLV --thinpool VG/ThinPoolLV
 
 .I Example
 .br
 .nf
-# lvchange \-an vg/lve
-# lvchange \-\-permission r vg/lve
-# lvcreate \-n snaplve \-s vg/lve \-\-thinpool vg/pool0
+# lvchange -an vg/lve
+# lvchange --permission r vg/lve
+# lvcreate -n snaplve -s vg/lve --thinpool vg/pool0
 
 # lvs vg/lve vg/snaplve
   LV      VG  Attr       LSize  Pool  Origin Data%
-  lve     vg  ori\-\-\-\-\-\-\- 10.00g
-  snaplve vg  Vwi\-a\-tz\-\- 10.00g pool0 lve      0.00
+  lve     vg  ori------- 10.00g
+  snaplve vg  Vwi-a-tz-- 10.00g pool0 lve      0.00
 .fi
 
 
@@ -1144,34 +1144,34 @@ standard LV.  At the same time, the existing LV is converted to a
 read only external LV with a new name.  Unwritten portions of the
 thin LV are read from the external LV.
 The new name given to the existing LV can be specified with
-\-\-originname, otherwise the existing LV will be given a default
+--originname, otherwise the existing LV will be given a default
 name, e.g. lvol#.
 
 Convert ExampleLV into a read only external LV with the new name
 NewExternalOriginLV, and create a new thin LV that is given the previous
 name of ExampleLV.
 
-.B lvconvert \-\-type thin \-\-thinpool VG/ThinPoolLV
+.B lvconvert --type thin --thinpool VG/ThinPoolLV
 .br
 .RS
-.B \-\-originname NewExternalOriginLV VG/ExampleLV
+.B --originname NewExternalOriginLV VG/ExampleLV
 .RE
 
 .I Example
 .br
 .nf
-# lvcreate \-n lv_example \-L 10G vg
+# lvcreate -n lv_example -L 10G vg
 
 # lvs
-  lv_example      vg          -wi\-a\-\-\-\-\-  10.00g
+  lv_example      vg          -wi-a-----  10.00g
 
-# lvconvert \-\-type thin \-\-thinpool vg/pool0
-          \-\-originname lv_external \-\-thin vg/lv_example
+# lvconvert --type thin --thinpool vg/pool0
+          --originname lv_external --thin vg/lv_example
 
 # lvs
   LV              VG          Attr       LSize   Pool  Origin
-  lv_example      vg          Vwi\-a\-tz\-\-  10.00g pool0 lv_external
-  lv_external     vg          ori\-\-\-\-\-\-\-  10.00g
+  lv_example      vg          Vwi-a-tz--  10.00g pool0 lv_external
+  lv_external     vg          ori-------  10.00g
 .fi
 
 
@@ -1184,21 +1184,21 @@ rather than using lvconvert on existing LVs.
 This one command creates a thin data LV, a thin metadata LV,
 and combines the two into a thin pool LV.
 
-.B lvcreate \-\-type thin\-pool \-L LargeSize \-n ThinPoolLV VG
+.B lvcreate --type thin-pool -L LargeSize -n ThinPoolLV VG
 
 .I Example
 .br
 .nf
-# lvcreate \-\-type thin\-pool \-L8M -n pool0 vg
+# lvcreate --type thin-pool -L8M -n pool0 vg
 
 # lvs vg/pool0
   LV    VG  Attr       LSize Pool Origin Data%
-  pool0 vg  twi\-a\-tz\-\- 8.00m               0.00
+  pool0 vg  twi-a-tz-- 8.00m               0.00
 
-# lvs \-a
-  pool0           vg          twi\-a\-tz\-\-   8.00m
-  [pool0_tdata]   vg          Twi\-ao\-\-\-\-   8.00m
-  [pool0_tmeta]   vg          ewi\-ao\-\-\-\-   8.00m
+# lvs -a
+  pool0           vg          twi-a-tz--   8.00m
+  [pool0_tdata]   vg          Twi-ao----   8.00m
+  [pool0_tmeta]   vg          ewi-ao----   8.00m
 .fi
 
 
@@ -1211,31 +1211,31 @@ lvcreate command.  This one command creates a thin data LV,
 a thin metadata LV, combines the two into a thin pool LV,
 and creates a thin LV in the new pool.
 .br
-\-L LargeSize specifies the physical size of the thin pool LV.
+-L LargeSize specifies the physical size of the thin pool LV.
 .br
-\-V VirtualSize specifies the virtual size of the thin LV.
+-V VirtualSize specifies the virtual size of the thin LV.
 
-.B lvcreate \-\-type thin \-V VirtualSize \-L LargeSize
+.B lvcreate --type thin -V VirtualSize -L LargeSize
 .RS
-.B \-n ThinLV \-\-thinpool VG/ThinPoolLV
+.B -n ThinLV --thinpool VG/ThinPoolLV
 .RE
 
 Equivalent to:
 .br
-.B lvcreate \-\-type thin\-pool \-L LargeSize VG/ThinPoolLV
+.B lvcreate --type thin-pool -L LargeSize VG/ThinPoolLV
 .br
-.B lvcreate \-n ThinLV \-V VirtualSize \-\-thinpool VG/ThinPoolLV
+.B lvcreate -n ThinLV -V VirtualSize --thinpool VG/ThinPoolLV
 
 .I Example
 .br
 .nf
-# lvcreate \-L8M \-V2G \-n thin1 \-\-thinpool vg/pool0
+# lvcreate -L8M -V2G -n thin1 --thinpool vg/pool0
 
-# lvs \-a
-  pool0           vg          twi\-a\-tz\-\-   8.00m
-  [pool0_tdata]   vg          Twi\-ao\-\-\-\-   8.00m
-  [pool0_tmeta]   vg          ewi\-ao\-\-\-\-   8.00m
-  thin1           vg          Vwi\-a\-tz\-\-   2.00g pool0
+# lvs -a
+  pool0           vg          twi-a-tz--   8.00m
+  [pool0_tdata]   vg          Twi-ao----   8.00m
+  [pool0_tmeta]   vg          ewi-ao----   8.00m
+  thin1           vg          Vwi-a-tz--   2.00g pool0
 .fi
 
 
@@ -1244,7 +1244,7 @@ Equivalent to:
 \&
 
 A thin snapshot can be merged into its origin thin LV using the lvconvert
-\-\-merge command.  The result of a snapshot merge is that the origin thin
+--merge command.  The result of a snapshot merge is that the origin thin
 LV takes the content of the snapshot LV, and the snapshot LV is removed.
 Any content that was unique to the origin thin LV is lost after the merge.
 
@@ -1253,23 +1253,23 @@ LVs are open, e.g. mounted.  If a merge is initiated while the LVs are open,
 the effect of the merge is delayed until the origin thin LV is next
 activated.
 
-.B lvconvert \-\-merge VG/SnapLV
+.B lvconvert --merge VG/SnapLV
 
 .I Example
 .br
 .nf
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
-  pool0   vg twi\-a\-tz\-\-  10.00g
-  thin1   vg Vwi\-a\-tz\-\- 100.00g pool0
-  thin1s1 vg Vwi\-a\-tz\-k 100.00g pool0 thin1
+  pool0   vg twi-a-tz--  10.00g
+  thin1   vg Vwi-a-tz-- 100.00g pool0
+  thin1s1 vg Vwi-a-tz-k 100.00g pool0 thin1
 
-# lvconvert \-\-merge vg/thin1s1
+# lvconvert --merge vg/thin1s1
 
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
-  pool0   vg twi\-a\-tz\-\-  10.00g
-  thin1   vg Vwi\-a\-tz\-\- 100.00g pool0
+  pool0   vg twi-a-tz--  10.00g
+  thin1   vg Vwi-a-tz-- 100.00g pool0
 .fi
 
 .I Example
@@ -1279,20 +1279,20 @@ Delayed merging of open LVs.
 
 # lvs vg
   LV      VG Attr       LSize   Pool  Origin
-  pool0   vg twi\-a\-tz\-\-  10.00g
-  thin1   vg Vwi\-aotz\-\- 100.00g pool0
-  thin1s1 vg Vwi\-aotz\-k 100.00g pool0 thin1
+  pool0   vg twi-a-tz--  10.00g
+  thin1   vg Vwi-aotz-- 100.00g pool0
+  thin1s1 vg Vwi-aotz-k 100.00g pool0 thin1
 
 # df
-/dev/mapper/vg\-thin1            100G   33M  100G   1% /mnt/X
-/dev/mapper/vg\-thin1s1          100G   33M  100G   1% /mnt/Xs
+/dev/mapper/vg-thin1            100G   33M  100G   1% /mnt/X
+/dev/mapper/vg-thin1s1          100G   33M  100G   1% /mnt/Xs
 
 # ls /mnt/X
 file1 file2 file3
 # ls /mnt/Xs
 file3 file4 file5
 
-# lvconvert \-\-merge vg/thin1s1
+# lvconvert --merge vg/thin1s1
 Logical volume vg/thin1s1 contains a filesystem in use.
 Delaying merge since snapshot is open.
 Merging of thin snapshot thin1s1 will occur on next activation.
@@ -1300,16 +1300,16 @@ Merging of thin snapshot thin1s1 will occur on next activation.
 # umount /mnt/X
 # umount /mnt/Xs
 
-# lvs \-a vg
+# lvs -a vg
   LV              VG   Attr       LSize   Pool  Origin
-  pool0           vg   twi\-a\-tz\-\-  10.00g
-  [pool0_tdata]   vg   Twi\-ao\-\-\-\-  10.00g
-  [pool0_tmeta]   vg   ewi\-ao\-\-\-\-   1.00g
-  thin1           vg   Owi\-a\-tz\-\- 100.00g pool0
-  [thin1s1]       vg   Swi\-a\-tz\-k 100.00g pool0 thin1
+  pool0           vg   twi-a-tz--  10.00g
+  [pool0_tdata]   vg   Twi-ao----  10.00g
+  [pool0_tmeta]   vg   ewi-ao----   1.00g
+  thin1           vg   Owi-a-tz-- 100.00g pool0
+  [thin1s1]       vg   Swi-a-tz-k 100.00g pool0 thin1
 
-# lvchange \-an vg/thin1
-# lvchange \-ay vg/thin1
+# lvchange -an vg/thin1
+# lvchange -ay vg/thin1
 
 # mount /dev/vg/thin1 /mnt/X
 
@@ -1330,18 +1330,18 @@ file system on the origin LV.
 If the snapshot LV is writable, mounting will recover the log to clear the
 dummy transaction, but will require skipping the uuid check:
 
-mount /dev/VG/SnapLV /mnt \-o nouuid
+mount /dev/VG/SnapLV /mnt -o nouuid
 
 Or, the uuid can be changed on disk before mounting:
 
-xfs_admin \-U generate /dev/VG/SnapLV
+xfs_admin -U generate /dev/VG/SnapLV
 .br
 mount /dev/VG/SnapLV /mnt
 
 If the snapshot LV is readonly, the log recovery and uuid check need to be
 skipped while mounting readonly:
 
-mount /dev/VG/SnapLV /mnt \-o ro,nouuid,norecovery
+mount /dev/VG/SnapLV /mnt -o ro,nouuid,norecovery
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/man/lvreduce.8_des b/man/lvreduce.8_des
index d9e840e..af67358 100644
--- a/man/lvreduce.8_des
+++ b/man/lvreduce.8_des
@@ -1,5 +1,5 @@
 lvreduce reduces the size of an LV. The freed logical extents are returned
-to the VG to be used by other LVs. A copy\-on\-write snapshot LV can also
+to the VG to be used by other LVs. A copy-on-write snapshot LV can also
 be reduced if less space is needed to hold COW blocks. Use
 \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
@@ -13,6 +13,6 @@ Sizes will be rounded if necessary. For example, the LV size must be an
 exact number of extents, and the size of a striped segment must be a
 multiple of the number of stripes.
 
-In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
-with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB--size\fP \fISize\fP can be replaced
+with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
diff --git a/man/lvreduce.8_end b/man/lvreduce.8_end
index 59fde52..53f1ac7 100644
--- a/man/lvreduce.8_end
+++ b/man/lvreduce.8_end
@@ -2,4 +2,4 @@
 
 Reduce the size of an LV by 3 logical extents:
 .br
-.B lvreduce \-l \-3 vg00/lvol1
+.B lvreduce -l -3 vg00/lvol1
diff --git a/man/lvremove.8_end b/man/lvremove.8_end
index 835b711..e746015 100644
--- a/man/lvremove.8_end
+++ b/man/lvremove.8_end
@@ -1,7 +1,7 @@
 .SH EXAMPLES
 Remove an active LV without asking for confirmation.
 .br
-.B lvremove \-f vg00/lvol1
+.B lvremove -f vg00/lvol1
 
 Remove all LVs the specified VG.
 .br
diff --git a/man/lvresize.8_des b/man/lvresize.8_des
index 4e80281..dcc42aa 100644
--- a/man/lvresize.8_des
+++ b/man/lvresize.8_des
@@ -1,6 +1,6 @@
 lvresize resizes an LV in the same way as lvextend and lvreduce. See
 \fBlvextend\fP(8) and \fBlvreduce\fP(8) for more information.
 
-In the usage section below, \fB\-\-size\fP \fISize\fP can be replaced
-with \fB\-\-extents\fP \fINumber\fP.  See both descriptions
+In the usage section below, \fB--size\fP \fISize\fP can be replaced
+with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
diff --git a/man/lvresize.8_end b/man/lvresize.8_end
index 9ae0a2a..563ea57 100644
--- a/man/lvresize.8_end
+++ b/man/lvresize.8_end
@@ -2,4 +2,4 @@
 
 Extend an LV by 16MB using specific physical extents:
 .br
-.B lvresize \-L+16M vg1/lv1 /dev/sda:0\-1 /dev/sdb:0\-1
+.B lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1
diff --git a/man/pvchange.8_end b/man/pvchange.8_end
index a524d07..f1cac15 100644
--- a/man/pvchange.8_end
+++ b/man/pvchange.8_end
@@ -3,4 +3,4 @@
 Disallow the allocation of physical extents on a PV (e.g. because of
 disk errors, or because it will be removed after freeing it).
 .br
-.B pvchange \-x n /dev/sdk1
+.B pvchange -x n /dev/sdk1
diff --git a/man/pvck.8_end b/man/pvck.8_end
index 67af238..4b9c6d0 100644
--- a/man/pvck.8_end
+++ b/man/pvck.8_end
@@ -2,7 +2,7 @@
 
 If the partition table is corrupted or lost on /dev/sda, and you suspect
 there was an LVM partition at approximately 100 MiB, then this
-area of the disk can be scanned using the \fB\-\-labelsector\fP
+area of the disk can be scanned using the \fB--labelsector\fP
 parameter with a value of 204800 (100 * 1024 * 1024 / 512 = 204800).
 .br
-.B pvck \-\-labelsector 204800 /dev/sda
+.B pvck --labelsector 204800 /dev/sda
diff --git a/man/pvcreate.8_end b/man/pvcreate.8_end
index 478abe3..e89decd 100644
--- a/man/pvcreate.8_end
+++ b/man/pvcreate.8_end
@@ -9,4 +9,4 @@ partitioning (sector 7 is the lowest aligned logical block, the 4KiB
 sectors start at LBA -1, and consequently sector 63 is aligned on a 4KiB
 boundary) manually account for this when initializing for use by LVM.
 .br
-.B pvcreate \-\-dataalignmentoffset 7s /dev/sdb
+.B pvcreate --dataalignmentoffset 7s /dev/sdb
diff --git a/man/pvmove.8_end b/man/pvmove.8_end
index 68f6ef5..8259b3f 100644
--- a/man/pvmove.8_end
+++ b/man/pvmove.8_end
@@ -33,7 +33,7 @@ Note that this new process cannot support the original LVM1
 type of on-disk metadata.  Metadata can be converted using
 \fBvgconvert\fP(8).
 
-If the \fB\-\-atomic\fP option is used, a slightly different approach is
+If the \fB--atomic\fP option is used, a slightly different approach is
 used for the move.  Again, a temporary 'pvmove' LV is created to store the
 details of all the data movements required.  This temporary LV contains
 all the segments of the various LVs that need to be moved.  However, in
@@ -57,13 +57,13 @@ Use a specific destination PV when moving physical extents.
 
 Move extents belonging to a single LV.
 .br
-.B pvmove \-n lvol1 /dev/sdb1 /dev/sdc1
+.B pvmove -n lvol1 /dev/sdb1 /dev/sdc1
 
 Rather than moving the contents of an entire device, it is possible to
 move a range of physical extents, for example numbers 1000 to 1999
 inclusive on the specified PV.
 .br
-.B pvmove /dev/sdb1:1000\-1999
+.B pvmove /dev/sdb1:1000-1999
 
 A range of physical extents to move can be specified as start+length. For
 example, starting from PE 1000. (Counting starts from 0, so this refers to the
@@ -74,18 +74,18 @@ example, starting from PE 1000. (Counting starts from 0, so this refers to the
 Move a range of physical extents to a specific PV (which must have
 sufficient free extents).
 .br
-.B pvmove /dev/sdb1:1000\-1999 /dev/sdc1
+.B pvmove /dev/sdb1:1000-1999 /dev/sdc1
 
 Move a range of physical extents to specific new extents on a new PV.
 .br
-.B pvmove /dev/sdb1:1000\-1999 /dev/sdc1:0\-999
+.B pvmove /dev/sdb1:1000-1999 /dev/sdc1:0-999
 
 If the source and destination are on the same disk, the
 \fBanywhere\fP allocation policy is needed.
 .br
-.B pvmove \-\-alloc anywhere /dev/sdb1:1000\-1999 /dev/sdb1:0\-999
+.B pvmove --alloc anywhere /dev/sdb1:1000-1999 /dev/sdb1:0-999
 
 The part of a specific LV present within in a range of physical
 extents can also be picked out and moved.
 .br
-.B pvmove \-n lvol1 /dev/sdb1:1000\-1999 /dev/sdc1
+.B pvmove -n lvol1 /dev/sdb1:1000-1999 /dev/sdc1
diff --git a/man/pvresize.8_end b/man/pvresize.8_end
index bedc334..a347e4a 100644
--- a/man/pvresize.8_end
+++ b/man/pvresize.8_end
@@ -9,4 +9,4 @@ Expand a PV after enlarging the partition.
 Shrink a PV prior to shrinking the partition (ensure that the PV size is
 appropriate for the intended new partition size).
 .br
-.B pvresize \-\-setphysicalvolumesize 40G /dev/sda1
+.B pvresize --setphysicalvolumesize 40G /dev/sda1
diff --git a/man/pvscan.8_des b/man/pvscan.8_des
index 14551ce..d6b554e 100644
--- a/man/pvscan.8_des
+++ b/man/pvscan.8_des
@@ -20,25 +20,25 @@ commands.
 When lvmetad is used, LVM commands avoid scanning disks by reading
 metadata from lvmetad.  When new disks appear, they must be scanned so
 their metadata can be cached in lvmetad.  This is done by the command
-pvscan \-\-cache, which scans disks and passes the metadata to lvmetad.
+pvscan --cache, which scans disks and passes the metadata to lvmetad.
 
-The pvscan \-\-cache command is typically run automatically by system
+The pvscan --cache command is typically run automatically by system
 services when a new device appears.  Users do not generally need to run
 this command if the system and lvmetad are running properly.
 
 Many scripts contain unnecessary pvscan (or vgscan) commands for
 historical reasons.  To avoid disrupting the system with extraneous disk
-scanning, an ordinary pvscan (without \-\-cache) will simply read metadata
+scanning, an ordinary pvscan (without --cache) will simply read metadata
 from lvmetad like other LVM commands.  It does not do anything beyond
 displaying the current state of the cache.
 .IP \[bu] 2
-When given specific device name arguments, pvscan \-\-cache will only
+When given specific device name arguments, pvscan --cache will only
 read the named devices.
 .IP \[bu] 2
 LVM udev rules and systemd services are used to initiate automatic device
 scanning.
 .IP \[bu] 2
-To prevent devices from being scanned by pvscan \-\-cache, add them
+To prevent devices from being scanned by pvscan --cache, add them
 to
 .BR lvm.conf (5)
 .B devices/global_filter.
@@ -46,11 +46,11 @@ The devices/filter setting does not
 apply to system level scanning.
 For more information, see:
 .br
-.B lvmconfig \-\-withcomments devices/global_filter
+.B lvmconfig --withcomments devices/global_filter
 .IP \[bu] 2
 If lvmetad is started or restarted after devices are visible, or
 if the global_filter has changed, then all devices must be rescanned
-for metadata with the command pvscan \-\-cache.
+for metadata with the command pvscan --cache.
 .IP \[bu] 2
 lvmetad does not cache older metadata formats, e.g. lvm1, and will
 be temporarily disabled if they are seen.
@@ -62,9 +62,9 @@ minor numbers must be given, not the path.
 
 When event-driven system services detect a new LVM device, the first step
 is to automatically scan and cache the metadata from the device.  This is
-done by pvscan \-\-cache.  A second step is to automatically activate LVs
+done by pvscan --cache.  A second step is to automatically activate LVs
 that are present on the new device.  This auto-activation is done by the
-same pvscan \-\-cache command when the option '\-a|\-\-activate ay' is
+same pvscan --cache command when the option '-a|--activate ay' is
 included.
 
 Auto-activation of VGs or LVs can be enabled/disabled using:
@@ -74,17 +74,17 @@ Auto-activation of VGs or LVs can be enabled/disabled using:
 
 For more information, see:
 .br
-.B lvmconfig \-\-withcomments activation/auto_activation_volume_list
+.B lvmconfig --withcomments activation/auto_activation_volume_list
 
 When this setting is undefined, all LVs are auto-activated (when lvm is
 fully integrated with the event-driven system services.)
 
 When a VG or LV is not auto-activated, traditional activation using
-vgchange or lvchange -a|\-\-activate is needed.
+vgchange or lvchange -a|--activate is needed.
 .IP \[bu] 2
-pvscan auto-activation can be only done in combination with \-\-cache.
+pvscan auto-activation can be only done in combination with --cache.
 .IP \[bu] 2
-Auto-activation is designated by the "a" argument in '-a|\-\-activate ay'.
+Auto-activation is designated by the "a" argument in '-a|--activate ay'.
 This is meant to distinguish system generated commands from explicit user
 commands, although it can be used in any activation command.  Whenever it
 is used, the auto_activation_volume_list is applied.
diff --git a/man/vgcfgbackup.8_des b/man/vgcfgbackup.8_des
index 0720e01..f96fad3 100644
--- a/man/vgcfgbackup.8_des
+++ b/man/vgcfgbackup.8_des
@@ -6,7 +6,7 @@ files.
 In a default installation, each VG is backed up into a separate file
 bearing the name of the VG in the directory \fI#DEFAULT_BACKUP_DIR#\fP.
 
-To use an alternative back up file, use \fB\-f\fP. In this case, when
+To use an alternative back up file, use \fB-f\fP. In this case, when
 backing up multiple VGs, the file name is treated as a template, with %s
 replaced by the VG name.
 
diff --git a/man/vgcfgrestore.8_des b/man/vgcfgrestore.8_des
index ee3a99e..b79e2ef 100644
--- a/man/vgcfgrestore.8_des
+++ b/man/vgcfgrestore.8_des
@@ -2,8 +2,8 @@ vgcfgrestore restores the metadata of a VG from a text back up file
 produced by \fBvgcfgbackup\fP. This writes VG metadata onto the devices
 specifed in back up file.
 
-A back up file can be specified with \fB\-\-file\fP.  If no backup file is
-specified, the most recent one is used. Use \fB\-\-list\fP for a list of
+A back up file can be specified with \fB--file\fP.  If no backup file is
+specified, the most recent one is used. Use \fB--list\fP for a list of
 the available back up and archive files of a VG.
 
 WARNING: When a VG contains thin pools, changes to thin metadata cannot be
diff --git a/man/vgcfgrestore.8_end b/man/vgcfgrestore.8_end
index 5ac451d..ffcb3ee 100644
--- a/man/vgcfgrestore.8_end
+++ b/man/vgcfgrestore.8_end
@@ -1,9 +1,9 @@
 .SH NOTES
 
-To replace PVs, \fBvgdisplay \-\-partial \-\-verbose\fP will show the
+To replace PVs, \fBvgdisplay --partial --verbose\fP will show the
 UUIDs and sizes of any PVs that are no longer present. If a PV in the VG
 is lost and you wish to substitute another of the same size, use
-\fBpvcreate \-\-restorefile filename \-\-uuid uuid\fP (plus additional
+\fBpvcreate --restorefile filename --uuid uuid\fP (plus additional
 arguments as appropriate) to initialise it with the same UUID as the
 missing PV. Repeat for all other missing PVs in the VG.  Then use
-\fBvgcfgrestore \-\-file filename\fP to restore the VG's metadata.
+\fBvgcfgrestore --file filename\fP to restore the VG's metadata.
diff --git a/man/vgchange.8_end b/man/vgchange.8_end
index 6cf9e87..828a707 100644
--- a/man/vgchange.8_end
+++ b/man/vgchange.8_end
@@ -5,8 +5,8 @@ snapshots should be removed.
 .SH EXAMPLES
 Activate all LVs in all VGs on all existing devices.
 .br
-.B vgchange \-a y
+.B vgchange -a y
 
 Change the maximum number of LVs for an inactive VG.
 .br
-.B vgchange \-l 128 vg00
+.B vgchange -l 128 vg00
diff --git a/man/vgextend.8_des b/man/vgextend.8_des
index 85fe6fc..cee2d1e 100644
--- a/man/vgextend.8_des
+++ b/man/vgextend.8_des
@@ -3,9 +3,9 @@ for LVs in the VG.
 
 Also, PVs that have gone missing and then returned, e.g. due to a
 transient device failure, can be added back to the VG without
-re-initializing them (see \-\-restoremissing).
+re-initializing them (see --restoremissing).
 
 If the specified PVs have not yet been initialized with pvcreate, vgextend
 will initialize them. In this case pvcreate options can be used, e.g.
-\-\-labelsector, \-\-metadatasize, \-\-metadataignore,
-\-\-pvmetadatacopies, \-\-dataalignment, \-\-dataalignmentoffset.
+--labelsector, --metadatasize, --metadataignore,
+--pvmetadatacopies, --dataalignment, --dataalignmentoffset.
diff --git a/man/vgimportclone.8_end b/man/vgimportclone.8_end
index 4b236f6..68c57d4 100644
--- a/man/vgimportclone.8_end
+++ b/man/vgimportclone.8_end
@@ -5,4 +5,4 @@ The corresponding PVs from a hardware snapshot are "/dev/sdc" and "/dev/sdd".
 Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_snap"
 (and change associated UUIDs).
 .br
-.B vgimportclone \-\-basevgname vg00_snap /dev/sdc /dev/sdd
+.B vgimportclone --basevgname vg00_snap /dev/sdc /dev/sdd
diff --git a/man/vgmerge.8_end b/man/vgmerge.8_end
index b65d044..905492d 100644
--- a/man/vgmerge.8_end
+++ b/man/vgmerge.8_end
@@ -3,4 +3,4 @@
 Merge an inactive VG named "vg00" into the active or inactive VG named
 "databases", giving verbose runtime information.
 .br
-.B vgmerge \-v databases vg00
+.B vgmerge -v databases vg00
diff --git a/man/vgremove.8_des b/man/vgremove.8_des
index 6414c73..e87666f 100644
--- a/man/vgremove.8_des
+++ b/man/vgremove.8_des
@@ -2,7 +2,7 @@ vgremove removes one or more VGs. If LVs exist in the VG, a prompt is used
 to confirm LV removal.
 
 If one or more PVs in the VG are lost, consider
-\fBvgreduce \-\-removemissing\fP to make the VG
+\fBvgreduce --removemissing\fP to make the VG
 metadata consistent again.
 
 Repeat the force option (\fB-ff\fP) to forcibly remove LVs in the VG
diff --git a/man/vgrename.8_end b/man/vgrename.8_end
index 2d191cf..5cdd0d0 100644
--- a/man/vgrename.8_end
+++ b/man/vgrename.8_end
@@ -6,4 +6,4 @@ Rename VG "vg02" to "myvg":
 
 Rename the VG with the specified UUID to "myvg".
 .br
-.B vgrename Zvlifi\-Ep3t\-e0Ng\-U42h\-o0ye\-KHu1\-nl7Ns4 myvg
+.B vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 myvg
diff --git a/tools/args.h b/tools/args.h
index 77f3bf5..b81e2c9 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -22,7 +22,7 @@ arg(ARG_UNUSED, '-', "", 0, 0, 0, NULL)  /* place holder for unused 0 value */
 arg(abort_ARG, '\0', "abort", 0, 0, 0,
     "#pvmove\n"
     "Abort any pvmove operations in progress. If a pvmove was started\n"
-    "with the \\-\\-atomic option, then all LVs will remain on the source PV.\n"
+    "with the --atomic option, then all LVs will remain on the source PV.\n"
     "Otherwise, segments that have been moved will remain on the\n"
     "destination PV, while unmoved segments will remain on the source PV.\n"
     "#lvpoll\n"
@@ -45,7 +45,7 @@ arg(addtag_ARG, '\0', "addtag", tag_VAL, ARG_GROUPABLE, 0,
     "multiple tags at once. See lvm(8) for information about tags.\n")
 
 arg(aligned_ARG, '\0', "aligned", 0, 0, 0,
-    "Use with \\-\\-separator to align the output columns\n")
+    "Use with --separator to align the output columns\n")
 
 arg(alloc_ARG, '\0', "alloc", alloc_VAL, 0, 0,
     "Determines the allocation policy when a command needs to allocate\n"
@@ -88,11 +88,11 @@ arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", sizemb_VAL, 0, 0,
     "area. The bootloader area is an area of reserved space on the PV from\n"
     "which LVM will not allocate any extents and it's kept untouched. This is\n"
     "primarily aimed for use with bootloaders to embed their own data or metadata.\n"
-    "The start of the bootloader area is always aligned, see also \\-\\-dataalignment\n"
-    "and \\-\\-dataalignmentoffset. The bootloader area size may eventually\n"
+    "The start of the bootloader area is always aligned, see also --dataalignment\n"
+    "and --dataalignmentoffset. The bootloader area size may eventually\n"
     "end up increased due to the alignment, but it's never less than the\n"
     "size that is requested. To see the bootloader area start and size of\n"
-    "an existing PV use pvs \\-o +pv_ba_start,pv_ba_size.\n")
+    "an existing PV use pvs -o +pv_ba_start,pv_ba_size.\n")
 
 arg(cache_long_ARG, '\0', "cache", 0, 0, 0,
     "#pvscan\n"
@@ -141,8 +141,8 @@ arg(dataalignment_ARG, '\0', "dataalignment", sizekb_VAL, 0, 0,
     "Align the start of the data to a multiple of this number.\n"
     "Also specify an appropriate Physical Extent size when creating a VG.\n"
     "To see the location of the first Physical Extent of an existing PV,\n"
-    "use pvs \\-o +pe_start. In addition, it may be shifted by an alignment offset.\n"
-    "See lvm.conf/data_alignment_offset_detection and \\-\\-dataalignmentoffset.\n")
+    "use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.\n"
+    "See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.\n")
 
 arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", sizekb_VAL, 0, 0,
     "Shift the start of the data area by this additional offset.\n")
@@ -205,7 +205,7 @@ arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", 0, 0, 0,
     "operations after locking failures.\n")
 
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", 0, 0, 0,
-    "Do not interact with dmeventd unless \\-\\-monitor is specified.\n"
+    "Do not interact with dmeventd unless --monitor is specified.\n"
     "Do not use this if dmeventd is already monitoring a device.\n")
 
 arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", 0, 0, 0,
@@ -222,7 +222,7 @@ arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", 0, 0, 0,
 arg(labelsector_ARG, '\0', "labelsector", number_VAL, 0, 0,
     "By default the PV is labelled with an LVM2 identifier in its second\n"
     "sector (sector 1). This lets you use a different sector near the\n"
-    "start of the disk (between 0 and 3 inclusive \\- see LABEL_SCAN_SECTORS\n"
+    "start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS\n"
     "in the source). Use with care.\n")
 
 arg(lockopt_ARG, '\0', "lockopt", string_VAL, 0, 0,
@@ -244,7 +244,7 @@ arg(locktype_ARG, '\0', "locktype", locktype_VAL, 0, 0,
     "Change the VG lock type to or from a shared lock type used with lvmlockd.\n"
     "See lvmlockd(8) for more information.\n"
     "#vgcreate\n"
-    "Specify the VG lock type directly in place of using \\-\\-shared.\n"
+    "Specify the VG lock type directly in place of using --shared.\n"
     "See lvmlockd(8) for more information.\n")
 
 arg(logonly_ARG, '\0', "logonly", 0, 0, 0,
@@ -260,12 +260,12 @@ arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", sizekb_VAL, 0, 0,
     "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(merge_ARG, '\0', "merge", 0, 0, 0,
-    "An alias for \\-\\-mergethin, \\-\\-mergemirrors, or \\-\\-mergesnapshot,\n"
+    "An alias for --mergethin, --mergemirrors, or --mergesnapshot,\n"
     "depending on the type of LV.\n")
 
 arg(mergemirrors_ARG, '\0', "mergemirrors", 0, 0, 0,
     "Merge LV images that were split from a raid1 LV.\n"
-    "See \\-\\-splitmirrors with \\-\\-trackchanges.\n")
+    "See --splitmirrors with --trackchanges.\n")
 
 arg(mergesnapshot_ARG, '\0', "mergesnapshot", 0, 0, 0,
     "Merge COW snapshot LV into its origin.\n"
@@ -288,9 +288,9 @@ arg(mergethin_ARG, '\0', "mergethin", 0, 0, 0,
     "See \\fBlvmthin\\fP(7) for more information.\n")
 
 arg(mergedconfig_ARG, '\0', "mergedconfig", 0, 0, 0,
-    "When the command is run with \\-\\-config\n"
-    "and/or \\-\\-commandprofile (or using LVM_COMMAND_PROFILE\n"
-    "environment variable), \\-\\-profile, or \\-\\-metadataprofile,\n"
+    "When the command is run with --config\n"
+    "and/or --commandprofile (or using LVM_COMMAND_PROFILE\n"
+    "environment variable), --profile, or --metadataprofile,\n"
     "merge all the contents of the \"config cascade\" before displaying it.\n"
     "Without merging, only the configuration@the front of the\n"
     "cascade is displayed.\n"
@@ -349,7 +349,7 @@ arg(monitor_ARG, '\0', "monitor", bool_VAL, 0, 0,
 
 arg(nameprefixes_ARG, '\0', "nameprefixes", 0, 0, 0,
     "Add an \"LVM2_\" prefix plus the field name to the output. Useful\n"
-    "with \\-\\-noheadings to produce a list of field=value pairs that can\n"
+    "with --noheadings to produce a list of field=value pairs that can\n"
     "be used to set environment variables (for example, in udev rules).\n")
 
 arg(noheadings_ARG, '\0', "noheadings", 0, 0, 0,
@@ -365,11 +365,11 @@ arg(nolocking_ARG, '\0', "nolocking", 0, 0, 0,
     "Disable locking.\n")
 
 arg(norestorefile_ARG, '\0', "norestorefile", 0, 0, 0,
-    "In conjunction with \\-\\-uuid, this allows a uuid to be specified\n"
+    "In conjunction with --uuid, this allows a uuid to be specified\n"
     "without also requiring that a backup of the metadata be provided.\n")
 
 arg(nosuffix_ARG, '\0', "nosuffix", 0, 0, 0,
-    "Suppress the suffix on output sizes. Use with \\-\\-units\n"
+    "Suppress the suffix on output sizes. Use with --units\n"
     "(except h and H) if processing the output.\n")
 
 arg(nosync_ARG, '\0', "nosync", 0, 0, 0,
@@ -387,8 +387,8 @@ arg(nosync_ARG, '\0', "nosync", 0, 0, 0,
     "and thus do not support initial synchronization.\n")
 
 arg(notifydbus_ARG, '\0', "notifydbus", 0, 0, 0,
-    "Send a notification to D\\-Bus. The command will exit with an error\n"
-    "if LVM is not built with support for D\\offsetus notification, or if the\n"
+    "Send a notification to D-Bus. The command will exit with an error\n"
+    "if LVM is not built with support for D-Bus notification, or if the\n"
     "notify_dbus config setting is disabled.\n")
 
 arg(noudevsync_ARG, '\0', "noudevsync", 0, 0, 0,
@@ -409,11 +409,11 @@ arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", sizemb_VAL, 0, 0,
 arg(poll_ARG, '\0', "poll", bool_VAL, 0, 0,
     "When yes, start the background transformation of an LV.\n"
     "An incomplete transformation, e.g. pvmove or lvconvert interrupted\n"
-    "by reboot or crash, can be restarted from the last checkpoint with \\-\\-poll y.\n"
+    "by reboot or crash, can be restarted from the last checkpoint with --poll y.\n"
     "When no, background transformation of an LV will not occur, and the\n"
     "transformation will not complete. It may not be appropriate to immediately\n"
-    "poll an LV after activation, in which case \\-\\-poll n can be used to defer\n"
-    "polling until a later \\-\\-poll y command.\n")
+    "poll an LV after activation, in which case --poll n can be used to defer\n"
+    "polling until a later --poll y command.\n")
 
 arg(polloperation_ARG, '\0', "polloperation", polloperation_VAL, 0, 0,
     "The command to perform from lvmpolld.\n")
@@ -440,7 +440,7 @@ arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", bool_VAL, 0, 0,
     "space that can be used when repairing a pool.\n")
 
 arg(profile_ARG, '\0', "profile", string_VAL, 0, 0,
-    "An alias for \\-\\-commandprofile or \\-\\-metadataprofile, depending\n"
+    "An alias for --commandprofile or --metadataprofile, depending\n"
     "on the command.\n")
 
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", pvmetadatacopies_VAL, 0, 0,
@@ -475,7 +475,7 @@ arg(removemissing_ARG, '\0', "removemissing", 0, 0, 0,
     "on them. This resumes normal operation of the VG (new LVs may again\n"
     "be created, changed and so on).\n"
     "If this is not possible because LVs are referencing the missing PVs,\n"
-    "this option can be combined with \\-\\-force to have the command remove\n"
+    "this option can be combined with --force to have the command remove\n"
     "any partial LVs. In this case, any LVs and dependent snapshots that\n"
     "were partly on the missing disks are removed completely, including\n"
     "those parts on disks that are still present.\n"
@@ -485,7 +485,7 @@ arg(removemissing_ARG, '\0', "removemissing", 0, 0, 0,
 arg(rebuild_ARG, '\0', "rebuild", pv_VAL, ARG_GROUPABLE, 0,
     "Selects a PV to rebuild in a raid LV. Multiple PVs can be rebuilt by\n"
     "repeating this option.\n"
-    "Use this option in place of \\-\\-resync or \\-\\-syncaction repair when the\n"
+    "Use this option in place of --resync or --syncaction repair when the\n"
     "PVs with corrupted data are known, and their data should be reconstructed\n"
     "rather than reconstructing default (rotating) data.\n"
     "See \\fBlvmraid\\fP(7) for more information.\n")
@@ -510,7 +510,7 @@ arg(reportformat_ARG, '\0', "reportformat", reportformat_VAL, 0, 0,
     "output in JSON format. See \\fBlvmreport\\fP(7) for more information.\n")
 
 arg(restorefile_ARG, '\0', "restorefile", string_VAL, 0, 0,
-    "In conjunction with \\-\\-uuid, this reads the file (produced by\n"
+    "In conjunction with --uuid, this reads the file (produced by\n"
     "vgcfgbackup), extracts the location and size of the data on the PV,\n"
     "and ensures that the metadata produced by the program is consistent\n"
     "with the contents of the file, i.e. the physical extents will be in\n"
@@ -525,7 +525,7 @@ arg(restoremissing_ARG, '\0', "restoremissing", 0, 0, 0,
 arg(resync_ARG, '\0', "resync", 0, 0, 0,
     "Initiates mirror synchronization. Synchronization generally happens\n"
     "automatically, but this option forces it to run.\n"
-    "Also see \\-\\-rebuild to synchronize a specific PV.\n"
+    "Also see --rebuild to synchronize a specific PV.\n"
     "During synchronization, data is read from the primary mirror device\n"
     "and copied to the others. This can take considerable time, during\n"
     "which the LV is without a complete redundant copy of the data.\n"
@@ -567,16 +567,16 @@ arg(shared_ARG, '\0', "shared", 0, 0, 0,
 arg(sinceversion_ARG, '\0', "sinceversion", string_VAL, 0, 0,
     "Specify an LVM version in x.y.z format where x is the major version,\n"
     "the y is the minor version and z is the patchlevel (e.g. 2.2.106).\n"
-    "This option is currently applicable only with \\-\\-typeconfig new\n"
+    "This option is currently applicable only with --typeconfig new\n"
     "to display all configuration settings introduced since given version.\n")
 
 arg(splitcache_ARG, '\0', "splitcache", 0, 0, 0,
     "Separates a cache pool from a cache LV, and keeps the unused cache pool LV.\n"
-    "Before the separation, the cache is flushed. Also see \\-\\-uncache.\n")
+    "Before the separation, the cache is flushed. Also see --uncache.\n")
 
 arg(splitmirrors_ARG, '\0', "splitmirrors", number_VAL, 0, 0,
     "Splits the specified number of images from a raid1 or mirror LV\n"
-    "and uses them to create a new LV. If \\-\\-trackchanges is also specified,\n"
+    "and uses them to create a new LV. If --trackchanges is also specified,\n"
     "changes to the raid1 LV are tracked while the split LV remains detached.\n")
 
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", 0, 0, 0,
@@ -587,7 +587,7 @@ arg(splitsnapshot_ARG, '\0', "splitsnapshot", 0, 0, 0,
 arg(showdeprecated_ARG, '\0', "showdeprecated", 0, 0, 0,
     "Include deprecated configuration settings in the output. These settings\n"
     "are deprecated after a certain version. If a concrete version is specified\n"
-    "with \\-\\-atversion, deprecated settings are automatically included\n"
+    "with --atversion, deprecated settings are automatically included\n"
     "if the specified version is lower than the version in which the settings were\n"
     "deprecated. The current and diff types include deprecated settings\n"
     "in their output by default, all the other types ignore deprecated settings.\n")
@@ -606,7 +606,7 @@ arg(stripes_long_ARG, '\0', "stripes", number_VAL, 0, 0,
     "Specifies the number of stripes in a striped LV. This is the number of\n"
     "PVs (devices) that a striped LV is spread across. Data that\n"
     "appears sequential in the LV is spread across multiple devices in units of\n"
-    "the stripe size (see \\-\\-stripesize). This does not apply to\n"
+    "the stripe size (see --stripesize). This does not apply to\n"
     "existing allocated space, only newly allocated space can be striped.\n")
 
 arg(swapmetadata_ARG, '\0', "swapmetadata", 0, 0, 0,
@@ -631,8 +631,8 @@ arg(sysinit_ARG, '\0', "sysinit", 0, 0, 0,
     "scripts (e.g. rc.sysinit or an initrd), before writable filesystems are\n"
     "available. As such, some functionality needs to be disabled and this option\n"
     "acts as a shortcut which selects an appropriate set of options. Currently,\n"
-    "this is equivalent to using \\-\\-ignorelockingfailure, \\-\\-ignoremonitoring,\n"
-    "\\-\\-poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.\n"
+    "this is equivalent to using --ignorelockingfailure, --ignoremonitoring,\n"
+    "--poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.\n"
     "When used in conjunction with lvmetad enabled and running,\n"
     "vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.\n")
 
@@ -655,7 +655,7 @@ arg(thinpool_ARG, '\0', "thinpool", lv_VAL, 0, 0,
     "The name of a thin pool LV.\n")
 
 arg(trackchanges_ARG, '\0', "trackchanges", 0, 0, 0,
-    "Can be used with \\-\\-splitmirrors on a raid1 LV. This causes\n"
+    "Can be used with --splitmirrors on a raid1 LV. This causes\n"
     "changes to the original raid1 LV to be tracked while the split images\n"
     "remain detached. This allows the read-only detached image(s) to be\n"
     "merged efficiently back into the raid1 LV later. Only the regions with\n"
@@ -675,7 +675,7 @@ arg(type_ARG, '\0', "type", segtype_VAL, 0, 0,
     "For copy-on-write snapshots (\\fBsnapshot\\fP) see usage definitions.\n"
     "Several commands omit an explicit type option because the type\n"
     "is inferred from other options or shortcuts\n"
-    "(e.g. \\-\\-stripes, \\-\\-mirrors, \\-\\-snapshot, \\-\\-virtualsize, \\-\\-thin, \\-\\-cache).\n"
+    "(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).\n"
     "Use inferred types with care because it can lead to unexpected results.\n")
 
 arg(unbuffered_ARG, '\0', "unbuffered", 0, 0, 0,
@@ -683,7 +683,7 @@ arg(unbuffered_ARG, '\0', "unbuffered", 0, 0, 0,
 
 arg(uncache_ARG, '\0', "uncache", 0, 0, 0,
     "Separates a cache pool from a cache LV, and deletes the unused cache pool LV.\n"
-    "Before the separation, the cache is flushed. Also see \\-\\-splitcache.\n")
+    "Before the separation, the cache is flushed. Also see --splitcache.\n")
 
 arg(cachepolicy_ARG, '\0', "cachepolicy", string_VAL, 0, 0,
     "Specifies the cache policy for a cache LV.\n"
@@ -707,10 +707,10 @@ arg(units_ARG, '\0', "units", units_VAL, 0, 0,
     "(h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,\n"
     "(g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.\n"
     "Capitalise to use multiples of 1000 (S.I.) instead of 1024.\n"
-    "Custom units can be specified, e.g. \\-\\-units 3M.\n")
+    "Custom units can be specified, e.g. --units 3M.\n")
 
 arg(unquoted_ARG, '\0', "unquoted", 0, 0, 0,
-    "When used with \\-\\-nameprefixes, output values in the field=value\n"
+    "When used with --nameprefixes, output values in the field=value\n"
     "pairs are not quoted.\n")
 
 arg(usepolicies_ARG, '\0', "usepolicies", 0, 0, 0,
@@ -721,7 +721,7 @@ arg(validate_ARG, '\0', "validate", 0, 0, 0,
     "Validate current configuration used and exit with appropriate\n"
     "return code. The validation is done only for the configuration\n"
     "at the front of the \"config cascade\". To validate the whole\n"
-    "merged configuration tree, also use \\-\\-mergedconfig.\n"
+    "merged configuration tree, also use --mergedconfig.\n"
     "The validation is done even if lvm.conf config/checks is disabled.\n")
 
 arg(version_ARG, '\0', "version", 0, 0, 0,
@@ -787,7 +787,7 @@ arg(writemostly_ARG, '\0', "writemostly", writemostly_VAL, ARG_GROUPABLE, 0,
  * these variants.  The description of the standard option names
  * can mention a synonym, or in some cases the man page generation
  * recognizes some of these and prints the option name to include
- * the variant, e.g. man page generation prints \\-\\-[raid]writebehind.
+ * the variant, e.g. man page generation prints --[raid]writebehind.
  */
 arg(corelog_ARG, '\0', "corelog", 0, 0, 0, NULL)
 arg(resizable_ARG, '\0', "resizable", bool_VAL, 0, 0, NULL)
@@ -838,10 +838,10 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "In some cases, creating an LV requires it to be active.\n"
     "For example, COW snapshots of an active origin LV can only\n"
     "be created in the active state (this does not apply to thin snapshots.)\n"
-    "The \\-\\-zero option normally requires the LV to be active.\n"
+    "The --zero option normally requires the LV to be active.\n"
     "If autoactivation \\fBay\\fP is used, the LV is only activated\n"
     "if it matches an item in lvm.conf activation/auto_activation_volume_list.\n"
-    "\\fBay\\fP implies \\-\\-zero n and \\-\\-wipesignatures n.\n"
+    "\\fBay\\fP implies --zero n and --wipesignatures n.\n"
     "See lvmlockd(8) for more information about activation options for shared VGs.\n"
     "See clvmd(8) for more information about activation options for clustered VGs.\n")
 
@@ -964,7 +964,7 @@ arg(help_ARG, 'h', "help", 0, 0, 0,
 
 arg(cache_ARG, 'H', "cache", 0, 0, 0,
     "Specifies the command is handling a cache LV or cache pool.\n"
-    "See \\-\\-type cache and \\-\\-type cache-pool.\n"
+    "See --type cache and --type cache-pool.\n"
     "See \\fBlvmcache\\fP(7) for more information about LVM caching.\n")
 
 arg(history_ARG, 'H', "history", 0, 0, 0,
@@ -989,7 +989,7 @@ arg(stripes_ARG, 'i', "stripes", number_VAL, 0, 0,
     "Specifies the number of stripes in a striped LV. This is the number of\n"
     "PVs (devices) that a striped LV is spread across. Data that\n"
     "appears sequential in the LV is spread across multiple devices in units of\n"
-    "the stripe size (see \\-\\-stripesize). This does not change existing\n"
+    "the stripe size (see --stripesize). This does not change existing\n"
     "allocated space, but only applies to space being allocated by the command.\n"
     "When creating a RAID 4/5/6 LV, this number does not include the extra\n"
     "devices that are required for parity. The largest number depends on\n"
@@ -1017,7 +1017,7 @@ arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", uint32_VAL, 0, 0,
 arg(extents_ARG, 'l', "extents", extents_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the size of the new LV in logical extents.\n"
-    "The \\-\\-size and \\-\\-extents options are alternate methods of specifying size.\n"
+    "The --size and --extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
     "An alternate syntax allows the size to be determined indirectly\n"
@@ -1035,7 +1035,7 @@ arg(extents_ARG, 'l', "extents", extents_VAL, 0, 0,
     "#lvextend\n"
     "#lvresize\n"
     "Specifies the new size of the LV in logical extents.\n"
-    "The \\-\\-size and \\-\\-extents options are alternate methods of specifying size.\n"
+    "The --size and --extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
     "An alternate syntax allows the size to be determined indirectly\n"
@@ -1058,12 +1058,12 @@ arg(list_ARG, 'l', "list", 0, 0, 0,
     "#dumpconfig\n"
     "#config\n"
     "List config settings with summarizing comment. This is the same as using\n"
-    "options \\-\\-typeconfig list \\-\\-withsummary.\n"
+    "options --typeconfig list --withsummary.\n"
     "#vgcfgrestore\n"
     "List metadata backup and archive files pertaining to the VG.\n"
-    "May be used with \\-\\-file. Does not restore the VG.\n"
+    "May be used with --file. Does not restore the VG.\n"
     "#vgmerge\n"
-    "Display merged destination VG like vgdisplay \\-v.\n")
+    "Display merged destination VG like vgdisplay -v.\n")
 
 arg(lvmpartition_ARG, 'l', "lvmpartition", 0, 0, 0,
     "Only report PVs.\n")
@@ -1076,14 +1076,14 @@ arg(lvmpartition_ARG, 'l', "lvmpartition", 0, 0, 0,
 arg(size_ARG, 'L', "size", sizemb_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the size of the new LV.\n"
-    "The \\-\\-size and \\-\\-extents options are alternate methods of specifying size.\n"
+    "The --size and --extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
     "#lvreduce\n"
     "#lvextend\n"
     "#lvresize\n"
     "Specifies the new size of the LV.\n"
-    "The \\-\\-size and \\-\\-extents options are alternate methods of specifying size.\n"
+    "The --size and --extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
     "When the plus \\fB+\\fP or minus \\fB-\\fP prefix is used,\n"
@@ -1103,7 +1103,7 @@ arg(major_ARG, 'j', "major", number_VAL, ARG_GROUPABLE, 0,
 arg(setactivationskip_ARG, 'k', "setactivationskip", bool_VAL, 0, 0,
     "Persistently sets (yes) or clears (no) the \"activation skip\" flag on an LV.\n"
     "An LV with this flag set is not activated unless the\n"
-    "\\-\\-ignoreactivationskip option is used by the activation command.\n"
+    "--ignoreactivationskip option is used by the activation command.\n"
     "This flag is set by default on new thin snapshot LVs.\n"
     "The flag is not applied to deactivation.\n"
     "The current value of the flag is indicated in the lvs lv_attr bits.\n")
@@ -1116,7 +1116,7 @@ arg(maps_ARG, 'm', "maps", 0, 0, 0,
     "#lvdisplay\n"
     "Display the mapping of logical extents to PVs and physical extents.\n"
     "To map physical extents to logical extents use:\n"
-    "pvs \\-\\-segments \\-o+lv_name,seg_start_pe,segtype\n"
+    "pvs --segments -o+lv_name,seg_start_pe,segtype\n"
     "#pvdisplay\n"
     "Display the mapping of physical extents to LVs and logical extents.\n")
 
@@ -1125,27 +1125,27 @@ arg(maps_ARG, 'm', "maps", 0, 0, 0,
 arg(mirrors_ARG, 'm', "mirrors", number_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the number of mirror images in addition to the original LV\n"
-    "image, e.g. \\-\\-mirrors 1 means there are two images of the data, the\n"
+    "image, e.g. --mirrors 1 means there are two images of the data, the\n"
     "original and one mirror image.\n"
     "Optional positional PV args on the command line can specify the devices\n"
     "the images should be placed on.\n"
     "There are two mirroring implementations: \"raid1\" and \"mirror\".\n"
     "These are the names of the corresponding LV types, or \"segment types\".\n"
-    "Use the \\-\\-type option to specify which to use (raid1 is default,\n"
+    "Use the --type option to specify which to use (raid1 is default,\n"
     "and mirror is legacy)\n"
     "Use lvm.conf global/mirror_segtype_default and\n"
     "global/raid10_segtype_default to configure the default types.\n"
-    "See the \\-\\-nosync option for avoiding initial image synchronization.\n"
+    "See the --nosync option for avoiding initial image synchronization.\n"
     "See \\fBlvmraid\\fP(7) for more information.\n"
     "#lvconvert\n"
     "Specifies the number of mirror images in addition to the original LV\n"
-    "image, e.g. \\-\\-mirrors 1 means there are two images of the data, the\n"
+    "image, e.g. --mirrors 1 means there are two images of the data, the\n"
     "original and one mirror image.\n"
     "Optional positional PV args on the command line can specify the devices\n"
     "the images should be placed on.\n"
     "There are two mirroring implementations: \"raid1\" and \"mirror\".\n"
     "These are the names of the corresponding LV types, or \"segment types\".\n"
-    "Use the \\-\\-type option to specify which to use (raid1 is default,\n"
+    "Use the --type option to specify which to use (raid1 is default,\n"
     "and mirror is legacy)\n"
     "Use lvm.conf global/mirror_segtype_default and\n"
     "global/raid10_segtype_default to configure the default types.\n"
@@ -1176,7 +1176,7 @@ arg(name_ARG, 'n', "name", string_VAL, 0, 0,
 
 arg(nofsck_ARG, 'n', "nofsck", 0, 0, 0,
     "Do not perform fsck before resizing filesystem when filesystem\n"
-    "requires it. You may need to use \\-\\-force to proceed with\n"
+    "requires it. You may need to use --force to proceed with\n"
     "this option.\n")
 
 arg(novolumegroup_ARG, 'n', "novolumegroup", 0, 0, 0,
@@ -1188,7 +1188,7 @@ arg(oldpath_ARG, 'n', "oldpath", 0, 0, 0, NULL)
 /*
  * FIXME: a free-form discussion section and document the
  * VG/LV/PV attr bits which were previously listed
- * in the description for \\-o.
+ * in the description for -o.
  */
 
 arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0,
@@ -1198,8 +1198,8 @@ arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0,
     "\\fB-\\fP will remove the specified fields from the default fields, and\n"
     "\\fB#\\fP will compact specified fields (removing them when empty for all rows.)\n"
     "Use \\fB-o help\\fP to view the list of all available fields.\n"
-    "Use separate lists of fields to add, remove or compact by repeating the \\-o option:\n"
-    "-o+field1,field2 \\-o-field3,field4 \\-o#field5.\n"
+    "Use separate lists of fields to add, remove or compact by repeating the -o option:\n"
+    "-o+field1,field2 -o-field3,field4 -o#field5.\n"
     "These lists are evaluated from left to right.\n"
     "Use field name \\fBlv_all\\fP to view all LV fields,\n"
     "\\fBvg_all\\fP all VG fields,\n"
@@ -1217,8 +1217,8 @@ arg(sort_ARG, 'O', "sort", string_VAL, ARG_GROUPABLE, 0,
 arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", uint32_VAL, 0, 0,
     "Sets the maximum number of PVs that can belong to the VG.\n"
     "The value 0 removes any limitation.\n"
-    "For large numbers of PVs, also see options \\-\\-pvmetadatacopies,\n"
-    "and \\-\\-vgmetadatacopies for improving performance.\n")
+    "For large numbers of PVs, also see options --pvmetadatacopies,\n"
+    "and --vgmetadatacopies for improving performance.\n")
 
 arg(permission_ARG, 'p', "permission", permission_VAL, 0, 0,
     "Set access permission to read only \\fBr\\fP or read and write \\fBrw\\fP.\n")
@@ -1235,7 +1235,7 @@ arg(partial_ARG, 'P', "partial", 0, 0, 0,
 arg(physicalvolume_ARG, 'P', "physicalvolume", 0, 0, 0, NULL)
 
 arg(quiet_ARG, 'q', "quiet", 0, ARG_COUNTABLE, 0,
-    "Suppress output and log messages. Overrides \\-\\-debug and \\-\\-verbose.\n"
+    "Suppress output and log messages. Overrides --debug and --verbose.\n"
     "Repeat once to also suppress any prompts with answer no.\n")
 
 arg(readahead_ARG, 'r', "readahead", readahead_VAL, 0, 0,
@@ -1285,7 +1285,7 @@ arg(snapshot_ARG, 's', "snapshot", 0, 0, 0,
     "the size option is NOT specified. Thin snapshots share the same blocks\n"
     "in the thin pool, and do not allocate new space from the VG.\n"
     "Thin snapshots are created with the \"activation skip\" flag,\n"
-    "see \\-\\-setactivationskip.\n"
+    "see --setactivationskip.\n"
     "A thin snapshot of a non-thin \"external origin\" LV is created\n"
     "when a thin pool is specified. Unprovisioned blocks in the thin snapshot\n"
     "LV are read from the external origin LV. The external origin LV must\n"
@@ -1299,11 +1299,11 @@ arg(snapshot_ARG, 's', "snapshot", 0, 0, 0,
     "be extended with lvextend (shrinking is also allowed with lvreduce.)\n"
     "A small amount of the COW snapshot LV size is used to track COW block\n"
     "locations, so the full size is not available for COW data blocks.\n"
-    "Use lvs to check how much space is used, and see \\-\\-monitor to\n"
+    "Use lvs to check how much space is used, and see --monitor to\n"
     "to automatically extend the size to avoid running out of space.\n"
     "#lvconvert\n"
     "Combine a former COW snapshot LV with a former origin LV to reverse\n"
-    "a previous \\-\\-splitsnapshot command.\n")
+    "a previous --splitsnapshot command.\n")
 
 arg(short_ARG, 's', "short", 0, 0, 0,
     "#pvdisplay\n"
@@ -1318,9 +1318,9 @@ arg(stdin_ARG, 's', "stdin", 0, 0, 0, NULL)
 
 arg(select_ARG, 'S', "select", string_VAL, ARG_GROUPABLE, 0,
     "Select objects for processing and reporting based on specified criteria.\n"
-    "The criteria syntax is described by \\fB\\-\\-select help\\fP and \\fBlvmreport\\fP(7).\n"
+    "The criteria syntax is described by \\fB--select help\\fP and \\fBlvmreport\\fP(7).\n"
     "For reporting commands, one row is displayed for each object matching the criteria.\n"
-    "See \\fB\\-\\-options help\\fP for selectable object fields.\n"
+    "See \\fB--options help\\fP for selectable object fields.\n"
     "Rows can be displayed with an additional \"selected\" field (-o selected)\n"
     "showing 1 if the row matches the selection and 0 otherwise.\n"
     "For non-reporting commands which process LVM entities, the selection is\n"
@@ -1335,7 +1335,7 @@ arg(test_ARG, 't', "test", 0, 0, 0,
 
 arg(thin_ARG, 'T', "thin", 0, 0, 0,
     "Specifies the command is handling a thin LV or thin pool.\n"
-    "See \\-\\-type thin, \\-\\-type thin-pool, and \\-\\-virtualsize.\n"
+    "See --type thin, --type thin-pool, and --virtualsize.\n"
     "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n")
 
 arg(uuid_ARG, 'u', "uuid", 0, 0, 0,
@@ -1351,7 +1351,7 @@ arg(uuidstr_ARG, 'u', "uuid", string_VAL, 0, 0,
     "Without this option, a random UUID is generated.\n"
     "This option is needed before restoring a backup of LVM metadata\n"
     "onto a replacement device; see vgcfgrestore(8). As such, use of\n"
-    "\\-\\-restorefile is compulsory unless the \\-\\-norestorefile is used.\n"
+    "--restorefile is compulsory unless the --norestorefile is used.\n"
     "All PVs must have unique UUIDs, and LVM will prevent certain operations\n"
     "if multiple devices are seen with the same UUID.\n"
     "See vgimportclone(8) for more information.\n")
@@ -1369,7 +1369,7 @@ arg(volumegroup_ARG, 'V', "volumegroup", 0, 0, 0, NULL)
 arg(virtualsize_ARG, 'V', "virtualsize", sizemb_VAL, 0, 0,
     "The virtual size of a new thin LV.\n"
     "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n"
-    "Using virtual size (\\-V) and actual size (\\-L) together creates\n"
+    "Using virtual size (-V) and actual size (-L) together creates\n"
     "a sparse LV.\n"
     "lvm.conf global/sparse_segtype_default determines the\n"
     "default segment type used to create a sparse LV.\n"
@@ -1383,13 +1383,13 @@ arg(virtualsize_ARG, 'V', "virtualsize", sizemb_VAL, 0, 0,
 arg(wipesignatures_ARG, 'W', "wipesignatures", bool_VAL, 0, 0,
     "Controls detection and subsequent wiping of signatures on new LVs.\n"
     "There is a prompt for each signature detected to confirm its wiping\n"
-    "(unless \\-\\-yes is used to override confirmations.)\n"
+    "(unless --yes is used to override confirmations.)\n"
     "When not specified, signatures are wiped whenever zeroing is done\n"
-    "(see \\-\\-zero). This behaviour can be configured with\n"
+    "(see --zero). This behaviour can be configured with\n"
     "lvm.conf allocation/wipe_signatures_when_zeroing_new_lvs.\n"
     "If blkid wiping is used (lvm.conf allocation/use_blkid_wiping)\n"
     "and LVM is compiled with blkid wiping support, then the blkid(8)\n"
-    "library is used to detect the signatures (use blkid \\-k to list the\n"
+    "library is used to detect the signatures (use blkid -k to list the\n"
     "signatures that are recognized).\n"
     "Otherwise, native LVM code is used to detect signatures\n"
     "(only MD RAID, swap and LUKS signatures are detected in this case.)\n"
@@ -1405,12 +1405,12 @@ arg(resizeable_ARG, 'x', "resizeable", bool_VAL, 0, 0,
 arg(yes_ARG, 'y', "yes", 0, 0, 0,
     "Do not prompt for confirmation interactively but always assume the\n"
     "answer yes. Use with extreme caution.\n"
-    "(For automatic no, see \\-qq.)\n")
+    "(For automatic no, see -qq.)\n")
 
 arg(zero_ARG, 'Z', "zero", bool_VAL, 0, 0,
     "#lvchange\n"
     "Set zeroing mode for thin pool. Note: already provisioned blocks from pool\n"
-    "in non-zero mode are not cleared in unwritten parts when setting \\-\\-zero y.\n"
+    "in non-zero mode are not cleared in unwritten parts when setting --zero y.\n"
     "#lvconvert\n"
     "For snapshots, this controls zeroing of the first 4KiB of data in the\n"
     "snapshot. If the LV is read-only, the snapshot will not be zeroed.\n"
@@ -1427,7 +1427,7 @@ arg(zero_ARG, 'Z', "zero", bool_VAL, 0, 0,
     "#vgextend\n"
     "Controls if the first 4 sectors (2048 bytes) of the device are wiped.\n"
     "The default is to wipe these sectors unless either or both of\n"
-    "\\-\\-restorefile or \\-\\-uuid are specified.\n")
+    "--restorefile or --uuid are specified.\n")
 
 /* this should always be last */
 arg(ARG_COUNT, '-', "", 0, 0, 0, NULL)
diff --git a/tools/command.c b/tools/command.c
index 812366f..8a739f0 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2094,7 +2094,7 @@ void print_usage_notes(struct command_name *cname)
                "        capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
                "        The default input unit is specified by letter, followed by |UNIT.\n"
                "        UNIT represents other possible input units: BbBsSkKmMgGtTpPeE.\n"
-               "        (This should not be confused with the output control \\-\\-units, where\n"
+               "        (This should not be confused with the output control --units, where\n"
                "        capital letters mean multiple of 1000.)\n");
 	printf("\n");
 }
@@ -2140,7 +2140,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == ssizemb_VAL) {
-		printf("[\\fB+\\fP|\\fB\\-\\fP]\\fISize\\fP[m|UNIT]");
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[m|UNIT]");
 		return;
 	}
 
@@ -2150,7 +2150,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == nsizemb_VAL) {
-		printf("[\\fB\\-\\fP]\\fISize\\fP[m|UNIT]");
+		printf("[\\fB-\\fP]\\fISize\\fP[m|UNIT]");
 		return;
 	}
 
@@ -2160,7 +2160,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == sextents_VAL) {
-		printf("[\\fB+\\fP|\\fB\\-\\fP]\\fINumber\\fP[PERCENT]");
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP[PERCENT]");
 		return;
 	}
 
@@ -2170,7 +2170,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == nextents_VAL) {
-		printf("[\\fB\\-\\fP]\\fINumber\\fP[PERCENT]");
+		printf("[\\fB-\\fP]\\fINumber\\fP[PERCENT]");
 		return;
 	}
 
@@ -2180,7 +2180,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == ssizekb_VAL) {
-		printf("[\\fB+\\fP|\\fB\\-\\fP]\\fISize\\fP[k|UNIT]");
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[k|UNIT]");
 		return;
 	}
 
@@ -2190,7 +2190,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == snumber_VAL) {
-		printf("[\\fB+\\fP|\\fB\\-\\fP]\\fINumber\\fP");
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP");
 		return;
 	}
 
@@ -2244,28 +2244,19 @@ static void print_def_man(struct command_name *cname, int opt_enum, struct arg_d
 	for (val_enum = 0; val_enum < VAL_COUNT; val_enum++) {
 		if (def->val_bits & val_enum_to_bit(val_enum)) {
 
-			if (val_enum == conststr_VAL) {
-				printf("\\fB");
-				printf("%s", def->str);
-				printf("\\fP");
-			}
+			if (val_enum == conststr_VAL)
+				printf("\\fB%s\\fP", def->str);
 
-			else if (val_enum == constnum_VAL) {
-				printf("\\fB");
-				printf("%llu", (unsigned long long)def->num);
-				printf("\\fP");
-			}
+			else if (val_enum == constnum_VAL)
+				printf("\\fB%llu\\fP", (unsigned long long)def->num);
 
 			else {
 				if (sep) printf("|");
 
-				if (!usage || !val_names[val_enum].usage) {
-					printf("\\fI");
-					printf("%s", val_names[val_enum].name);
-					printf("\\fP");
-				} else {
+				if (!usage || !val_names[val_enum].usage)
+					printf("\\fI%s\\fP", val_names[val_enum].name);
+				else
 					print_val_man(cname, opt_enum, val_enum);
-				}
 
 				sep = 1;
 			}
@@ -2279,16 +2270,9 @@ static void print_def_man(struct command_name *cname, int opt_enum, struct arg_d
 				printf("\\fP");
 			}
 
-			if ((val_enum == vg_VAL) && (def->flags & ARG_DEF_FLAG_NEW_VG)) {
-				printf("\\fI");
-				printf("_new");
-				printf("\\fP");
-			}
-			if ((val_enum == lv_VAL) && (def->flags & ARG_DEF_FLAG_NEW_LV)) {
-				printf("\\fI");
-				printf("_new");
-				printf("\\fP");
-			}
+			if (((val_enum == vg_VAL) && (def->flags & ARG_DEF_FLAG_NEW_VG)) ||
+			    ((val_enum == lv_VAL) && (def->flags & ARG_DEF_FLAG_NEW_LV)))
+				printf("\\fI_new\\fP");
 		}
 	}
 
@@ -2296,13 +2280,6 @@ static void print_def_man(struct command_name *cname, int opt_enum, struct arg_d
 		printf(" ...");
 }
 
-static const char *_emit_long_opt_name(char *buf, const char *long_opt_name, size_t len)
-{
-	strcpy(buf, "\\-\\-");
-	strncat(buf, long_opt_name + 2, len - strlen(buf) - 1);
-	return buf;
-}
-
 #define	LONG_OPT_NAME_LEN	64
 static const char *man_long_opt_name(const char *cmdname, int opt_enum)
 {
@@ -2344,7 +2321,7 @@ static const char *man_long_opt_name(const char *cmdname, int opt_enum)
 		break;
 	}
 
-	return _emit_long_opt_name(long_opt_name, long_opt, sizeof(long_opt_name));
+	return long_opt;
 }
 
 static void _print_man_usage(char *lvmname, struct command *cmd)
@@ -2354,9 +2331,6 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 	int sep, ro, rp, oo, op, opt_enum;
 	int need_ro_indent_end = 0;
 	int include_extents = 0;
-	char long_opt_name[LONG_OPT_NAME_LEN];
-
-	memset (long_opt_name, 0, sizeof(long_opt_name));
 
 	if (!(cname = find_command_name(cmd->name)))
 		return;
@@ -2400,7 +2374,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			}
 
 			if (opt_names[opt_enum].short_opt) {
-				printf(" \\fB\\-%c\\fP|\\fB%s\\fP",
+				printf(" \\fB-%c\\fP|\\fB%s\\fP",
 				       opt_names[opt_enum].short_opt,
 				       man_long_opt_name(cmd->name, opt_enum));
 			} else {
@@ -2490,14 +2464,11 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				include_extents = 1;
 
 			if (opt_names[opt_enum].short_opt) {
-				printf(" \\fB\\-%c\\fP|\\fB%s\\fP",
+				printf(" \\fB-%c\\fP|\\fB%s\\fP",
 				       opt_names[opt_enum].short_opt,
 				       man_long_opt_name(cmd->name, opt_enum));
-			} else {
-				_emit_long_opt_name(long_opt_name, opt_names[cmd->required_opt_args[ro].opt].long_opt,
-						    sizeof(long_opt_name));
-				printf(" \\fB%s\\fP", long_opt_name);
-			}
+			} else
+				printf(" \\fB%s\\fP", opt_names[cmd->required_opt_args[ro].opt].long_opt);
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
@@ -2543,7 +2514,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			 * in opt_names[] according to the command name.
 			 */
 			printf(".ad l\n");
-			printf("[ \\fB\\-l\\fP|\\fB\\-\\-extents\\fP ");
+			printf("[ \\fB-l\\fP|\\fB--extents\\fP ");
 			print_val_man(cname, extents_ARG, opt_names[extents_ARG].val_enum);
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2568,7 +2539,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				printf(".br\n");
 			printf(".ad l\n");
 
-			printf("[ \\fB\\-%c\\fP|\\fB%s\\fP",
+			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cmd->name, opt_enum));
 
@@ -2693,7 +2664,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
 				continue;
 
-			printf("[ \\fB\\-%c\\fP|\\fB%s\\fP",
+			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cmd->name, opt_enum));
 
@@ -2790,7 +2761,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
 				continue;
 
-			printf("[ \\fB\\-%c\\fP|\\fB%s\\fP",
+			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cmd->name, opt_enum));
 
@@ -2953,7 +2924,7 @@ static void _print_man_all_options_list(struct command_name *cname)
 		printf(".ad l\n");
 
 		if (opt_names[opt_enum].short_opt) {
-			printf(" \\fB\\-%c\\fP|\\fB%s\\fP",
+			printf(" \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cname->name, opt_enum));
 		} else {
@@ -3001,7 +2972,7 @@ static void _print_man_all_options_desc(struct command_name *cname)
 		printf(".ad l\n");
 
 		if (opt_names[opt_enum].short_opt) {
-			printf("\\fB\\-%c\\fP|\\fB%s\\fP",
+			printf("\\fB-%c\\fP|\\fB%s\\fP",
 			       opt_names[opt_enum].short_opt,
 			       man_long_opt_name(cname->name, opt_enum));
 		} else {
@@ -3104,7 +3075,7 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 		if (!strcmp(cname->name, "lvcreate"))
 			printf("For lvcreate, the required VG positional arg may be\n"
 			       "omitted when the VG name is included in another option,\n"
-			       "e.g. \\-\\-name VG/LV.\n");
+			       "e.g. --name VG/LV.\n");
 	}
 
 	if (has_lv_val) {
@@ -3132,7 +3103,7 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 		       "generally accepts a suffix indicating a range (or multiple ranges)\n"
 		       "of physical extents (PEs). When the first PE is omitted, it defaults\n"
 		       "to the start of the device, and when the last PE is omitted it defaults to end.\n"
-		       "Start and end range (inclusive): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP\\fB\\-\\fP\\fIPE\\fP]...\n"
+		       "Start and end range (inclusive): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP\\fB-\\fP\\fIPE\\fP]...\n"
 		       "Start and length range (counting from 0): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP\\fB+\\fP\\fIPE\\fP]...\n");
 	}
 
@@ -3153,7 +3124,7 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 		printf("\n");
 		printf(".br\n");
 		printf("Select indicates that a required positional parameter can\n"
-		       "be omitted if the \\fB\\-\\-select\\fP option is used.\n"
+		       "be omitted if the \\fB--select\\fP option is used.\n"
 		       "No arg appears in this position.\n");
 	}
 
@@ -3183,7 +3154,7 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 	       "b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,\n"
 	       "m|M is megabytes, g|G is gigabytes, t|T is terabytes,\n"
 	       "p|P is petabytes, e|E is exabytes.\n"
-	       "(This should not be confused with the output control \\-\\-units, where\n"
+	       "(This should not be confused with the output control --units, where\n"
 	       "capital letters mean multiple of 1000.)\n");
 
 	printf(".SH ENVIRONMENT VARIABLES\n");
@@ -3311,7 +3282,7 @@ static void _print_man(char *name, char *des_file, int secondary)
 		if (!prev_cmd || strcmp(prev_cmd->name, cmd->name)) {
 			printf(".SH NAME\n");
 			if (cname->desc)
-				printf("%s \\- %s\n", lvmname, cname->desc);
+				printf("%s - %s\n", lvmname, cname->desc);
 			else
 				printf("%s\n", lvmname);
 


