From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  7 Aug 2015 21:26:27 +0000 (UTC)
Subject: master - man lvmlockd: update
Message-ID: <20150807212627.AACF561106@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2bbf2fa8ebc3d723bc686689378db2a1fe8eaf6e
Commit:        2bbf2fa8ebc3d723bc686689378db2a1fe8eaf6e
Parent:        1c013e7ae29a9e3aa20930a24f3fcf0637ef1e91
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 7 15:18:44 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 7 15:18:44 2015 -0500

man lvmlockd: update

---
 man/lvmlockd.8.in |  549 ++++++++++++++++++++++++++---------------------------
 1 files changed, 269 insertions(+), 280 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 9318350..1daea18 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -8,75 +8,75 @@ LVM commands use lvmlockd to coordinate access to shared storage.
 .br
 When LVM is used on devices shared by multiple hosts, locks will:
 
-.IP \[bu] 2
+\[bu]
 coordinate reading and writing of LVM metadata
-.IP \[bu] 2
+.br
+\[bu]
 validate caching of LVM metadata
-.IP \[bu] 2
+.br
+\[bu]
 prevent concurrent activation of logical volumes
-
-.P
+.br
 
 lvmlockd uses an external lock manager to perform basic locking.
 .br
 Lock manager (lock type) options are:
 
-.IP \[bu] 2
+\[bu]
 sanlock: places locks on disk within LVM storage.
-.IP \[bu] 2
+.br
+\[bu]
 dlm: uses network communication and a cluster manager.
-
-.P
+.br
 
 .SH OPTIONS
 
 lvmlockd [options]
 
-For default settings, see lvmlockd -h.
+For default settings, see lvmlockd \-h.
 
-.B  --help | -h
+.B  \-\-help | \-h
         Show this help information.
 
-.B  --version | -V
+.B  \-\-version | \-V
         Show version of lvmlockd.
 
-.B  --test | -T
+.B  \-\-test | \-T
         Test mode, do not call lock manager.
 
-.B  --foreground | -f
+.B  \-\-foreground | \-f
         Don't fork.
 
-.B  --daemon-debug | -D
+.B  \-\-daemon\-debug | \-D
         Don't fork and print debugging to stdout.
 
-.B  --pid-file | -p
+.B  \-\-pid\-file | \-p
 .I path
         Set path to the pid file.
 
-.B  --socket-path | -s
+.B  \-\-socket\-path | \-s
 .I path
         Set path to the socket to listen on.
 
-.B  --syslog-priority | -S err|warning|debug
+.B  \-\-syslog\-priority | \-S err|warning|debug
         Write log messages from this level up to syslog.
 
-.B  --gl-type | -g
-.I str
-        Set global lock type to be sanlock|dlm.
+.B  \-\-gl\-type | \-g sanlock|dlm
+        Set global lock type to be sanlock or dlm.
 
-.B  --host-id | -i
+.B  \-\-host\-id | \-i
 .I num
         Set the local sanlock host id.
 
-.B  --host-id-file | -F
+.B  \-\-host\-id\-file | \-F
 .I path
         A file containing the local sanlock host_id.
 
-.B  --sanlock-timeout | -o
+.B  \-\-sanlock\-timeout | \-o
 .I seconds
         Override the default sanlock I/O timeout.
 
-.B  --adopt | A 0|1
+.B  \-\-adopt | \-A 0|1
         Adopt locks from a previous instance of lvmlockd.
 
 
@@ -84,7 +84,7 @@ For default settings, see lvmlockd -h.
 
 .SS Initial set up
 
-Using LVM with lvmlockd for the first time includes some one-time set up
+Using LVM with lvmlockd for the first time includes some one\-time set up
 steps:
 
 .SS 1. choose a lock manager
@@ -112,9 +112,9 @@ use_lvmetad = 1
 
 .I sanlock
 .br
-Assign each host a unique host_id in the range 1-2000 by setting
+Assign each host a unique host_id in the range 1\-2000 by setting
 .br
-/etc/lvm/lvmlocal.conf local/host_id = <num>
+/etc/lvm/lvmlocal.conf local/host_id
 
 .SS 3. start lvmlockd
 
@@ -132,32 +132,32 @@ Follow external clustering documentation when applicable, otherwise:
 .br
 systemctl start corosync dlm
 
