From: David Teigland <teigland@sourceware.org>
Date: Thu, 14 Jun 2018 14:35:42 -0400
Subject: 2018-06-01-stable - man: updates to lvmlockd
Message-ID: <201806141835.w5EIZgm9025941@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d136790bab14040412c4e02b9395d12577966ae5
Commit:        d136790bab14040412c4e02b9395d12577966ae5
Parent:        214de62b5dd68dbab50f1c87d285814aa7454663
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 14 12:30:45 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 14 12:53:50 2018 -0500

man: updates to lvmlockd

The terminology has migrated toward using "shared VG"
rather than "lockd VG".

Also improve the wording in a number of places.
---
 man/lvmlockd.8_main |  341 +++++++++++++++++++++-----------------------------
 1 files changed, 143 insertions(+), 198 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 6411c01..cfb45b2 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -84,8 +84,8 @@ For default settings, see lvmlockd -h.
 
 .SS Initial set up
 
-Using LVM with lvmlockd for the first time includes some one-time set up
-steps:
+Setting up LVM to use lvmlockd and a shared VG for the first time includes
+some one time set up steps:
 
 .SS 1. choose a lock manager
 
@@ -94,7 +94,7 @@ steps:
 If dlm (or corosync) are already being used by other cluster
 software, then select dlm.  dlm uses corosync which requires additional
 configuration beyond the scope of this document.  See corosync and dlm
-documentation for instructions on configuration, setup and usage.
+documentation for instructions on configuration, set up and usage.
 
 .I sanlock
 .br
@@ -117,7 +117,9 @@ Assign each host a unique host_id in the range 1-2000 by setting
 
 .SS 3. start lvmlockd
 
-Use a unit/init file, or run the lvmlockd daemon directly:
+Start the lvmlockd daemon.
+.br
+Use systemctl, a cluster resource agent, or run directly, e.g.
 .br
 systemctl start lvm2-lvmlockd
 
@@ -125,14 +127,17 @@ systemctl start lvm2-lvmlockd
 
 .I sanlock
 .br
-Use unit/init files, or start wdmd and sanlock daemons directly:
+Start the sanlock and wdmd daemons.
+.br
+Use systemctl or run directly, e.g.
 .br
 systemctl start wdmd sanlock
 
 .I dlm
 .br
-Follow external clustering documentation when applicable, or use
-unit/init files:
+Start the dlm and corosync daemons.
+.br
+Use systemctl, a cluster resource agent, or run directly, e.g.
 .br
 systemctl start corosync dlm
 
@@ -141,18 +146,17 @@ systemctl start corosync dlm
 vgcreate --shared <vgname> <devices>
 
 The shared option sets the VG lock type to sanlock or dlm depending on
-which lock manager is running.  LVM commands will perform locking for the
-VG using lvmlockd.  lvmlockd will use the chosen lock manager.
+which lock manager is running.  LVM commands acquire locks from lvmlockd,
+and lvmlockd uses the chosen lock manager.
 
 .SS 6. start VG on all hosts
 
 vgchange --lock-start
 
-lvmlockd requires shared VGs to be started before they are used.  This is
-a lock manager operation to start (join) the VG lockspace, and it may take
-some time.  Until the start completes, locks for the VG are not available.
-LVM commands are allowed to read the VG while start is in progress.  (A
-unit/init file can also be used to start VGs.)
+Shared VGs must be started before they are used.  Starting the VG performs
+lock manager initialization that is necessary to begin using locks (i.e.
+creating and joining a lockspace).  Starting the VG may take some time,
+and until the start completes the VG may not be modified or activated.
 
 .SS 7. create and activate LVs
 
@@ -168,9 +172,9 @@ multiple hosts.)
 
 .SS Normal start up and shut down
 
-After initial set up, start up and shut down include the following general
-steps.  They can be performed manually or using the system service
-manager.
+After initial set up, start up and shut down include the following steps.
+They can be performed directly or may be automated using systemd or a
+cluster resource manager/agents.
 
 \[bu]
 start lvmlockd
