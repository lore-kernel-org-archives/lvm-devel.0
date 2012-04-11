From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Apr 2012 12:42:17 -0000
Subject: LVM2 ./WHATS_NEW man/clvmd.8.in man/fsadm.8.in ...
Message-ID: <20120411124217.2056.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-11 12:42:10

Modified files:
	.              : WHATS_NEW 
	man            : clvmd.8.in fsadm.8.in lvchange.8.in 
	                 lvconvert.8.in lvcreate.8.in lvdisplay.8.in 
	                 lvextend.8.in lvm.8.in lvm.conf.5.in 
	                 lvmchange.8.in lvmconf.8.in lvmdiskscan.8.in 
	                 lvmdump.8.in lvmsadc.8.in lvmsar.8.in 
	                 lvreduce.8.in lvremove.8.in lvrename.8.in 
	                 lvs.8.in lvscan.8.in pvchange.8.in pvck.8.in 
	                 pvcreate.8.in pvdisplay.8.in pvmove.8.in 
	                 pvremove.8.in pvresize.8.in pvs.8.in 
	                 pvscan.8.in vgcfgbackup.8.in vgcfgrestore.8.in 
	                 vgchange.8.in vgck.8.in vgconvert.8.in 
	                 vgcreate.8.in vgdisplay.8.in vgexport.8.in 
	                 vgextend.8.in vgimport.8.in vgimportclone.8.in 
	                 vgmerge.8.in vgmknodes.8.in vgreduce.8.in 
	                 vgremove.8.in vgrename.8.in vgs.8.in 
	                 vgscan.8.in vgsplit.8.in 

Log message:
	Update man pages
	
	Use one style for man pages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2381&r2=1.2382
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/fsadm.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvdisplay.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmchange.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmconf.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdiskscan.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdump.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmsadc.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmsar.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvremove.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvrename.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvscan.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvchange.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvck.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvcreate.8.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvdisplay.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvmove.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvremove.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvresize.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvscan.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgbackup.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcfgrestore.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgck.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgconvert.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgdisplay.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgexport.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgextend.8.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgimport.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgimportclone.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgmerge.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgmknodes.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgreduce.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgremove.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgrename.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgscan.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2012/04/11 12:40:03	1.2381
+++ LVM2/WHATS_NEW	2012/04/11 12:42:10	1.2382
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Update man pages to give them same look&feel.
   Fix lvresize of thin pool for stipped devices.
   For lvresize round upward when specifying number of extents.
   For lvcreate with %FREE support rounding downward strip alignment.
--- LVM2/man/clvmd.8.in	2011/09/24 20:50:36	1.8
+++ LVM2/man/clvmd.8.in	2012/04/11 12:42:10	1.9
@@ -3,97 +3,113 @@
 clvmd \- cluster LVM daemon
 .SH SYNOPSIS
 .B clvmd
-[\-d[<value>]] [\-C] [\-h]
-[\-E <lock uuid>]
-[\-R]
-[\-S]
-[\-t <timeout>]
-[\-T <start timeout>]
-[\-V]
+.RB [ \-d
+.RI [< value >]
+.RB [ \-C ]]
+.RB [ \-E
+.RI < "lock uuid" >]
+.RB [ \-f ]
+.RB [ \-h ]
+.RB [ \-I
+.IR "cluster_manager" ]
+.RB [ \-R ]
+.RB [ \-S ]
+.RB [ \-t
+.RI < timeout >]
+.RB [ \-T
+.RI < "start timeout" >]
+.RB [ \-V ]
 .SH DESCRIPTION
 clvmd is the daemon that distributes LVM metadata updates around a cluster.
-It must be running on all nodes in the cluster and will give an error 
+It must be running on all nodes in the cluster and will give an error
 if a node in the cluster does not have this daemon running.
 .SH OPTIONS
 .TP
-.I \-d[<value>]
+.BR \-d [< \fIvalue >]
 Enable debug logging. Value can be 0, 1 or 2.
 .br
 0 disables debug logging
 .br
-1 sends debug logs to stderr (implies -f option)
+1 sends debug logs to stderr (implies \fB\-f\fP option)
 .br
 2 sends debug logs to syslog
 .br
-If 
-.B -d 
+If
+.B \-d
 is specified without a value then 1 is assumed.
 .TP
-.I \-C
-Only valid if 
-.B -d 
+.B \-C
+Only valid if
+.B \-d
 is also specified. Tells all clvmds in a cluster to enable/disable debug logging.
 Without this switch, only the local clvmd will change its debug level to that
-given with 
-.B -d.
+given with
+.B \-d
+.
 .br
 This does not work correctly if specified on the command-line that starts clvmd.
-If you want to start clvmd 
-.B and 
+If you want to start clvmd
+.B and
 enable cluster-wide logging then the command needs to be issued twice, eg:
 .br
-clvmd
+.B clvmd
 .br
-clvmd -d2
+.B clvmd -d2
 .br
 .TP
-.I \-t <timeout>
-Specifies the timeout for commands to run around the cluster. This should not
-be so small that commands with many disk updates to do will fail, so you
-may need to increase this on systems with very large disk farms. 
-The default is 30 seconds.
+.BR \-E < "\fIlock uuid" >
+Pass lock uuid to be reacquired exclusively when clvmd is restarted.
 .TP
-.I \-T <start timeout>
-Specifies the timeout for clvmd daemon startup. If the daemon does not report 
-that it has started up within this time then the parent command will exit with 
-status of 5. This does NOT mean that clvmd has not started! What it means is 
-that the startup of clvmd has been delayed for some reason; the most likely 
-cause of this is an inquorate cluster though it could be due to locking 
-latencies on a cluster with large numbers of logical volumes. If you get the 
-return code of 5 it is usually not necessary to restart clvmd - it will start
-as soon as that blockage has cleared. This flag is to allow startup scripts
-to exit in a timely fashion even if the cluster is stalled for some reason.
-.br
-The default is 0 (no timeout) and the value is in seconds. Don't set this too
-small or you will experience spurious errors. 10 or 20 seconds might be
-sensible.
-.br
-This timeout will be ignored if you start clvmd with the -d switch.
+.B \-f
+Don't fork, run in the foreground.
 .TP
-.I \-E <lock uuid>
-Pass lock uuid to be reacquired exclusively when clvmd is restarted.
+.B \-h
+Show help information.
 .TP
-.I \-R
+.B \-I \fIcluster manager
+Selects the cluster manager to use for locking and internal communications,
+the available managers will be listed as part of the \fBclvmd -h\fP output.
+clvmd will use the first cluster manager that succeeds, and it checks them
+in the order cman,corosync,openais. As it is quite possible to have
+(eg) corosync and cman available on the same system you might have to
+manually specify this option to override the search.
+.TP
+.B \-R
 Tells all the running clvmds in the cluster to reload their device cache and
 re-read the lvm configuration file. This command should be run whenever the
 devices on a cluster system are changed.
 .TP
-.I \-S
+.B \-S
 Tells the running clvmd to exit and reexecute itself, for example at the
 end of a package upgrade.  The new instance is instructed to reacquire
 any locks in the same state as they were previously held.  (Alternative
 methods of restarting the daemon have the side effect of changing
 exclusive LV locks into shared locks.)
 .TP
-.I \-I
-Selects the cluster manager to use for locking and internal communications,
-the available managers will be listed as part of the 'clvmd -h' output.
-clvmd will use the first cluster manager that succeeds, and it checks them
-in the order cman,corosync,openais. As it is quite possible to have
-(eg) corosync and cman available on the same system you might have to
-manually specify this option to override the search.
+.BR \-t < \fItimeout >
+Specifies the timeout for commands to run around the cluster. This should not
+be so small that commands with many disk updates to do will fail, so you
+may need to increase this on systems with very large disk farms.
+The default is 30 seconds.
+.TP
+.BR \-T < "\fIstart timeout" >
+Specifies the timeout for clvmd daemon startup. If the daemon does not report
+that it has started up within this time then the parent command will exit with
+status of 5. This does NOT mean that clvmd has not started! What it means is
+that the startup of clvmd has been delayed for some reason; the most likely
+cause of this is an inquorate cluster though it could be due to locking
+latencies on a cluster with large numbers of logical volumes. If you get the
+return code of 5 it is usually not necessary to restart clvmd - it will start
+as soon as that blockage has cleared. This flag is to allow startup scripts
+to exit in a timely fashion even if the cluster is stalled for some reason.
+.br
+The default is 0 (no timeout) and the value is in seconds. Don't set this too
+small or you will experience spurious errors. 10 or 20 seconds might be
+sensible.
+.br
+This timeout will be ignored if you start clvmd with the -d switch.
 .TP
-.I \-V
+.B \-V
 Display the version of the cluster LVM daemon.
 
 .SH ENVIRONMENT VARIABLES
--- LVM2/man/fsadm.8.in	2011/09/19 19:36:53	1.6
+++ LVM2/man/fsadm.8.in	2012/04/11 12:42:10	1.7
@@ -14,28 +14,27 @@
 .RI [ new_size [ BKMGTEP ]]
 .sp
 .SH DESCRIPTION
-.B fsadm
-utility checks or resizes the filesystem on a device.
+fsadm utility checks or resizes the filesystem on a device.
 It tries to use the same API for 
-.IR ext2 , ext3 , ext4 , ReiserFS
-and \fIXFS\fP filesystem.
+.IR ext2 ", " ext3 ", " ext4 ", " ReiserFS " and " XFS
+filesystem.
 .SH OPTIONS
 .TP
-.BR \-h ", " \-\-help
-Display the help text.
-.TP
-.BR \-v ", " \-\-verbose
-Be more verbose.
-.TP
 .BR \-e ", " \-\-ext\-offline
 Unmount ext2/ext3/ext4 filesystem before doing resize.
 .TP
 .BR \-f ", " \-\-force
 Bypass some sanity checks.
 .TP
+.BR \-h ", " \-\-help
+Display the help text.
+.TP
 .BR \-n ", " \-\-dry\-run
 Print commands without running them.
 .TP
+.BR \-v ", " \-\-verbose
+Be more verbose.
+.TP
 .BR \-y ", " \-\-yes
 Answer "yes" at any prompts.
 .TP
--- LVM2/man/lvchange.8.in	2010/05/06 11:15:55	1.8
+++ LVM2/man/lvchange.8.in	2012/04/11 12:42:10	1.9
@@ -3,49 +3,68 @@
 lvchange \- change attributes of a logical volume
 .SH SYNOPSIS
 .B lvchange
-[\-\-addtag Tag]
-[\-A|\-\-autobackup y|n] [\-a|\-\-available y|n|ey|en|ly|ln]
-[\-\-alloc AllocationPolicy]
-[\-C|\-\-contiguous y|n] [\-d|\-\-debug] [\-\-deltag Tag]
-[\-\-resync]
-[\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure]
-[\-\-ignoremonitoring]
-[\-\-monitor {y|n}]
-[\-\-poll {y|n}]
-[\-\-sysinit]
-[\-\-noudevsync]
-[\-M|\-\-persistent y|n] [\-\-minor minor]
-[\-P|\-\-partial]
-[\-p|\-\-permission r|rw] [\-r/\-\-readahead ReadAheadSectors|auto|none]
-[\-\-refresh]
-[\-t|\-\-test]
-[\-v|\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+.RB [ \-\-addtag
+.IR Tag ]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-a | \-\-available
+.RI [ e | l ]{ y | n }]
+.RB [ \-\-alloc
+.IR AllocationPolicy ]
+.RB [ \-C | \-\-contiguous
+.RI { y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-\-deltag
+.IR Tag ]
+.RB [ \-\-resync ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoremonitoring ]
+.RB [ \-\-monitor
+.RI { y | n }]
+.RB [ \-\-poll
+.RI { y | n }]
+.RB [ \-\-sysinit ]
+.RB [ \-\-noudevsync ]
+.RB [ \-M | \-\-persistent
+.RI { y | n }]
+.RB [ \-\-minor
+.IR minor ]
+.RB [ \-P | \-\-partial ]
+.RB [ \-p | \-\-permission
+.RI { r | rw }]
+.RB [ \-r | \-\-readahead
+.RI { ReadAheadSectors | auto | none }]
+.RB [ \-\-refresh ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose]
+.I LogicalVolumePath
+.RI [ LogicalVolumePath ...]
 .SH DESCRIPTION
 lvchange allows you to change the attributes of a logical volume
 including making them known to the kernel ready for use.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-a, \-\-available y|n|ey|en|ly|ln
+.BR \-a ", " \-\-available " [" \fIe | \fIl ]{ \fIy | \fIn }
 Controls the availability of the logical volumes for use.
 Communicates with the kernel device-mapper driver via
-libdevmapper to activate (-ay) or deactivate (-an) the 
+libdevmapper to activate (\-ay) or deactivate (\-an) the
 logical volumes.
 .IP
 If clustered locking is enabled, -aey will activate exclusively
 on one node and -aly will activate only on the local node.
 To deactivate only on the local node use -aln.
-Logical volumes with single-host snapshots are always activated 
+Logical volumes with single-host snapshots are always activated
 exclusively because they can only be used on one node at once.
 .TP
-.I \-C, \-\-contiguous y|n
+.BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
 Tries to set or reset the contiguous allocation policy for
 logical volumes. It's only possible to change a non-contiguous
 logical volume's allocation policy to contiguous, if all of the
 allocated physical extents are already contiguous.
 .TP
-.I \-\-resync
+.B \-\-resync
 Forces the complete resynchronization of a mirror.  In normal
 circumstances you should not need this option because synchronization
 happens automatically.  Data is read from the primary mirror device
@@ -53,53 +72,55 @@
 time - and during this time you are without a complete redundant copy
 of your data.
 .TP
-.I \-\-minor minor
+.B \-\-minor \fIminor
 Set the minor number.
 .TP
-.I \-\-monitor y|n
+.BR \-\-monitor " {" \fIy | \fIn }
 Start or stop monitoring a mirrored or snapshot logical volume with
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
-the failure is handled according to 
+the failure is handled according to
 \fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
 set in \fBlvm.conf\fP.
 .TP
-.I \-\-poll y|n
+.BR \-\-poll " {" \fIy | \fIn }
 Without polling a logical volume's backgrounded transformation process
 will never complete.  If there is an incomplete pvmove or lvconvert (for
-example, on rebooting after a crash), use \fB--poll y\fP to restart the
+example, on rebooting after a crash), use \fB\-\-poll y\fP to restart the
 process from its last checkpoint.  However, it may not be appropriate to
-immediately poll a logical volume when it is activated, use \fB--poll
-n\fP to defer and then \fB--poll y\fP to restart the process.
+immediately poll a logical volume when it is activated, use
+\fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
 .TP
-.I \-\-sysinit
-Indicates that lvchange(8) is being invoked from early system initialisation
-scripts (e.g. rc.sysinit or an initrd), before writeable filesystems are
-available. As such, some functionality needs to be disabled and this option
+.B \-\-sysinit
+Indicates that \fBlvchange\fP(8) is being invoked from early system
+initialisation scripts (e.g. rc.sysinit or an initrd),
+before writeable filesystems are available. As such,
+some functionality needs to be disabled and this option
 acts as a shortcut which selects an appropriate set of options. Currently
-this is equivalent to using  \fB--ignorelockingfailure\fP, \fB--ignoremonitoring\fP,
-\fB--poll n\fP and setting \fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
+this is equivalent to using  \fB\-\-ignorelockingfailure\fP,
+\fB\-\-ignoremonitoring\fP, \fB\-\-poll n\fP and setting
+\fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
 environment variable.
 .TP
-.I \-\-noudevsync
+.B \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-\-ignoremonitoring
-Make no attempt to interact with dmeventd unless \-\-monitor
+.B \-\-ignoremonitoring
+Make no attempt to interact with dmeventd unless \fB\-\-monitor\fP
 is specified.
 Do not use this if dmeventd is already monitoring a device.
 .TP
-.I \-M, \-\-persistent y|n
+.BR \-M ", " \-\-persistent " {" \fIy | \fIn }
 Set to y to make the minor number specified persistent.
 .TP
-.I \-p, \-\-permission r|rw
+.BR \-p ", " \-\-permission " {" \fIr | \fIrw }
 Change access permission to read-only or read/write.
 .TP
-.I \-r, \-\-readahead ReadAheadSectors|auto|none
+.BR \-r ", " \-\-readahead " {" \fIReadAheadSectors | \fIauto | \fInone }
 Set read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
 be a value between 2 and 120 sectors.
@@ -107,16 +128,16 @@
 a suitable value automatically.
 "None" is equivalent to specifying zero.
 .TP
-.I \-\-refresh
+.B \-\-refresh
 If the logical volume is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
-if something has gone wrong or if you're doing clustering 
+if something has gone wrong or if you're doing clustering
 manually without a clustered lock manager.
 .SH Examples
-"lvchange -pr vg00/lvol1" changes the permission on 
-volume lvol1 in volume group vg00 to be read-only.
-
+Changes the permission on volume lvol1 in volume group vg00 to be read-only:
+.sp
+.B lvchange -pr vg00/lvol1
 .SH SEE ALSO
-.BR lvm (8), 
+.BR lvm (8),
 .BR lvcreate (8),
 .BR vgchange (8)
--- LVM2/man/lvconvert.8.in	2011/11/30 02:02:12	1.24
+++ LVM2/man/lvconvert.8.in	2012/04/11 12:42:10	1.25
@@ -3,62 +3,75 @@
 lvconvert \- convert a logical volume from linear to mirror or snapshot
 .SH SYNOPSIS
 .B lvconvert
-\-m|\-\-mirrors Mirrors [\-\-mirrorlog {disk|core|mirrored}] [\-\-corelog] [\-R|\-\-regionsize MirrorLogRegionSize]
-[\-\-type SegmentType]
-[\-A|\-\-alloc AllocationPolicy]
-[\-b|\-\-background] [\-f|\-\-force] [\-i|\-\-interval Seconds]
-[\-h|\-?|\-\-help]
-[\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
-[\-\-noudevsync]
-[\-v|\-\-verbose] [\-y|\-\-yes]
-[\-\-version]
-.br
-LogicalVolume[Path] [PhysicalVolume[Path][:PE[-PE]]...]
-.br
-
-.br
+.BR \-m | \-\-mirrors
+.I Mirrors
+.RB [ \-\-mirrorlog
+.RI { disk | core | mirrored }]
+.RB [ \-\-corelog ]
+.RB [ \-R | \-\-regionsize
+.IR MirrorLogRegionSize ]
+.RB [ \-\-type
+.IR SegmentType ]
+.RB [ \-A | \-\-alloc
+.IR AllocationPolicy ]
+.RB [ \-b | \-\-background ]
+.RB [ \-f | \-\-force ]
+.RB [ \-i | \-\-interval
+.IR Seconds ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-stripes
+.I Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-y | \-\-yes ]
+.RB [ \-\-version ]
+.IR LogicalVolume [ Path ]
+.RI [ PhysicalVolume [ Path ][ :PE [ -PE ]]...]
+.sp
+.B lvconvert \-\-splitmirrors \fIImages
+.RB [ \-\-name
+.IR SplitLogicalVolumeName ]
+.RB [ \-\-trackchanges ]
+.IR MirrorLogicalVolume [ Path ]
+.RI [ SplittablePhysicalVolume [ Path ][ :PE [ -PE ]]...]
+.sp
 .B lvconvert
-\-\-splitmirrors Images [\-\-name SplitLogicalVolumeName] [\-\-trackchanges]
-.br
-MirrorLogicalVolume[Path] [SplittablePhysicalVolume[Path][:PE[-PE]]...]
-.br
-
-.br
-.B lvconvert
-\-s|\-\-snapshot [\-c|\-\-chunksize ChunkSize]
-[\-h|\-?|\-\-help]
-[\-\-noudevsync]
-[\-v|\-\-verbose]
-[\-Z|\-\-zero y|n]
-[\-\-version]
-.br
-OriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]
-.br
-
-.br
-.B lvconvert
-\-\-merge [\-b|\-\-background] [\-i|\-\-interval Seconds]
-[\-h|\-?|\-\-help]
-[\-v|\-\-verbose]
-[\-\-version]
-LogicalVolume[Path]...
-.br
-
-.br
-.B lvconvert
-\-\-repair
-[\-h|\-?|\-\-help]
-[\-v|\-\-verbose]
-[\-\-version]
-LogicalVolume[Path] [PhysicalVolume[Path]...]
-
-.br
-.B lvconvert
-\-\-replace PhysicalVolume
-[\-h|\-?|\-\-help]
-[\-v|\-\-verbose]
-[\-\-version]
-LogicalVolume[Path] [PhysicalVolume[Path]...]
+.BR \-s | \-\-snapshot
+.RB [ \-c | \-\-chunksize
+.IR ChunkSize ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-Z | \-\-zero
+.RI { y | n }]
+.RB [ \-\-version ]
+.IR OriginalLogicalVolume [ Path ]
+.IR SnapshotLogicalVolume [ Path ]
+.sp
+.B lvconvert \-\-merge
+.RB [ \-b | \-\-background ]
+.RB [ \-i | \-\-interval
+.IR Seconds ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR LogicalVolume [ Path ]...
+.sp
+.B lvconvert \-\-repair
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR LogicalVolume [ Path ]
+.RI [ PhysicalVolume [ Path ]...]
+.sp
+.B lvconvert \-\-replace \fIPhysicalVolume
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.IR LogicalVolume [ Path ]
+.RI [ PhysicalVolume [ Path ]...]
 
 .SH DESCRIPTION
 lvconvert is used to change the segment type (i.e. linear, mirror, etc) or
@@ -75,19 +88,19 @@
 mirror legs) and you specify one or more PhysicalVolumes,
 the freed extents come first from the specified PhysicalVolumes.
 .SH OPTIONS
-See \fBlvm\fP for common options.
-.br
-Exactly one of \-\-splitmirrors, \-\-mirrors, \-\-repair, \-\-snapshot
-or \-\-merge arguments is required.
+See \fBlvm\fP(8) for common options.
 .br
+Exactly one of 
+.BR \-\-splitmirrors ", " \-\-mirrors ", " \-\-repair ", " \-\-snapshot
+or \fB\-\-merge\fP arguments is required.
 .TP
-.I \-m, \-\-mirrors Mirrors
+.BR \-m ", " \-\-mirrors " " \fIMirrors
 Specifies the degree of the mirror you wish to create.
-For example, "-m 1" would convert the original logical
+For example, "\fB-m 1\fP" would convert the original logical
 volume to a mirror volume with 2-sides; that is, a
 linear volume plus one copy.
 .TP
-.I \-\-mirrorlog {disk|core|mirrored}
+.IR \fB\-\-mirrorlog " {" disk | core | mirrored }
 Specifies the type of log to use.
 The default is disk, which is persistent and requires
 a small amount of storage space, usually on a separate device
@@ -97,76 +110,69 @@
 time the device is activated - perhaps, for example, after every reboot.
 Using "mirrored" will create a persistent log that is itself mirrored.
 .TP
-.I \-\-corelog
-The optional argument "--corelog" is the same as specifying "--mirrorlog core".
+.B \-\-corelog
+The optional argument \fB--corelog\fP is the same as specifying
+\fB--mirrorlog core\fP.
 .TP
-.I \-R, \-\-regionsize MirrorLogRegionSize
+.BR \-R ", " \-\-regionsize " " \fIMirrorLogRegionSize
 A mirror is divided into regions of this size (in MB), and the mirror log
 uses this granularity to track which regions are in sync.
 .TP
-.I \-\-type SegmentType
+.B \-\-type \fISegmentType
 Used to convert a logical volume to another segment type or to explicitly state
-the desired RAID1 segment type ("mirror" or "raid1") when converting a linear
-logical volume to a mirror with the '-m' argument.
+the desired RAID1 segment type (\fImirror\fP or \fIraid1\fP) when converting
+a linear logical volume to a mirror with the \fB-m\fP argument.
 .TP
-.I \-b, \-\-background
+.BR \-b ", " \-\-background
 Run the daemon in the background.
 .TP
-.I \-i, \-\-interval Seconds
+.BR \-i ", " \-\-interval " " \fISeconds
 Report progress as a percentage at regular intervals.
-.br
 .TP
-.I \-\-noudevsync
+.B \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
-.br
-
-
 .TP
-.I \-\-splitmirrors Images
+.B \-\-splitmirrors \fIImages
 The number of redundant Images of a mirror to be split off and used
 to form a new logical volume.  A name must be supplied for the