-.SS 5. create VGs on shared devices
+.SS 5. create VG on shared devices
 
-vgcreate --shared <vg_name> <devices>
+vgcreate \-\-shared <vgname> <devices>
 
-The vgcreate --shared option sets the VG lock type to sanlock or dlm
-depending on which lock manager is running.  LVM commands will perform
-locking for the VG using lvmlockd.
+The shared option sets the VG lock type to sanlock or dlm depending on
+which lock manager is running.  LVM commands will perform locking for the
+VG using lvmlockd.
 
-.SS 6. start VGs on all hosts
+.SS 6. start VG on all hosts
 
-vgchange --lock-start
+vgchange \-\-lock\-start
 
-lvmlockd requires shared VGs to be "started" before they are used.  This
-is a lock manager operation to start/join the VG lockspace, and it may
-take some time.  Until the start completes, locks for the VG are not
-available.  LVM commands are allowed to read the VG while start is in
-progress.  (A service/init file can be used to start VGs.)
+lvmlockd requires shared VGs to be started before they are used.  This is
+a lock manager operation to start (join) the VG lockspace, and it may take
+some time.  Until the start completes, locks for the VG are not available.
+LVM commands are allowed to read the VG while start is in progress.  (An
+init/unit file can also be used to start VGs.)
 
 .SS 7. create and activate LVs
 
 Standard lvcreate and lvchange commands are used to create and activate
-LVs in a lockd VG.
+LVs in a shared VG.
 
 An LV activated exclusively on one host cannot be activated on another.
 When multiple hosts need to use the same LV concurrently, the LV can be
-activated with a shared lock (see lvchange options -aey vs -asy.)
+activated with a shared lock (see lvchange options \-aey vs \-asy.)
 (Shared locks are disallowed for certain LV types that cannot be used from
 multiple hosts.)
 
@@ -165,43 +165,51 @@ multiple hosts.)
 .SS Normal start up and shut down
 
 After initial set up, start up and shut down include the following general
-steps.  They can be performed manually or using the system init/service
+steps.  They can be performed manually or using the system service
 manager.
 
-.IP \[bu] 2
+\[bu]
 start lvmetad
-.IP \[bu] 2
+.br
+\[bu]
 start lvmlockd
-.IP \[bu] 2
+.br
+\[bu]
 start lock manager
-.IP \[bu] 2
-vgchange --lock-start
-.IP \[bu] 2
+.br
+\[bu]
+vgchange \-\-lock\-start
+.br
+\[bu]
 activate LVs in shared VGs
-
-.P
+.br
 
 The shut down sequence is the reverse:
 
-.IP \[bu] 2
+\[bu]
 deactivate LVs in shared VGs
-.IP \[bu] 2
-vgchange --lock-stop
-.IP \[bu] 2
+.br
+\[bu]
+vgchange \-\-lock\-stop
+.br
+\[bu]
 stop lock manager
-.IP \[bu] 2
+.br
+\[bu]
 stop lvmlockd
-.IP \[bu] 2
+.br
+\[bu]
 stop lvmetad
+.br
 
 .P
 
 .SH TOPICS
 
-.SS locking terms
+.SS VG access control
 
-The following terms are used to distinguish VGs that require locking from
-those that do not.
+The following terms are used to describe different forms of VG access
+control.
 
 .I "lockd VG"
 
@@ -210,18 +218,19 @@ Using it requires lvmlockd.  These VGs exist on shared storage that is
 visible to multiple hosts.  LVM commands use lvmlockd to perform locking
 for these VGs when they are used.
 
-If the lock manager for a lock type is not available (e.g. not started or
-failed), lvmlockd is not able to acquire locks from it, and LVM commands
-are unable to fully use VGs with the given lock type.  Commands generally
-allow reading VGs in this condition, but changes and activation are not
-allowed.  Maintaining a properly running lock manager can require
-background not covered here.
+If the lock manager for the lock type is not available (e.g. not started
+or failed), lvmlockd is unable to acquire locks for LVM commands.  LVM
+commands that only read the VG will generally be allowed to continue
+without locks in this case (with a warning).  Commands to modify or
+activate the VG will fail without the necessary locks.  Maintaining a
+properly running lock manager requires knowledge covered in separate
+documentation.
 
 .I "local VG"
 
 A "local VG" is meant to be used by a single host.  It has no lock type or
 lock type "none".  LVM commands and lvmlockd do not perform locking for