@@ -204,106 +208,64 @@ stop lvmlockd
 
 .SH TOPICS
 
-.SS VG access control
+.SS Protecting VGs on shared devices
 
-The following terms are used to describe different forms of VG access
-control.
+The following terms are used to describe the different ways of accessing
+VGs on shared devices.
 
-.I "lockd VG"
+.I "shared VG"
 
-A "lockd VG" is a shared VG that has a "lock type" of dlm or sanlock.
-Using it requires lvmlockd.  These VGs exist on shared storage that is
-visible to multiple hosts.  LVM commands use lvmlockd to perform locking
-for these VGs when they are used.
+A shared VG exists on shared storage that is visible to multiple hosts.
+LVM acquires locks through lvmlockd to coordinate access to shared VGs.
+A shared VG has lock_type "dlm" or "sanlock", which specifies the lock
+manager lvmlockd will use.
 
-If the lock manager for the lock type is not available (e.g. not started
-or failed), lvmlockd is unable to acquire locks for LVM commands.  LVM
-commands that only read the VG will generally be allowed to continue
-without locks in this case (with a warning).  Commands to modify or
-activate the VG will fail without the necessary locks.
+When the lock manager for the lock type is not available (e.g. not started
+or failed), lvmlockd is unable to acquire locks for LVM commands.  In this
+situation, LVM commands are only allowed to read and display the VG;
+changes and activation will fail.
 
 .I "local VG"
 
-A "local VG" is meant to be used by a single host.  It has no lock type or
-lock type "none".  LVM commands and lvmlockd do not perform locking for
-these VGs.  A local VG typically exists on local (non-shared) devices and
-cannot be used concurrently from different hosts.
+A local VG is meant to be used by a single host.  It has no lock type or
+lock type "none".  A local VG typically exists on local (non-shared)
+devices and cannot be used concurrently from different hosts.
 
 If a local VG does exist on shared devices, it should be owned by a single
-host by having its system ID set, see
+host by having the system ID set, see
 .BR lvmsystemid (7).
-Only the host with a matching system ID can use the local VG.  A VG
-with no lock type and no system ID should be excluded from all but one
-host using lvm.conf filters.  Without any of these protections, a local VG
-on shared devices can be easily damaged or destroyed.
+The host with a matching system ID can use the local VG and other hosts
+will ignore it.  A VG with no lock type and no system ID should be
+excluded from all but one host using lvm.conf filters.  Without any of
+these protections, a local VG on shared devices can be easily damaged or
+destroyed.
 
 .I "clvm VG"
 
-A "clvm VG" is a VG on shared storage (like a lockd VG) that requires
-clvmd for clustering.  See below for converting a clvm VG to a lockd VG.
+A clvm VG (or clustered VG) is a VG on shared storage (like a shared VG)
+that requires clvmd for clustering and locking.  See below for converting
+a clvm/clustered VG to a shared VG.
 
 
-.SS lockd VGs from hosts not using lvmlockd
+.SS shared VGs from hosts not using lvmlockd
 