-newly-split-off logical volume using the \-\-name argument, unless
-the \-\-trackchanges argument is given.
-
+newly-split-off logical volume using the \fB\-\-name\fP argument, unless
+the \fB\-\-trackchanges\fP argument is given.
 .TP
-.I \-n Name
+.B \-n \fIName
 The name to apply to a logical volume which has been split off from
 a mirror logical volume.
-.br
-
 .TP
-.I \-\-trackchanges
-Used with \-\-splitmirrors on a raid1 device, this tracks changes so that the
-read-only detached image can be merged efficiently back into the mirror later.
-Only the regions of the detatched device where the data changed get resynchronized.
+.B \-\-trackchanges
+Used with \fB\-\-splitmirrors\fP on a raid1 device, this tracks changes so
+that the read-only detached image can be merged efficiently back into
+the mirror later. Only the regions of the detatched device where
+the data changed get resynchronized.
 
 Please note that this feature is only supported with the new md-based mirror
 implementation and not with the original device-mapper mirror implementation.
-.br
-
 .TP
-.I \-s, \-\-snapshot
+.B \-s, \-\-snapshot
 Create a snapshot from existing logical volume using another
 existing logical volume as its origin.
 .TP
-.I \-c, \-\-chunksize ChunkSize
-Power of 2 chunk size for the snapshot logical volume between 4k and 512k.
+.BR \-c ", " \-\-chunksize " " \fIChunkSize
+Power of 2 chunk size for the snapshot logical volume between 4KiB and 512KiB.
 .TP
-.I \-Z, \-\-zero y|n
+.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 Controls zeroing of the first KB of data in the snapshot.
 If the volume is read-only the snapshot will not be zeroed.
 .TP
-.I \-\-merge
+.B \-\-merge
 Merges a snapshot into its origin volume or merges a raid1 image that has
-been split from its mirror with \-\-trackchanges back into its mirror.
+been split from its mirror with \fB\-\-trackchanges\fP back into its mirror.
 
 To check if your kernel supports the snapshot merge feature, look
 for 'snapshot-merge' in the output
-of 'dmsetup targets'.  If both the origin and snapshot volume are not
+of \fBdmsetup targets\fP.  If both the origin and snapshot volume are not
 open the merge will start immediately.  Otherwise, the merge will start
 the first time either the origin or snapshot are activated and both are closed.
 Merging a snapshot into an origin that cannot be closed, for example a root
@@ -177,122 +183,107 @@
 merge finishes, the merged snapshot is removed.  Multiple snapshots may
 be specified on the commandline or a @tag may be used to specify
 multiple snapshots be merged to their respective origin.
-.br
-
 .TP
-.I \-\-repair
+.B \-\-repair
 Repair a mirror after suffering a disk failure. The mirror will be brought back
 into a consistent state.  By default, the original number of mirrors will be
-restored if possible.  Specify \-y on the command line to skip the prompts.
-Use \-f if you do not want any replacement.  Additionally, you may use
-\-\-use-policies to use the device replacement policy specified in lvm.conf,
+restored if possible.  Specify \fB\-y\fP on the command line to skip
+the prompts. Use \fB\-f\fP if you do not want any replacement.
+Additionally, you may use \fB\-\-use-policies\fP to use the device
+replacement policy specified in \fBlvm.conf\fP(5),
 viz. activation/mirror_log_fault_policy or
 activation/mirror_device_fault_policy.
-.br
-
 .TP
-.I \-\-replace PhysicalVolume
-Remove the specified device (PhysicalVolume) and replace it with one that is
-available in the volume group or from the specific list provided.  This option
-is only available to RAID segment types (e.g. "raid1", "raid5", etc).
-.br
+.B \-\-replace \fIPhysicalVolume
+Remove the specified device (\fIPhysicalVolume\fP) and replace it with one
+that is available in the volume group or from the specific list provided.
+This option is only available to RAID segment types
+(e.g. "raid1", "raid5", etc).
 
 .SH Examples
-"lvconvert -m1 vg00/lvol1"
-.br
-converts the linear logical volume "vg00/lvol1" to
-a two-way mirror logical volume.
-.br
-.SH Examples
-"lvconvert --type raid1 -m1 vg00/lvol1"
-.br
-converts the linear logical volume "vg00/lvol1" to a two-way RAID1
-logical volume.
-
-"lvconvert --mirrorlog core vg00/lvol1"
-.br
-converts a mirror with a disk log to a
-mirror with an in-memory log.
-
-"lvconvert --mirrorlog disk vg00/lvol1"
-.br
-converts a mirror with an in-memory log
-to a mirror with a disk log.
-
-"lvconvert -m0 vg00/lvol1"
-.br
-converts a mirror logical volume to a linear logical
-volume.
-.br
-"lvconvert --type raid1 vg00/mirror_lv"
-.br
-converts a mirror logical volume to a RAID1 logical volume with the same
-number of images.
-.br
-
-.br
-"lvconvert -s vg00/lvol1 vg00/lvol2"
-.br
-converts logical volume "vg00/lvol2" to snapshot of original volume "vg00/lvol1"
-
-.br
-"lvconvert -m1 vg00/lvol1 /dev/sda:0-15 /dev/sdb:0-15"
-.br
-converts linear logical volume "vg00/lvol1" to a two-way mirror, using physical
-extents /dev/sda:0-15 and /dev/sdb:0-15 for allocation of new extents.
-
-.br
-"lvconvert -m0 vg00/lvmirror1 /dev/sda"
-.br
-converts mirror logical volume "vg00/lvmirror1" to linear, freeing physical
-extents from /dev/sda.
-
-.br
-"lvconvert --merge vg00/lvol1_snap"
-.br
-merges "vg00/lvol1_snap" into its origin.
-
-.br
-"lvconvert --merge @some_tag"
-.br
-If vg00/lvol1, vg00/lvol2, and vg00/lvol3 are all tagged with "some_tag"
-each snapshot logical volume will be merged serially, e.g.: vg00/lvol1,
-then vg00/lvol2, then vg00/lvol3.  If --background were used it would start
+Converts the linear logical volume "vg00/lvol1" to a two-way mirror
+logical volume:
+.sp
+.B lvconvert \-m1 vg00/lvol1
+
+Converts the linear logical volume "vg00/lvol1" to a two-way RAID1
+logical volume:
+.sp
+.B lvconvert \-\-type raid1 \-m1 vg00/lvol1
+
+Converts a mirror with a disk log to a mirror with an in-memory log:
+.sp
+.B lvconvert \-\-mirrorlog core vg00/lvol1
+
+Converts a mirror with an in-memory log to a mirror with a disk log:
+.sp
+.B lvconvert \-\-mirrorlog disk vg00/lvol1
+
+Converts a mirror logical volume to a linear logical volume:
+.sp
+.B lvconvert \-m0 vg00/lvol1
+
+Converts a mirror logical volume to a RAID1 logical volume with the same
+number of images:
+.sp
+.B lvconvert \-\-type raid1 vg00/mirror_lv
+
+Converts logical volume "vg00/lvol2" to snapshot of original volume
+"vg00/lvol1":
+.sp
+.B lvconvert \-s vg00/lvol1 vg00/lvol2
+
+Converts linear logical volume "vg00/lvol1" to a two-way mirror,
+using physical extents /dev/sda:0-15 and /dev/sdb:0-15 for allocation
+of new extents:
+.sp
+.B lvconvert \-m1 vg00/lvol1 /dev/sda:0-15 /dev/sdb:0-15
+
+Converts mirror logical volume "vg00/lvmirror1" to linear, freeing physical
+extents from /dev/sda:
+.sp
+.B lvconvert \-m0 vg00/lvmirror1 /dev/sda
+
+Merges "vg00/lvol1_snap" into its origin:
+.sp
+.B lvconvert \-\-merge vg00/lvol1_snap
+
+If "vg00/lvol1", "vg00/lvol2" and "vg00/lvol3" are all tagged with "some_tag"
+each snapshot logical volume will be merged serially, 
+e.g.: "vg00/lvol1", then "vg00/lvol2", then "vg00/lvol3".
+If \-\-background were used it would start
 all snapshot logical volume merges in parallel.
+.sp
+.B lvconvert \-\-merge @some_tag
 
-.br
-"lvconvert --splitmirrors 1 --name lv_split vg00/lvmirror1"
-.br
-Extract one image from the mirror, making it a new logical volume named
+Extracts one image from the mirror, making it a new logical volume named
 "lv_split".  The mirror the image is extracted from is reduced accordingly.
 If it was a 2-way mirror (created with '-m 1'), then the resulting original
 volume will be linear.
+.sp
+.B lvconvert \-\-splitmirrors 1 \-\-name lv_split vg00/lvmirror1
 
-.br
-"lvconvert --splitmirrors 1 --trackchanges vg00/lv_raid1"
-.br
-A mirrored logical volume created with --type raid1 can use the '\-\-trackchanges' argument when splitting
-off an image.  
-
+A mirrored logical volume created with \-\-type raid1 can use the
+\-\-trackchanges argument when splitting off an image.
 Detach one image from the mirrored logical volume lv_raid1 as a separate
 read-only device and track the changes made to the mirror while it is detached.
 The split-off device has a name of the form lv_raid1_rimage_N, where N is
 a number, and it cannot be renamed.
+.sp
+.B lvconvert \-\-splitmirrors 1 \-\-trackchanges vg00/lv_raid1
 
-.br
-"lvconvert --merge vg00/lv_raid1_rimage_1"
-.br
-Merge an image that was detached temporarily from its mirror with 
-the '\-\-trackchanges' argument back into its original mirror and
+Merge an image that was detached temporarily from its mirror with
+the \-\-trackchanges argument back into its original mirror and
 bring its contents back up-to-date.
+.sp
+.B lvconvert \-\-merge vg00/lv_raid1_rimage_1
 
-.br
-"lvconvert --replace /dev/sdb1 vg00/my_raid1 /dev/sdf1"
-.br
-Replace the physical volume "/dev/sdb1" in the RAID1 logical volume "my_raid1"
+Replaces the physical volume "/dev/sdb1" in the RAID1 logical volume "my_raid1"
 with the specified physical volume "/dev/sdf1".  Had the argument "/dev/sdf1"
 been left out, lvconvert would attempt to find a suitable device from those
 available in the volume group.
+.sp
+.B lvconvert \-\-replace /dev/sdb1 vg00/my_raid1 /dev/sdf1
 
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/lvcreate.8.in	2012/03/06 09:22:02	1.36
+++ LVM2/man/lvcreate.8.in	2012/04/11 12:42:10	1.37
@@ -8,7 +8,7 @@
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
 .RB [ \-a | \-\-available
-.RI { y | n | ey | en | ly | ln }]
+.RI [ e | l ]{ y | n }]
 .RB [ \-A | \-\-autobackup
 .RI { y | n }]
 .RB [ \-C | \-\-contiguous
@@ -87,20 +87,20 @@
 .br
 
 .SH DESCRIPTION
-lvcreate creates a new logical volume in a volume group ( see
-.BR vgcreate "(8), " vgchange (8)
-) by allocating logical extents from the free physical extent pool
+lvcreate creates a new logical volume in a volume group (see
+.BR vgcreate "(8), " vgchange (8))
+by allocating logical extents from the free physical extent pool
 of that volume group.  If there are not enough free physical extents then
-the volume group can be extended ( see
-.BR vgextend (8)
-) with other physical volumes or by reducing existing logical volumes
-of this volume group in size ( see
-.BR lvreduce (8)
-). If you specify one or more PhysicalVolumes, allocation of physical
+the volume group can be extended (see
+.BR vgextend (8))
+with other physical volumes or by reducing existing logical volumes
+of this volume group in size (see
+.BR lvreduce (8)).
+If you specify one or more PhysicalVolumes, allocation of physical
 extents will be restricted to these volumes.
 .br
 .br
-The second form supports the creation of snapshot logical volumes which 
+The second form supports the creation of snapshot logical volumes which
 keep the contents of the original logical volume for backup purposes.
 .SH OPTIONS
 See
@@ -108,16 +108,16 @@
 for common options.
 .TP
 .IR \fB\-a ", " \fB\-\-available " {" y | n | ey | en | ly | ln }
-Controls the availability of the Logical Volumes for immediate use after 
+Controls the availability of the Logical Volumes for immediate use after
 the command finishes running.
 By default, new Logical Volumes are activated automatically (\fB-a\fIy\fR).
-If it is possible technically, \fB-a\fIn\fR will leave the new Logical Volume inactive.
-But for example, snapshots can only be created
-in the active state so \fB-a\fIn\fR cannot be used with --snapshot.
-Normally the --zero n argument has to be supplied too because zeroing (the
-default behaviour) also requires activation.
-If clustered locking is enabled, \fB-a\fIey\fR will activate exclusively
-on one node and \fB-a\fIly\fR will activate only on the local node.
+If it is possible technically, \fB-a\fIn\fR will leave the new Logical
+Volume inactive. But for example, snapshots can only be created
+in the active state so \fB\-a\fIn\fR cannot be used with \fB\-\-snapshot\fP.
+Normally the \fB\-\-zero n\fP argument has to be supplied too because
+zeroing (the default behaviour) also requires activation.
+If clustered locking is enabled, \fB\-a\fIey\fR will activate exclusively
+on one node and \fB\-a\fIly\fR will activate only on the local node.
 .TP
 .BR \-c ", " \-\-chunksize " " \fIChunkSize
 Gives the size of chunk for snapshot and thin pool logical volumes.
@@ -125,7 +125,7 @@
 and the default value is 4.
 For thin pools the value must be power of 2 between 64KiB and
 1048576KiB and the default value starts with 64 and scales
-up to fit the pool metadata size within 128MB, 
+up to fit the pool metadata size within 128MB,
 if the poolmetadata size is not specified.
 Default unit is in kilobytes.
 .TP
@@ -208,9 +208,9 @@
 .TP
 .BR \-\-monitor " {" \fIy | \fIn }
 Start or avoid monitoring a mirrored or snapshot logical volume with
-dmeventd, if it is installed. 
+dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
-the failure is handled according to 
+the failure is handled according to
 \fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
 set in \fBlvm.conf\fP.
 .TP
@@ -228,7 +228,6 @@
 Supported value is in range between 2MiB and 16GiB.
 Default value is  (Pool_LV_size / Pool_LV_chunk_size * 64b).
 Default unit is megabytes.
-
 .TP
 .IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
 Set read ahead sector count of this logical volume.
@@ -239,11 +238,10 @@
 "None" is equivalent to specifying zero.
 .TP
 .BR \-R ", " \-\-regionsize " " \fIMirrorLogRegionSize
-A mirror is divided into regions of this size (in MB), and the mirror log 
+A mirror is divided into regions of this size (in MB), and the mirror log
 uses this granularity to track which regions are in sync.
 .TP
 .IR \fB\-s ", " \fB\-\-snapshot " " OriginalLogicalVolume { Name | Path }
-
 Create a snapshot logical volume (or snapshot) for an existing, so called
 original logical volume (or origin).
 Snapshots provide a 'frozen image' of the contents of the origin
@@ -269,10 +267,10 @@
 .TP
 .IR \fB\-T ", " \fB\-\-thin ", " \fB\-\-thinpool " " ThinPoolLogicalVolume { Name | Path }
 Creates thin pool or thin logical volume or both.
-Specifying the optional argument --size will cause the creation of
+Specifying the optional argument \fB\-\-size\fP will cause the creation of
 the thin pool logical volume.
-Specifying the optional argument --virtualsize will cause the creation of
-the thin logical volume from given thin pool volume.
+Specifying the optional argument \fB\-\-virtualsize\fP will cause
+the creation of the thin logical volume from given thin pool volume.
 Specifying both arguments will cause the creation of both
 thin pool and thin volume using this pool.
 Requires device mapper kernel driver for thin provisioning
@@ -282,12 +280,14 @@
 Create a logical volume that uses the specified segment type
 (e.g. "raid5", "mirror", "snapshot", "thin", "thin-pool").
 Many segment types have a
-commandline switch alias that will enable their use (-s is an alias for
---type snapshot).  However, this argument must be used when no existing
-commandline switch alias is available for the desired type, as is the case
-with "error", "zero", "raid1", "raid4", "raid5", or "raid6".
+commandline switch alias that will enable their use
+(\fB\-s\fP is an alias for \fB\-\-type snapshot\fP).
+However, this argument must be used when no existing
+commandline switch alias is available for the desired type,
+as is the case with
+.IR error ", " zero ", " raid1 ", " raid4 ", " raid5 " or " raid6 .
 .TP
-.IR \fB\-V ", " \fB\-\-virtualsize " " VirtualSize [ bBsSkKmMgGtTpPeE ]
+.BR \-V ", " \-\-virtualsize " " \fIVirtualSize [ \fIbBsSkKmMgGtTpPeE ]
 Create a sparse device of the given size (in MB by default) using a snapshot
 or thinly provisioned device when thin pool is specified.
 Anything written to the device will be returned when reading from it.
@@ -309,59 +309,60 @@
 Warning: trying to mount an unzeroed logical volume can cause the system to
 hang.
 .SH Examples
-Creates a striped logical volume with 3 stripes, a stripesize of 8KB 
+Creates a striped logical volume with 3 stripes, a stripesize of 8KB
 and a size of 100MB in the volume group named vg00.
 The logical volume name will be chosen by lvcreate:
 .sp
-.B lvcreate -i 3 -I 8 -L 100M vg00
+.B lvcreate \-i 3 \-I 8 \-L 100M vg00
 
 Creates a mirror logical volume with 2 sides with a useable size of 500 MiB.
-This operation would require 3 devices (or option --alloc anywhere) - two 
-for the mirror devices and one for the disk log.
+This operation would require 3 devices (or option --alloc anywhere) - two
+for the mirror devices and one for the disk log:
 .sp
-.B lvcreate -m1 -L 500M vg00
+.B lvcreate \-m1 \-L 500M vg00
 
 Creates a mirror logical volume with 2 sides with a useable size of 500 MiB.
-This operation would require 2 devices - the log is "in-memory".
+This operation would require 2 devices - the log is "in-memory":
 .sp
-.B lvcreate -m1 --mirrorlog core -L 500M vg00
+.B lvcreate \-m1 \-\-mirrorlog core \-L 500M vg00
 
 Creates a snapshot logical volume named /dev/vg00/snap which has access to the
 contents of the original logical volume named /dev/vg00/lvol1
 at snapshot logical volume creation time. If the original logical volume
 contains a file system, you can mount the snapshot logical volume on an
 arbitrary directory in order to access the contents of the filesystem to run
-a backup while the original filesystem continues to get updated.
+a backup while the original filesystem continues to get updated:
 .sp
-.B lvcreate --size 100m --snapshot --name snap /dev/vg00/lvol1
+.B lvcreate \-\-size 100m \-\-snapshot \-\-name snap /dev/vg00/lvol1
 
-Creates a sparse device named /dev/vg1/sparse of size 1TB with space for just
-under 100MB of actual data on it.
+Creates a sparse device named /dev/vg1/sparse of size 1TiB with space for just
+under 100MiB of actual data on it:
 .sp
-.B lvcreate --virtualsize 1T --size 100M --snapshot --name sparse vg1
+.B lvcreate \-\-virtualsize 1T \-\-size 100M \-\-snapshot \-\-name sparse vg1
 
 Creates a linear logical volume "vg00/lvol1" using physical extents
-/dev/sda:0-7 and /dev/sdb:0-7 for allocation of extents.
+/dev/sda:0-7 and /dev/sdb:0-7 for allocation of extents:
 .sp
-.B lvcreate -L 64M -n lvol1 vg00 /dev/sda:0-7 /dev/sdb:0-7
+.B lvcreate \-L 64M -n lvol1 vg00 /dev/sda:0\-7 /dev/sdb:0\-7
 
 Creates a 5GiB RAID5 logical volume "vg00/my_lv", with 3 stripes (plus
-a parity drive for a total of 4 devices) and a stripesize of 64kiB.
+a parity drive for a total of 4 devices) and a stripesize of 64KiB:
 .sp
-.B lvcreate --type raid5 -L 5G -i 3 -I 64 -n my_lv vg00
+.B lvcreate \-\-type raid5 \-L 5G \-i 3 \-I 64 \-n my_lv vg00
 
 Creates 100MiB pool logical volume for thin provisioning
 build with 2 stripes 64KiB and chunk size 128KiB together with
-1TiB thin provisioned logical volume "vg00/thin_lv".
+1TiB thin provisioned logical volume "vg00/thin_lv":
 .sp
-.B lvcreate -i 2 -I 64 -c 256  -L100M -T vg00/pool -V 1T --name thin_lv
+.B lvcreate \-i 2 \-I 64 \-c 256 \-L100M \-T vg00/pool \-V 1T \-\-name thin_lv
 
 .SH SEE ALSO
-.BR lvm (8), 
-.BR vgcreate (8), 
-.BR lvremove (8), 
+.BR lvm (8),
+.BR vgcreate (8),
+.BR lvchange (8),
+.BR lvremove (8),
 .BR lvrename (8)
-.BR lvextend (8), 
-.BR lvreduce (8), 
-.BR lvdisplay (8), 
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvdisplay (8),
 .BR lvscan (8)
--- LVM2/man/lvdisplay.8.in	2010/04/27 13:34:56	1.4
+++ LVM2/man/lvdisplay.8.in	2012/04/11 12:42:10	1.5
@@ -3,57 +3,70 @@
 lvdisplay \- display attributes of a logical volume
 .SH SYNOPSIS
 .B lvdisplay