-these VGs.  A local VG typically exists on local (non-shared) devices and
+these VGs.  A local VG typically exists on local (non\-shared) devices and
 cannot be used concurrently from different hosts.
 
 If a local VG does exist on shared devices, it should be owned by a single
@@ -240,21 +249,25 @@ clvmd for clustering.  See below for converting a clvm VG to a lockd VG.
 
 .SS lockd VGs from hosts not using lvmlockd
 
-Only hosts that will use lockd VGs should be configured to run lvmlockd.
+Only hosts that use lockd VGs should be configured to run lvmlockd.
 However, devices with lockd VGs may be visible from hosts not using
 lvmlockd.  From a host not using lvmlockd, visible lockd VGs are ignored
 in the same way as foreign VGs, i.e. those with a foreign system ID, see
 .BR lvmsystemid (7).
 
-The --shared option displays lockd VGs on a host not using lvmlockd, like
-the --foreign option does for foreign VGs.
+The \-\-shared option for reporting and display commands causes lockd VGs
+to be displayed on a host not using lvmlockd, like the \-\-foreign option
+does for foreign VGs.
 
 
-.SS vgcreate differences
+.SS vgcreate comparison
 
-Forms of the vgcreate command:
+The type of VG access control is specified in the vgcreate command.
+See
+.BR vgcreate (8)
+for all vgcreate options.
 
-.B vgcreate <vg_name> <devices>
+.B vgcreate <vgname> <devices>
 
 .IP \[bu] 2
 Creates a local VG with the local system ID when neither lvmlockd nor clvm are configured.
@@ -265,11 +278,12 @@ Creates a clvm VG when clvm is configured.
 
 .P
 
-.B vgcreate --shared <vg_name> <devices>
+.B vgcreate \-\-shared <vgname> <devices>
 .IP \[bu] 2
-Requires lvmlockd to be configured (use_lvmlockd=1).
+Requires lvmlockd to be configured and running.
 .IP \[bu] 2
-Creates a lockd VG with lock type sanlock|dlm depending on which is running.
+Creates a lockd VG with lock type sanlock|dlm depending on which lock
+manager is running.
 .IP \[bu] 2
 LVM commands request locks from lvmlockd to use the VG.
 .IP \[bu] 2
@@ -277,9 +291,9 @@ lvmlockd obtains locks from the selected lock manager.
 
 .P
 
-.B vgcreate -c|--clustered y <vg_name> <devices>
+.B vgcreate \-c|\-\-clustered y <vgname> <devices>
 .IP \[bu] 2
-Requires clvm to be configured (locking_type=3).
+Requires clvm to be configured and running.
 .IP \[bu] 2
 Creates a clvm VG with the "clustered" flag.
 .IP \[bu] 2
@@ -289,62 +303,79 @@ LVM commands request locks from clvmd to use the VG.
 
 .SS using lockd VGs
 
+There are some special considerations to be aware of when using lockd VGs.
+
 When use_lvmlockd is first enabled, and before the first lockd VG is
-created, no global lock will exist, and LVM commands will try and fail to
-acquire it.  LVM commands will report a warning until the first lockd VG
-is created which will create the global lock.  Before the global lock
-exists, VGs can still be read, but commands that require the global lock
-exclusively will fail.
+created, no global lock will exist.  In this initial state, LVM commands
+try and fail to acquire the global lock, producing a warning, and some
+commands are disallowed.  Once the first lockd VG is created, the global
+lock will be available, and LVM will be fully operational.
 
 When a new lockd VG is created, its lockspace is automatically started on
-the host that creates the VG.  Other hosts will need to run 'vgchange
---lock-start' to start the new VG before they can use it.
+the host that creates it.  Other hosts need to run 'vgchange
+\-\-lock\-start' to start the new VG before they can use it.
 
 From the 'vgs' command, lockd VGs are indicated by "s" (for shared) in the
 sixth attr field.  The specific lock type and lock args for a lockd VG can
-be displayed with 'vgs -o+locktype,lockargs'.
+be displayed with 'vgs \-o+locktype,lockargs'.
+
+lockd VGs need to be "started" and "stopped", unlike other types of VGs.
+See the following section for a full description of starting and stopping.
 
 
 .SS starting and stopping VGs
 
