From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 28 Aug 2015 16:38:42 +0000 (UTC)
Subject: master - man lvmlockd: various improvements
Message-ID: <20150828163842.BB3ED609D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09b2649c5fe4259a38265b80f4038b7481d03db2
Commit:        09b2649c5fe4259a38265b80f4038b7481d03db2
Parent:        cc17210bce2cf08015e19caad3bc6a8307c841c8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 28 11:37:55 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 28 11:38:26 2015 -0500

man lvmlockd: various improvements

---
 man/lvmlockd.8.in |  177 +++++++++++++++++++++++++++++++++++------------------
 1 files changed, 117 insertions(+), 60 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 1daea18..4e7883a 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -107,7 +107,6 @@ On all hosts running lvmlockd, configure lvm.conf:
 .nf
 locking_type = 1
 use_lvmlockd = 1
-use_lvmetad = 1
 .fi
 
 .I sanlock
@@ -138,7 +137,7 @@ vgcreate \-\-shared <vgname> <devices>
 
 The shared option sets the VG lock type to sanlock or dlm depending on
 which lock manager is running.  LVM commands will perform locking for the
-VG using lvmlockd.
+VG using lvmlockd.  lvmlockd will use the chosen lock manager.
 
 .SS 6. start VG on all hosts
 
@@ -222,9 +221,7 @@ If the lock manager for the lock type is not available (e.g. not started
 or failed), lvmlockd is unable to acquire locks for LVM commands.  LVM
 commands that only read the VG will generally be allowed to continue
 without locks in this case (with a warning).  Commands to modify or
-activate the VG will fail without the necessary locks.  Maintaining a
-properly running lock manager requires knowledge covered in separate
-documentation.
+activate the VG will fail without the necessary locks.
 
 .I "local VG"
 
@@ -250,10 +247,10 @@ clvmd for clustering.  See below for converting a clvm VG to a lockd VG.
 .SS lockd VGs from hosts not using lvmlockd
 
 Only hosts that use lockd VGs should be configured to run lvmlockd.
-However, devices with lockd VGs may be visible from hosts not using
-lvmlockd.  From a host not using lvmlockd, visible lockd VGs are ignored
-in the same way as foreign VGs, i.e. those with a foreign system ID, see
-.BR lvmsystemid (7).
+However, shared devices used by lockd VGs may be visible from hosts not
+using lvmlockd.  From a host not using lvmlockd, visible lockd VGs are
+ignored in the same way as foreign VGs (see
+.BR lvmsystemid (7).)
 
 The \-\-shared option for reporting and display commands causes lockd VGs
 to be displayed on a host not using lvmlockd, like the \-\-foreign option
@@ -303,13 +300,13 @@ LVM commands request locks from clvmd to use the VG.
 
 .SS using lockd VGs
 
-There are some special considerations to be aware of when using lockd VGs.
+There are some special considerations when using lockd VGs.
 
-When use_lvmlockd is first enabled, and before the first lockd VG is
-created, no global lock will exist.  In this initial state, LVM commands
-try and fail to acquire the global lock, producing a warning, and some
-commands are disallowed.  Once the first lockd VG is created, the global
-lock will be available, and LVM will be fully operational.
+When use_lvmlockd is first enabled in lvm.conf, and before the first lockd
+VG is created, no global lock will exist.  In this initial state, LVM
+commands try and fail to acquire the global lock, producing a warning, and
+some commands are disallowed.  Once the first lockd VG is created, the
+global lock will be available, and LVM will be fully operational.
 
 When a new lockd VG is created, its lockspace is automatically started on
 the host that creates it.  Other hosts need to run 'vgchange
@@ -328,8 +325,8 @@ See the following section for a full description of starting and stopping.
 Starting a lockd VG (vgchange \-\-lock\-start) causes the lock manager to
 start (join) the lockspace for the VG on the host where it is run.  This
 makes locks for the VG available to LVM commands on the host.  Before a VG
-is started, only LVM commands that read/display the VG without locks are
-allowed.
+is started, only LVM commands that read/display the VG are allowed to
+continue without locks (and with a warning).
 
 Stopping a lockd VG (vgchange \-\-lock\-stop) causes the lock manager to
 stop (leave) the lockspace for the VG on the host where it is run.  This
@@ -369,13 +366,11 @@ vgchange \-\-lock\-stop <vgname> ...
 
 To make vgchange not wait for start to complete:
 .br
-vgchange \-\-lock\-start \-\-lock\-opt nowait
-.br
-vgchange \-\-lock\-start \-\-lock\-opt nowait <vgname>
+vgchange \-\-lock\-start \-\-lock\-opt nowait ...
 