-Only hosts that use lockd VGs should be configured to run lvmlockd.
-However, shared devices in lockd VGs may be visible from hosts not
-using lvmlockd.  From a host not using lvmlockd, lockd VGs are ignored
-in the same way as foreign VGs (see
+Hosts that do not use shared VGs will not be running lvmlockd.  In this
+case, shared VGs that are still visible to the host will be ignored
+(like foreign VGs, see 
 .BR lvmsystemid (7).)
 
-The --shared option for reporting and display commands causes lockd VGs
+The --shared option for reporting and display commands causes shared VGs
 to be displayed on a host not using lvmlockd, like the --foreign option
 does for foreign VGs.
 
 
-.SS vgcreate comparison
-
-The type of VG access control is specified in the vgcreate command.
-See
-.BR vgcreate (8)
-for all vgcreate options.
-
-.B vgcreate <vgname> <devices>
-
-.IP \[bu] 2
-Creates a local VG with the local host's system ID when neither lvmlockd nor clvm are configured.
-.IP \[bu] 2
-Creates a local VG with the local host's system ID when lvmlockd is configured.
-.IP \[bu] 2
-Creates a clvm VG when clvm is configured.
-
-.P
-
-.B vgcreate --shared <vgname> <devices>
-.IP \[bu] 2
-Requires lvmlockd to be configured and running.
-.IP \[bu] 2
-Creates a lockd VG with lock type sanlock|dlm depending on which lock
-manager is running.
-.IP \[bu] 2
-LVM commands request locks from lvmlockd to use the VG.
-.IP \[bu] 2
-lvmlockd obtains locks from the selected lock manager.
-
-.P
-
-.B vgcreate -c|--clustered y <vgname> <devices>
-.IP \[bu] 2
-Requires clvm to be configured and running.
-.IP \[bu] 2
-Creates a clvm VG with the "clustered" flag.
-.IP \[bu] 2
-LVM commands request locks from clvmd to use the VG.
-
-.P
-
 .SS creating the first sanlock VG
 
 Creating the first sanlock VG is not protected by locking, so it requires
 special attention.  This is because sanlock locks exist on storage within
-the VG, so they are not available until the VG exists.  The first sanlock
-VG created will automatically contain the "global lock".  Be aware of the
-following special considerations:
+the VG, so they are not available until after the VG is created.  The
+first sanlock VG that is created will automatically contain the "global
+lock".  Be aware of the following special considerations:
 
 .IP \[bu] 2
 The first vgcreate command needs to be given the path to a device that has
@@ -318,54 +280,48 @@ to be accessible to all hosts that will use sanlock shared VGs.  All hosts
 will need to use the global lock from the first sanlock VG.
 
 .IP \[bu] 2
-While running vgcreate for the first sanlock VG, ensure that the device
-being used is not used by another LVM command.  Allocation of shared
-devices is usually protected by the global lock, but this cannot be done
-for the first sanlock VG which will hold the global lock.
-
-.IP \[bu] 2
-While running vgcreate for the first sanlock VG, ensure that the VG name
-being used is not used by another LVM command.  Uniqueness of VG names is
-usually ensured by the global lock.
+The device and VG name used by the initial vgcreate will not be protected
+from concurrent use by another vgcreate on another host.
 
 See below for more information about managing the sanlock global lock.
 
 
-.SS using lockd VGs
+.SS using shared VGs
 
-There are some special considerations when using lockd VGs.
+There are some special considerations when using shared VGs.
 
-When use_lvmlockd is first enabled in lvm.conf, and before the first lockd
-VG is created, no global lock will exist.  In this initial state, LVM
-commands try and fail to acquire the global lock, producing a warning, and
-some commands are disallowed.  Once the first lockd VG is created, the
-global lock will be available, and LVM will be fully operational.
+When use_lvmlockd is first enabled in lvm.conf, and before the first
+shared VG is created, no global lock will exist.  In this initial state,
+LVM commands try and fail to acquire the global lock, producing a warning,
+and some commands are disallowed.  Once the first shared VG is created,
+the global lock will be available, and LVM will be fully operational.
 
-When a new lockd VG is created, its lockspace is automatically started on
-the host that creates it.  Other hosts need to run 'vgchange
---lock-start' to start the new VG before they can use it.
+When a new shared VG is created, its lockspace is automatically started on
+the host that creates it.  Other hosts need to run 'vgchange --lock-start'
+to start the new VG before they can use it.
 
-From the 'vgs' command, lockd VGs are indicated by "s" (for shared) in the
-sixth attr field.  The specific lock type and lock args for a lockd VG can
-be displayed with 'vgs -o+locktype,lockargs'.
+From the 'vgs' command, shared VGs are indicated by "s" (for shared) in
+the sixth attr field, and by "shared" in the "--options shared" report
+field.  The specific lock type and lock args for a shared VG can be
+displayed with 'vgs -o+locktype,lockargs'.
 
-lockd VGs need to be "started" and "stopped", unlike other types of VGs.
+Shared VGs need to be "started" and "stopped", unlike other types of VGs.
 See the following section for a full description of starting and stopping.
 
-vgremove of a lockd VG will fail if other hosts have the VG started.
-Run vgchange --lock-stop <vgname> on all other hosts before vgremove.
-(It may take several seconds before vgremove recognizes that all hosts
-have stopped a sanlock VG.)
+Removing a shared VG will fail if other hosts have the VG started.  Run
+vgchange --lock-stop <vgname> on all other hosts before vgremove.  (It may
+take several seconds before vgremove recognizes that all hosts have
+stopped a sanlock VG.)
 
 .SS starting and stopping VGs
 
-Starting a lockd VG (vgchange --lock-start) causes the lock manager to
+Starting a shared VG (vgchange --lock-start) causes the lock manager to
 start (join) the lockspace for the VG on the host where it is run.  This
 makes locks for the VG available to LVM commands on the host.  Before a VG
 is started, only LVM commands that read/display the VG are allowed to
 continue without locks (and with a warning).
 
-Stopping a lockd VG (vgchange --lock-stop) causes the lock manager to
+Stopping a shared VG (vgchange --lock-stop) causes the lock manager to
 stop (leave) the lockspace for the VG on the host where it is run.  This
 makes locks for the VG inaccessible to the host.  A VG cannot be stopped
 while it has active LVs.
@@ -374,7 +330,7 @@ When using the lock type sanlock, starting a VG can take a long time
 (potentially minutes if the host was previously shut down without cleanly
 stopping the VG.)
 
-A lockd VG can be started after all the following are true:
+A shared VG can be started after all the following are true:
 .br
 \[bu]
 lvmlockd is running
@@ -386,9 +342,9 @@ the lock manager is running
 the VG's devices are visible on the system
 .br
 
-A lockd VG can be stopped if all LVs are deactivated.
+A shared VG can be stopped if all LVs are deactivated.
 
-All lockd VGs can be started/stopped using:
+All shared VGs can be started/stopped using:
 .br
 vgchange --lock-start
 .br
@@ -407,12 +363,12 @@ vgchange --lock-start --lock-opt nowait ...
 
 lvmlockd can be asked directly to stop all lockspaces:
 .br
-lvmlockctl --stop-lockspaces
+lvmlockctl -S|--stop-lockspaces
 
-To start only selected lockd VGs, use the lvm.conf
+To start only selected shared VGs, use the lvm.conf
 activation/lock_start_list.  When defined, only VG names in this list are
 started by vgchange.  If the list is not defined (the default), all
-visible lockd VGs are started.  To start only "vg1", use the following
+visible shared VGs are started.  To start only "vg1", use the following
 lvm.conf configuration:
 
 .nf
@@ -435,7 +391,7 @@ The "auto" option causes the command to follow the lvm.conf
 activation/auto_lock_start_list.  If auto_lock_start_list is undefined,
 all VGs are started, just as if the auto option was not used.
 
-When auto_lock_start_list is defined, it lists the lockd VGs that should
+When auto_lock_start_list is defined, it lists the shared VGs that should
 be started by the auto command.  VG names that do not match an item in the
 list will be ignored by the auto start command.
 
@@ -443,23 +399,20 @@ list will be ignored by the auto start command.
 commands, i.e. with or without the auto option.  When the lock_start_list
 is defined, only VGs matching a list item can be started with vgchange.)
 