-Starting a lockd VG (vgchange --lock-start) causes the lock manager to
-start or join the lockspace for the VG.  This makes locks for the VG
-accessible to the host.  Stopping the VG leaves the lockspace and makes
-locks for the VG inaccessible to the host.
+Starting a lockd VG (vgchange \-\-lock\-start) causes the lock manager to
+start (join) the lockspace for the VG on the host where it is run.  This
+makes locks for the VG available to LVM commands on the host.  Before a VG
+is started, only LVM commands that read/display the VG without locks are
+allowed.
 
-Lockspaces should be started as early as possible because starting
-(joining) a lockspace can take a long time (potentially minutes after a
-host failure when using sanlock.)  A VG can be started after all the
-following are true:
+Stopping a lockd VG (vgchange \-\-lock\-stop) causes the lock manager to
+stop (leave) the lockspace for the VG on the host where it is run.  This
+makes locks for the VG inaccessible to the host.  A VG cannot be stopped
+while it has active LVs.
 
-.nf
-- lvmlockd is running
-- lock manager is running
-- VG is visible to the system
-.fi
+When using the lock type sanlock, starting a VG can take a long time
+(potentially minutes if the host was previously shut down without cleanly
+stopping the VG.)
+
+A lockd VG can be started after all the following are true:
+.br
+\[bu]
+lvmlockd is running
+.br
+\[bu]
+the lock manager is running
+.br
+\[bu]
+the VG is visible to the system
+.br
+
+A lockd VG can be stopped if all LVs are deactivated.
 
 All lockd VGs can be started/stopped using:
 .br
-vgchange --lock-start
+vgchange \-\-lock-start
 .br
-vgchange --lock-stop
+vgchange \-\-lock-stop
 
 
 Individual VGs can be started/stopped using:
 .br
-vgchange --lock-start <vg_name> ...
+vgchange \-\-lock\-start <vgname> ...
 .br
-vgchange --lock-stop <vg_name> ...
+vgchange \-\-lock\-stop <vgname> ...
 
 To make vgchange not wait for start to complete:
 .br
-vgchange --lock-start --lock-opt nowait
+vgchange \-\-lock\-start \-\-lock\-opt nowait
 .br
-vgchange --lock-start --lock-opt nowait <vg_name>
+vgchange \-\-lock\-start \-\-lock\-opt nowait <vgname>
 
 To stop all lockspaces and wait for all to complete:
 .br
-lvmlockctl --stop-lockspaces --wait
+lvmlockctl \-\-stop\-lockspaces \-\-wait
 
 To start only selected lockd VGs, use the lvm.conf
 activation/lock_start_list.  When defined, only VG names in this list are
@@ -366,7 +397,7 @@ Scripts or programs on a host that automatically start VGs will use the
 "auto" option to indicate that the command is being run automatically by
 the system:
 
-vgchange --lock-start --lock-opt auto [vg_name ...]
+vgchange \-\-lock\-start \-\-lock\-opt auto [<vgname> ...]
 
 Without any additional configuration, including the "auto" option has no
 effect; all VGs are started unless restricted by lock_start_list.
@@ -387,21 +418,25 @@ To use auto activation of lockd LVs (see auto_activation_volume_list),
 auto starting of the corresponding lockd VGs is necessary.
 
 
-.SS locking activity
+.SS internal command locking
 
-To optimize the use of LVM with lvmlockd, consider the three kinds of
-locks in lvmlockd and when they are used:
+To optimize the use of LVM with lvmlockd, be aware of the three kinds of
+locks and when they are used:
 
 .I GL lock
 
 The global lock (GL lock) is associated with global information, which is
 information not isolated to a single VG.  This includes:
 
-- The global VG namespace.
+\[bu]
+The global VG namespace.
+.br
+\[bu]
+The set of orphan PVs and unused devices.
 .br
-- The set of orphan PVs and unused devices.
+\[bu]
+The properties of orphan PVs, e.g. PV size.
 .br
-- The properties of orphan PVs, e.g. PV size.
 
 The global lock is used in shared mode by commands that read this
 information, or in exclusive mode by commands that change it.
@@ -414,12 +449,7 @@ creates a new VG name, and it takes a PV from the list of unused PVs.
 
 When an LVM command is given a tag argument, or uses select, it must read
 all VGs to match the tag or selection, which causes the global lock to be