-[\-a|\-\-all]
-[\-c|\-\-colon] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure]
-[\-\-maps]
-[\-\-nosuffix]
-[\-P|\-\-partial]
-[\-\-units hHbBsSkKmMgGtTpPeE]
-[\-v|\-\-verbose]
-[\-\-version] [LogicalVolumePath [LogicalVolumePath...]]
+.RB [ \-a | \-\-all ]
+.RB [ \-c | \-\-colon ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-maps ]
+.RB [ \-\-nosuffix ]
+.RB [ \-P | \-\-partial ]
+.RB [ \-\-units
+.IR hHbBsSkKmMgGtTpPeE ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RI [ LogicalVolumePath
+.RI [ LogicalVolumePath ...]]
 .br
 
-.br
-.B lvdisplay \-\-columns | \-C
-[\-\-aligned]
-[\-a|\-\-all]
-[\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure]
-[\-\-noheadings]
-[\-\-nosuffix]
-[\-o|\-\-options [+]Field[,Field]]
-[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-P|\-\-partial]
-[\-\-segments]
-[\-\-separator Separator]
-[\-\-unbuffered]
-[\-\-units hHbBsSkKmMgGtTpPeE]
-[\-v|\-\-verbose]
-[\-\-version] [LogicalVolumePath [LogicalVolumePath...]]
+.B lvdisplay
+.BR \-\-columns | \-C
+.RB [ \-\-aligned ]
+.RB [ \-a | \-\-all ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-noheadings ]
+.RB [ \-\-nosuffix ]
+.RB [ \-o | \-\-options
+.RI [ + ] Field [ ,Field ...]]
+.RB [ \-O | \-\-sort
+.RI [ + | - ] Key1 [ , [ + | - ] Key2 ...]]
+.RB [ \-P | \-\-partial ]
+.RB [ \-\-segments ]
+.RB [ \-\-separator
+.IR Separator ]
+.RB [ \-\-unbuffered ]
+.RB [ \-\-units
+.IR hHbBsSkKmMgGtTpPeE ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RI [ LogicalVolumePath
+.RI [ LogicalVolumePath ...]]
 .SH DESCRIPTION
 lvdisplay allows you to see the attributes of a logical volume
 like size, read/write status, snapshot information etc.
 .P
-\fBlvs\fP (8) is an alternative that provides the same information 
-in the style of \fBps\fP (1).  \fBlvs\fP is recommended over
-\fBlvdisplay\fP.
+\fBlvs\fP(8) is an alternative that provides the same information
+in the style of \fBps\fP(1).
+\fBlvs\fP(8) is recommended over \fBlvdisplay\fP.
 
 .SH OPTIONS
-See \fBlvm\fP for common options and \fBlvs\fP for options given with
+See \fBlvm\fP(8) for common options and \fBlvs\fP for options given with
 \fB\-\-columns\fP.
 .TP
-.I \-\-all
+.B \-\-all
 Include information in the output about internal Logical Volumes that
 are components of normally-accessible Logical Volumes, such as mirrors,
 but which are not independently accessible (e.g. not mountable).
-For example, after creating a mirror using 'lvcreate -m1 --mirrorlog disk',
+For example, after creating a mirror using
+\fBlvcreate \-m1 \-\-mirrorlog disk\fP,
 this option will reveal three internal Logical Volumes, with suffixes
 mimage_0, mimage_1, and mlog.
 .TP
-.I \-c, \-\-colon
+.BR \-c ", " \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
-N.B. \fBlvs\fP (8) provides considerably more control over the output.
+N.B. \fBlvs\fP(8) provides considerably more control over the output.
 .nf
 
 The values are:
@@ -74,29 +87,30 @@
 
 .fi
 .TP
-.I \-m, \-\-maps
+.BR \-m ", " \-\-maps
 Display the mapping of logical extents to physical volumes and
 physical extents.  To map physical extents
-to logical extents use
-.BR
-\fBpvs --segments -o+lv_name,seg_start_pe,segtype\fP.
+to logical extents use:
+.B pvs \-\-segments \-o+lv_name,seg_start_pe,segtype
 .TP
-.I \-\-columns | \-C
-Display output in columns, the equivalent of \fBlvs\fP.  Options listed
-are the same as options given in \fBlvs (8)\fP.
+.BR \-\-columns ", " \-C
+Display output in columns, the equivalent of \fBlvs\fP. Options listed
+are the same as options given in \fBlvs\fP(8).
 .SH Examples
-"lvdisplay -v /dev/vg00/lvol2" shows attributes of that logical volume.
-If snapshot
+Shows attributes of that logical volume. If snapshot
 logical volumes have been created for this original logical volume,
 this command shows a list of all snapshot logical volumes and their
-status (active or inactive) as well.
-
-"lvdisplay /dev/vg00/snapshot" shows the attributes of this snapshot
-logical volume and also which original logical volume
-it is associated with.
+status (active or inactive) as well:
+.sp
+.B lvdisplay \-v /dev/vg00/lvol2
+
+Shows the attributes of this snapshot logical volume and also which
+original logical volume it is associated with:
+.sp
+.B lvdisplay /dev/vg00/snapshot
 
 .SH SEE ALSO
-.BR lvm (8), 
-.BR lvcreate (8), 
+.BR lvm (8),
+.BR lvcreate (8),
 .BR lvscan (8),
 .BR pvs (8)
--- LVM2/man/lvextend.8.in	2012/01/05 15:38:18	1.9
+++ LVM2/man/lvextend.8.in	2012/04/11 12:42:10	1.10
@@ -3,100 +3,114 @@
 lvextend \- extend the size of a logical volume
 .SH SYNOPSIS
 .B lvextend
-[\-\-alloc AllocationPolicy]
-[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-noudevsync]
-[\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
-{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |
-\-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
-[\-f|\-\-force]
-[\-n|\-\-nofsck]
-[\-r|\-\-resizefs]
-[\-t|\-\-test]
-[\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
+.RB [ \-\-alloc
+.IR AllocationPolicy ]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync]
+.RB [ \-i | \-\-stripes
+.I Stripes
+.RB [ \-I | \-\-stripesize
+.IR StripeSize ]]
+.RB { \-l | \-\-extents
+.RI [ + ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN }]
+|
+.BR \-L | \-\-size
+.RI [ + ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
+.RB [ \-f | \-\-force ]
+.RB [ \-n | \-\-nofsck ]
+.RB [ \-r | \-\-resizefs ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.I LogicalVolumePath
+.RI [ PhysicalVolumePath [ :PE [ -PE ]]...]
 .SH DESCRIPTION
 lvextend allows you to extend the size of a logical volume.
 Extension of snapshot logical volumes (see
-.B lvcreate(8)
+.BR lvcreate (8)
 for information to create snapshots) is supported as well.
 But to change the number of copies in a mirrored logical
-volume use 
+volume use
 .BR lvconvert (8).
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-\-noudevsync
+.B \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-l, \-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}]
+.IR \fB\-l ", " \fB\-\-extents " [" + ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN }]
 Extend or set the logical volume size in units of logical extents.
-With the + sign the value is added to the actual size
+With the '\fI+\fP' sign the value is added to the actual size
 of the logical volume and without it, the value is taken as an absolute one.
 The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG, relative to the existing
-size of the Logical Volume with the suffix %LV, of the remaining
-free space for the specified PhysicalVolume(s) with the suffix %PVS,
+in the Volume Group with the suffix \fI%VG\fP, relative to the existing
+size of the Logical Volume with the suffix \fI%LV\fP, of the remaining
+free space for the specified PhysicalVolume(s) with the suffix \fI%PVS\fP,
 as a percentage of the remaining free space in the Volume Group
-with the suffix %FREE, or (for a snapshot) as a percentage of the total
-space in the Origin Logical Volume with the suffix %ORIGIN.
+with the suffix \fI%FREE\fP, or (for a snapshot) as a percentage of the total
+space in the Origin Logical Volume with the suffix \fI%ORIGIN\fP.
 The resulting value is rounded upward.
 .TP
-.I \-L, \-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
+.IR \fB\-L ", " \fB\-\-size " [" + ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]
 Extend or set the logical volume size in units of megabytes.
 A size suffix of M for megabytes,
-G for gigabytes, T for terabytes, P for petabytes 
+G for gigabytes, T for terabytes, P for petabytes
 or E for exabytes is optional.
 With the + sign the value is added to the actual size
 of the logical volume and without it, the value is taken as an absolute one.
 .TP
-.I \-i, \-\-stripes Stripes
+.BR \-i ", " \-\-stripes " " \fIStripes
 Gives the number of stripes for the extension.
 Not applicable to LVs using the original metadata LVM format, which must
 use a single value throughout.
 .TP
-.I \-I, \-\-stripesize StripeSize
+.BR \-I ", " \-\-stripesize " " \fIStripeSize
 Gives the number of kilobytes for the granularity of the stripes.
 Not applicable to LVs using the original metadata LVM format, which must
 use a single value throughout.
 .br
 StripeSize must be 2^n (n = 2 to 9)
 .TP
-.I \-f, \-\-force
+.BR \-f ", " \-\-force
 Proceed with size extension without prompting.
 .TP
-.I \-n, \-\-nofsck
+.BR \-n ", " \-\-nofsck
 Do not perform fsck before extending filesystem when filesystem
-requires it. You may need to use \fB--force\fR to proceed with 
+requires it. You may need to use \fB\-\-force\fR to proceed with
 this option.
 .TP
-.I \-r, \-\-resizefs
-Resize underlying filesystem together with the logical volume using 
+.BR \-r ", " \-\-resizefs
+Resize underlying filesystem together with the logical volume using
 \fBfsadm\fR(8).
 .SH Examples
-"lvextend -L +54 /dev/vg01/lvol10 /dev/sdk3" tries to extend the size of
-that logical volume by 54MB on physical volume /dev/sdk3.
-This is only possible if /dev/sdk3 is a member of volume group vg01 and
-there are enough free physical extents in it.
+Extends the size of the logical volume "vg01/lvol10" by 54MiB on physical
+volume /dev/sdk3. This is only possible if /dev/sdk3 is a member of
+volume group vg01 and there are enough free physical extents in it:
+.sp
+.B lvextend -L +54 /dev/vg01/lvol10 /dev/sdk3
 
-"lvextend /dev/vg01/lvol01 /dev/sdk3" tries to extend the size of that
-logical volume by the amount of free space on physical volume /dev/sdk3.
-This is equivalent to specifying "-l +100%PVS" on the command line.
+Extends the size of logical volume "vg01/lvol01" by the amount of free
+space on physical volume /dev/sdk3. This is equivalent to specifying
+"-l +100%PVS" on the command line:
+.sp
+.B lvextend /dev/vg01/lvol01 /dev/sdk3
 
-.br
-"lvextend -L+16M vg01/lvol01 /dev/sda:8-9 /dev/sdb:8-9"
-.br
-tries to extend a logical volume "vg01/lvol01" by 16MB using physical extents
-/dev/sda:8-9 and /dev/sdb:8-9 for allocation of extents.
+Extends a logical volume "vg01/lvol01" by 16MiB using physical extents
+/dev/sda:8-9 and /dev/sdb:8-9 for allocation of extents:
+.sp
+.B lvextend -L+16M vg01/lvol01 /dev/sda:8-9 /dev/sdb:8-9
 
 .SH SEE ALSO
 .BR fsadm (8),
-.BR lvm (8), 
-.BR lvcreate (8), 
-.BR lvconvert (8), 
-.BR lvreduce (8), 
-.BR lvresize (8), 
+.BR lvm (8),
+.BR lvcreate (8),
+.BR lvconvert (8),
+.BR lvreduce (8),
+.BR lvresize (8),
 .BR lvchange (8)
--- LVM2/man/lvm.8.in	2012/03/01 10:39:21	1.9
+++ LVM2/man/lvm.8.in	2012/04/11 12:42:10	1.10
@@ -5,18 +5,18 @@
 .B lvm
 [command | file]
 .SH DESCRIPTION
-\fBlvm\fP provides the command-line tools for LVM2.  A separate
+lvm provides the command-line tools for LVM2.  A separate
 manual page describes each command in detail.
 .LP
 If \fBlvm\fP is invoked with no arguments it presents a readline prompt
 (assuming it was compiled with readline support).
-LVM commands may be entered interactively at this prompt with 
-readline facilities including history and command name and option 
+LVM commands may be entered interactively at this prompt with
+readline facilities including history and command name and option
 completion.  Refer to \fBreadline\fP(3) for details.
 .LP
 If \fBlvm\fP is invoked with argv[0] set to the name of a specific
-LVM command (for example by using a hard or soft link) it acts as 
-that command.  
+LVM command (for example by using a hard or soft link) it acts as
+that command.
 .LP
 On invocation, \fBlvm\fP requires that only the standard file descriptors
 stdin, stdout and stderr are available.  If others are found, they
@@ -24,16 +24,16 @@
 .LP
 Where commands take VG or LV names as arguments, the full path name is
 optional.  An LV called "lvol0" in a VG called "vg0" can be specified
-as "vg0/lvol0".  Where a list of VGs is required but is left empty, 
+as "vg0/lvol0".  Where a list of VGs is required but is left empty,
 a list of all VGs will be substituted.  Where a list of LVs is required
 but a VG is given, a list of all the LVs in that VG will be substituted.
-So "lvdisplay vg0" will display all the LVs in "vg0".
-Tags can also be used - see \fBaddtag\fP below.
+So \fBlvdisplay vg0\fP will display all the LVs in "vg0".
+Tags can also be used - see \fB\-\-addtag\fP below.
 .LP
-One advantage of using the built-in shell is that configuration 
-information gets cached internally between commands.  
+One advantage of using the built-in shell is that configuration
+information gets cached internally between commands.
 .LP
-A file containing a simple script with one command per line 
+A file containing a simple script with one command per line
 can also be given on the command line.  The script can also be
 executed directly if the first line is #! followed by the absolute
 path of \fBlvm\fP.
@@ -41,8 +41,8 @@
 The following commands are built into lvm without links normally
 being created in the filesystem for them.
 .TP
-\fBdumpconfig\fP \(em Display the configuration information after 
-loading \fBlvm.conf\fP (5) and any other configuration files.
+\fBdumpconfig\fP \(em Display the configuration information after
+loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
 \fBformats\fP \(em Display recognised metadata formats.
 .TP
@@ -143,111 +143,119 @@
 .TP
 The following commands are not implemented in LVM2 but might be in the future: lvmsadc, lvmsar, pvdata.
 .SH OPTIONS
-The following options are available for many of the commands. 
-They are implemented generically and documented here rather 
+The following options are available for many of the commands.
+They are implemented generically and documented here rather
 than repeated on individual manual pages.
 .TP
-\fB-h | --help\fP \(em Display the help text.
+.BR \-h ", " \-\-help
+Display the help text.
 .TP
-\fB--version\fP \(em Display version information.
+.B \-\-version
+Display version information.
 .TP
-\fB-v | --verbose\fP \(em Set verbose level.
-Repeat from 1 to 3 times to increase the detail of messages 
-sent to stdout and stderr.  Overrides config file setting.
-.TP
-\fB-d | --debug\fP \(em Set debug level.
-Repeat from 1 to 6 times to increase the detail of messages sent 
-to the log file and/or syslog (if configured).
+.BR \-v ", " \-\-verbose
+Set verbose level. Repeat from 1 to 3 times to increase the detail
+of messages sent to stdout and stderr.  Overrides config file setting.
+.TP
+.BR \-d ", " \-\-debug
+Set debug level. Repeat from 1 to 6 times to increase the detail of
+messages sent to the log file and/or syslog (if configured).
 Overrides config file setting.
 .TP
-\fB--quiet\fP \(em Suppress output and log messages.
-Overrides -d and -v.
+.B \-\-quiet
+Suppress output and log messages.
+Overrides \fB\-d\fP and \fB\-v\fP.
 .TP
-\fB-t | --test\fP \(em Run in test mode.
-Commands will not update metadata.
+.BR \-t ", " \-\-test
+Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function.  This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .TP
-\fB--driverloaded\fP { \fBy\fP | \fBn\fP }
+.BR \-\-driverloaded " {" \fIy | \fIn }
 Whether or not the device-mapper kernel driver is loaded.
-If you set this to \fBn\fP, no attempt will be made to contact the driver.
+If you set this to \fIn\fP, no attempt will be made to contact the driver.
 .TP
-\fB-A | --autobackup\fP { \fBy\fP | \fBn\fP }
-Whether or not to metadata should be backed up automatically after a change.  
+.BR \-A ", " \-\-autobackup " {" \fIy | \fIn }
+Whether or not to metadata should be backed up automatically after a change.
 You are strongly advised not to disable this!
-See
-.B vgcfgbackup (8).
+See \fBvgcfgbackup\fP(8).
 .TP
-\fB-P | --partial\fP
+.BR \-P ", " \-\-partial
 When set, the tools will do their best to provide access to volume groups
 that are only partially available (one or more physical volumes belonging
 to the volume group are missing from the system).  Where part of a logical
 volume is missing, \fB/dev/ioerror\fP will be substituted, and you could use
-\fBdmsetup (8)\fP to set this up to return I/O errors when accessed,
+\fBdmsetup\fP(8) to set this up to return I/O errors when accessed,
 or create it as a large block device of nulls.  Metadata may not be
 changed with this option. To insert a replacement physical volume
-of the same or large size use \fBpvcreate -u\fP to set the uuid to 
-match the original followed by \fBvgcfgrestore (8)\fP.
+of the same or large size use \fBpvcreate \-u\fP to set the uuid to
+match the original followed by \fBvgcfgrestore\fP(8).
 .TP
-\fB-M | --metadatatype type\fP
-Specifies which type of on-disk metadata to use, such as \fBlvm1\fP 
-or \fBlvm2\fP, which can be abbreviated to \fB1\fP or \fB2\fP respectively.
-The default (lvm2) can be changed by setting \fBformat\fP in the \fBglobal\fP
-section of the config file.
+.BR \-M ", " \-\-metadatatype " " \fIType
+Specifies which type of on-disk metadata to use, such as \fIlvm1\fP
+or \fIlvm2\fP, which can be abbreviated to \fI1\fP or \fI2\fP respectively.
+The default (\fIlvm2\fP) can be changed by setting \fBformat\fP
+in the \fBglobal\fP section of the config file.
 .TP
-\fB--ignorelockingfailure\fP
+.B \-\-ignorelockingfailure
 This lets you proceed with read-only metadata operations such as
-\fBlvchange -ay\fP and \fBvgchange -ay\fP even if the locking module fails.
-One use for this is in a system init script if the lock directory 
+\fBlvchange \-ay\fP and \fBvgchange \-ay\fP even if the locking module fails.
+One use for this is in a system init script if the lock directory
 is mounted read-only when the script runs.
 .TP
-\fB--addtag tag\fP
-Add the tag \fBtag\fP to a PV, VG or LV.  
+.B \-\-addtag \fITag
+Add the tag \fITag\fP to a PV, VG or LV.
 Supply this argument multiple times to add more than one tag at once.
-A tag is a word that can be used to group LVM2 objects of the same type 
-together. 
-Tags can be given on the command line in place of PV, VG or LV 
+A tag is a word that can be used to group LVM2 objects of the same type
+together.
+Tags can be given on the command line in place of PV, VG or LV
 arguments.  Tags should be prefixed with @ to avoid ambiguity.
 Each tag is expanded by replacing it with all objects possessing
 that tag which are of the type expected by its position on the command line.
 PVs can only possess tags while they are part of a Volume Group:
 PV tags are discarded if the PV is removed from the VG.
-As an example, you could tag some LVs as \fBdatabase\fP and others 
-as \fBuserdata\fP and then activate the database ones 
-with \fBlvchange -ay @database\fP.
+As an example, you could tag some LVs as \fBdatabase\fP and others
+as \fBuserdata\fP and then activate the database ones
+with \fBlvchange \-ay @database\fP.
 Objects can possess multiple tags simultaneously.
 Only the new LVM2 metadata format supports tagging: objects using the
 LVM1 metadata format cannot be tagged because the on-disk format does not
 support it.
 Snapshots cannot be tagged.
-Characters allowed in tags are: A-Z a-z 0-9 _ + . - and 
-as of version 2.02.78 the following characters are also
-accepted: / = ! : # &
+Characters allowed in tags are:
+.B A-Z a-z 0-9 _ + . -
+and as of version 2.02.78 the following characters are also accepted:
+.B / = ! : # &
 .TP
-\fB--deltag tag\fP
-Delete the tag \fBtag\fP from a PV, VG or LV, if it's present.
+.B \-\-deltag \fITag
+Delete the tag \fITag\fP from a PV, VG or LV, if it's present.
 Supply this argument multiple times to remove more than one tag at once.
 .TP
-\fB--alloc AllocationPolicy\fP
-The allocation policy to use: \fBcontiguous\fP, \fBcling\fP, \fBnormal\fP, \fBanywhere\fP or \fBinherit\fP.
+.B \-\-alloc \fIAllocationPolicy
+The allocation policy to use:
+.IR contiguous ,
+.IR cling ,
+.IR normal ,
+.IR anywhere " or"
+.IR inherit .
 When a command needs to allocate physical extents from the volume group,
-the allocation policy controls how they are chosen.  
+the allocation policy controls how they are chosen.
 Each volume group and logical volume has an allocation policy.
-The default for a volume group is \fBnormal\fP which applies
+The default for a volume group is \fInormal\fP which applies
 common-sense rules such as not placing parallel stripes on the same
-physical volume.  The default for a logical volume is \fBinherit\fP
+physical volume.  The default for a logical volume is \fIinherit\fP
 which applies the same policy as for the volume group.  These policies can
-be changed using \fBlvchange\fP (8) and \fBvgchange\fP (8) or over-ridden
+be changed using \fBlvchange\fP(8) and \fBvgchange\fP(8) or over-ridden
 on the command line of any command that performs allocation.
-The \fBcontiguous\fP policy requires that new extents be placed adjacent
-to existing extents. 
-The \fBcling\fP policy places new extents on the same physical
+The \fIcontiguous\fP policy requires that new extents be placed adjacent
+to existing extents.
+The \fIcling\fP policy places new extents on the same physical
 volume as existing extents in the same stripe of the Logical Volume.
 If there are sufficient free extents to satisfy
-an allocation request but \fBnormal\fP doesn't use them,
-\fBanywhere\fP will - even if that reduces performance by
+an allocation request but \fInormal\fP doesn't use them,
+\fIanywhere\fP will - even if that reduces performance by
 placing two stripes on the same physical volume.
 .IP
 N.B. The policies described above are not implemented fully yet.
@@ -255,22 +263,21 @@
 satisfy allocation attempts.
 .SH ENVIRONMENT VARIABLES
 .TP
-\fBLVM_SYSTEM_DIR\fP 
-Directory containing lvm.conf and other LVM
-system files.
-Defaults to "#DEFAULT_SYS_DIR#".
+.B HOME
+Directory containing \fI.lvm_history\fP if the internal readline
+shell is invoked.
 .TP
-\fBHOME\fP 
-Directory containing .lvm_history if the internal readline shell
-is invoked.
+.B LVM_SYSTEM_DIR
+Directory containing \fBlvm.conf\fP(5) and other LVM system files.
+Defaults to "#DEFAULT_SYS_DIR#".
 .TP
-\fBLVM_VG_NAME\fP 
-The volume group name that is assumed for 
+.B LVM_VG_NAME
+The volume group name that is assumed for
 any reference to a logical volume that doesn't specify a path.
 Not set by default.
 .SH VALID NAMES
 The following characters are valid for VG and LV names:
-\fBa-z A-Z 0-9 + _ . -\fP
+.B a-z A-Z 0-9 + _ . -
 .LP
 VG and LV names cannot begin with a hyphen.
 There are also various reserved names that are used internally by lvm that can not be used as LV or VG names.
@@ -326,4 +333,3 @@
 .BR vgsplit (8),
 .BR readline (3),
 .BR lvm.conf (5)
-
--- LVM2/man/lvm.conf.5.in	2012/01/12 02:32:09	1.23
+++ LVM2/man/lvm.conf.5.in	2012/04/11 12:42:10	1.24
@@ -4,35 +4,35 @@
 .SH SYNOPSIS
 .B #DEFAULT_SYS_DIR#/lvm.conf
 .SH DESCRIPTION
-lvm.conf is loaded during the initialisation phase of 
-\fBlvm\fP (8).  This file can in turn lead to other files
+lvm.conf is loaded during the initialisation phase of
+\fBlvm\fP(8).  This file can in turn lead to other files
 being loaded - settings read in later override earlier
-settings.  File timestamps are checked between commands and if 
-any have changed, all the files are reloaded.  
+settings.  File timestamps are checked between commands and if
+any have changed, all the files are reloaded.
 .LP
 Use \fBlvm dumpconfig\fP to check what settings are in use.
 .SH SYNTAX
 .LP
 This section describes the configuration file syntax.
 .LP
-Whitespace is not significant unless it is within quotes. 
+Whitespace is not significant unless it is within quotes.
 This provides a wide choice of acceptable indentation styles.
 Comments begin with # and continue to the end of the line.
 They are treated as whitespace.
 .LP
 Here is an informal grammar:
 .TP
-\fBfile = value*\fP
+.BR file " = " value *
 .br
 A configuration file consists of a set of values.
 .TP
-\fBvalue = section | assignment\fP
+.BR value " = " section " | " assignment
 .br
 A value can either be a new section, or an assignment.
 .TP
-\fBsection = identifier '{' value* '}'\fP
+.BR section " = " identifier " '" { "' " value "* '" } '
 .br
-A section is groups associated values together.  
+A section is groups associated values together.
 .br
 It is denoted by a name and delimited by curly brackets.
 .br
@@ -42,27 +42,27 @@
 .br
 	}
 .TP
-\fBassignment = identifier '=' (array | type)\fP
+.BR assignment " = " identifier " '" = "' ( " array " | " type " )"
 .br
 An assignment associates a type with an identifier.
 .br
 e.g.	max_archives = 42
 .br
 .TP
-\fBarray = '[' (type ',')* type ']' | '[' ']'\fP
+.BR array " =  '" [ "' ( " type " '" , "')* " type " '" ] "' | '" [ "' '" ] '
 .br
-Inhomogeneous arrays are supported. 
+Inhomogeneous arrays are supported.
 .br
-Elements must be separated by commas.  
+Elements must be separated by commas.
 .br
 An empty array is acceptable.
 .TP
-\fBtype = integer | float | string\fP
-\fBinteger = [0-9]*\fP
+.BR type " = " integer " | " float " | " string
+.BR integer " = [0-9]*"
 .br
-\fBfloat = [0-9]*\.[0-9]*\fP
+.BR float " = [0-9]*'" . '[0-9]*
 .br
-\fBstring = '"' .* '"'\fP
+.B string \fR= '\fB"\fR'.*'\fB"\fR'
 .IP
 Strings must be enclosed in double quotes.
 
@@ -73,10 +73,10 @@
 \fBdevices\fP \(em Device settings
 .IP
 \fBdir\fP \(em Directory in which to create volume group device nodes.
-Defaults to "/dev".  Commands also accept this as a prefix on volume 
+Defaults to "/dev".  Commands also accept this as a prefix on volume
 group names.
 .IP
-\fBscan\fP \(em List of directories to scan recursively for 
+\fBscan\fP \(em List of directories to scan recursively for
 LVM physical volumes.
 Devices in directories outside this hierarchy will be ignored.
 Defaults to "/dev".
@@ -102,35 +102,35 @@
 pattern in the list for any of the names is an \fBr\fP pattern it is rejected;
 otherwise it is accepted.  As an example, to ignore /dev/cdrom you could use:
 .br
-\fBdevices { filter=["r|cdrom|"] }\fP 
+\fBdevices { filter=["r|cdrom|"] }\fP
 .IP
 \fBcache_dir\fP \(em Persistent filter cache file directory.
 Defaults to "#DEFAULT_CACHE_DIR#".
 .IP
-\fBwrite_cache_state\fP \(em Set to 0 to disable the writing out of the 
+\fBwrite_cache_state\fP \(em Set to 0 to disable the writing out of the
 persistent filter cache file when \fBlvm\fP exits.
 Defaults to 1.
 .IP
 \fBtypes\fP \(em List of pairs of additional acceptable block device types
 found in /proc/devices together with maximum (non-zero) number of
-partitions (normally 16).  By default, LVM2 supports ide, sd, md, loop, 
+partitions (normally 16).  By default, LVM2 supports ide, sd, md, loop,
 dasd, dac960, nbd, ida, cciss, ubd, ataraid, drbd, power2, i2o_block
 and iseries/vd.  Block devices with major
-numbers of different types are ignored by LVM2.  
+numbers of different types are ignored by LVM2.
 Example: \fBtypes = ["fd", 16]\fP.
 To create physical volumes on device-mapper volumes
 created outside LVM2, perhaps encrypted ones from \fBcryptsetup\fP,
 you'll need \fBtypes = ["device-mapper", 16]\fP.  But if you do this,
-be careful to avoid recursion within LVM2.  The figure for number 
+be careful to avoid recursion within LVM2.  The figure for number
 of partitions is not currently used in LVM2 - and might never be.
 .IP
-\fBsysfs_scan\fP \(em If set to 1 and your kernel supports sysfs and 
+\fBsysfs_scan\fP \(em If set to 1 and your kernel supports sysfs and
 it is mounted, sysfs will be used as a quick way of filtering out
 block devices that are not present.
 .IP
 \fBmd_component_detection\fP \(em If set to 1, LVM2 will ignore devices
 used as components of software RAID (md) devices by looking for md
-superblocks. This doesn't always work satisfactorily e.g. if a device 
+superblocks. This doesn't always work satisfactorily e.g. if a device
 has been reused without wiping the md superblocks first.
 .IP
 \fBmd_chunk_alignment\fP \(em If set to 1, and a Physical Volume is placed
@@ -187,7 +187,7 @@
 should be issued by the kernel (TRIM, UNMAP, or WRITE SAME with UNMAP bit set).
 Not all storage will support or benefit from discards but SSDs and thinly
 provisioned LUNs generally do.  If set to 1, discards will only be issued if
-both the storage and kernel provide support.  
+both the storage and kernel provide support.
 .IP
 .TP
 \fBallocation\fP \(em Space allocation policies
@@ -200,9 +200,9 @@
 list of tags is defined here, it will check whether any of them are
 attached to the PVs concerned and then seek to match those PV tags
 between existing extents and new extents.
-.IP 
+.IP
 The @ prefix for tags is required.
-Use the special tag "@*" as a wildcard to match any PV tag and so use 
+Use the special tag "@*" as a wildcard to match any PV tag and so use
 all PV tags for this purpose.
 .IP
 For example, LVs are mirrored between two sites within a single VG.
@@ -228,12 +228,12 @@
 .IP
 \fBsyslog\fP \(em Set to 1 (the default) to send log messages through syslog.
 Turn off by setting to 0.  If you set to an integer greater than one,
-this is used - unvalidated - as the facility.  The default is LOG_USER.  
+this is used - unvalidated - as the facility.  The default is LOG_USER.
 See /usr/include/sys/syslog.h for safe facility values to use.
 For example, LOG_LOCAL0 might be 128.
 .IP
-\fBindent\fP \(em When set to 1 (the default) messages are indented 
-according to their severity, two spaces per level.  
+\fBindent\fP \(em When set to 1 (the default) messages are indented
+according to their severity, two spaces per level.
 Set to 0 to turn off indentation.
 .IP
 \fBcommand_names\fP \(em When set to 1, the command name is used as a
@@ -244,7 +244,7 @@
 Default is two spaces.
 .IP
 \fBactivation\fP \(em Set to 1 to log messages while
-devices are suspended during activation.  
+devices are suspended during activation.
 Only set this temporarily while debugging a problem because
 in low memory situations this setting can cause your machine to lock up.
 .TP
@@ -255,21 +255,21 @@
 Defaults to "#DEFAULT_ARCHIVE_DIR#".
 .IP
 \fBbackup_dir\fP \(em Directory used for automatic metadata backups.
-A single backup copy of the current metadata for each volume group 
+A single backup copy of the current metadata for each volume group
 is stored here.
 Defaults to "#DEFAULT_BACKUP_DIR#".
 .IP
 \fBarchive\fP \(em Whether or not tools automatically archive existing
 metadata into \fBarchive_dir\fP before making changes to it.
-Default is 1 (automatic archives enabled).  
-Set to 0 to disable.  
-Disabling this might make metadata recovery difficult or impossible 
+Default is 1 (automatic archives enabled).
+Set to 0 to disable.
+Disabling this might make metadata recovery difficult or impossible
 if something goes wrong.
 .IP
-\fBbackup\fP \(em Whether or not tools make an automatic backup 
-into \fBbackup_dir\fP after changing metadata.  
+\fBbackup\fP \(em Whether or not tools make an automatic backup
+into \fBbackup_dir\fP after changing metadata.
 Default is 1 (automatic backups enabled).  Set to 0 to disable.
-Disabling this might make metadata recovery difficult or impossible 
+Disabling this might make metadata recovery difficult or impossible
 if something goes wrong.
 .IP
 \fBretain_min\fP \(em Minimum number of archives to keep.
@@ -297,23 +297,23 @@
 .IP
 \fBumask\fP \(em File creation mask for any files and directories created.
 Interpreted as octal if the first digit is zero.
-Defaults to 077.  
+Defaults to 077.
 Use 022 to allow other users to read the files by default.
 .IP
 \fBformat\fP \(em The default value of \fB--metadatatype\fP used
-to determine which format of metadata to use when creating new 
+to determine which format of metadata to use when creating new
 physical volumes and volume groups. \fBlvm1\fP or \fBlvm2\fP.
 .IP
-\fBfallback_to_lvm1\fP \(em Set this to 1 if you need to 
+\fBfallback_to_lvm1\fP \(em Set this to 1 if you need to
 be able to switch between 2.4 kernels using LVM1 and kernels
 including device-mapper.
 The LVM2 tools should be installed as normal and
 the LVM1 tools should be installed with a .lvm1 suffix e.g.
-vgscan.lvm1.  
+vgscan.lvm1.
 If an LVM2 tool is then run but unable to communicate
-with device-mapper, it will automatically invoke the equivalent LVM1 
-version of the tool.  Note that for LVM1 tools to 
-manipulate physical volumes and volume groups created by LVM2 you 
+with device-mapper, it will automatically invoke the equivalent LVM1
+version of the tool.  Note that for LVM1 tools to
+manipulate physical volumes and volume groups created by LVM2 you
 must use \fB--metadataformat lvm1\fP when creating them.
 .IP
 \fBlibrary_dir\fP \(em A directory searched for LVM2's shared libraries
@@ -330,7 +330,7 @@
 machine. 0 disables locking and risks corrupting your metadata.
 If set to 2, the tools will load the external \fBlocking_library\fP
 (see below).
-If the tools were configured \fB--with-cluster=internal\fP 
+If the tools were configured \fB--with-cluster=internal\fP
 (the default) then 3 means to use built-in cluster-wide locking.
 Type 4 enforces read-only metadata and forbids any operations that
 might want to modify Volume Group metadata.
@@ -355,11 +355,11 @@
 Setting this to 0 does nothing, neither creating nor destroying any tag.
 The machine name used is the nodename as returned by \fBuname\fP (2).
 .IP
-Additional host tags to be set can be listed here as subsections. 
+Additional host tags to be set can be listed here as subsections.
 The @ prefix for tags is optional.
-Each of these host tag subsections can contain a \fBhost_list\fP 
-array of host names. If any one of these entries matches the machine 
-name exactly then the host tag gets defined on this particular host, 
+Each of these host tag subsections can contain a \fBhost_list\fP
+array of host names. If any one of these entries matches the machine
+name exactly then the host tag gets defined on this particular host,
 otherwise it doesn't.
 .IP
 After lvm.conf has been processed, LVM2 works through each host
@@ -378,9 +378,9 @@
 .IP
 These options are useful if you are replicating configuration files
 around a cluster.  Use of \fBhosttags = 1\fP means every machine
-can have static and identical local configuration files yet use 
+can have static and identical local configuration files yet use
 different settings and activate different logical volumes by
-default.  See also \fBvolume_list\fP below and \fB--addtag\fP 
+default.  See also \fBvolume_list\fP below and \fB--addtag\fP
 in \fBlvm\fP (8).
 .TP
 \fBactivation\fP \(em Settings affecting device-mapper activation
@@ -399,13 +399,13 @@
 \fBmirror_region_size\fP \(em Unit size in KB for copy operations
 when mirroring.
 .IP
-\fBreadahead\fP \(em Used when there is no readahead value stored 
+\fBreadahead\fP \(em Used when there is no readahead value stored
 in the volume group metadata.  Set to \fBnone\fP to disable
 readahead in these circumstances or \fBauto\fP to use the default
 value chosen by the kernel.
 .IP
-\fBreserved_memory\fP, \fBreserved_stack\fP \(em How many KB to reserve 
-for LVM2 to use while logical volumes are suspended.  If insufficient 
+\fBreserved_memory\fP, \fBreserved_stack\fP \(em How many KB to reserve
+for LVM2 to use while logical volumes are suspended.  If insufficient
 memory is reserved before suspension, there is a risk of machine deadlock.
 .IP
 \fBprocess_priority\fP \(em The nice value to use while devices are
@@ -417,7 +417,7 @@
 all requests to activate a logical volume on this machine
 are passed.  A logical volume is only activated if it matches
 an item in the list.  Tags must be preceded by @ and are checked
-against all tags defined in the logical volume and volume group 
+against all tags defined in the logical volume and volume group
 metadata for a match.
 @* is short-hand to check every tag set on the host machine (see
 \fBtags\fP above).
@@ -440,8 +440,8 @@
 .IP
 \fBpvmetadatacopies\fP \(em When creating a physical volume using the
 LVM2 metadata format, this is the default number of copies of metadata
-to store on each physical volume.  
-Currently it can be set to 0, 1 or 2.  The default is 1.  
+to store on each physical volume.
+Currently it can be set to 0, 1 or 2.  The default is 1.
 If set to 2, one copy is placed at the beginning of the disk
 and the other is placed at the end.
 It can be overridden on the command line with \fB--pvmetadatacopies\fP
@@ -450,7 +450,7 @@
 good idea to have 2 copies.  If creating a large volume group with
 many physical volumes, you may decide that 3 copies of the metadata
 is sufficient, i.e. setting it to 1 on three of the physical volumes,
-and 0 on the rest.  Every volume group must contain at least one 
+and 0 on the rest.  Every volume group must contain at least one
 physical volume with at least 1 copy of the metadata (unless using
 the text files described below).  The disadvantage of having lots
 of copies is that every time the tools access the volume group, every
@@ -459,7 +459,7 @@
 .IP
 \fBpvmetadatasize\fP \(em Approximate number of sectors to set aside
 for each copy of the metadata. Volume groups with large numbers of
-physical or logical volumes, or volumes groups containing complex 
+physical or logical volumes, or volumes groups containing complex
 logical volume structures will need additional space for their metadata.
 The metadata areas are treated as circular buffers, so
 unused space becomes filled with an archive of the most recent
@@ -507,16 +507,20 @@
 Alternatively these directories can be in addition to the
 on-disk metadata areas.  This feature was created during the
 development of the LVM2 metadata before the new on-disk metadata
-areas were designed and no longer gets tested.  
-It is not supported under low-memory conditions, and it is 
-important never to edit these metadata files unless you fully 
-understand how things work: to make changes you should always use 
+areas were designed and no longer gets tested.
+It is not supported under low-memory conditions, and it is
+important never to edit these metadata files unless you fully
+understand how things work: to make changes you should always use
 the tools as normal, or else vgcfgbackup, edit backup, vgcfgrestore.
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
+.br
 .I #DEFAULT_ARCHIVE_DIR#
+.br
 .I #DEFAULT_BACKUP_DIR#
+.br
 .I #DEFAULT_CACHE_DIR#/.cache
+.br
 .I #DEFAULT_LOCK_DIR#
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/lvmchange.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvmchange.8.in	2012/04/11 12:42:10	1.2
@@ -5,6 +5,6 @@
 .B lvmchange
 .SH DESCRIPTION
 lvmchange is not currently supported under LVM2, although
-\fBdmsetup (8)\fP has a \fBremove_all\fP command.
+\fBdmsetup\fP(8) has a \fBremove_all\fP command.
 .SH SEE ALSO
 .BR dmsetup (8)
--- LVM2/man/lvmconf.8.in	2010/06/21 15:56:59	1.2
+++ LVM2/man/lvmconf.8.in	2012/04/11 12:42:10	1.3
@@ -6,15 +6,18 @@
 
 .SH "SYNOPSIS"
 .B lvmconf
-[\-\-disable-cluster]
-[\-\-enable-cluster]
-[\-\-file <configfile>]
-[\-\-lockinglib <lib>]
-[\-\-lockinglibdir <dir>]
+.RB [ \-\-disable-cluster ]
+.RB [ \-\-enable-cluster ]
+.RB [ \-\-file
+.RI < configfile >]
+.RB [ \-\-lockinglib
+.RI < lib >]
+.RB [ \-\-lockinglibdir
+.RI < dir >]
 
 .SH "DESCRIPTION"
-.B lvmconf
-is a script that modifies the locking configuration in an lvm configuration file. See \fBlvm.conf\fP(5).
+lvmconf is a script that modifies the locking configuration in
+an lvm configuration file. See \fBlvm.conf\fP(5).
 
 .SH "OPTIONS"
 .TP
@@ -24,13 +27,14 @@
 .BR \-\-enable-cluster
 Set \fBlocking_type\fR to the default clustered type on this system.
 .TP
-.BR \-\-file " " \fI<configfile>\fR
-Apply the changes to \fBconfigfile\fR instead of the default \fB#DEFAULT_SYS_DIR#/lvm.conf\fR.
+.BR \-\-file " <" \fIconfigfile >
+Apply the changes to \fIconfigfile\fP instead of the default
+\fI#DEFAULT_SYS_DIR#/lvm.conf\fP.
 .TP
-.BR \-\-lockinglib " " \fI<lib>\fR
+.BR \-\-lockinglib " <" \fIlib >
 Set external \fBlocking_library\fR locking library to load if an external locking type is used.
 .TP
-.BR \-\-lockinglibdir " " \fI<dir>\fR
+.BR \-\-lockinglibdir " <" \fIdir >
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
 
--- LVM2/man/lvmdiskscan.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/lvmdiskscan.8.in	2012/04/11 12:42:10	1.3
@@ -3,22 +3,23 @@
 lvmdiskscan \- scan for all devices visible to LVM2
 .SH SYNOPSIS
 .B lvmdiskscan
-[\-d|\-\-debug] [\-h|\-?|\-\-help] 
-[\-l|\-\-lvmpartition]
-[\-v|\-\-verbose]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-l | \-\-lvmpartition ]
+.RB [ \-v | \-\-verbose ]
 .SH DESCRIPTION
-\fBlvmdiskscan\fP scans all SCSI, (E)IDE disks, multiple devices and a bunch
+lvmdiskscan scans all SCSI, (E)IDE disks, multiple devices and a bunch
 of other block devices in the system looking for LVM physical volumes.
 The size reported is the real device size.
-Define a filter in \fBlvm.conf\fP(5) to restrict 
+Define a filter in \fBlvm.conf\fP(5) to restrict
 the scan to avoid a CD ROM, for example.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-l, \-\-lvmpartition
+.BR \-l ", " \-\-lvmpartition
 Only reports Physical Volumes.
 .SH SEE ALSO
-.BR lvm (8), 
+.BR lvm (8),
 .BR lvm.conf (5),
 .BR pvscan (8),
 .BR vgscan (8)
--- LVM2/man/lvmdump.8.in	2010/06/24 08:18:54	1.2
+++ LVM2/man/lvmdump.8.in	2012/04/11 12:42:10	1.3
@@ -2,9 +2,17 @@
 .SH NAME
 lvmdump - create lvm2 information dumps for diagnostic purposes
 .SH SYNOPSIS
-\fBlvmdump\fP [options] [-d directory]
+.B lvmdump
+.RB [ \-a ]
+.RB [ \-c ]
+.RB [ \-d
+.IR directory ]
+.RB [ \-h ]
+.RB [ \-m ]
 .SH DESCRIPTION
-\fBlvmdump\fP is a tool to dump various information concerning LVM2. By default, it creates a tarball suitable for submission along with a problem report.
+lvmdump is a tool to dump various information concerning LVM2.
+By default, it creates a tarball suitable for submission along
+with a problem report.
 .PP
 The content of the tarball is as follows:
 .br
@@ -22,33 +30,45 @@
 .br
 - list of files present /sys/devices/virtual/block
 .br
-- if enabled with -m, metadata dump will be also included
+- if enabled with \-m, metadata dump will be also included
 .br
-- if enabled with -a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
+- if enabled with \-a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
 .br
-- if enabled with -c, cluster status info
+- if enabled with \-c, cluster status info
 .SH OPTIONS
 .TP
-\fB\-h\fR \(em print help message
-.TP
-\fB\-a\fR \(em advanced collection 
-\fBWARNING\fR: if lvm is already hung, then this script may hang as well if \fB\-a\fR is used
-.TP
-\fB\-m\fR \(em gather LVM metadata from the PVs
-This option generates a 1:1 dump of the metadata area from all PVs visible to the system, which can cause the dump to increase in size considerably. However, the metadata dump may represent a valuable diagnostic resource.
-.TP
-\fB\-d\fR directory \(em dump into a directory instead of tarball
-By default, lvmdump will produce a single compressed tarball containing all the information. Using this option, it can be instructed to only produce the raw dump tree, rooted in \fBdirectory\fP.
-.TP
-\fB\-c\fR \(em if clvmd is running, gather cluster data as well
+.B \-a
+Advanced collection.
+\fBWARNING\fR: if lvm is already hung, then this script may hang as well
+if \fB\-a\fR is used.
+.TP
+.B \-c
+If clvmd is running, gather cluster data as well.
+.TP
+.B \-d  \fIdirectory
+Dump into a directory instead of tarball
+By default, lvmdump will produce a single compressed tarball containing
+all the information. Using this option, it can be instructed to only
+produce the raw dump tree, rooted in \fIdirectory\fP.
+.TP
+.B \-h
+Print help message
+.TP
+.B \-m
+Gather LVM metadata from the PVs
+This option generates a 1:1 dump of the metadata area from all PVs visible
+to the system, which can cause the dump to increase in size considerably.
+However, the metadata dump may represent a valuable diagnostic resource.
 .SH ENVIRONMENT VARIABLES
 .TP
-\fBLVM_BINARY\fP 
+\fBLVM_BINARY\fP
 The LVM2 binary to use.
 Defaults to "lvm".
 Sometimes you might need to set this to "/sbin/lvm.static", for example.
 .TP
-\fBDMSETUP_BINARY\fP 
+\fBDMSETUP_BINARY\fP
 The dmsetup binary to use.
 Defaults to "dmsetup".
 .PP
+.SH SEE ALSO
+.BR lvm (8)
--- LVM2/man/lvmsadc.8.in	2010/06/18 10:19:30	1.1
+++ LVM2/man/lvmsadc.8.in	2012/04/11 12:42:10	1.2
@@ -7,8 +7,7 @@
 .B lvmsadc
 
 .SH "DESCRIPTION"
-.B lvmsadc
-is not currently supported under LVM2.
+lvmsadc is not currently supported under LVM2.
 
 .SH "SEE ALSO"
 .BR lvm (8)
--- LVM2/man/lvmsar.8.in	2010/06/18 10:19:30	1.1
+++ LVM2/man/lvmsar.8.in	2012/04/11 12:42:10	1.2
@@ -7,8 +7,7 @@
 .B lvmsar
 
 .SH "DESCRIPTION"
-.B lvmsar
-is not currently supported under LVM2.
+lvmsar is not currently supported under LVM2.
 
 .SH "SEE ALSO"
 .BR lvm (8)
--- LVM2/man/lvreduce.8.in	2012/01/05 15:38:18	1.10
+++ LVM2/man/lvreduce.8.in	2012/04/11 12:42:10	1.11
@@ -12,9 +12,9 @@
 .RB [ \-\-version ]
 .RB [ \-f | \-\-force ]
 .RB [ \-\-noudevsync ]
-.RB { \-l | \-\-extents 
+.RB { \-l | \-\-extents
 .RI [ \- ] LogicalExtentsNumber [ % { VG | LV | FREE | ORIGIN "}] |"
-.RB [ \-L | \-\-size 
+.RB [ \-L | \-\-size
 .RI [ \- ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
 .RB [ \-n | \-\-nofsck ]
 .RB [ \-r | \-\-resizefs ]
@@ -22,9 +22,9 @@
 .SH DESCRIPTION
 lvreduce allows you to reduce the size of a logical volume.
 Be careful when reducing a logical volume's size, because data in the
-reduced part is lost!!! 
-.br 
-You should therefore ensure that any filesystem on the volume is 
+reduced part is lost!!!
+.br
+You should therefore ensure that any filesystem on the volume is
 resized
 .I before
 running lvreduce so that the extents that are to be removed are not in use.
@@ -33,7 +33,7 @@
 .BR lvcreate (8)
 for information to create snapshots) is supported as well.
 But to change the number of copies in a mirrored logical
-volume use 
+volume use
 .BR lvconvert (8).
 .br
 Sizes will be rounded if necessary - for example, the volume size must
@@ -41,20 +41,11 @@
 be a multiple of the number of stripes.
 .br
 .SH OPTIONS
-See 
-.BR lvm (8)
-for common options.
+See \fBlvm\fP(8) for common options.
 .TP
 .BR \-f ", " \-\-force
 Force size reduction without prompting even when it may cause data loss.
 .TP
-.BR \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
-.TP
 .IR \fB\-l ", " \fB\-\-extents " [" \- ] LogicalExtentsNumber [ % { VG | LV | FREE | ORIGIN }]
 Reduce or set the logical volume size in units of logical extents.
 With the \fI-\fP sign the value will be subtracted from
@@ -74,28 +65,35 @@
 A size suffix of \fIk\fP for kilobyte, \fIm\fP for megabyte,
 \fIg\fP for gigabytes, \fIt\fP for terabytes, \fIp\fP for petabytes
 or \fIe\fP for exabytes is optional.
-With the \fI-\fP sign the value will be subtracted from
+With the \fI\-\fP sign the value will be subtracted from
 the logical volume's actual size and without it it will be taken as
 an absolute size.
 .TP
 .BR \-n ", " \-\-nofsck
 Do not perform fsck before resizing filesystem when filesystem
-requires it. You may need to use \fB--force\fR to proceed with 
+requires it. You may need to use \fB\-\-force\fR to proceed with
 this option.
 .TP
+.BR \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .BR \-r ", " \-\-resizefs
-Resize underlying filesystem together with the logical volume using 
+Resize underlying filesystem together with the logical volume using
 .BR fsadm (8).
-.SH EXAMPLES
+.SH Examples
 Reduce the size of logical volume lvol1 in volume group vg00 by 3 logical extents:
 .sp
-.B lvreduce -l -3 vg00/lvol1
+.B lvreduce \-l \-3 vg00/lvol1
 .SH SEE ALSO
 .BR fsadm (8),
 .BR lvchange (8),
-.BR lvconvert (8), 
-.BR lvcreate (8), 
-.BR lvextend (8), 
-.BR lvm (8), 
+.BR lvconvert (8),
+.BR lvcreate (8),
+.BR lvextend (8),
+.BR lvm (8),
 .BR lvresize (8),
 .BR vgreduce (8)
--- LVM2/man/lvremove.8.in	2011/09/07 08:50:35	1.5
+++ LVM2/man/lvremove.8.in	2012/04/11 12:42:10	1.6
@@ -15,7 +15,7 @@
 .IR LogicalVolume { Name |  Path }
 .RI [ LogicalVolume { Name | Path }...]
 .SH DESCRIPTION
-\fBlvremove\fP removes one or more logical volumes.
+lvremove removes one or more logical volumes.
 Confirmation will be requested before deactivating any active logical
 volume prior to removal.  Logical volumes cannot be deactivated
 or removed while they are open (e.g. if they contain a mounted filesystem).
@@ -36,20 +36,20 @@
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
-.SH EXAMPLES
-Remove the active logical volume lvol1 in volume group vg00 
+.SH Examples
+Remove the active logical volume lvol1 in volume group vg00
 without asking for confirmation:
 .sp
-.B lvremove -f vg00/lvol1
+.B lvremove \-f vg00/lvol1
 .sp
 Remove all logical volumes in volume group vg00:
 .sp
 .B lvremove vg00
 .SH SEE ALSO
-.BR lvcreate (8), 
+.BR lvcreate (8),
 .BR lvdisplay (8),
-.BR lvchange (8),  
-.BR lvm (8), 
+.BR lvchange (8),
+.BR lvm (8),
 .BR lvs (8),
 .BR lvscan (8),
 .BR vgremove (8)
--- LVM2/man/lvrename.8.in	2011/09/07 08:50:35	1.4
+++ LVM2/man/lvrename.8.in	2012/04/11 12:42:10	1.5
@@ -15,11 +15,9 @@
 .RI { OldLogicalVolume { Name | Path }
 .IR NewLogicalVolume { Name | Path }
 |
-.I VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName
-}
+.I VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName\fR}
 .SH DESCRIPTION
-.B lvrename
-renames an existing logical volume from
+lvrename renames an existing logical volume from
 .IR OldLogicalVolume { Name | Path }
 to
 .IR NewLogicalVolume { Name | Path }.
--- LVM2/man/lvs.8.in	2012/01/20 22:03:04	1.20
+++ LVM2/man/lvs.8.in	2012/04/11 12:42:10	1.21
@@ -14,7 +14,7 @@
 .RB [ \-o | \-\-options
 .RI [ + ] Field [, Field ]]
 .RB [ \-O | \-\-sort
-.RI [ + | - ] Key1 [,[ + | - ] Key2 [,...]]]
+.RI [ + | \- ] Key1 [,[ + | \- ] Key2 [,...]]]
 .RB [ \-P | \-\-partial ]
 .RB [ \-\-rows ]
 .RB [ \-\-segments ]
@@ -41,17 +41,18 @@
 are components of normally-accessible Logical Volumes, such as mirrors,
 but which are not independently accessible (e.g. not mountable).
 The names of such Logical Volumes are enclosed within square brackets
-in the output.  For example, after creating a mirror using 'lvcreate -m1
---mirrorlog disk', this option will reveal three internal Logical
+in the output.  For example, after creating a mirror using
+.B lvcreate -m1 --mirrorlog disk
+, this option will reveal three internal Logical
 Volumes, with suffixes mimage_0, mimage_1, and mlog.
 .TP
 .B \-\-aligned
-Use with \-\-separator to align the output columns.
+Use with \fB\-\-separator\fP to align the output columns.
 .TP
 .B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
-with --noheadings to produce a list of field=value pairs that can
-be used to set environment variables (for example, in 
+with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
+be used to set environment variables (for example, in
 .BR udev (7)
 rules).
 .TP
@@ -60,17 +61,18 @@
 Useful if grepping the output.
 .TP
 .B \-\-nosuffix
-Suppress the suffix on output sizes.  Use with \-\-units (except h and H)
-if processing the output.
+Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
+(except h and H) if processing the output.
 .TP
 .BR \-o ", " \-\-options
 Comma-separated ordered list of columns.  Precede the list with '+' to append
 to the default selection of columns instead of replacing it.
 .IP
-Use \fb-o lv_all\fP to select all logical volume columns, and \fb-o seg_all\fP
+Use \fB\-o lv_all\fP to select all logical volume columns,
+and \fB\-o seg_all\fP
 to select all logical volume segment columns.
 .IP
-Use \fb-o help\fP to view the full list of columns available.
+Use \fB\-o help\fP to view the full list of columns available.
 .IP
 Column names include:
 lv_uuid, lv_name, lv_path, lv_attr, lv_major, lv_minor, lv_read_ahead, lv_kernel_major,
@@ -79,12 +81,12 @@
 segtype, stripes, stripesize, regionsize, chunksize, seg_start, seg_start_pe,
 seg_size, seg_tags, seg_pe_ranges, devices.
 .IP
-With \-\-segments, any "seg_" prefixes are optional; otherwise any "lv_"
-prefixes are optional.  Columns mentioned in
+With \fB\-\-segments\fP, any "seg_" prefixes are optional;
+otherwise any "lv_" prefixes are optional. Columns mentioned in
 .BR vgs (8)
 can also be chosen.
 .IP
-The lv_attr bits are: 
+The lv_attr bits are:
 .RS
 .IP 1 3
 Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin,
@@ -110,7 +112,7 @@
 .IP 6 3
 device (o)pen
 .IP 7 3
-Target type: (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.  
+Target type: (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.
 This groups logical volumes related to the same kernel target together.  So,
 for example, mirror images, mirror logs as well as mirrors themselves appear as
 (m) if they use the original device-mapper mirror kernel driver; whereas the raid
@@ -126,7 +128,7 @@
 .TP
 .BR \-O ", " \-\-sort
 Comma-separated ordered list of columns to sort by.  Replaces the default
-selection. Precede any column with - for a reverse sort on that column.
+selection. Precede any column with '\fI\-\fP' for a reverse sort on that column.
 .TP
 .B \-\-rows
 Output columns as rows.
@@ -139,12 +141,13 @@
 .TP
 .B \-\-units \fIhHbBsSkKmMgGtTpPeE
 All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
-Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
-custom units e.g. \-\-units 3M
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
+Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify
+custom units e.g. \fB\-\-units 3M\fP
 .TP
 .B \-\-unquoted
-When used with --nameprefixes, output values in the field=value pairs are not quoted.
+When used with \fB\-\-nameprefixes\fP, output values in the field=value
+pairs are not quoted.
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvdisplay (8),
--- LVM2/man/lvscan.8.in	2011/01/24 20:02:08	1.3
+++ LVM2/man/lvscan.8.in	2012/04/11 12:42:10	1.4
@@ -11,29 +11,29 @@
 .RB [ \-P | \-\-partial ]
 .RB [ \-v | \-\-verbose ]
 .SH DESCRIPTION
-.B lvscan
-scans all known volume groups or all supported LVM block devices
+lvscan scans all known volume groups or all supported LVM block devices
 in the system for defined Logical Volumes.  The output consists
-of one line for each Logical Volume indicating whether or not it is active, 
+of one line for each Logical Volume indicating whether or not it is active,
 a snapshot or origin, the size of the device and its allocation policy.
-Use \fBlvs(8)\fP or \fBlvdisplay(8)\fP to obtain more-comprehensive information 
-about the Logical Volumes.
+Use \fBlvs\fP(8) or \fBlvdisplay\fP(8) to obtain more-comprehensive
+information about the Logical Volumes.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
 .BR \-\-all
 Include information in the output about internal Logical Volumes that
 are components of normally-accessible Logical Volumes, such as mirrors,
 but which are not independently accessible (e.g. not mountable).
-For example, after creating a mirror using 'lvcreate -m1 --mirrorlog disk',
+For example, after creating a mirror using
+.B lvcreate \-m1 \-\-mirrorlog disk\fR,
 this option will reveal three internal Logical Volumes, with suffixes
 mimage_0, mimage_1, and mlog.
 .TP
 .BR \-b ", " \-\-blockdevice
-This option is now ignored.  Instead, use \fBlvs(8)\fP or \fBlvdisplay(8)\fP to obtain
-the device number.
+This option is now ignored.  Instead, use \fBlvs\fP(8) or
+\fBlvdisplay\fP(8) to obtain the device number.
 .SH SEE ALSO
-.BR lvm (8), 
+.BR lvm (8),
 .BR lvcreate (8),
 .BR lvdisplay (8)
 .BR lvs (8)
--- LVM2/man/pvchange.8.in	2010/07/13 15:04:23	1.6
+++ LVM2/man/pvchange.8.in	2012/04/11 12:42:10	1.7
@@ -3,40 +3,51 @@
 pvchange \- change attributes of a physical volume
 .SH SYNOPSIS
 .B pvchange
-[\-\-addtag Tag]
-[\-A|\-\-autobackup y|n] [\-d|\-\-debug] 
-[\-f|\-\-force]
-[\-\-deltag Tag]
-[\-\-metadataignore y|n]
-[\-h|\-?|\-\-help]
-[\-t|\-\-test]
-[\-v|\-\-verbose] [\-a|\-\-all] [\-x|\-\-allocatable y|n]
-[\-u|\-\-uuid] [PhysicalVolumePath...]
+.RB [ \-\-addtag
+.IR Tag ]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-f | \-\-force ]
+.RB [ \-\-deltag
+.IR Tag ]
+.RB [ \-\-metadataignore
+.RI { y | n }]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-a | \-\-all ]
+.RB [ \-x | \-\-allocatable
+.RI { y | n }]
+.RB [ \-u | \-\-uuid ]
+.RI [ PhysicalVolumePath ...]
 .SH DESCRIPTION
 pvchange allows you to change the allocation permissions of one or
 more physical volumes.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-a, \-\-all
+.BR \-a ", " \-\-all
 If PhysicalVolumePath is not specified on the command line all
 physical volumes are searched for and used.
 .TP
-.I \-\-metadataignore " y|n"
+.BR \-\-metadataignore " {" \fIy | \fIn }
 Ignore or un-ignore metadata areas on this physical volume.
 If metadata areas on a physical volume are ignored, LVM will
 not not store metadata in the metadata areas present on this Physical
 Volume.
 .TP
-.I \-u, \-\-uuid
+.BR \-u ", " \-\-uuid
 Generate new random UUID for specified physical volumes.
 .TP
-.I \-x, \-\-allocatable y|n
+.BR \-x ", " \-\-allocatable " {" \fIy | \fIn }
 Enable or disable allocation of physical extents on this physical volume.
 .SH Example
-"pvchange -x n /dev/sdk1" disallows the allocation of physical extents
-on this physical volume (possibly because of disk errors, or because it will
-be removed after freeing it.
+Disallows the allocation of physical extents on this physical volume
+(possibly because of disk errors, or because it will be removed after
+freeing it:
+.sp
+.B pvchange -x n /dev/sdk1
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8)
--- LVM2/man/pvck.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/pvck.8.in	2012/04/11 12:42:10	1.2
@@ -6,25 +6,27 @@
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-v | \-\-verbose ]
-.RB [ \-\-labelsector ]
-.IR PhysicalVolume " [" PhysicalVolume ...]
+.RB [ \-\-labelsector
+.IR sector ]
+.I PhysicalVolume
+.RI [ PhysicalVolume ...]
 .SH DESCRIPTION
 pvck checks physical volume LVM metadata for consistency.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.BR \-\-labelsector " sector"
+.B \-\-labelsector \fIsector
 By default, 4 sectors of \fBPhysicalVolume\fP are scanned for an LVM label,
 starting at sector 0.  This parameter allows you to specify a different
 starting sector for the scan and is useful for recovery situations.  For
 example, suppose the partition table is corrupted or lost on /dev/sda,
-but you suspect there was an LVM partition at approximately 100 MB.  This
-area of the disk may be scanned by using the \fB--labelsector\fP parameter
+but you suspect there was an LVM partition at approximately 100 MiB.  This
+area of the disk may be scanned by using the \fB\-\-labelsector\fP parameter
 with a value of 204800 (100 * 1024 * 1024 / 512 = 204800):
 .sp
-.BI "pvck --labelsector 204800 /dev/sda"
+.B pvck \-\-labelsector 204800 /dev/sda
 .sp
-Note that a script can be used with \fB--labelsector\fP to automate the
+Note that a script can be used with \fB\-\-labelsector\fP to automate the
 process of finding LVM labels.
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/pvcreate.8.in	2011/09/07 09:48:50	1.12
+++ LVM2/man/pvcreate.8.in	2012/04/11 12:42:10	1.13
@@ -8,30 +8,42 @@
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RB [ \-f [ f ]| \-\-force " [" \-\-force ]]
+.RB [ \-f [ f ]| \-\-force
+.RB [ \-\-force ]]
 .RB [ \-y | \-\-yes ]
 .RB [ \-\-labelsector ]
-.RB [ \-M | \-\-metadatatype " " \fItype ]
-.RB [ \-\-[pv]metadatacopies " " \fI#copies ]
-.RB [ \-\-metadatasize " " \fIsize ]
-.RB [ \-\-metadataignore " {" \fIy | \fIn }]
-.RB [ \-\-dataalignment " " \fIalignment ]
-.RB [ \-\-dataalignmentoffset " " \fIalignment_offset ]
-.RB [ \-\-restorefile " " \fIfile ]
+.RB [ \-M | \-\-metadatatype
+.IR type ]
+.RB [ \-\- [ pv ] metadatacopies
+.IR NumberOfCopies ]
+.RB [ \-\-metadatasize
+.IR size ]
+.RB [ \-\-metadataignore
+.RI { y | n }]
+.RB [ \-\-dataalignment
+.IR alignment ]
+.RB [ \-\-dataalignmentoffset
+.IR alignment_offset ]
+.RB [ \-\-restorefile
+.IR file ]
 .RB [ \-\-norestorefile ]
-.RB [ \-\-setphysicalvolumesize " " \fIsize ]
-.RB [ \-u | \-\-uuid " " \fIuuid ]
-.RB [ \-Z | \-\-zero " {" \fIy | \fIn }]
-.IR PhysicalVolume " [" PhysicalVolume ...]
+.RB [ \-\-setphysicalvolumesize
+.IR size ]
+.RB [ \-u | \-\-uuid
+.IR uuid ]
+.RB [ \-Z | \-\-zero
+.RI { y | n }]
+.I PhysicalVolume
+.RI [ PhysicalVolume ...]
 .SH DESCRIPTION
-.B pvcreate
-initializes
+pvcreate initializes
 .I PhysicalVolume
 for later use by the Logical Volume Manager (LVM).  Each
 .I PhysicalVolume
 can be a disk partition, whole disk, meta device, or loopback file.
 For DOS disk partitions, the partition id should be set to 0x8e using
-.BR fdisk "(8), " cfdisk "(8), "
+.BR fdisk (8),
+.BR cfdisk (8),
 or a equivalent.  For
 .B whole disk devices only
 the partition table must be erased, which will effectively destroy all
@@ -57,45 +69,45 @@
 In an emergency you can override this behaviour with \fB-ff\fP.
 .TP
 .BR \-u ", " \-\-uuid " " \fIuuid
-Specify the uuid for the device.  
-Without this option, \fBpvcreate\fP generates a random uuid.
+Specify the uuid for the device.
+Without this option, \fBpvcreate\fP(8) generates a random uuid.
 All of your physical volumes must have unique uuids.
-You need to use this option before restoring a backup of LVM metadata 
+You need to use this option before restoring a backup of LVM metadata
 onto a replacement device - see \fBvgcfgrestore\fP(8).  As such, use of
-\fB--restorefile\fP is compulsory unless the \fB--norestorefile\fP is
+\fB\-\-restorefile\fP is compulsory unless the \fB\-\-norestorefile\fP is
 used.
 .TP
 .BR \-y ", " \-\-yes
 Answer yes to all questions.
 .TP
-.BR \-Z ", " \-\-zero " " \fIy | \fIn
-Whether or not the first 4 sectors (2048 bytes) of the device should be 
+.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
+Whether or not the first 4 sectors (2048 bytes) of the device should be
 wiped.
-If this option is not given, the 
-default is to wipe these sectors unless either or both of the \fB--restorefile\fP
-or \fB--uuid\fP options were specified.
+If this option is not given, the
+default is to wipe these sectors unless either or both of the
+\fB\-\-restorefile\fP or \fB\-\-uuid\fP options were specified.
 .SH NEW METADATA OPTIONS
 LVM2 introduces a new format for storing metadata on disk.
-This new format is more efficient and resilient than the format the 
-original version of LVM used and offers the advanced user greater 
+This new format is more efficient and resilient than the format the
+original version of LVM used and offers the advanced user greater
 flexibility and control.
-.sp
-The new format may be selected on the command line with \fB-M2\fP or by 
-setting \fBformat = "lvm2"\fP in the \fBglobal\fP section of \fBlvm.conf\fP.
+.P
+The new format may be selected on the command line with \fB\-M2\fP or by
+setting \fBformat = "lvm2"\fP in the \fBglobal\fP section of \fBlvm.conf\fP(5).
 Each physical volume in the same volume group must use the same format, but
-different volume groups on a machine may use different formats 
+different volume groups on a machine may use different formats
 simultaneously: the tools can handle both formats.
 Additional formats can be added as shared libraries.
-.sp
-Additional tools for manipulating the locations and sizes of metadata areas 
+.P
+Additional tools for manipulating the locations and sizes of metadata areas
 will be written in due course.  Use the verbose/debug options on the tools
 to see where the metadata areas are placed.
 .TP
-.BI \-\-metadatasize " size"
+.B \-\-metadatasize \fIsize
 The approximate amount of space to be set aside for each metadata area.
 (The size you specify may get rounded.)
 .TP
-.BI \-\-dataalignment " alignment"
+.B \-\-dataalignment \fIalignment
 Align the start of the data to a multiple of this number.
 You should also specify an appropriate \fIPhysicalExtentSize\fP when creating
 the Volume Group with \fBvgcreate\fP.
@@ -103,25 +115,25 @@
 To see the location of the first Physical Extent of an existing Physical Volume
 use \fBpvs -o +pe_start\fP .  It will be a multiple of the requested
 alignment.  In addition it may be shifted by \fIalignment_offset\fP from
-\fIdata_alignment_offset_detection\fP (if enabled in \fBlvm.conf\fP) or
-\fB--dataalignmentoffset\fP.
+\fIdata_alignment_offset_detection\fP (if enabled in \fBlvm.conf\fP(5)) or
+\fB\-\-dataalignmentoffset\fP.
 .TP
-.BI \-\-dataalignmentoffset " alignment_offset"
+.B \-\-dataalignmentoffset \fIalignment_offset
 Shift the start of the data area by this additional \fIalignment_offset\fP.
 .TP
-.BI \-\-[pv]metadatacopies " copies"
+.BR \-\- [ pv ] metadatacopies " " \fINumberOfCopies
 The number of metadata areas to set aside on each PV.  Currently
-this can be 0, 1 or 2.  
-If set to 2, two copies of the volume group metadata 
-are held on the PV, one at the front of the PV and one at the end.  
-If set to 1 (the default), one copy is kept at the front of the PV 
+this can be 0, 1 or 2.
+If set to 2, two copies of the volume group metadata
+are held on the PV, one at the front of the PV and one at the end.
+If set to 1 (the default), one copy is kept at the front of the PV
 (starting in the 5th sector).
 If set to 0, no copies are kept on this PV - you might wish to use this
 with VGs containing large numbers of PVs.  But if you do this and
-then later use \fBvgsplit\fP you must ensure that each VG is still going 
+then later use \fBvgsplit\fP(8) you must ensure that each VG is still going
 to have a suitable number of copies of the metadata after the split!
 .TP
-.BI \-\-metadataignore " y" \fR| n
+.BR \-\-metadataignore " {" \fIy | \fIn }
 Ignore or un-ignore metadata areas on this physical volume.
 The default is "n".  This setting can be changed with \fBpvchange\fP.
 If metadata areas on a physical volume are ignored, LVM will
@@ -132,49 +144,49 @@
 area in case you need it in the future and to use this option to instruct
 LVM2 to ignore it.
 .TP
-.BI \-\-restorefile " file"
+.B \-\-restorefile \fIfile
 In conjunction with \fB--uuid\fP, this extracts the location and size
 of the data on the PV from the file (produced by \fBvgcfgbackup\fP)
-and ensures that the metadata that the program produces is consistent 
-with the contents of the file i.e. the physical extents will be in 
+and ensures that the metadata that the program produces is consistent
+with the contents of the file i.e. the physical extents will be in
 the same place and not get overwritten by new metadata.  This provides
 a mechanism to upgrade the metadata format or to add/remove metadata
 areas. Use with care. See also \fBvgconvert\fP(8).
 .TP
 .B \-\-norestorefile
-In conjunction with \fB--uuid\fP, this allows a \fIuuid\fP to be specified
+In conjunction with \fB\-\-uuid\fP, this allows a \fIuuid\fP to be specified
 without also requiring that a backup of the metadata be provided.
 .TP
-.BI \-\-labelsector " sector"
-By default the PV is labelled with an LVM2 identifier in its second 
+.B \-\-labelsector \fIsector
+By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1).  This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source).  Use with care.
 .TP
-.BI \-\-setphysicalvolumesize " size"
+.B \-\-setphysicalvolumesize \fIsize
 Overrides the automatically-detected size of the PV.  Use with care.
-.SH EXAMPLES
+.SH Examples
 Initialize partition #4 on the third SCSI disk and the entire fifth
 SCSI disk for later use by LVM:
 .sp
 .B pvcreate /dev/sdc4 /dev/sde
-.sp
-If the 2nd SCSI disk is a 4KB sector drive that compensates for windows
-partitioning (sector 7 is the lowest aligned logical block, the 4KB
-sectors start at LBA -1, and consequently sector 63 is aligned on a 4KB
+
+If the 2nd SCSI disk is a 4KiB sector drive that compensates for windows
+partitioning (sector 7 is the lowest aligned logical block, the 4KiB
+sectors start at LBA -1, and consequently sector 63 is aligned on a 4KiB
 boundary) manually account for this when initializing for use by LVM:
 .sp
-.B pvcreate --dataalignmentoffset 7s /dev/sdb
-.sp
+.B pvcreate \-\-dataalignmentoffset 7s /dev/sdb
+
 .SH SEE ALSO
 .BR lvm.conf (5),
 .BR lvm (8),
-.BR vgcreate (8), 
-.BR vgextend (8), 
-.BR lvcreate (8), 
-.BR cfdisk (8), 
-.BR fdisk (8), 
-.BR losetup (8), 
-.BR mdadm (8), 
-.BR vgcfgrestore (8), 
+.BR vgcreate (8),
+.BR vgextend (8),
+.BR lvcreate (8),
+.BR cfdisk (8),
+.BR fdisk (8),
+.BR losetup (8),
+.BR mdadm (8),
+.BR vgcfgrestore (8),
 .BR vgconvert (8)
--- LVM2/man/pvdisplay.8.in	2009/10/26 14:37:09	1.3
+++ LVM2/man/pvdisplay.8.in	2012/04/11 12:42:10	1.4
@@ -3,48 +3,61 @@
 pvdisplay \- display attributes of a physical volume
 .SH SYNOPSIS
 .B pvdisplay
-[\-c|\-\-colon]
-[\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure]
-[\-\-maps]
-[\-\-nosuffix]
-[\-s|\-\-short]
-[\-\-units hsbkmgtHKMGT]
-[\-v[v]|\-\-verbose [\-\-verbose]]
-[\-\-version]
-[PhysicalVolumePath [PhysicalVolumePath...]]
+.RB [ \-c | \-\-colon ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-maps ]
+.RB [ \-\-nosuffix ]
+.RB [ \-s | \-\-short ]
+.RB [ \-\-units
+.IR hsbkmgtHKMGT ]
+.RB [ \-v [ v ]| \-\-verbose
+.RB [ \-\-verbose ]]
+.RB [ \-\-version ]
+.RI [ PhysicalVolumePath
+.RI [ PhysicalVolumePath ...]]
 .br
 
 .br
-.B pvdisplay \-\-columns | \-C
-[\-\-aligned]
-[\-a|\-\-all]
-[\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure]
-[\-\-noheadings]
-[\-\-nosuffix]
-[\-o|\-\-options [+]Field[,Field]]
-[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-\-separator Separator]
-[\-\-unbuffered]
-[\-\-units hHbBsSkKmMgGtTpPeE]
-[\-v[v]|\-\-verbose [\-\-verbose]]
-[\-\-version]
-[PhysicalVolumePath [PhysicalVolumePath...]]
+.B pvdisplay
+.BR \-\-columns | \-C
+.RB [ \-\-aligned ]
+.RB [ \-a | \-\-all ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-noheadings ]
+.RB [ \-\-nosuffix ]
+.RB [ \-o | \-\-options
+.RI [ + ] Field [ ,Field ...]]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...
+.RI ]]
+.RB [ \-\-separator
+.IR Separator ]
+.RB [ \-\-unbuffered ]
+.RB [ \-\-units
+.IR hHbBsSkKmMgGtTpPeE ]
+.RB [ \-v [ v ]| \-\-verbose
+.RB [ \-\-verbose ]]
+.RB [ \-\-version ]
+.RI [ PhysicalVolumePath
+.RI [ PhysicalVolumePath ...]]
 .SH DESCRIPTION
 pvdisplay allows you to see the attributes of one or more physical volumes
 like size, physical extent size, space used for the volume group descriptor
 area and so on.
 .P
-\fBpvs\fP (8) is an alternative that provides the same information 
-in the style of \fBps\fP (1).
+\fBpvs\fP(8) is an alternative that provides the same information 
+in the style of \fBps\fP(1).
 .SH OPTIONS
 See \fBlvm\fP for common options and \fBpvs\fP for options given with
 \fB\-\-columns\fP.
 .TP
-.I \-c, \-\-colon
+.BR \-c ", " \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
-N.B. \fBpvs\fP (8) provides considerably more control over the output.
+N.B. \fBpvs\fP(8) provides considerably more control over the output.
 .nf
 
 The values are:
@@ -63,16 +76,16 @@
 
 .fi
 .TP
-.I \-s, \-\-short
+.BR \-s ", " \-\-short
 Only display the size of the given physical volumes.
 .TP
-.I \-m, \-\-maps
+.BR \-m ", " \-\-maps
 Display the mapping of physical extents to logical volumes and
 logical extents.
 .TP
-.I \-\-columns | \-C
-Display output in columns, the equivalent of \fBpvs\fP (8).  See
-\fBpvs (8)\fP for a description of other options with this form of
+.BR \-\-columns ", " \-C
+Display output in columns, the equivalent of \fBpvs\fP(8).  See
+\fBpvs\fP(8) for a description of other options with this form of
 \fBpvdisplay\fP.
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/pvmove.8.in	2011/04/28 16:22:47	1.6
+++ LVM2/man/pvmove.8.in	2012/04/11 12:42:10	1.7
@@ -3,15 +3,22 @@
 pvmove \- move physical extents
 .SH SYNOPSIS
 .B pvmove
-[\-\-abort]
-[\-\-alloc AllocationPolicy]
-[\-b|\-\-background]
-[\-d|\-\-debug] [\-h|\-\-help] [\-i|\-\-interval Seconds]
-[\-\-noudevsync] [\-v|\-\-verbose] [\-n|\-\-name LogicalVolume]
-[SourcePhysicalVolume[:PE[-PE]...] [DestinationPhysicalVolume[:PE[-PE]...]...]]
+.RB [ \-\-abort ]
+.RB [ \-\-alloc
+.IR AllocationPolicy ]
+.RB [ \-b | \-\-background ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-i | \-\-interval
+.IR Seconds ]
+.RB [ \-\-noudevsync ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-n | \-\-name
+.IR LogicalVolume ]
+.RI [ SourcePhysicalVolume [ :PE [ -PE ]...]
+.RI [ DestinationPhysicalVolume [ :PE [ -PE ]...]...]]
 .SH DESCRIPTION
-.B pvmove
-allows you to move the allocated physical extents (PEs) on
+pvmove allows you to move the allocated physical extents (PEs) on
 .I SourcePhysicalVolume
 to one or more other physical volumes (PVs).
 You can optionally specify a source
@@ -23,8 +30,8 @@
 .I DestinationPhysicalVolume
 is specified, the normal allocation rules for the Volume Group are used.
 
-If \fBpvmove\fP gets interrupted for any reason (e.g. the machine crashes)
-then run \fBpvmove\fP again without any PhysicalVolume arguments to
+If pvmove gets interrupted for any reason (e.g. the machine crashes)
+then run pvmove again without any PhysicalVolume arguments to
 restart any moves that were in progress from the last checkpoint.
 Alternatively use \fBpvmove --abort\fP at any time to abort them
 at the last checkpoint.
@@ -71,78 +78,74 @@
 N.B. The moving of mirrors, snapshots and their origins is not yet supported.
 
 .SH OPTIONS
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-\-abort
+.B \-\-abort
 Abort any moves in progress.
 .TP
-.I \-\-noudevsync
+.B \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
 It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-b, \-\-background
+.BR \-b ", " \-\-background
 Run the daemon in the background.
 .TP
-.I \-i, \-\-interval Seconds
+.BR \-i ", " \-\-interval " " \fISeconds
 Report progress as a percentage at regular intervals.
 .TP
-.I \-n, \-\-name " \fILogicalVolume\fR"
+.BR \-n ", " \-\-name " " \fILogicalVolume
 Move only the extents belonging to
 .I LogicalVolume
 from
 .I SourcePhysicalVolume
 instead of all allocated extents to the destination physical volume(s).
 
-.SH EXAMPLES
+.SH Examples
 To move all Physical Extents that are used by simple Logical Volumes on
-.B /dev/sdb1
-to free Physical Extents elsewhere in the Volume Group use:
+/dev/sdb1 to free Physical Extents elsewhere in the Volume Group use:
 .sp
-\	pvmove /dev/sdb1
+.B pvmove /dev/sdb1
 .P
 Any mirrors, snapshots and their origins are left unchanged.
 .P
-Additionally, a specific destination device
-.B /dev/sdc1
+Additionally, a specific destination device /dev/sdc1
 can be specified like this:
 .sp
-\	pvmove /dev/sdb1 /dev/sdc1
+.B pvmove /dev/sdb1 /dev/sdc1
 .P
 To perform the action only on extents belonging to the single Logical Volume 
-.B lvol1
-do this:
+lvol1 do this:
 .sp
-\	pvmove -n lvol1 /dev/sdb1 /dev/sdc1
+.B pvmove -n lvol1 /dev/sdb1 /dev/sdc1
 .P
 Rather than moving the contents of the entire device, it is possible to
-move a range of Physical Extents - for example numbers 1000 to 1999 inclusive on
-.B /dev/sdb1
-- like this:
+move a range of Physical Extents - for example numbers 1000 to 1999
+inclusive on /dev/sdb1 - like this:
 .sp
-\	pvmove /dev/sdb1:1000-1999
+.B pvmove /dev/sdb1:1000-1999
 .P
 To move a range of Physical Extents to a specific location (which must have
 sufficent free extents) use the form:
 .sp
-\	pvmove /dev/sdb1:1000-1999 /dev/sdc1
+.B pvmove /dev/sdb1:1000-1999 /dev/sdc1
 .sp
 or
 .sp
-\	pvmove /dev/sdb1:1000-1999 /dev/sdc1:0-999
+.B pvmove /dev/sdb1:1000-1999 /dev/sdc1:0-999
 .P
 If the source and destination are on the same disk, the 
 .B anywhere
 allocation policy would be needed, like this:
 .sp
-\	pvmove --alloc anywhere /dev/sdb1:1000-1999 /dev/sdb1:0-999
+.B pvmove --alloc anywhere /dev/sdb1:1000-1999 /dev/sdb1:0-999
 .P
-
 The part of a specific Logical Volume present within in a range of Physical
 Extents can also be picked out and moved, like this:
 .sp
-\	pvmove -n lvol1 /dev/sdb1:1000-1999 /dev/sdc1
+.B pvmove -n lvol1 /dev/sdb1:1000-1999 /dev/sdc1
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgconvert (8)
--- LVM2/man/pvremove.8.in	2011/02/28 19:40:04	1.4
+++ LVM2/man/pvremove.8.in	2012/04/11 12:42:10	1.5
@@ -14,9 +14,8 @@
 .I PhysicalVolume
 .RI [ PhysicalVolume ...]
 .SH DESCRIPTION
-.B pvremove
-wipes the label on a device so that LVM will no longer recognise it
-as a physical volume.
+pvremove wipes the label on a device so that LVM will no longer
+recognise it as a physical volume.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
--- LVM2/man/pvresize.8.in	2011/02/04 21:19:04	1.3
+++ LVM2/man/pvresize.8.in	2012/04/11 12:42:10	1.4
@@ -13,8 +13,7 @@
 .I PhysicalVolume 
 .RI [ PhysicalVolume ...]
 .SH DESCRIPTION
-.B pvresize
-resizes
+pvresize resizes
 .I PhysicalVolume
 which may already be in a volume group and have active logical volumes
 allocated on it.
@@ -33,11 +32,10 @@
 (ensure that the PV size is appropriate for your intended new partition
 size):
 .sp
-.B pvresize --setphysicalvolumesize 40G /dev/sda1
+.B pvresize \-\-setphysicalvolumesize 40G /dev/sda1
 .sp
 .SH RESTRICTIONS
-.B pvresize
-will refuse to shrink
+pvresize will refuse to shrink
 .I PhysicalVolume
 if it has allocated extents after where its new end would be. In the future,
 it should relocate these elsewhere in the volume group if there is sufficient
--- LVM2/man/pvs.8.in	2011/06/29 14:56:33	1.14
+++ LVM2/man/pvs.8.in	2012/04/11 12:42:10	1.15
@@ -3,90 +3,102 @@
 pvs \- report information about physical volumes
 .SH SYNOPSIS
 .B pvs
-[\-a|\-\-all]
-[\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
-[\-o|\-\-options [+]Field[,Field]]
-[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-P|\-\-partial]
-[\-\-rows]
-[\-\-segments]
-[\-\-separator Separator]
-[\-\-unbuffered]
-[\-\-units hHbBsSkKmMgGtTpPeE]
-[\-\-unquoted]
-[\-v|\-\-verbose] 
-[\-\-version] [PhysicalVolume [PhysicalVolume...]]
+.RB [ \-a | \-\-all ]
+.RB [ \-\-aligned ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-nameprefixes ]
+.RB [ \-\-noheadings ]
+.RB [ \-\-nosuffix ]
+.RB [ \-o | \-\-options
+.RI [ + ] Field [ ,Field ...]]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
+.RB [ \-P | \-\-partial ]
+.RB [ \-\-rows ]
+.RB [ \-\-segments ]
+.RB [ \-\-separator
+.IR Separator ]
+.RB [ \-\-unbuffered ]
+.RB [ \-\-units
+.IR hHbBsSkKmMgGtTpPeE ]
+.RB [ \-\-unquoted ]
+.RB [ \-v|\-\-verbose ]
+.RB [ \-\-version]
+.RI [ PhysicalVolume
+.RI [ PhysicalVolume ...]]
 .SH DESCRIPTION
 pvs produces formatted output about physical volumes.
 .SH OPTIONS
-See \fBlvm\fP for common options.
-\fB\-\-columns\fP.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-\-all
+.B \-\-all
 Include information in the output about devices that have not been
-initialized with \fBpvcreate\fP.
+initialized with \fBpvcreate\fP(8).
 .TP
-.I \-\-aligned
-Use with \-\-separator to align the output columns.
+.B \-\-aligned
+Use with \fB\-\-separator\fP to align the output columns.
 .TP
-.I \-\-nameprefixes
+.B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
-with --noheadings to produce a list of field=value pairs that can
-be used to set environment variables (for example, in \fBudev (7)\fP rules).
+with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
+be used to set environment variables (for example, in \fBudev\fP(7) rules).
 .TP
-.I \-\-noheadings
+.B \-\-noheadings
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .TP
-.I \-\-nosuffix
-Suppress the suffix on output sizes.  Use with \-\-units (except h and H)
-if processing the output.
-.TP
-.I \-o, \-\-options
-Comma-separated ordered list of columns.  Precede the list with '+' to append
-to the default selection of columns.
+.B \-\-nosuffix
+Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
+(except h and H) if processing the output.
+.TP
+.BR \-o ", " \-\-options
+Comma-separated ordered list of columns.  Precede the list with '\fI+\fP'
+to append to the default selection of columns.
 .IP
-Use \fb-o pv_all\fP to select all physical volume columns, and \fb-o pvseg_all\fP
-to select all Physical Volume segment columns.
+Use \fB-o pv_all\fP to select all physical volume columns,
+and \fB-o pvseg_all\fP to select all Physical Volume segment columns.
 .IP
-Use \fb-o help\fP to view the full list of columns available.
+Use \fB-o help\fP to view the full list of columns available.
 .IP
 Column names include: pv_fmt, pv_uuid, dev_size, pv_name, pv_mda_free,
 pv_mda_size, pe_start, pv_size, pv_free, pv_used, pv_attr, pv_pe_count,
 pv_pe_alloc_count, pv_tags, pv_mda_count, pv_mda_used_count,
 pvseg_start, and pvseg_size.
 .IP
-With --segments, any "pvseg_" prefixes are optional; otherwise any
-"pv_" prefixes are optional.  Columns mentioned in \fBvgs (8)\fP can also
+With \fB\-\-segments\fP, any "pvseg_" prefixes are optional; otherwise any
+"pv_" prefixes are optional.  Columns mentioned in \fBvgs\fP(8) can also
 be chosen. The pv_attr bits are: (a)llocatable, e(x)ported and (m)issing.
 .TP
-.I \-\-segments
+.B \-\-segments
 Produces one line of output for each contiguous allocation of space on each
 Physical Volume, showing the start (pvseg_start) and length (pvseg_size) in
 units of physical extents.
 .TP
-.I \-O, \-\-sort
+.BR \-O ", " \-\-sort
 Comma-separated ordered list of columns to sort by.  Replaces the default
-selection. Precede any column with - for a reverse sort on that column.
+selection. Precede any column with '\fI\-\fP' for a reverse sort on that
+column.
 .TP
-.I \-\-rows
+.B \-\-rows
 Output columns as rows.
 .TP
-.I \-\-separator Separator
+.B \-\-separator \fISeparator
 String to use to separate each column.  Useful if grepping the output.
 .TP
-.I \-\-unbuffered
+.B \-\-unbuffered
 Produce output immediately without sorting or aligning the columns properly.
 .TP
-.I \-\-units hHbBsSkKmMgGtTpPeE
+.B \-\-units \fIhHbBsSkKmMgGtTpPeE
 All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
-Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
+Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify
 custom units e.g. \-\-units 3M
 .TP
-.I \-\-unquoted
-When used with --nameprefixes, output values in the field=value pairs are not quoted.
+.B \-\-unquoted
+When used with \fB\-\-nameprefixes\fP, output values in the field=value
+pairs are not quoted.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvdisplay (8),
--- LVM2/man/pvscan.8.in	2012/03/06 02:30:50	1.10
+++ LVM2/man/pvscan.8.in	2012/04/11 12:42:10	1.11
@@ -17,17 +17,16 @@
 .B pvscan
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
-.RB \-\-cache
+.B \-\-cache
 .RB [ \-\-major
-.IR major
-.RB \-\-minor
-.IR minor
+.I major
+.B \-\-minor
+.I minor
 |
-.RI DevicePath 
-] ...
+.IR DevicePath ]...
 .SH DESCRIPTION
-.B pvscan
-scans all supported LVM block devices in the system for physical volumes.
+pvscan scans all supported LVM block devices in the system for
+physical volumes.
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
@@ -43,7 +42,7 @@
 .BR \-u ", " \-\-uuid
 Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
 .TP
-.BR \-\-cache " " [ " " \-\-major " " major " " \-\-minor " " minor " " | " " DevicePath " " ] " " ...
+.BR \-\-cache " [" \-\-major " " \fImajor " " \-\-minor " " \fIminor " | " \fIDevicePath " ]..."
 Scan one or more devices and instruct the lvmetad daemon to update its cached
 state accordingly.  Called internally by udev rules.
 All devices listed explicitly are processed \fBregardless\fP of any device
--- LVM2/man/vgcfgbackup.8.in	2010/05/20 13:47:22	1.2
+++ LVM2/man/vgcfgbackup.8.in	2012/04/11 12:42:10	1.3
@@ -4,29 +4,28 @@
 .SH SYNOPSIS
 .B vgcfgbackup
 .RB [ \-d | \-\-debug ]
-.RB [ \-f | \-\-file " filename" ]
+.RB [ \-f | \-\-file
+.RI < filename >]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-P | \-\-partial ]
 .RB [ \-v | \-\-verbose ]
 .RI [ VolumeGroupName ...]
 .SH DESCRIPTION
-.B vgcfgbackup
-allows you to backup the metadata 
-of your volume groups.
-If you don't name any volume groups on the command line, all of them 
+vgcfgbackup allows you to backup the metadata of your volume groups.
+If you don't name any volume groups on the command line, all of them
 will be backed up.
 .sp
 In a default installation, each volume group gets backed up into a separate
 file bearing the name of the volume group in the directory #DEFAULT_BACKUP_DIR#.
-You can write the backup to an alternative file using -f.  In this case
+You can write the backup to an alternative file using \fB-f\fP.  In this case
 if you are backing up more than one volume group the filename is
 treated as a template, and %s gets replaced by the volume group name.
 .sp
 NB. This DOESN'T backup user/system data in logical
 volume(s)!  Backup #DEFAULT_SYS_DIR# regularly too.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcfgrestore (8)
--- LVM2/man/vgcfgrestore.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgcfgrestore.8.in	2012/04/11 12:42:10	1.2
@@ -4,40 +4,43 @@
 .SH SYNOPSIS
 .B vgcfgrestore
 .RB [ \-d | \-\-debug ]
-.RB [ \-f | \-\-file " filename" ]
-.RB [ \-l[l] | \-\-list ]
+.RB [ \-f | \-\-file
+.RI < filename >]
+.RB [ \-l [ l ]| \-\-list ]
 .RB [ \-h | \-\-help ]
-.RB [ \-M | \-\-Metadatatype 1|2]
+.RB [ \-M | \-\-metadatatype
+.IR 1 | 2 ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RI \fIVolumeGroupName\fP
 .SH DESCRIPTION
-.B vgcfgrestore
-allows you to restore the metadata of \fIVolumeGroupName\fP from a text 
-backup file produced by \fBvgcfgbackup\fP.  You can specify a backup file 
-with \fP--file\fP.  If no backup file is specified, the most recent
-one is used.  Use \fB--list\fP for a list of the available
+vgcfgrestore allows you to restore the metadata of \fIVolumeGroupName\fP
+from a text backup file produced by \fBvgcfgbackup\fP.
+You can specify a backup file with \fB\-\-file\fP.
+If no backup file is specified, the most recent
+one is used.  Use \fB\-\-list\fP for a list of the available
 backup and archive files of \fIVolumeGroupName\fP.
 .SH OPTIONS
+See \fBlvm\fP(8) for common options.
 .TP
-\fB-l | --list\fP \(em List files pertaining to \fIVolumeGroupName\fP
+.BR \-l ", " \-\-list\fP
+List files pertaining to \fIVolumeGroupName\fP
 List metadata backup and archive files pertaining to \fIVolumeGroupName\fP.
-May be used with the \fB-f\fP option.  Does not restore \fIVolumeGroupName\fP.
+May be used with the \fB\-f\fP option.  Does not restore \fIVolumeGroupName\fP.
 .TP
-\fB-f | --file\fP filename \(em Name of LVM metadata backup file
+.BR \-f ", " \-\-file " " \fIfilename
+Name of LVM metadata backup file
 Specifies a metadata backup or archive file to be used for restoring 
 VolumeGroupName.  Often this file has been created with \fBvgcfgbackup\fP.
-.TP
-See \fBlvm\fP for common options.
 .SH REPLACING PHYSICAL VOLUMES
-\fBvgdisplay --partial --verbose\fP will show you the UUIDs and sizes of
+\fBvgdisplay \-\-partial \-\-verbose\fP will show you the UUIDs and sizes of
 any PVs that are no longer present.
 If a PV in the VG is lost and you wish to substitute 
 another of the same size, use 
-\fBpvcreate --restorefile filename --uuid uuid\fP (plus additional 
+\fBpvcreate \-\-restorefile filename \-\-uuid uuid\fP (plus additional 
 arguments as appropriate) to initialise it with the same UUID as 
 the missing PV.  Repeat for all other missing PVs in the VG. 
-Then use \fBvgcfgrestore --file filename\fP to restore the volume
+Then use \fBvgcfgrestore \-\-file filename\fP to restore the volume
 group's metadata.
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/vgchange.8.in	2010/07/13 15:04:23	1.12
+++ LVM2/man/vgchange.8.in	2012/04/11 12:42:10	1.13
@@ -7,39 +7,45 @@
 .IR Tag ]
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
-.RB [ \-A | \-\-autobackup " {" y | n }]
-.RB [ \-a | \-\-available " [e|l] {" y | n }]
-.RB [ \-\-monitor " {" y | n }]
-.RB [ \-\-poll " {" y | n }]
-.RB [ \-c | \-\-clustered " {" y | n }]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-a | \-\-available
+.RI [ e | l ]
+.RI { y | n }]
+.RB [ \-\-monitor
+.RI { y | n }]
+.RB [ \-\-poll
+.RI { y | n }]
+.RB [ \-c | \-\-clustered
+.RI { y | n }]
 .RB [ \-u | \-\-uuid ]
-.RB [ \-d | \-\-debug]
+.RB [ \-d | \-\-debug ]
 .RB [ \-\-deltag
 .IR Tag ]
-.RB [ \-h | \-\-help]
-.RB [ \-\-ignorelockingfailure]
-.RB [ \-\-ignoremonitoring]
-.RB [ \-\-sysinit]
+.RB [ \-h | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-ignoremonitoring ]
+.RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
 .RB [ \-l | \-\-logicalvolume
 .IR MaxLogicalVolumes ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
-.RB [ \-\-[vg]metadatacopies ]
-.IR NumberOfCopies|unmanaged|all ]
-.RB [ \-P | \-\-partial]
+.RB [ \-\- [ vg ] metadatacopies ]
+.IR NumberOfCopies | unmanaged | all ]
+.RB [ \-P | \-\-partial ]
 .RB [ \-s | \-\-physicalextentsize
-.IR PhysicalExtentSize [ \fBbBsSkKmMgGtTpPeE\fR ]]
-.RB [ \-\-refresh]
-.RB [ -t | \-\-test]
-.RB [ \-v | \-\-verbose]
+.IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-\-refresh ]
+.RB [ -t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RB [ \-x | \-\-resizeable " {" y | n }]
+.RB [ \-x | \-\-resizeable
+.RI { y | n }]
 .RI [ VolumeGroupName ...]
 .SH DESCRIPTION
-.B vgchange
-allows you to change the attributes of one or more volume groups.
-Its main purpose is to activate and deactivate
+vgchange allows you to change the attributes of one or more
+volume groups. Its main purpose is to activate and deactivate
 .IR VolumeGroupName ,
 or all volume groups if none is specified.  Only active volume groups
 are subject to changes and allow access to their logical volumes.
@@ -51,25 +57,25 @@
 .BR lvremove (8)).
 ]
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.BR \-A ", " \-\-autobackup " " { y | n }
+.BR \-A ", " \-\-autobackup " {" \fIy | \fIn }
 Controls automatic backup of metadata after the change.  See
-.B vgcfgbackup (8).
+.BR vgcfgbackup (8).
 Default is yes.
 .TP
-.BR \-a ", " \-\-available " " [e|l] { y | n }
-Controls the availability of the logical volumes in the volume 
+.BR \-a ", " \-\-available " [" \fIe | \fIl ]{ \fIy | \fIn }
+Controls the availability of the logical volumes in the volume
 group for input/output.
 In other words, makes the logical volumes known/unknown to the kernel.
 .IP
 If clustered locking is enabled, add 'e' to activate/deactivate
 exclusively on one node or 'l' to activate/deactivate only
-on the local node.  
+on the local node.
 Logical volumes with single-host snapshots are always activated
 exclusively because they can only be used on one node at once.
 .TP
-.BR \-c ", " \-\-clustered " " { y | n }
+.BR \-c ", " \-\-clustered " {" \fIy | \fIn }
 If clustered locking is enabled, this indicates whether this
 Volume Group is shared with other nodes in the cluster or whether
 it contains only local disks that are not visible on the other nodes.
@@ -80,32 +86,35 @@
 .BR \-u ", " \-\-uuid
 Generate new random UUID for specified Volume Groups.
 .TP
-.BR \-\-monitor " " { y | n }
+.BR \-\-monitor " {" \fIy | \fIn }
 Start or stop monitoring a mirrored or snapshot logical volume with
 dmeventd, if it is installed.
 If a device used by a monitored mirror reports an I/O error,
-the failure is handled according to 
-.BR mirror_image_fault_policy
-and 
-.BR mirror_log_fault_policy
-set in 
+the failure is handled according to
+.B mirror_image_fault_policy
+and
+.B mirror_log_fault_policy
+set in
 .BR lvm.conf (5).
 .TP
-.BR \-\-poll " " { y | n }
+.BR \-\-poll " {" \fIy | \fIn }
 Without polling a logical volume's backgrounded transformation process
 will never complete.  If there is an incomplete pvmove or lvconvert (for
-example, on rebooting after a crash), use \fB--poll y\fP to restart the
+example, on rebooting after a crash), use \fB\-\-poll y\fP to restart the
 process from its last checkpoint.  However, it may not be appropriate to
-immediately poll a logical volume when it is activated, use \fB--poll
-n\fP to defer and then \fB--poll y\fP to restart the process.
+immediately poll a logical volume when it is activated, use 
+\fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
 .TP
 .BR \-\-sysinit
 Indicates that vgchange(8) is being invoked from early system initialisation
 scripts (e.g. rc.sysinit or an initrd), before writeable filesystems are
 available. As such, some functionality needs to be disabled and this option
 acts as a shortcut which selects an appropriate set of options. Currently
-this is equivalent to using  \fB--ignorelockingfailure\fP, \fB--ignoremonitoring\fP,
-\fB--poll n\fP and setting \fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
+this is equivalent to using
+.BR \-\-ignorelockingfailure ,
+.BR \-\-ignoremonitoring ,
+.B \-\-poll n
+and setting \fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
 environment variable.
 .TP
 .BR \-\-noudevsync
@@ -116,16 +125,16 @@
 or has rules that ignore the devices LVM2 creates.
 .TP
 .BR \-\-ignoremonitoring
-Make no attempt to interact with dmeventd unless 
+Make no attempt to interact with dmeventd unless
 .BR \-\-monitor
 is specified.
 Do not use this if dmeventd is already monitoring a device.
 .TP
-.BR \-l ", " \-\-logicalvolume " " \fIMaxLogicalVolumes\fR
+.BR \-l ", " \-\-logicalvolume " " \fIMaxLogicalVolumes
 Changes the maximum logical volume number of an existing inactive
 volume group.
 .TP
-.BR \-p ", " \-\-maxphysicalvolumes " " \fIMaxPhysicalVolumes\fR
+.BR \-p ", " \-\-maxphysicalvolumes " " \fIMaxPhysicalVolumes
 Changes the maximum number of physical volumes that can belong
 to this volume group.
 For volume groups with metadata in lvm1 format, the limit is 255.
@@ -135,7 +144,7 @@
 you should consider some use of \fB--pvmetadatacopies 0\fP as described in
 \fBpvcreate(8)\fP, and/or use \fB--vgmetadatacopies\fP.
 .TP
-.BR \-\-[vg]metadatacopies " " \fINumberOfCopies|unmanaged|all\fP
+.BR \-\- [ vg ] metadatacopies " " \fINumberOfCopies | \fIunmanaged | \fIall
 Sets the desired number of metadata copies in the volume group.  If set to
 a non-zero value, LVM will automatically manage the 'metadataignore'
 flags on the physical volumes (see \fBpvchange\fP or \fBpvcreate --metadataignore\fP) in order
@@ -147,26 +156,26 @@
 large numbers of physical volumes with metadata as it may be used to
 minimize metadata read and write overhead.
 .TP
-.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
+.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize [ \fIBbBsSkKmMgGtTpPeE ]
 Changes the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
 is the default if no suffix is present.
-The default is 4 MB and it must be at least 1 KB and a power of 2.
- 
+The default is 4 MiB and it must be at least 1 KiB and a power of 2.
+
 Before increasing the physical extent size, you might need to use lvresize,
 pvresize and/or pvmove so that everything fits.  For example, every
-contiguous range of extents used in a logical volume must start and 
+contiguous range of extents used in a logical volume must start and
 end on an extent boundary.
- 
+
 If the volume group metadata uses lvm1 format, extents can vary in size from
-8KB to 16GB and there is a limit of 65534 extents in each logical volume.  The
-default of 4 MB leads to a maximum logical volume size of around 256GB.
- 
+8KiB to 16GiB and there is a limit of 65534 extents in each logical volume.
+The default of 4 MiB leads to a maximum logical volume size of around 256GiB.
+
 If the volume group metadata uses lvm2 format those restrictions do not apply,
 but having a large number of extents will slow down the tools but have no
-impact on I/O performance to the logical volume.  The smallest PE is 1KB.
- 
-The 2.4 kernel has a limitation of 2TB per block device.
+impact on I/O performance to the logical volume.  The smallest PE is 1KiB.
+
+The 2.4 kernel has a limitation of 2TiB per block device.
 .TP
 .BR \-\-refresh
 If any logical volume in the volume group is active, reload its metadata.
@@ -174,24 +183,20 @@
 if something has gone wrong or if you're doing clustering
 manually without a clustered lock manager.
 .TP
-.BR \-x ", " \-\-resizeable " " { y | n }
+.BR \-x ", " \-\-resizeable " {" \fIy | \fIn }
 Enables or disables the extension/reduction of this volume group
 with/by physical volumes.
-.SH EXAMPLES
+.SH Examples
 To activate all known volume groups in the system:
-.nf
-
-\	vgchange -a y
+.sp
+.B vgchange -a y
 
-.fi
 To change the maximum number of logical volumes of inactive volume group
-.B vg00
-to 128.
-.nf
+vg00 to 128.
+.sp
+.B vgchange -l 128 /dev/vg00
 
-\	vgchange -l 128 /dev/vg00
 
-.fi
 .SH SEE ALSO
 .BR lvchange (8),
 .BR lvm (8),
--- LVM2/man/vgck.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgck.8.in	2012/04/11 12:42:10	1.3
@@ -3,11 +3,14 @@
 vgck \- check volume group metadata
 .SH SYNOPSIS
 .B vgck
-[\-d|\-\-debug] [\-h|\-?|\-\-help] [\-v|\-\-verbose] [VolumeGroupName...]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RI [ VolumeGroupName ...]
 .SH DESCRIPTION
 vgck checks LVM metadata for each named volume group for consistency.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
--- LVM2/man/vgconvert.8.in	2009/10/05 20:55:57	1.2
+++ LVM2/man/vgconvert.8.in	2012/04/11 12:42:10	1.3
@@ -8,29 +8,32 @@
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-labelsector ]
-.RB [ \-M | \-\-metadatatype type ]
-.RB [ \-\-pvmetadatacopies #copies ]
-.RB [ \-\-metadatasize size ]
+.RB [ \-M | \-\-metadatatype
+.IR type ]
+.RB [ \-\-pvmetadatacopies
+.IR NumberOfCopies ]
+.RB [ \-\-metadatasize
+.IR size ]
 .RB [ \-\-version ]
-.IR VolumeGroupName " [" VolumeGroupName ...]
+.I VolumeGroupName
+.RI [ VolumeGroupName ...]
 .SH DESCRIPTION
-.B vgconvert
-converts 
+vgconvert converts
 .I VolumeGroupName
 metadata from one format to another provided that the metadata
 fits into the same space.
 .SH OPTIONS
 See \fBlvm\fP(8) and \fBpvcreate\fP(8) for options.
-.SH EXAMPLE
-Convert volume group vg1 from LVM1 metadata format to the new LVM2 
+.SH Examples
+Convert volume group vg1 from LVM1 metadata format to the new LVM2
 metadata format.
 .sp
-.B vgconvert -M2 vg1
+.B vgconvert \-M2 vg1
 .SH RECOVERY
 Use \fBpvscan\fP(8) to see which PVs lost their metadata.
-Run \fBpvcreate\fP(8) with the --uuid and --restorefile options on each
-such PV to reformat it as it was, using the archive file that
-\fBvgconvert\fP(8) created at the start of the procedure.
+Run \fBpvcreate\fP(8) with the \fB\-\-uuid\fP and \fB\-\-restorefile\fP
+options on each such PV to reformat it as it was, using the archive
+file that \fBvgconvert\fP(8) created at the start of the procedure.
 Finally run \fBvgcfgrestore\fP(8) with that archive file to restore
 the original metadata.
 .SH SEE ALSO
--- LVM2/man/vgcreate.8.in	2010/07/02 17:05:22	1.9
+++ LVM2/man/vgcreate.8.in	2012/04/11 12:42:10	1.10
@@ -5,79 +5,83 @@
 .B vgcreate
 .RB [ \-\-addtag
 .IR Tag ]
-.RB [ \-\-alloc 
+.RB [ \-\-alloc
 .IR AllocationPolicy ]
-.RB [ \-A | \-\-autobackup " {" y | n }]
-.RB [ \-c | \-\-clustered " {" y | n }]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-c | \-\-clustered
+.RI { y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-l | \-\-maxlogicalvolumes
 .IR MaxLogicalVolumes ]
-.RB [ -M | \-\-metadatatype type]
+.RB [ -M | \-\-metadatatype
+.IR type ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
-.RB [ \-\-[vg]metadatacopies ]
-.IR NumberOfCopies|unmanaged|all ]
+.RB [ \-\- [ vg ] metadatacopies
+.IR NumberOfCopies | unmanaged | all ]
 .RB [ \-s | \-\-physicalextentsize
-.IR PhysicalExtentSize [ \fBbBsSkKmMgGtTpPeE\fR ]]
+.IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-[ \fIPHYSICAL DEVICE OPTIONS\fP ]
+.RB [ "PHYSICAL DEVICE OPTIONS" ]
 .I VolumeGroupName PhysicalDevicePath
 .RI [ PhysicalDevicePath ...]
 .SH DESCRIPTION
-.B vgcreate
-creates a new volume group called
+vgcreate creates a new volume group called
 .I VolumeGroupName
 using the block special device \fIPhysicalDevicePath\fP.
 .sp
 If \fIPhysicalDevicePath\fP was not previously configured for LVM with
-\fBpvcreate (8)\fP, the device will be initialized with the same
-default values used with \fBpvcreate\fP.  If non-default
+\fBpvcreate\fP(8), the device will be initialized with the same
+default values used with \fBpvcreate\fP(8).  If non-default
 \fPpvcreate\fP values are desired, they may be given on the
-commandline with the same options as \fPpvcreate\fP.  See
-\fBPHYSICAL DEVICE OPTIONS\fP for available options.  Note
-that the restore-related options such as --restorefile, --uuid,
-and --physicalvolumesize are not available.  If a restore operation
-is needed, use \fBpvcreate (8)\fP and \fBvgcfgrestore (8)\fP.
+commandline with the same options as \fBpvcreate\fP(8).  See
+.B PHYSICAL DEVICE OPTIONS
+for available options.  Note that the restore-related options such as
+.BR \-\-restorefile ", " \-\-uuid " and " \-\-physicalvolumesize
+are not available.  If a restore operation is needed, use 
+\fBpvcreate\fP(8) and \fBvgcfgrestore\fP(8).
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.BR \-c ", " \-\-clustered " " { y | n }
-If clustered locking is enabled, this defaults to \fBy\fP indicating that 
+.BR \-c ", " \-\-clustered " {" \fIy | \fIn }
+If clustered locking is enabled, this defaults to \fBy\fP indicating that
 this Volume Group is shared with other nodes in the cluster.
 
-If the new Volume Group contains only local disks that are not visible 
+If the new Volume Group contains only local disks that are not visible
 on the other nodes, you must specify \fB\-\-clustered\ n\fP.
 If the cluster infrastructure is unavailable on a particular node at a
 particular time, you may still be able to use such Volume Groups.
 .TP
-.BR \-l ", " \-\-maxlogicalvolumes " " \fIMaxLogicalVolumes\fR
+.BR \-l ", " \-\-maxlogicalvolumes " " \fIMaxLogicalVolumes
 Sets the maximum number of logical volumes allowed in this
-volume group. 
-The setting can be changed with \fBvgchange\fP.
+volume group.
+The setting can be changed with \fBvgchange\fP(8).
 For volume groups with metadata in lvm1 format, the limit
-and default value is 255.  
+and default value is 255.
 If the metadata uses lvm2 format, the default value is 0
 which removes this restriction: there is then no limit.
 .TP
-.BR \-p ", " \-\-maxphysicalvolumes " " \fIMaxPhysicalVolumes\fR
+.BR \-p ", " \-\-maxphysicalvolumes " " \fIMaxPhysicalVolumes
 Sets the maximum number of physical volumes that can belong
 to this volume group.
 The setting can be changed with \fBvgchange\fP.
 For volume groups with metadata in lvm1 format, the limit
-and default value is 255.  
+and default value is 255.
 If the metadata uses lvm2 format, the value 0 removes this restriction:
 there is then no limit.  If you have a large number of physical volumes in
 a volume group with metadata in lvm2 format, for tool performance reasons,
-you should consider some use of \fB--pvmetadatacopies 0\fP as described in
-\fBpvcreate(8)\fP, and/or use \fB--vgmetadatacopies\fP.
+you should consider some use of \fB\-\-pvmetadatacopies 0\fP as described in
+\fBpvcreate\fP(8), and/or use \fB\-\-vgmetadatacopies\fP.
 .TP
-.BR \-\-vgmetadatacopies " " \fINumberOfCopies|unmanaged|all\fP
+.BR \-\- [ vg ] metadatacopies " " \fINumberOfCopies | \fIunmanaged | \fIall
 Sets the desired number of metadata copies in the volume group.  If set to
 a non-zero value, LVM will automatically manage the 'metadataignore'
-flags on the physical volumes (see \fBpvcreate\fP or \fBpvchange\fP --metadataignore\fP) in order
+flags on the physical volumes (see \fBpvcreate\fP(8) or
+\fBpvchange \-\-metadataignore\fP) in order
 to achieve \fINumberOfCopies\fP copies of metadata.  If set to \fIunmanaged\fP,
 LVM will not automatically manage the 'metadataignore' flags.  If set to
 \fIall\fP, LVM will first clear all of the 'metadataignore' flags on all
@@ -87,56 +91,53 @@
 minimize metadata read and write overhead.
 The default value is \fIunmanaged\fP.
 .TP
-.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
+.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize [ \fIbBsSkKmMgGtTpPeE ]
 Sets the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
-is the default if no suffix is present.  
-The default is 4 MB and it must be at least 1 KB and a power of 2.
+is the default if no suffix is present.
+The default is 4 MiB and it must be at least 1 KiB and a power of 2.
 
 Once this value has been set, it is difficult to change it without recreating
-the volume group which would involve backing up and restoring data on any 
+the volume group which would involve backing up and restoring data on any
 logical volumes.  However, if no extents need moving for the new
-value to apply, it can be altered using vgchange \-s.
+value to apply, it can be altered using \fBvgchange \-s\fP.
 
 If the volume group metadata uses lvm1 format, extents can vary in size from
-8KB to 16GB and there is a limit of 65534 extents in each logical volume.  The
-default of 4 MB leads to a maximum logical volume size of around 256GB.  
+8KiB to 16GiB and there is a limit of 65534 extents in each logical volume.  The
+default of 4 MiB leads to a maximum logical volume size of around 256GiB.
 
 If the volume group metadata uses lvm2 format those restrictions do not apply,
 but having a large number of extents will slow down the tools but have no
-impact on I/O performance to the logical volume.  The smallest PE is 1KB.
+impact on I/O performance to the logical volume.  The smallest PE is 1KiB
+
+The 2.4 kernel has a limitation of 2TiB per block device.
 
-The 2.4 kernel has a limitation of 2TB per block device.
 .SH PHYSICAL DEVICE OPTIONS
 The following options are available for initializing physical devices in the
-volume group.  These options are further described in the pvcreate man page.
+volume group.  These options are further described in the \fBpvcreate\fP(8)
+man page.
 .TP
 .BR \-f ", " \-\-force
 .TP
 .BR \-y ", " \-\-yes
 .TP
-.BR \-Z ", " \-\-zero " y|n"
+.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 .TP
-.BR \-\-labelsector " sector"
+.B \-\-labelsector \fIsector
 .TP
-.BR \-\-metadatasize " size"
+.B \-\-metadatasize \fIsize
 .TP
-.BR \-\-pvmetadatacopies " copies"
+.B \-\-pvmetadatacopies \fIcopies
 .TP
-.BR \-\-dataalignment " alignment"
+.B \-\-dataalignment \fIalignment
 .TP
-.BR \-\-dataalignmentoffset " alignment_offset"
-.SH EXAMPLES
-To create a volume group named
-.B test_vg 
-using physical volumes
-.BR /dev/sdk1 ", and " /dev/sdl1
-with default physical extent size of 4MB:
-.nf
-
-\	vgcreate test_vg /dev/sdk1 /dev/sdl1
+.B \-\-dataalignmentoffset \fIalignment_offset
+.SH Examples
+Creates a volume group named "test_vg" using physical volumes "/dev/sdk1"
+and "/dev/sdl1" with default physical extent size of 4MiB:
+.sp
+.B vgcreate test_vg /dev/sdk1 /dev/sdl1
 
-.fi
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvdisplay (8),
--- LVM2/man/vgdisplay.8.in	2009/10/26 14:37:09	1.2
+++ LVM2/man/vgdisplay.8.in	2012/04/11 12:42:10	1.3
@@ -4,41 +4,54 @@
 .SH SYNOPSIS
 .B vgdisplay
 .RB [ \-A | \-\-activevolumegroups ]
-.RB [ \-c | \-\-colon | \-s | \-\-short | \-v|\-\-verbose ]
+.RB [ \-c | \-\-colon ]
+.RB [ \-s | \-\-short ]
+.RB [ \-v | \-\-verbose ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
 .RB [ \-\-nosuffix ]
 .RB [ \-P | \-\-partial ]
-.RB [\-\-units hHbBsSkKmMgGtTpPeE]
+.RB [ \-\-units
+.IR hHbBsSkKmMgGtTpPeE ]
 .RB [ \-\-version ]
-.RI [VolumeGroupName [VolumeGroupName...]]
+.RI [ VolumeGroupName
+.RI [ VolumeGroupName ...]]
 .br
 
 .br
-.B vgdisplay \-\-columns | \-C
-.RB [ \-\-aligned ] [ \-d|\-\-debug ] [ \-h|\-?|\-\-help ]
-.RB [ \-\-ignorelockingfailure ] [ \-\-noheadings ] [ \-\-nosuffix ]
-.RB [ \-o|\-\-options [+]Field[,Field] ]
-.RB [ \-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]] ]
-.RB [ \-P|\-\-partial ]
-.RB [ \-\-separator Separator ]
+.B vgdisplay
+.BR \-\-columns | \-C
+.RB [ \-\-aligned ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-noheadings ]
+.RB [ \-\-nosuffix ]
+.RB [ \-o|\-\-options
+.RI [ + ] Field1 [ ,Field2 ...]]
+.RB [ \-O | \-\-sort
+.RI [ + | - ] Key1 [ , [ + | - ] Key2 ...]]
+.RB [ \-P | \-\-partial ]
+.RB [ \-\-separator
+.IR Separator ]
 .RB [ \-\-unbuffered ]
-.RB [ \-\-units hHbBsSkKmMgGtTpPeE ]
-.RB [ \-v|\-\-verbose ]
+.RB [ \-\-units
+.IR hHbBsSkKmMgGtTpPeE ]
+.RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RI [VolumeGroupName [VolumeGroupName...]]
+.RI [ VolumeGroupName
+.RI [ VolumeGroupName ...]]
 .SH DESCRIPTION
-.B vgdisplay
-allows you to see the attributes of
+vgdisplay allows you to see the attributes of
 .I VolumeGroupName
 (or all volume groups if none is given) with it's physical and logical
 volumes and their sizes etc.
 .P
-\fBvgs\fP (8) is an alternative that provides the same information 
-in the style of \fBps\fP (1).
+\fBvgs\fP(8) is an alternative that provides the same information
+in the style of \fBps\fP(1).
 .SH OPTIONS
-See \fBlvm\fP for common options and \fBvgs\fP for options given with
+See \fBlvm\fP(8) for common options and \fBvgs\fP(8) for options given with
 \fB\-\-columns\fP.
 .TP
 .BR \-A ", " \-\-activevolumegroups
@@ -46,7 +59,7 @@
 .TP
 .BR \-c ", " \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
-N.B. \fBvgs\fP (8) provides considerably more control over the output.
+N.B. \fBvgs\fP(8) provides considerably more control over the output.
 .nf
 
 The values are:
@@ -79,12 +92,12 @@
 and logical volumes.  If given twice, also display verbose runtime
 information of vgdisplay's activities.
 .TP
-.BR \-\-version
+.B \-\-version
 Display version and exit successfully.
 .TP
 .BR \-\-columns | \-C
-Display output in columns, the equivalent of \fBvgs\fP.  Options listed
-are the same as options given in \fPvgs (8)\fP.
+Display output in columns, the equivalent of \fBvgs\fP(8). 
+Options listed are the same as options given in \fPvgs\fP(8).
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgs (8),
--- LVM2/man/vgexport.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgexport.8.in	2012/04/11 12:42:10	1.3
@@ -3,12 +3,14 @@
 vgexport \- make volume groups unknown to the system
 .SH SYNOPSIS
 .B vgexport
-[\-a|\-\-all]
-[\-d|\-\-debug] [\-h|\-?|\-\-help] 
-[\-v|\-\-verbose]
-VolumeGroupName [VolumeGroupName...]
+.RB [ \-a | \-\-all ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.I VolumeGroupName
+.RI [ VolumeGroupName ...]
 .SH DESCRIPTION
-vgexport allows you to make the inactive 
+vgexport allows you to make the inactive
 .IR VolumeGroupName (s)
 unknown to the system.
 You can then move all the Physical Volumes in that Volume Group to
@@ -16,9 +18,9 @@
 .BR vgimport (8).
 Most LVM2 tools ignore exported Volume Groups.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-a, \-\-all
+.BR \-a ", " \-\-all
 Export all inactive Volume Groups.
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/vgextend.8.in	2010/10/13 10:34:31	1.9
+++ LVM2/man/vgextend.8.in	2012/04/11 12:42:10	1.10
@@ -3,58 +3,63 @@
 vgextend \- add physical volumes to a volume group
 .SH SYNOPSIS
 .B vgextend
-[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help] 
-[\-\-restoremissing]
-[\-f|\-\-force]
-[\-t|\-\-test]
-[\-v|\-\-verbose]
-[ \fIPHYSICAL DEVICE OPTIONS\fP ]
-VolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-restoremissing ]
+.RB [ \-f | \-\-force ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.RB [ "PHYSICAL DEVICE OPTIONS" ]
+.I VolumeGroupName PhysicalDevicePath
+.RI [ PhysicalDevicePath ...]
 .SH DESCRIPTION
-vgextend allows you to add one or more initialized physical volumes ( see
-.B pvcreate(8)
-) to an existing volume group to extend it in size. Moreover, it allows you to
+vgextend allows you to add one or more initialized physical volumes
+(see \fBpvcreate\fP(8)) to an existing volume group to extend it in size. Moreover, it allows you to
 re-add a physical volume that has gone missing previously, due to a transient
-device failure, without re-initialising it. Use vgextend \-\-restoremissing to
-that effect.
+device failure, without re-initialising it. Use
+\fBvgextend \-\-restoremissing\fP to that effect.
 .sp
 If \fIPhysicalDevicePath\fP was not previously configured for LVM with
-\fBpvcreate (8)\fP, the device will be initialized with the same
-default values used with \fBpvcreate\fP.  If non-default
-\fPpvcreate\fP values are are desired, they may be given on the
-commandline with the same options as \fPpvcreate\fP.  See
-\fBPHYSICAL DEVICE OPTIONS\fP for available options.  Note
-that the restore-related options such as --restorefile, --uuid,
-and --physicalvolumesize are not available.  If a restore operation
-is needed, use \fBpvcreate (8)\fP and \fBvgcfgrestore (8)\fP.
+\fBpvcreate\fP(8), the device will be initialized with the same
+default values used with \fBpvcreate\fP(8).  If non-default
+\fPpvcreate\fP(8) values are desired, they may be given on the
+commandline with the same options as \fPpvcreate\fP(8).  See
+.B PHYSICAL DEVICE OPTIONS
+for available options.  Note that the restore-related options such as
+.BR \-\-restorefile ", " \-\-uuid " and " \-\-physicalvolumesize
+are not available.  If a restore operation
+is needed, use \fBpvcreate\fP(8) and \fBvgcfgrestore\fP(8).
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .SH PHYSICAL DEVICE OPTIONS
 The following options are available for initializing physical devices in the
-volume group.  These options are further described in the pvcreate man page.
+volume group.  These options are further described in the
+\fBpvcreate\fP(8) man page.
 .TP
 .BR \-f ", " \-\-force
 .TP
 .BR \-y ", " \-\-yes
 .TP
-.BR \-Z ", " \-\-zero " y|n"
+.BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 .TP
-.BR \-\-labelsector " sector"
+.B \-\-labelsector \fIsector
 .TP
-.BR \-\-metadatasize " size"
+.B \-\-metadatasize \fIsize
 .TP
-.RB [ \-\-metadataignore y|n ]
+.BR \-\-metadataignore " {" \fIy | \fIn }
 .TP
-.BR \-\-pvmetadatacopies " copies"
+.B \-\-pvmetadatacopies \fIcopies
 .TP
-.BR \-\-dataalignment " alignment"
+.B \-\-dataalignment \fIalignment
 .TP
-.BR \-\-dataalignmentoffset " alignment_offset"
+.B \-\-dataalignmentoffset \fIalignment_offset
 .SH Examples
-"vgextend vg00 /dev/sda4 /dev/sdn1" tries to extend the existing volume
-group "vg00" by the new physical volumes (see
-.B pvcreate(8)
-) "/dev/sdn1" and /dev/sda4".
+Extends the existing volume group "vg00" by the new physical volumes
+(see \fBpvcreate\fP(8)) "/dev/sda4" and "/dev/sdn1".
+.sp
+.B vgextend vg00 /dev/sda4 /dev/sdn1
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
--- LVM2/man/vgimport.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgimport.8.in	2012/04/11 12:42:10	1.3
@@ -3,20 +3,22 @@
 vgimport \- make exported volume groups known to the system
 .SH SYNOPSIS
 .B vgimport
-[\-a|\-\-all]
-[\-d|\-\-debug] [\-h|\-?|\-\-help] 
-[\-v|\-\-verbose]
-VolumeGroupName [VolumeGroupName...]
+.RB [ \-a | \-\-all ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.I VolumeGroupName
+.RI [ VolumeGroupName ...]
 .SH DESCRIPTION
-.B vgimport
-allows you to make a Volume Group that was previously exported using
+vgimport allows you to make a Volume Group that was previously
+exported using
 .BR vgexport (8)
 known to the system again, perhaps after moving its Physical Volumes
 from a different machine.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-a, \-\-all
+.BR \-a ", " \-\-all
 Import all exported Volume Groups.
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/vgimportclone.8.in	2010/06/23 16:12:30	1.3
+++ LVM2/man/vgimportclone.8.in	2012/04/11 12:42:10	1.4
@@ -3,55 +3,44 @@
 vgimportclone \- import and rename duplicated volume group (e.g. a hardware snapshot)
 .SH SYNOPSIS
 .B vgimportclone
-[\-n|\-\-basevgname VolumeGroupName]
-[\-i|\-\-import]
-PhysicalVolume [PhysicalVolume...]
+.RB [ \-n | \-\-basevgname
+.IR VolumeGroupName ]
+.RB [ \-i | \-\-import ]
+.I PhysicalVolume
+.RI [ PhysicalVolume ...]
 .SH DESCRIPTION
-.B vgimportclone
-is used to import a duplicated VG (e.g. hardware snapshot).  Duplicate VG(s)
-and PV(s) are not able to be used until they are made to coexist with
-the origin VG(s) and PV(s).   
-.B vgimportclone 
-renames the VG associated with the specified PV(s) and changes the
-associated VG and PV UUIDs.
+vgimportclone is used to import a duplicated VG (e.g. hardware snapshot).
+Duplicate VG(s) and PV(s) are not able to be used until they are made
+to coexist with the origin VG(s) and PV(s).
+vgimportclone renames the VG associated with the specified PV(s) and
+changes the associated VG and PV UUIDs.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-n|\-\-basevgname VolumeGroupName
+.BR \-n ", " \-\-basevgname " " \fIVolumeGroupName
 By default the snapshot VG will be renamed to the original name plus a
 numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed
 to 'test_vg1').  This option will override the base VG name that is
 used for all VG renames.  If a VG already exists with the specified name
 a numeric suffix will be added (like the previous example) to make it unique.
 .TP
-.I \-i|\-\-import
+.BR \-i ", " \-\-import
 Import exported Volume Groups.  Otherwise VGs that have been exported
 will not be changed (nor will their associated PVs).
 .SH ENVIRONMENT VARIABLES
 .TP
-\fBLVM_BINARY\fP
-The LVM2 binary to use.
-Defaults to "lvm".
-.SH EXAMPLES
-The origin VG
-.B vg00
-has origin PVs
-.BR /dev/sda " and " /dev/sdb
-and the respective snapshot PVs are
-.BR /dev/sdc " and " /dev/sdd "."
-To rename the VG
-associated with
-.BR /dev/sdc " and " /dev/sdd
-from
-.B vg00
-to
-.B vg00_snap
+.B LVM_BINARY
+The LVM2 binary to use. Defaults to "lvm".
+.SH Examples
+The origin VG "vg00" has origin PVs "/dev/sda" and "/dev/sdb"
+and the respective snapshot PVs are "/dev/sdc" and "/dev/sdd".
+To rename the VG associated with "/dev/sdc" and "/dev/sdd"
+from "vg00" to "vg00_snap"
 (and to change associated VG and PV UUIDs) do:
-.nf
-
-\	vgimportclone --basevgname vg00_snap /dev/sdc /dev/sdd
+.sp
+.B vgimportclone --basevgname vg00_snap /dev/sdc /dev/sdd
 
-.fi
 .SH SEE ALSO
-.BR lvm (8)
+.BR lvm (8),
+.BR vgrename (8)
 
--- LVM2/man/vgmerge.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgmerge.8.in	2012/04/11 12:42:10	1.3
@@ -3,25 +3,35 @@
 vgmerge \- merge two volume groups
 .SH SYNOPSIS
 .B vgmerge
-[\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help] [\-l|\-\-list]
-[\-t|\-\-test] [\-v|\-\-verbose] DestinationVolumeGroupName
-SourceVolumeGroupName
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-l | \-\-list ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.I DestinationVolumeGroupName
+.I SourceVolumeGroupName
 .SH DESCRIPTION
-vgmerge merges two existing volume groups. The inactive SourceVolumeGroupName
-will be merged into the DestinationVolumeGroupName if physical extent sizes
+vgmerge merges two existing volume groups. The inactive
+\fISourceVolumeGroupName\fP will be merged into 
+the \fIDestinationVolumeGroupName\fP if physical extent sizes
 are equal and physical and logical volume summaries of both volume groups
-fit into DestinationVolumeGroupName's limits.
+fit into \fIDestinationVolumeGroupName\fP's limits.
 .SH OPTIONS
-See \fBlvm\fP for common options.
-.I \-l, \-\-list
-Display merged DestinationVolumeGroupName like "vgdisplay -v".
+See \fBlvm\fP(8) for common options.
+.TP
+.BR \-l ", " \-\-list
+Display merged \fIDestinationVolumeGroupName\fP like \fBvgdisplay -v\fP.
 .TP 
-.I \-t, \-\-test
+.BR \-t ", " \-\-test
 Do a test run WITHOUT making any real changes.
 .SH Examples
-"vgmerge -v databases my_vg" merges the inactive volume group named "my_vg" 
+Merge the inactive volume group named "my_vg"
 into the active or inactive volume group named "databases" giving verbose
-runtime information.
+runtime information:
+.sp
+.B vgmerge -v databases my_vg
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
--- LVM2/man/vgmknodes.8.in	2009/02/25 13:17:41	1.3
+++ LVM2/man/vgmknodes.8.in	2012/04/11 12:42:10	1.4
@@ -3,23 +3,23 @@
 vgmknodes \- recreate volume group directory and logical volume special files
 .SH SYNOPSIS
 .B vgmknodes
-.RB [ \-d | \-\-debug]
-.RB [ \-h | \-\-help]
-.RB [ \-\-refresh]
-.RB [ \-v | \-\-verbose]
-[[VolumeGroupName | LogicalVolumePath]...]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-\-refresh ]
+.RB [ \-v | \-\-verbose ]
+.RI [[ VolumeGroupName | LogicalVolumePath ]...]
 .SH DESCRIPTION
 Checks the LVM2 special files in /dev that are needed for active 
 logical volumes and creates any missing ones and removes unused ones.
 .SH OPTIONS
 .TP
+See \fBlvm\fP(8) for common options.
+.TP
 .BR \-\-refresh
 If any logical volume in the volume group is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong or if you're doing clustering
 manually without a clustered lock manager.
-.TP
-See \fBlvm\fP for common options.
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgscan (8),
--- LVM2/man/vgreduce.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgreduce.8.in	2012/04/11 12:42:10	1.3
@@ -3,28 +3,34 @@
 vgreduce \- reduce a volume group
 .SH SYNOPSIS
 .B vgreduce
-[\-a|\-\-all] [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-removemissing]
-[\-t|\-\-test]
-[\-v|\-\-verbose] VolumeGroupName
-[PhysicalVolumePath...]
+.RB [ \-a | \-\-all ]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-removemissing ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.I VolumeGroupName
+.RI [ PhysicalVolumePath ...]
 .SH DESCRIPTION
 vgreduce allows you to remove one or more unused physical volumes
 from a volume group.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-a, \-\-all
+.BR \-a ", " \-\-all
 Removes all empty physical volumes if none are given on command line.
 .TP
-.I \-\-removemissing
+.B \-\-removemissing
 Removes all missing physical volumes from the volume group, if there are no
 logical volumes allocated on those. This resumes normal operation of the volume
 group (new logical volumes may again be created, changed and so on).
 
 If this is not possible (there are logical volumes referencing the missing
 physical volumes) and you cannot or do not want to remove them manually, you
-can run this option with --force to have vgreduce remove any partial LVs.
+can run this option with \fB--force\fP to have \fBvgreduce\fP
+remove any partial LVs.
 
 Any logical volumes and dependent snapshots that were partly on the 
 missing disks get removed completely. This includes those parts 
@@ -32,7 +38,7 @@
 
 If your logical volumes spanned several disks including the ones that are
 lost, you might want to try to salvage data first by activating your
-logical volumes with --partial as described in \fBlvm (8)\fP.
+logical volumes with \fB--partial\fP as described in \fBlvm\fP(8).
 
 .SH SEE ALSO
 .BR lvm (8),
--- LVM2/man/vgremove.8.in	2009/08/04 08:09:52	1.3
+++ LVM2/man/vgremove.8.in	2012/04/11 12:42:10	1.4
@@ -3,9 +3,14 @@
 vgremove \- remove a volume group
 .SH SYNOPSIS
 .B vgremove
-[\-d|\-\-debug] [\-f|\-\-force] [\-h|\-?|\-\-help]
-[\-\-noudevsync] [\-t|\-\-test] [\-v|\-\-verbose]
-VolumeGroupName [VolumeGroupName...]
+.RB [ \-d | \-\-debug ]
+.RB [ \-f | \-\-force ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-noudevsync ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
+.I VolumeGroupName
+.RI [ VolumeGroupName ...]
 .SH DESCRIPTION
 vgremove allows you to remove one or more volume groups.
 If one or more physical volumes in the volume group are lost,
@@ -16,7 +21,7 @@
 a prompt will be given to confirm removal.  You can override
 the prompt with \fB-f\fP.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
 .BR \-f ", " \-\-force
 Force the removal of any logical volumes on the volume group
--- LVM2/man/vgrename.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgrename.8.in	2012/04/11 12:42:10	1.3
@@ -3,32 +3,21 @@
 vgrename \- rename a volume group
 .SH SYNOPSIS
 .B vgrename
-[\-A|\-\-autobackup y|n]
-[\-d|\-\-debug]
-[\-h|\-?|\-\-help]
-[\-t|\-\-test]
-[\-v|\-\-verbose]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
 .IR OldVolumeGroup { Path | Name | UUID }
 .IR NewVolumeGroup { Path | Name }
 .SH DESCRIPTION
 vgrename renames an existing (see
-.B vgcreate(8)
-) volume group from
+.BR vgcreate (8))
+volume group from
 .IR OldVolumeGroup { Name | Path | UUID }
 to
 .IR NewVolumeGroup { Name | Path }.
-.SH OPTIONS
-See \fBlvm\fP for common options.
-.SH Examples
-"vgrename /dev/vg02 /dev/my_volume_group" renames existing
-volume group "vg02" to "my_volume_group".
-.TP
-"vgrename vg02 my_volume_group" does the same.
-.TP
-"vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 VolGroup00_tmp"
-changes the name of the Volume Group with UUID
-Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 to 
-"VolGroup00_tmp".
 
 All the Volume Groups visible to a system need to have different
 names.  Otherwise many LVM2 commands will refuse to run or give
@@ -41,7 +30,23 @@
 different UUIDs (unless the disk was cloned) so you can rename
 one of the conflicting Volume Groups with
 \fBvgrename\fP.
-.TP
+.SH OPTIONS
+See \fBlvm\fP(8) for common options.
+.SH Examples
+Renames existing volume group vg02 to my_volume_group:
+.sp
+.B vgrename /dev/vg02 /dev/my_volume_group
+
+or
+.sp
+.B vgrename vg02 my_volume_group
+
+Changes the name of the Volume Group with UUID
+.br
+Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 to VolGroup00_tmp:
+.sp
+.B vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 VolGroup00_tmp
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgchange (8),
--- LVM2/man/vgs.8.in	2010/06/28 20:34:12	1.12
+++ LVM2/man/vgs.8.in	2012/04/11 12:42:10	1.13
@@ -3,56 +3,69 @@
 vgs \- report information about volume groups
 .SH SYNOPSIS
 .B vgs
-[\-a|\-\-all]
-[\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
-[\-o|\-\-options [+]Field[,Field]]
-[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-P|\-\-partial] [\-\-rows]
-[\-\-separator Separator] [\-\-unbuffered]
-[\-\-units hHbBsSkKmMgGtTpPeE]
-[\-\-unquoted]
-[\-v|\-\-verbose] 
-[\-\-version] [VolumeGroupName [VolumeGroupName...]]
+.RB [ \-a | \-\-all ]
+.RB [ \-\-aligned ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-nameprefixes ]
+.RB [ \-\-noheadings ]
+.RB [ \-\-nosuffix ]
+.RB [ \-o | \-\-options
+.RI [ + ] Field1 [ ,Field2 ...]]
+.RB [ \-O | \-\-sort
+.RI [ + | \- ] Key1 [ , [ + | \- ] Key2 ...]]
+.RB [ \-P | \-\-partial ]
+.RB [ \-\-rows ]
+.RB [ \-\-separator
+.IR Separator ]
+.RB [ \-\-unbuffered ]
+.RB [ \-\-units
+.IR hHbBsSkKmMgGtTpPeE ]
+.RB [ \-\-unquoted ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RI [ VolumeGroupName
+.RI [ VolumeGroupName ...]]
 .SH DESCRIPTION
 vgs produces formatted output about volume groups.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-\-all
+.B \-\-all
 List all volume groups.  Equivalent to not specifying any volume groups.
 .TP
-.I \-\-aligned
-Use with \-\-separator to align the output columns.
+.B \-\-aligned
+Use with \fB\-\-separator\fP to align the output columns.
 .TP
-.I \-\-nameprefixes
+.B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
-with --noheadings to produce a list of field=value pairs that can
-be used to set environment variables (for example, in \fBudev (7)\fP rules).
+with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
+be used to set environment variables (for example, in \fBudev\fP(7) rules).
 .TP
-.I \-\-noheadings
+.B \-\-noheadings
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .TP
-.I \-\-nosuffix
-Suppress the suffix on output sizes.  Use with \-\-units (except h and H)
-if processing the output.
+.B \-\-nosuffix
+Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
+(except h and H) if processing the output.
 .TP
-.I \-o, \-\-options
+.BR \-o ", " \-\-options
 Comma-separated ordered list of columns.  Precede the list with '+' to append
 to the default selection of columns.
 .IP
-Use \fb-o vg_all\fP to select all volume group columns.
+Use \fB\-o vg_all\fP to select all volume group columns.
 .IP
-Use \fb-o help\fP to view the full list of columns available.
+Use \fB\-o help\fP to view the full list of columns available.
 .IP
 Column names include: vg_fmt, vg_uuid, vg_name, vg_attr, vg_size, vg_free,
 vg_sysid, vg_extent_size, vg_extent_count, vg_free_count, max_lv, max_pv,
 pv_count, lv_count, snap_count, vg_seqno, vg_tags, vg_mda_count, vg_mda_free,
 and vg_mda_size, vg_mda_used_count.
 .IP
-Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs (8)\fP 
-or \fBlvs (8)\fP can also be chosen, but columns cannot be taken from both
+Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs\fP(8)
+or \fBlvs\fP(8) can also be chosen, but columns cannot be taken from both
 at the same time.  
 .IP
 The vg_attr bits are:
@@ -72,27 +85,29 @@
 (c)lustered
 .RE
 .TP
-.I \-O, \-\-sort
+.BR \-O ", " \-\-sort
 Comma-separated ordered list of columns to sort by.  Replaces the default
-selection. Precede any column with - for a reverse sort on that column.
+selection. Precede any column with '\fI\-\fP' for a reverse sort on that
+column.
 .TP
-.I \-\-rows
+.B \-\-rows
 Output columns as rows.
 .TP
-.I \-\-separator Separator
+.B \-\-separator \fISeparator
 String to use to separate each column.  Useful if grepping the output.
 .TP
-.I \-\-unbuffered
+.B \-\-unbuffered
 Produce output immediately without sorting or aligning the columns properly.
 .TP
-.I \-\-units hHbBsSkKmMgGtTpPeE
+.B \-\-units \fIhHbBsSkKmMgGtTpPeE
 All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
 (k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
 custom units e.g. \-\-units 3M
 .TP
-.I \-\-unquoted
-When used with --nameprefixes, output values in the field=value pairs are not quoted.
+.B \-\-unquoted
+When used with \fB\-\-nameprefixes\fP, output values in the field=value
+pairs are not quoted.
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgdisplay (8),
--- LVM2/man/vgscan.8.in	2012/03/27 11:04:47	1.3
+++ LVM2/man/vgscan.8.in	2012/04/11 12:42:10	1.4
@@ -3,11 +3,12 @@
 vgscan \- scan all disks for volume groups and rebuild caches
 .SH SYNOPSIS
 .B vgscan
-[\-d|\-\-debug] [\-h|\-?|\-\-help] 
-[\-\-ignorelockingfailure]
-[\-\-mknodes]
-[\-P|\-\-partial]
-[\-v|\-\-verbose]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-mknodes ]
+.RB [ \-P | \-\-partial ]
+.RB [ \-v | \-\-verbose ]
 .SH DESCRIPTION
 vgscan scans all SCSI, (E)IDE disks, multiple devices and a bunch
 of other disk devices in the system looking for LVM physical volumes
@@ -17,13 +18,13 @@
 In LVM2, vgscans take place automatically; but you might still need to
 run one explicitly after changing hardware.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .TP
-.I \-\-mknodes
+.B \-\-mknodes
 Also checks the LVM special files in /dev that are needed for active 
 logical volumes and creates any missing ones and removes unused ones.
 .TP
-.I \-\-cache
+.B \-\-cache
 Scan devices for LVM physical volumes and volume groups and instruct
 the lvmetad daemon to update its cached state accordingly.
 .SH SEE ALSO
--- LVM2/man/vgsplit.8.in	2010/06/28 20:39:24	1.3
+++ LVM2/man/vgsplit.8.in	2012/04/11 12:42:10	1.4
@@ -5,8 +5,10 @@
 .B vgsplit
 .RB [ \-\-alloc
 .IR AllocationPolicy ]
-.RB [ \-A | \-\-autobackup " {" y | n }]
-.RB [ \-c | \-\-clustered " {" y | n }]
+.RB [ \-A | \-\-autobackup
+.RI { y | n }]
+.RB [ \-c | \-\-clustered
+.RI { y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-l | \-\-maxlogicalvolumes
@@ -15,35 +17,36 @@
 .IR type ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
-.RB [ \-\-[vg]metadatacopies ]
-.IR NumberOfCopies|unmanaged|all ]
-.RB [ \-n | \-\-name 
+.RB [ \-\- [ vg ] metadatacopies
+.IR NumberOfCopies | unmanaged | all ]
+.RB [ \-n | \-\-name
 .IR LogicalVolumeName ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
-SourceVolumeGroupName DestinationVolumeGroupName
-[ PhysicalVolumePath ...]
+.I SourceVolumeGroupName DestinationVolumeGroupName
+.RI [ PhysicalVolumePath ...]
 .SH DESCRIPTION
-.B vgsplit 
-moves one or more physical volumes from
-.I SourceVolumeGroupName
-into
-.I DestinationVolumeGroupName\fP.  The physical volumes moved can be
-specified either explicitly via \fIPhysicalVolumePath\fP, or implicitly by
-\fB-n\fP \fILogicalVolumeName\fP, in which case only physical volumes
+vgsplit moves one or more physical volumes from
+\fISourceVolumeGroupName\fP into \fIDestinationVolumeGroupName\fP.
+The physical volumes moved can be specified either explicitly via
+\fIPhysicalVolumePath\fP, or implicitly by \fB\-n\fP
+\fILogicalVolumeName\fP, in which case only physical volumes
 underlying the specified logical volume will be moved.
 
-If
-.I DestinationVolumeGroupName
-does not exist, a new volume group will be created.  The default attributes
-for the new volume group can be specified with \fB\-\-alloc\fR,
-\fB\-\-clustered\fR, \fB\-\-maxlogicalvolumes\fR, \fB\-\-metadatatype\fR,
-\fB\-\-maxphysicalvolumes\fR and \fB\-\-[vg]metadatacopies\fR,
-(see \fBvgcreate(8)\fR for a description of these options).  If any
+If \fIDestinationVolumeGroupName\fP does not exist, a new volume
+group will be created.  The default attributes
+for the new volume group can be specified with
+.BR \-\-alloc ,
+.BR \-\-clustered ,
+.BR \-\-maxlogicalvolumes ,
+.BR \-\-metadatatype ,
+.B \-\-maxphysicalvolumes \fRand
+.BR \-\- [ vg ] metadatacopies
+(see \fBvgcreate\fP(8) for a description of these options).  If any
 of these options are not given, default attribute(s) are taken from
-.I SourceVolumeGroupName\fP.  If a non-LVM2 metadata type (e.g. lvm1) is
-being used, you should use the -M option to specify the metadata type
-directly.
+\fISourceVolumeGroupName\fP. If a non-LVM2 metadata type (e.g. lvm1) is
+being used, you should use the \fB\-M\fP option to specify the metadata
+type directly.
 
 If
 .I DestinationVolumeGroupName
@@ -53,20 +56,20 @@
 volume group attributes with an existing destination volume group is an error,
 and no split will occur.
 
-Logical volumes cannot be split between volume groups. \fBVgsplit(8)\fP only
+Logical volumes cannot be split between volume groups. \fBvgsplit\fP(8) only
 moves complete physical volumes: To move part of a physical volume, use
-\fBpvmove(8)\fP.  Each existing logical volume must be entirely on the physical
+\fBpvmove\fP(8).  Each existing logical volume must be entirely on the physical
 volumes forming either the source or the destination volume group.  For this
-reason, \fBvgsplit(8)\fP may fail with an error if a split would result in a
+reason, \fBvgsplit\fP(8) may fail with an error if a split would result in a
 logical volume being split across volume groups.
 
-A \fBvgsplit\fP into an existing volume group retains the existing volume group's
-value of \fPvgmetadatacopies\fP (see \fBvgcreate\fP and \fBlvm.conf\fP for further
+A vgsplit into an existing volume group retains the existing volume group's
+value of \fPvgmetadatacopies\fP (see \fBvgcreate\fP(8) and \fBlvm.conf\fP(5) for further
 explanation of \fPvgmetadatacopies\fP).  To change the value of
-\fBvgmetadatacopies\fP, use \fBvgchange\fP.
+\fBvgmetadatacopies\fP, use \fBvgchange\fP(8).
 
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP(8) for common options.
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),