-The auto_lock_start_list allows a user to select certain lockd VGs that
+The auto_lock_start_list allows a user to select certain shared VGs that
 should be automatically started by the system (or indirectly, those that
 should not).
 
-To use auto activation of lockd LVs (see auto_activation_volume_list),
-auto starting of the corresponding lockd VGs is necessary.
-
 
 .SS internal command locking
 
 To optimize the use of LVM with lvmlockd, be aware of the three kinds of
 locks and when they are used:
 
-.I GL lock
+.I Global lock
 
-The global lock (GL lock) is associated with global information, which is
-information not isolated to a single VG.  This includes:
+The global lock s associated with global information, which is information
+not isolated to a single VG.  This includes:
 
 \[bu]
 The global VG namespace.
@@ -484,61 +437,58 @@ acquired.
 
 .I VG lock
 
-A VG lock is associated with each lockd VG.  The VG lock is acquired in
-shared mode to read the VG and in exclusive mode to change the VG (modify
-the VG metadata or activating LVs).  This lock serializes access to a VG
-with all other LVM commands accessing the VG from all hosts.
-
-The command 'vgs' will not only acquire the GL lock to read the list of
-all VG names, but will acquire the VG lock for each VG prior to reading
-it.
+A VG lock is associated with each shared VG.  The VG lock is acquired in
+shared mode to read the VG and in exclusive mode to change the VG or
+activate LVs.  This lock serializes access to a VG with all other LVM
+commands accessing the VG from all hosts.
 