-acquired.  To avoid use of the global lock, avoid using tags and select,
-and specify VG name arguments.
-
-When use_lvmlockd is enabled, LVM commands attempt to acquire the global
-lock even if no lockd VGs exist.  For this reason, lvmlockd should not be
-enabled unless lockd VGs will be used.
+acquired.
 
 .I VG lock
 
@@ -432,7 +462,7 @@ The command 'vgs' will not only acquire the GL lock to read the list of
 all VG names, but will acquire the VG lock for each VG prior to reading
 it.
 
-The command 'vgs <vg_name>' does not acquire the GL lock (it does not need
+The command 'vgs <vgname>' does not acquire the GL lock (it does not need
 the list of all VG names), but will acquire the VG lock on each VG name
 argument.
 
@@ -444,14 +474,14 @@ activated.  LV locks are persistent and remain in place after the
 activation command is done.  GL and VG locks are transient, and are held
 only while an LVM command is running.
 
-.I retries
+.I lock retries
 
 If a request for a GL or VG lock fails due to a lock conflict with another
 host, lvmlockd automatically retries for a short time before returning a
-failure to the LVM command.  The LVM command will then retry the entire
-lock request a number of times specified by global/lvmlockd_lock_retries
-before failing.  If a request for an LV lock fails due to a lock conflict,
-the command fails immediately.
+failure to the LVM command.  If those retries are insufficient, the LVM
+command will retry the entire lock request a number of times specified by
+global/lvmlockd_lock_retries before failing.  If a request for an LV lock
+fails due to a lock conflict, the command fails immediately.
 
 
 .SS sanlock global lock
@@ -470,21 +500,22 @@ are moved or removed.
 
 The vgcreate command typically acquires the global lock, but in the case
 of the first sanlock VG, there will be no global lock to acquire until the
-initial vgcreate is complete.  So, creating the first sanlock VG is a
+first vgcreate is complete.  So, creating the first sanlock VG is a
 special case that skips the global lock.
 
 vgcreate for a sanlock VG determines it is the first one to exist if no
 other sanlock VGs are visible.  It is possible that other sanlock VGs do
-exist but are not visible or started on the host running vgcreate.  This
-raises the possibility of more than one global lock existing.  If this
-happens, commands will warn of the condition, and it should be manually
-corrected.
+exist but are not visible on the host running vgcreate.  In this case,
+vgcreate would create a new sanlock VG with the global lock enabled.  When
+the other VG containing a global lock appears, lvmlockd will see more than
+one VG with a global lock enabled, and LVM commands will report that there
+are duplicate global locks.
 
 If the situation arises where more than one sanlock VG contains a global
 lock, the global lock should be manually disabled in all but one of them
 with the command:
 
-lvmlockctl --gl-disable <vg_name>
+lvmlockctl \-\-gl\-disable <vgname>
 
 (The one VG with the global lock enabled must be visible to all hosts.)
 
@@ -494,55 +525,18 @@ and subsequent LVM commands will fail to acquire it.  In this case, the
 global lock needs to be manually enabled in one of the remaining sanlock
 VGs with the command:
 
-lvmlockctl --gl-enable <vg_name>
+lvmlockctl \-\-gl\-enable <vgname>
 
 A small sanlock VG dedicated to holding the global lock can avoid the case
 where the GL lock must be manually enabled after a vgremove.
 
 
-.SS changing a local VG to a lockd VG
-
-All LVs must be inactive to change the lock type.
-
-lvmlockd must be configured and running as described in USAGE.
-
-Change a local VG to a lockd VG with the command:
-.br
-vgchange \-\-lock\-type sanlock|dlm <vg_name>
-
-Start the VG on any hosts that need to use it:
-.br
-vgchange \-\-lock\-start <vg_name>
+.SS sanlock VG usage
 
-
-.SS changing a clvm VG to a lockd VG
-
-All LVs must be inactive to change the lock type.
-
-1. Change the clvm VG to a local VG.
-
-Within a running clvm cluster, change a clvm VG to a local VG with the
-command:
-
-vgchange \-cn <vg_name>
-
-If the clvm cluster is no longer running on any nodes, then extra options
-can be used forcibly make the VG local.  Caution: this is only safe if all
-nodes have stopped using the VG:
-
-vgchange \-\-config 'global/locking_type=0 global/use_lvmlockd=0'
-.RS
-\-cn <vg_name>
-.RE
-
-2. After the VG is local, follow the steps described in "changing a local
-VG to a lockd VG".
-
-
-.SS vgremove and vgreduce with sanlock VGs
+There are some special cases related to using a sanlock VG.
 
 vgremove of a sanlock VG will fail if other hosts have the VG started.
-Run vgchange --lock-stop <vg_name> on all other hosts before vgremove.
+Run vgchange \-\-lock-stop <vgname> on all other hosts before vgremove.
 
 (It may take several seconds before vgremove recognizes that all hosts
 have stopped.)
@@ -550,17 +544,20 @@ have stopped.)
 A sanlock VG contains a hidden LV called "lvmlock" that holds the sanlock
 locks.  vgreduce cannot yet remove the PV holding the lvmlockd LV.
 