-To stop all lockspaces and wait for all to complete:
+lvmlockd can be asked directly to stop all lockspaces:
 .br
-lvmlockctl \-\-stop\-lockspaces \-\-wait
+lvmlockctl \-\-stop\-lockspaces
 
 To start only selected lockd VGs, use the lvm.conf
 activation/lock_start_list.  When defined, only VG names in this list are
@@ -455,8 +450,8 @@ acquired.
 
 A VG lock is associated with each VG.  The VG lock is acquired in shared
 mode to read the VG and in exclusive mode to change the VG (modify the VG
-metadata).  This lock serializes modifications to a VG with all other LVM
-commands accessing the VG from all hosts.
+metadata or activate LVs).  This lock serializes access to a VG with all
+other LVM commands accessing the VG from all hosts.
 
 The command 'vgs' will not only acquire the GL lock to read the list of
 all VG names, but will acquire the VG lock for each VG prior to reading
@@ -537,12 +532,13 @@ There are some special cases related to using a sanlock VG.
 
 vgremove of a sanlock VG will fail if other hosts have the VG started.
 Run vgchange \-\-lock-stop <vgname> on all other hosts before vgremove.
-
 (It may take several seconds before vgremove recognizes that all hosts
 have stopped.)
 
 A sanlock VG contains a hidden LV called "lvmlock" that holds the sanlock
-locks.  vgreduce cannot yet remove the PV holding the lvmlockd LV.
+locks.  vgreduce cannot yet remove the PV holding the lvmlockd LV.  To
+remove this PV, change the VG lock type to "none", run vgreduce, then
+change the VG lock type back to "sanlock".
 
 To place the lvmlock LV on a specific device, create the VG with only that
 device, then use vgextend to add other devices.
@@ -570,9 +566,10 @@ deactivated, or activated exclusively to run lvextend.
 
 .SS recover from lost PV holding sanlock locks
 
-A number of special manual steps must be performed to restore sanlock
-locks if the PV holding the locks is lost.  Contact the LVM group for
-help with this process.
+The general approach is to change the VG lock type to "none", and then
+change the lock type back to "sanlock".  This recreates the internal
+lvmlock LV and the necessary locks on it.  Additional steps may be
+required to deal with the missing PV.
 
 
 .SS locking system failures
@@ -594,54 +591,103 @@ the dlm/corosync recovery process is complete.
 .B sanlock lease storage failure
 
 If a host loses access to the device holding a VG's locks, sanlock cannot
-renew the VG's lockspace lease for those locks.  After some time, the
-lease will expire, and locks held by the host can be acquired by other
-hosts.
+renew its lease for the VG's locks.  After some time, the lease will
+expire, and locks held by the host can be acquired by other hosts.
 
 If no LVs are active in the VG, the lockspace with an expiring lease will
 be shut down, and errors will be reported when trying to use the VG.  Use
 the lvmlockctl \-\-drop command to clear the stale lockspace from
 lvmlockd.
 
-If the VG has active LVs, the LVs must be quickly deactivated before the
-lockspace lease expires.  After all LVs are deactivated, run lvmlockctl
-\-\-drop <vgname> to clear the expiring lockspace from lvmlockd.  If all
-LVs in the VG are not deactivated within about 40 seconds, sanlock will
-reset the host using the local watchdog.  The host reset is ultimately a
-severe form of "deactivating" LVs before they can be activated on other
-hosts.  The reset is considered a better alternative than having LVs used
-by multiple hosts at once, which could easily damage or destroy their
-content.  A future enhancement may automatically attempt to deactivate LVs
-before the lockspace lease expires.
+If the VG has active LVs when the lock storage is lost, the LVs must be
+quickly deactivated before the lockspace lease expires.  After all LVs are
+deactivated, run lvmlockctl \-\-drop <vgname> to clear the expiring
+lockspace from lvmlockd.  If all LVs in the VG are not deactivated within
+about 40 seconds, sanlock will reset the host using the local watchdog.
+The machine reset is effectively a severe form of "deactivating" LVs
+before they can be activated on other hosts.  The reset is considered a
+better alternative than having LVs used by multiple hosts at once, which
+could easily damage or destroy their content.  A future enhancement may
+automatically attempt to forcibly deactivate LVs before the lockspace
+lease expires.
 
 .B sanlock daemon failure
 
 If the sanlock daemon fails or exits while a lockspace is started, the
-local watchdog will reset the host.
+local watchdog will reset the host.  This is necessary to protect any
+application resources that depend on sanlock leases which will be lost
+without sanlock running.
 
 
 .SS changing dlm cluster name
 