-The command 'vgs <vgname>' does not acquire the GL lock (it does not need
-the list of all VG names), but will acquire the VG lock on each VG name
-argument.
+The command 'vgs <vgname>' does not acquire the global lock (it does not
+need the list of all VG names), but will acquire the VG lock on each VG
+name argument.
 
 .I LV lock
 
 An LV lock is acquired before the LV is activated, and is released after
 the LV is deactivated.  If the LV lock cannot be acquired, the LV is not
-activated.  LV locks are persistent and remain in place when the
-activation command is done.  GL and VG locks are transient, and are held
-only while an LVM command is running.
+activated.  (LV locks are persistent and remain in place when the
+activation command is done.  Global and VG locks are transient, and are
+held only while an LVM command is running.)
 
 .I lock retries
 
-If a request for a GL or VG lock fails due to a lock conflict with another
-host, lvmlockd automatically retries for a short time before returning a
-failure to the LVM command.  If those retries are insufficient, the LVM
-command will retry the entire lock request a number of times specified by
-global/lvmlockd_lock_retries before failing.  If a request for an LV lock
-fails due to a lock conflict, the command fails immediately.
+If a request for a Global or VG lock fails due to a lock conflict with
+another host, lvmlockd automatically retries for a short time before
+returning a failure to the LVM command.  If those retries are
+insufficient, the LVM command will retry the entire lock request a number
+of times specified by global/lvmlockd_lock_retries before failing.  If a
+request for an LV lock fails due to a lock conflict, the command fails
+immediately.
 
 
 .SS managing the global lock in sanlock VGs
 
 The global lock exists in one of the sanlock VGs.  The first sanlock VG
 created will contain the global lock.  Subsequent sanlock VGs will each
-contain disabled global locks that can be enabled later if necessary.
+contain a disabled global lock that can be enabled later if necessary.
 
 The VG containing the global lock must be visible to all hosts using
-sanlock VGs.  This can be a reason to create a small sanlock VG, visible
-to all hosts, and dedicated to just holding the global lock.  While not
-required, this strategy can help to avoid difficulty in the future if VGs
-are moved or removed.
+sanlock VGs.  For this reason, it can be useful to create a small sanlock
+VG, visible to all hosts, and dedicated to just holding the global lock.
+While not required, this strategy can help to avoid difficulty in the
+future if VGs are moved or removed.
 
 The vgcreate command typically acquires the global lock, but in the case
 of the first sanlock VG, there will be no global lock to acquire until the
 first vgcreate is complete.  So, creating the first sanlock VG is a
 special case that skips the global lock.
 