+To place the lvmlock LV on a specific device, create the VG with only that
+device, then use vgextend to add other devices.
+
 
 .SS shared LVs
 
 When an LV is used concurrently from multiple hosts (e.g. by a
-multi-host/cluster application or file system), the LV can be activated on
-multiple hosts concurrently using a shared lock.
+multi\-host/cluster application or file system), the LV can be activated
+on multiple hosts concurrently using a shared lock.
 
-To activate the LV with a shared lock:  lvchange -asy vg/lv.
+To activate the LV with a shared lock:  lvchange \-asy vg/lv.
 
 With lvmlockd, an unspecified activation mode is always exclusive, i.e.
--ay defaults to -aey.
+\-ay defaults to \-aey.
 
 If the LV type does not allow the LV to be used concurrently from multiple
 hosts, then a shared activation lock is not allowed and the lvchange
@@ -578,57 +575,13 @@ locks if the PV holding the locks is lost.  Contact the LVM group for
 help with this process.
 
 
-.\" This is not clean or safe enough to suggest using without help.
-.\"
-.\" .SS recover from lost PV holding sanlock locks
-.\"
-.\" In a sanlock VG, the locks are stored on a PV within the VG.  If this PV
-.\" is lost, the locks need to be reconstructed as follows:
-.\"
-.\" 1. Enable the unsafe lock modes option in lvm.conf so that default locking requirements can be overriden.
-.\"
-.\" .nf
-.\" allow_override_lock_modes = 1
-.\" .fi
-.\"
-.\" 2. Remove missing PVs and partial LVs from the VG.
-.\"
-.\" Warning: this is a dangerous operation.  Read the man page
-.\" for vgreduce first, and try running with the test option.
-.\" Verify that the only missing PV is the PV holding the sanlock locks.
-.\"
-.\" .nf
-.\" vgreduce --removemissing --force --lock-gl na --lock-vg na <vg>
-.\" .fi
-.\"
-.\" 3. If step 2 does not remove the internal/hidden "lvmlock" lv, it should be removed.
-.\"
-.\" .nf
-.\" lvremove --lock-vg na --lock-lv na <vg>/lvmlock
-.\" .fi
-.\"
-.\" 4. Change the lock type to none.
-.\"
-.\" .nf
-.\" vgchange --lock-type none --force --lock-gl na --lock-vg na <vg>
-.\" .fi
-.\"
-.\" 5. VG space is needed to recreate the locks.  If there is not enough space, vgextend the vg.
-.\"
-.\" 6. Change the lock type back to sanlock.  This creates a new internal
-.\" lvmlock lv, and recreates locks.
-.\"
-.\" .nf
-.\" vgchange --lock-type sanlock <vg>
-.\" .fi
-
 .SS locking system failures
 
 .B lvmlockd failure
 
 If lvmlockd fails or is killed while holding locks, the locks are orphaned
-in the lock manager.  lvmlockd can be restarted, and it will adopt the
-locks from the lock manager that had been held by the previous instance.
+in the lock manager.  lvmlockd can be restarted with an option to adopt
+locks in the lock manager that had been held by the previous instance.
 
 .B dlm/corosync failure
 
@@ -638,37 +591,33 @@ method configured within the dlm/corosync clustering environment.
 LVM commands on other hosts will be blocked from acquiring any locks until
 the dlm/corosync recovery process is complete.
 