-When a dlm VG is created, the cluster name is saved in the VG metadata for
-the new VG.  To use the VG, a host must be in the named cluster.  If the
-cluster name is changed, or the VG is moved to a different cluster, the
-cluster name for the dlm VG must be changed.  To do this:
+When a dlm VG is created, the cluster name is saved in the VG metadata.
+To use the VG, a host must be in the named dlm cluster.  If the dlm
+cluster name changes, or the VG is moved to a new cluster, the dlm cluster
+name saved in the VG must also be changed.
+
+To see the dlm cluster name saved in the VG, use the command:
+.br
+vgs -o+locktype,lockargs <vgname>
+
+To change the dlm cluster name in the VG when the VG is still used by the
+original cluster:
+
+.IP \[bu] 2
+Stop the VG on all hosts:
+.br
+vgchange --lock-stop <vgname>
+
+.IP \[bu] 2
+Change the VG lock type to none:
+.br
+vgchange \-\-lock\-type none <vgname>
+
+.IP \[bu] 2
+Change the dlm cluster name on the host or move the VG to the new cluster.
+The new dlm cluster must now be active on the host.  Verify the new name
+by:
+.br
+cat /sys/kernel/config/dlm/cluster/cluster_name
+
+.IP \[bu] 2
+Change the VG lock type back to dlm which sets the new cluster name:
+.br
+vgchange \-\-lock\-type dlm <vgname>
+
+.IP \[bu] 2
+Start the VG on hosts to use it:
+.br
+vgchange --lock-start <vgname>
+
+.P
+
+To change the dlm cluster name in the VG when the dlm cluster name has
+already changed, or the VG has already moved to a different cluster:
 
-1. Ensure the VG is not being used by any hosts.
+.IP \[bu] 2
+Ensure the VG is not being used by any hosts.
 
-2. The new cluster must be active on the node making the change.
+.IP \[bu] 2
+The new dlm cluster must be active on the host making the change.
+The current dlm cluster name can be seen by:
 .br
-   The current dlm cluster name can be seen by:
+cat /sys/kernel/config/dlm/cluster/cluster_name
+
+.IP \[bu] 2
+Change the VG lock type to none:
 .br
-   cat /sys/kernel/config/dlm/cluster/cluster_name
+vgchange \-\-lock\-type none \-\-force <vgname>
 
-3. Change the VG lock type to none:
+.IP \[bu] 2
+Change the VG lock type back to dlm which sets the new cluster name:
 .br
-   vgchange \-\-lock\-type none \-\-force <vgname>
+vgchange \-\-lock\-type dlm <vgname>
 
-4. Change the VG lock type back to dlm which sets the new cluster name:
+.IP \[bu] 2
+Start the VG on hosts to use it:
 .br
-   vgchange \-\-lock\-type dlm <vgname>
+vgchange --lock-start <vgname>
 
 
 .SS changing a local VG to a lockd VG
@@ -654,11 +700,21 @@ Change a local VG to a lockd VG with the command:
 .br
 vgchange \-\-lock\-type sanlock|dlm <vgname>
 
-Start the VG on any hosts that need to use it:
+Start the VG on hosts to use it:
 .br
 vgchange \-\-lock\-start <vgname>
 
 
+.SS changing a lockd VG to a local VG
+
+Stop the lockd VG on all hosts, then run:
+.br
+vgchange \-\-lock\-type none <vgname>
+
+To change a VG from one lockd type to another (i.e. between sanlock and
+dlm), first change it to a local VG, then to the new type.
+
+
 .SS changing a clvm VG to a lockd VG
 
 All LVs must be inactive to change the lock type.
@@ -669,8 +725,8 @@ change a clvm VG to a local VG with the command:
 vgchange \-cn <vgname>
 
 If the clvm cluster is no longer running on any nodes, then extra options
-can be used forcibly make the VG local.  Caution: this is only safe if all
-nodes have stopped using the VG:
+can be used to forcibly make the VG local.  Caution: this is only safe if
+all nodes have stopped using the VG:
 
 vgchange \-\-config 'global/locking_type=0 global/use_lvmlockd=0'
 .RS
@@ -683,8 +739,6 @@ to a lockd VG".
 
 .SS limitations of lockd VGs
 
-lvmlockd currently requires using lvmetad and lvmpolld.
-
 Things that do not yet work in lockd VGs:
 .br
 \[bu]
@@ -744,6 +798,9 @@ on a remote host.  (The activation option 'l' is not used.)
 lvmlockd works with thin and cache pools and LVs.
 
 .IP \[bu] 2
+lvmlockd works with lvmetad.
+
+.IP \[bu] 2
 lvmlockd saves the cluster name for a lockd VG using dlm.  Only hosts in
 the matching cluster can use the VG.
 