-vgcreate for a sanlock VG determines it is the first one to exist if no
-other sanlock VGs are visible.  It is possible that other sanlock VGs do
-exist but are not visible on the host running vgcreate.  In this case,
-vgcreate would create a new sanlock VG with the global lock enabled.  When
-the other VG containing a global lock appears, lvmlockd will see more than
-one VG with a global lock enabled, and LVM commands will report that there
-are duplicate global locks.
+vgcreate determines that it's creating the first sanlock VG when no other
+sanlock VGs are visible on the system.  It is possible that other sanlock
+VGs do exist, but are not visible when vgcreate checks for them.  In this
+case, vgcreate will create a new sanlock VG with the global lock enabled.
+When the another VG containing a global lock appears, lvmlockd will then
+see more than one VG with a global lock enabled.  LVM commands will report
+that there are duplicate global locks.
 
 If the situation arises where more than one sanlock VG contains a global
 lock, the global lock should be manually disabled in all but one of them
@@ -556,8 +506,8 @@ VGs with the command:
 
 lvmlockctl --gl-enable <vgname>
 
-A small sanlock VG dedicated to holding the global lock can avoid the case
-where the GL lock must be manually enabled after a vgremove.
+(Using a small sanlock VG dedicated to holding the global lock can avoid
+the case where the global lock must be manually enabled after a vgremove.)
 
 
 .SS internal lvmlock LV
@@ -574,8 +524,8 @@ device, then use vgextend to add other devices.
 
 .SS LV activation
 
-In a shared VG, activation changes involve locking through lvmlockd, and
-the following values are possible with lvchange/vgchange -a:
+In a shared VG, LV activation involves locking through lvmlockd, and the
+following values are possible with lvchange/vgchange -a:
 
 .IP \fBy\fP|\fBey\fP
 The command activates the LV in exclusive mode, allowing a single host
@@ -596,10 +546,6 @@ The shared mode is intended for a multi-host/cluster application or
 file system.
 LV types that cannot be used concurrently
 from multiple hosts include thin, cache, raid, and snapshot.
-lvextend on LV with shared locks is not yet allowed.  The LV must be
-deactivated, or activated exclusively to run lvextend.  (LVs with
-the mirror type can be activated in shared mode from multiple hosts
-when using the dlm lock type and cmirrord.)
 
 .IP \fBn\fP
 The command deactivates the LV.  After deactivating the LV, the command
@@ -654,7 +600,7 @@ with the expiring lease before other hosts can acquire its locks.
 
 When the sanlock daemon detects that the lease storage is lost, it runs
 the command lvmlockctl --kill <vgname>.  This command emits a syslog
-message stating that lease storage is lost for the VG and LVs must be
+message stating that lease storage is lost for the VG, and LVs must be
 immediately deactivated.
 
 If no LVs are active in the VG, then the lockspace with an expiring lease
@@ -666,10 +612,10 @@ If the VG has active LVs when the lock storage is lost, the LVs must be
 quickly deactivated before the lockspace lease expires.  After all LVs are
 deactivated, run lvmlockctl --drop <vgname> to clear the expiring
 lockspace from lvmlockd.  If all LVs in the VG are not deactivated within
-about 40 seconds, sanlock will reset the host using the local watchdog.
-The machine reset is effectively a severe form of "deactivating" LVs
-before they can be activated on other hosts.  The reset is considered a
-better alternative than having LVs used by multiple hosts at once, which
+about 40 seconds, sanlock uses wdmd and the local watchdog to reset the
+host.  The machine reset is effectively a severe form of "deactivating"
+LVs before they can be activated on other hosts.  The reset is considered
+a better alternative than having LVs used by multiple hosts at once, which
 could easily damage or destroy their content.
 
 In the future, the lvmlockctl kill command may automatically attempt to
@@ -681,8 +627,7 @@ sanlock resets the machine.
 
 If the sanlock daemon fails or exits while a lockspace is started, the
 local watchdog will reset the host.  This is necessary to protect any
-application resources that depend on sanlock leases which will be lost
-without sanlock running.
+application resources that depend on sanlock leases.
 
 
 .SS changing dlm cluster name
@@ -762,14 +707,14 @@ Start the VG on hosts to use it:
 vgchange --lock-start <vgname>
 
 