-.B sanlock lock storage failure
-
-If access to the device containing the VG's locks is lost, sanlock cannot
-renew its leases for locked LVs.  This means that the host could soon lose
-the lease to another host which could activate the LV exclusively.
-sanlock is designed to never reach the point where two hosts hold the
-same lease exclusively at once, so the same LV should never be active on
-two hosts at once when activated exclusively.
-
-The current method of handling this involves no action from lvmlockd,
-which allows sanlock to protect the leases itself.  This produces a safe
-but potentially inconvenient result.  Doing nothing from lvmlockd leads to
-the host's LV locks not being released, which leads to sanlock using the
-local watchdog to reset the host before another host can acquire any locks
-held by the local host.
-
-LVM commands on other hosts will be blocked from acquiring locks held by
-the failed/reset host until the sanlock recovery time expires (2-4
-minutes).  This includes activation of any LVs that were locked by the
-failed host.  It also includes GL/VG locks held by any LVM commands that
-happened to be running on the failed host at the time of the failure.
-
-(In the future, lvmlockd may have the option to suspend locked LVs in
-response the sanlock leases expiring.  This would avoid the need for
-sanlock to reset the host.)
+.B sanlock lease storage failure
+
+If a host loses access to the device holding a VG's locks, sanlock cannot
+renew the VG's lockspace lease for those locks.  After some time, the
+lease will expire, and locks held by the host can be acquired by other
+hosts.
+
+If no LVs are active in the VG, the lockspace with an expiring lease will
+be shut down, and errors will be reported when trying to use the VG.  Use
+the lvmlockctl \-\-drop command to clear the stale lockspace from
+lvmlockd.
+
+If the VG has active LVs, the LVs must be quickly deactivated before the
+lockspace lease expires.  After all LVs are deactivated, run lvmlockctl
+\-\-drop <vgname> to clear the expiring lockspace from lvmlockd.  If all
+LVs in the VG are not deactivated within about 40 seconds, sanlock will
+reset the host using the local watchdog.  The host reset is ultimately a
+severe form of "deactivating" LVs before they can be activated on other
+hosts.  The reset is considered a better alternative than having LVs used
+by multiple hosts at once, which could easily damage or destroy their
+content.  A future enhancement may automatically attempt to deactivate LVs
+before the lockspace lease expires.
 
 .B sanlock daemon failure
 
 If the sanlock daemon fails or exits while a lockspace is started, the
-local watchdog will reset the host.  See previous section for the impact
-on other hosts.
+local watchdog will reset the host.
 
 
 .SS changing dlm cluster name
@@ -688,44 +637,84 @@ cluster name for the dlm VG must be changed.  To do this:
 
 3. Change the VG lock type to none:
 .br
-   vgchange --lock-type none --force <vg_name>
+   vgchange \-\-lock\-type none \-\-force <vgname>
 
 4. Change the VG lock type back to dlm which sets the new cluster name:
 .br
-   vgchange --lock-type dlm <vg_name>
+   vgchange \-\-lock\-type dlm <vgname>
 
 
-.SS limitations of lvmlockd and lockd VGs
+.SS changing a local VG to a lockd VG
 
-lvmlockd currently requires using lvmetad and lvmpolld.
+All LVs must be inactive to change the lock type.
+
+lvmlockd must be configured and running as described in USAGE.
 
-If a lockd VG becomes visible after the initial system startup, it is not
-automatically started through the system service/init manager, and LVs in
-it are not autoactivated.
+Change a local VG to a lockd VG with the command:
+.br
+vgchange \-\-lock\-type sanlock|dlm <vgname>
+
+Start the VG on any hosts that need to use it:
+.br
+vgchange \-\-lock\-start <vgname>
+
+
+.SS changing a clvm VG to a lockd VG
+
+All LVs must be inactive to change the lock type.
+
+First change the clvm VG to a local VG.  Within a running clvm cluster,
+change a clvm VG to a local VG with the command:
+
+vgchange \-cn <vgname>
+
+If the clvm cluster is no longer running on any nodes, then extra options
+can be used forcibly make the VG local.  Caution: this is only safe if all
+nodes have stopped using the VG:
+
+vgchange \-\-config 'global/locking_type=0 global/use_lvmlockd=0'
+.RS
+\-cn <vgname>
+.RE
+
+After the VG is local, follow the steps described in "changing a local VG
+to a lockd VG".
+
+
+.SS limitations of lockd VGs
+
+lvmlockd currently requires using lvmetad and lvmpolld.
 
 Things that do not yet work in lockd VGs:
 .br
-- creating a new thin pool and a new thin LV in a single command
+\[bu]
+creating a new thin pool and a new thin LV in a single command
 .br
-- using lvcreate to create cache pools or cache LVs (use lvconvert)
+\[bu]
+using lvcreate to create cache pools or cache LVs (use lvconvert)
 .br
-- using external origins for thin LVs
+\[bu]
+using external origins for thin LVs
 .br
-- splitting mirrors and snapshots from LVs
+\[bu]
+splitting mirrors and snapshots from LVs
 .br
-- vgsplit
+\[bu]
+vgsplit
 .br
-- vgmerge
+\[bu]
+vgmerge
 .br
-- resizing an LV that is active in the shared mode on multiple hosts
+\[bu]
+resizing an LV that is active in the shared mode on multiple hosts
 
 
-.SS clvmd to lvmlockd transition
+.SS lvmlockd changes from clvmd
 
 (See above for converting an existing clvm VG to a lockd VG.)
 
-While lvmlockd and clvmd are entirely different systems, LVM usage remains
-largely the same.  Differences are more notable when using lvmlockd's
+While lvmlockd and clvmd are entirely different systems, LVM command usage
+remains similar.  Differences are more notable when using lvmlockd's
 sanlock option.
 
 Visible usage differences between lockd VGs with lvmlockd and clvm VGs
@@ -736,19 +725,16 @@ lvm.conf must be configured to use either lvmlockd (use_lvmlockd=1) or
 clvmd (locking_type=3), but not both.
 
 .IP \[bu] 2
-vgcreate --shared creates a lockd VG, and vgcreate --clustered y creates a
-clvm VG.
+vgcreate \-\-shared creates a lockd VG, and vgcreate \-\-clustered y
+creates a clvm VG.
 
 .IP \[bu] 2
 lvmlockd adds the option of using sanlock for locking, avoiding the
 need for network clustering.
 
 .IP \[bu] 2
-lvmlockd does not require all hosts to see all the same shared devices.
-
-.IP \[bu] 2
 lvmlockd defaults to the exclusive activation mode whenever the activation
-mode is unspecified, i.e. -ay means -aey, not -asy.
+mode is unspecified, i.e. \-ay means \-aey, not \-asy.
 
 .IP \[bu] 2
 lvmlockd commands always apply to the local host, and never have an effect
@@ -762,13 +748,13 @@ lvmlockd saves the cluster name for a lockd VG using dlm.  Only hosts in
 the matching cluster can use the VG.
 
 .IP \[bu] 2
-lvmlockd requires starting/stopping lockd VGs with vgchange --lock-start
-and --lock-stop.
+lvmlockd requires starting/stopping lockd VGs with vgchange \-\-lock-start
+and \-\-lock-stop.
 
 .IP \[bu] 2
 vgremove of a sanlock VG may fail indicating that all hosts have not
-stopped the lockspace for the VG.  Stop the VG lockspace on all uses using
-vgchange --lock-stop.
+stopped the VG lockspace.  Stop the VG on all hosts using vgchange
+\-\-lock-stop.
 
 .IP \[bu] 2
 vgreduce of a PV in a sanlock VG may fail if it holds the internal
@@ -777,12 +763,15 @@ vgreduce of a PV in a sanlock VG may fail if it holds the internal
 .IP \[bu] 2
 lvmlockd uses lock retries instead of lock queueing, so high lock
 contention may require increasing global/lvmlockd_lock_retries to
-avoid transient lock contention failures.
+avoid transient lock failures.
+
+.IP \[bu] 2
+lvmlockd includes VG reporting options lock_type and lock_args, and LV
+reporting option lock_args to view the corresponding metadata fields.
 
 .IP \[bu] 2
-The reporting options locktype and lockargs can be used to view lockd VG
-and LV lock_type and lock_args fields, i.g. vgs -o+locktype,lockargs.
-In the sixth VG attr field, "s" for "shared" is displayed for lockd VGs.
+In the 'vgs' command's sixth VG attr field, "s" for "shared" is displayed
+for lockd VGs.
 
 .IP \[bu] 2
 If lvmlockd fails or is killed while in use, locks it held remain but are