-.SS changing a local VG to a lockd VG
+.SS changing a local VG to a shared VG
 
 All LVs must be inactive to change the lock type.
 
 lvmlockd must be configured and running as described in USAGE.
 
 .IP \[bu] 2
-Change a local VG to a lockd VG with the command:
+Change a local VG to a shared VG with the command:
 .br
 vgchange --lock-type sanlock|dlm <vgname>
 
@@ -780,7 +725,7 @@ vgchange --lock-start <vgname>
 
 .P
 
-.SS changing a lockd VG to a local VG
+.SS changing a shared VG to a local VG
 
 All LVs must be inactive to change the lock type.
 
@@ -806,11 +751,11 @@ type can be forcibly changed to none with:
 
 vgchange --lock-type none --lock-opt force <vgname>
 
-To change a VG from one lockd type to another (i.e. between sanlock and
+To change a VG from one lock type to another (i.e. between sanlock and
 dlm), first change it to a local VG, then to the new type.
 
 
-.SS changing a clvm VG to a lockd VG
+.SS changing a clvm/clustered VG to a shared VG
 
 All LVs must be inactive to change the lock type.
 
@@ -823,15 +768,15 @@ If the clvm cluster is no longer running on any nodes, then extra options
 can be used to forcibly make the VG local.  Caution: this is only safe if
 all nodes have stopped using the VG:
 
-vgchange  --lock-type none --lock-opt force <vgname>
+vgchange --lock-type none --lock-opt force <vgname>
 
 After the VG is local, follow the steps described in "changing a local VG
-to a lockd VG".
+to a shared VG".
 
 
-.SS limitations of lockd VGs
+.SS limitations of shared VGs
 
-Things that do not yet work in lockd VGs:
+Things that do not yet work in shared VGs:
 .br
 \[bu]
 using external origins for thin LVs
@@ -851,22 +796,22 @@ vgsplit and vgmerge (convert to a local VG to do this)
 
 .SS lvmlockd changes from clvmd
 
-(See above for converting an existing clvm VG to a lockd VG.)
+(See above for converting an existing clvm VG to a shared VG.)
 
 While lvmlockd and clvmd are entirely different systems, LVM command usage
 remains similar.  Differences are more notable when using lvmlockd's
 sanlock option.
 
-Visible usage differences between lockd VGs (using lvmlockd) and clvm VGs
-(using clvmd):
+Visible usage differences between shared VGs (using lvmlockd) and
+clvm/clustered VGs (using clvmd):
 
 .IP \[bu] 2
 lvm.conf must be configured to use either lvmlockd (use_lvmlockd=1) or
 clvmd (locking_type=3), but not both.
 
 .IP \[bu] 2
-vgcreate --shared creates a lockd VG, and vgcreate --clustered y
-creates a clvm VG.
+vgcreate --shared creates a shared VG, and vgcreate --clustered y
+creates a clvm/clustered VG.
 
 .IP \[bu] 2
 lvmlockd adds the option of using sanlock for locking, avoiding the
@@ -887,11 +832,11 @@ lvmlockd works with thin and cache pools and LVs.
 lvmlockd works with lvmetad.
 
 .IP \[bu] 2
-lvmlockd saves the cluster name for a lockd VG using dlm.  Only hosts in
+lvmlockd saves the cluster name for a shared VG using dlm.  Only hosts in
 the matching cluster can use the VG.
 
 .IP \[bu] 2
-lvmlockd requires starting/stopping lockd VGs with vgchange --lock-start
+lvmlockd requires starting/stopping shared VGs with vgchange --lock-start
 and --lock-stop.
 
 .IP \[bu] 2
@@ -914,7 +859,7 @@ reporting option lock_args to view the corresponding metadata fields.
 
 .IP \[bu] 2
 In the 'vgs' command's sixth VG attr field, "s" for "shared" is displayed
-for lockd VGs.
+for shared VGs.
 
 .IP \[bu] 2
 If lvmlockd fails or is killed while in use, locks it held remain but are


