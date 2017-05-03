From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 15:47:36 -0400
Subject: master - man lvmlockd: minor wording updates
Message-ID: <201705031947.v43JlaMg027104@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb573d1ec987f74cb28ccc5089be4214ed7de317
Commit:        cb573d1ec987f74cb28ccc5089be4214ed7de317
Parent:        a946327bb7bc746e7b2ff3aa6d179d1e12925a4a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 14:45:33 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 14:45:33 2017 -0500

man lvmlockd: minor wording updates

---
 man/lvmlockd.8_main |   97 +++++++++++++++++++++++++++------------------------
 1 files changed, 51 insertions(+), 46 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 1a1c2fc..552eb94 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -117,17 +117,22 @@ Assign each host a unique host_id in the range 1-2000 by setting
 
 .SS 3. start lvmlockd
 
-Use a service/init file if available, or just run "lvmlockd".
+Use a unit/init file, or run the lvmlockd daemon directly:
+.br
+systemctl start lvm2-lvmlockd
 
 .SS 4. start lock manager
 
 .I sanlock
 .br
+Use unit/init files, or start wdmd and sanlock daemons directly:
+.br
 systemctl start wdmd sanlock
 
 .I dlm
 .br
-Follow external clustering documentation when applicable, otherwise:
+Follow external clustering documentation when applicable, or use
+unit/init files:
 .br
 systemctl start corosync dlm
 
@@ -146,8 +151,8 @@ vgchange --lock-start
 lvmlockd requires shared VGs to be started before they are used.  This is
 a lock manager operation to start (join) the VG lockspace, and it may take
 some time.  Until the start completes, locks for the VG are not available.
-LVM commands are allowed to read the VG while start is in progress.  (An
-init/unit file can also be used to start VGs.)
+LVM commands are allowed to read the VG while start is in progress.  (A
+unit/init file can also be used to start VGs.)
 
 .SS 7. create and activate LVs
 
@@ -247,9 +252,9 @@ clvmd for clustering.  See below for converting a clvm VG to a lockd VG.
 .SS lockd VGs from hosts not using lvmlockd
 
 Only hosts that use lockd VGs should be configured to run lvmlockd.
-However, shared devices used by lockd VGs may be visible from hosts not
-using lvmlockd.  From a host not using lvmlockd, visible lockd VGs are
-ignored in the same way as foreign VGs (see
+However, shared devices in lockd VGs may be visible from hosts not
+using lvmlockd.  From a host not using lvmlockd, lockd VGs are ignored
+in the same way as foreign VGs (see
 .BR lvmsystemid (7).)
 
 The --shared option for reporting and display commands causes lockd VGs
@@ -267,9 +272,9 @@ for all vgcreate options.
 .B vgcreate <vgname> <devices>
 
 .IP \[bu] 2
-Creates a local VG with the local system ID when neither lvmlockd nor clvm are configured.
+Creates a local VG with the local host's system ID when neither lvmlockd nor clvm are configured.
 .IP \[bu] 2
-Creates a local VG with the local system ID when lvmlockd is configured.
+Creates a local VG with the local host's system ID when lvmlockd is configured.
 .IP \[bu] 2
 Creates a clvm VG when clvm is configured.
 
@@ -300,10 +305,11 @@ LVM commands request locks from clvmd to use the VG.
 
 .SS creating the first sanlock VG
 
-Creating the first sanlock VG is not protected by locking and requires
-special attention.  This is because sanlock locks exist within the VG, so
-they are not available until the VG exists.  The first sanlock VG will
-contain the "global lock".
+Creating the first sanlock VG is not protected by locking, so it requires
+special attention.  This is because sanlock locks exist on storage within
+the VG, so they are not available until the VG exists.  The first sanlock
+VG created will automatically contain the "global lock".  Be aware of the
+following special considerations:
 
 .IP \[bu] 2
 The first vgcreate command needs to be given the path to a device that has
@@ -313,6 +319,11 @@ global lock, which will not be available until after the first sanlock VG
 is created.
 
 .IP \[bu] 2
+Because the first sanlock VG will contain the global lock, this VG needs
+to be accessible to all hosts that will use sanlock shared VGs.  All hosts
+will need to use the global lock from the first sanlock VG.
+
+.IP \[bu] 2
 While running vgcreate for the first sanlock VG, ensure that the device
 being used is not used by another LVM command.  Allocation of shared
 devices is usually protected by the global lock, but this cannot be done
@@ -323,11 +334,6 @@ While running vgcreate for the first sanlock VG, ensure that the VG name
 being used is not used by another LVM command.  Uniqueness of VG names is
 usually ensured by the global lock.
 
-.IP \[bu] 2
-Because the first sanlock VG will contain the global lock, this VG needs
-to be accessible to all hosts that will use sanlock shared VGs.  All hosts
-will need to use the global lock from the first sanlock VG.
-
 See below for more information about managing the sanlock global lock.
 
 
@@ -383,7 +389,7 @@ lvmlockd is running
 the lock manager is running
 .br
 \[bu]
-the VG is visible to the system
+the VG's devices are visible on the system
 .br
 
 A lockd VG can be stopped if all LVs are deactivated.
@@ -425,22 +431,23 @@ activation {
 
 .SS automatic starting and automatic activation
 
-Scripts or programs on a host that automatically start VGs will use the
-"auto" option to indicate that the command is being run automatically by
-the system:
+When system-level scripts/programs automatically start VGs, they should
+use the "auto" option.  This option indicates that the command is being
+run automatically by the system:
 
 vgchange --lock-start --lock-opt auto [<vgname> ...]
 
-Without any additional configuration, including the "auto" option has no
-effect; all VGs are started unless restricted by lock_start_list.
+The "auto" option causes the command to follow the lvm.conf
+activation/auto_lock_start_list.  If auto_lock_start_list is undefined,
+all VGs are started, just as if the auto option was not used.
 
-However, when the lvm.conf activation/auto_lock_start_list is defined, the
-auto start command performs an additional filtering phase to all VGs being
-started, testing each VG name against the auto_lock_start_list.  The
-auto_lock_start_list defines lockd VGs that will be started by the auto
-start command.  Visible lockd VGs not included in the list are ignored by
-the auto start command.  If the list is undefined, all VG names pass this
-filter.  (The lock_start_list is also still used to filter all VGs.)
+When auto_lock_start_list is defined, it lists the lockd VGs that should
+be started by the auto command.  VG names that do not match an item in the
+list will be ignored by the auto start command.
+
+(The lock_start_list is also still used to filter VG names from all start
+commands, i.e. with or without the auto option.  When the lock_start_list
+is defined, only VGs matching a list item can be started with vgchange.)
 
 The auto_lock_start_list allows a user to select certain lockd VGs that
 should be automatically started by the system (or indirectly, those that
@@ -470,14 +477,12 @@ The set of orphan PVs and unused devices.
 The properties of orphan PVs, e.g. PV size.
 .br
 
-The global lock is used in shared mode by commands that read this
-information, or in exclusive mode by commands that change it.
-
-The command 'vgs' acquires the global lock in shared mode because it
-reports the list of all VG names.
-
-The vgcreate command acquires the global lock in exclusive mode because it
-creates a new VG name, and it takes a PV from the list of unused PVs.
+The global lock is acquired in shared mode by commands that read this
+information, or in exclusive mode by commands that change it.  For
+example, the command 'vgs' acquires the global lock in shared mode because
+it reports the list of all VG names, and the vgcreate command acquires the
+global lock in exclusive mode because it creates a new VG name, and it
+takes a PV from the list of unused PVs.
 
 When an LVM command is given a tag argument, or uses select, it must read
 all VGs to match the tag or selection, which causes the global lock to be
@@ -485,10 +490,10 @@ acquired.
 
 .I VG lock
 
-A VG lock is associated with each VG.  The VG lock is acquired in shared
-mode to read the VG and in exclusive mode to change the VG (modify the VG
-metadata or activate LVs).  This lock serializes access to a VG with all
-other LVM commands accessing the VG from all hosts.
+A VG lock is associated with each lockd VG.  The VG lock is acquired in
+shared mode to read the VG and in exclusive mode to change the VG (modify
+the VG metadata or activating LVs).  This lock serializes access to a VG
+with all other LVM commands accessing the VG from all hosts.
 
 The command 'vgs' will not only acquire the GL lock to read the list of
 all VG names, but will acquire the VG lock for each VG prior to reading
@@ -502,7 +507,7 @@ argument.
 
 An LV lock is acquired before the LV is activated, and is released after
 the LV is deactivated.  If the LV lock cannot be acquired, the LV is not
-activated.  LV locks are persistent and remain in place after the
+activated.  LV locks are persistent and remain in place when the
 activation command is done.  GL and VG locks are transient, and are held
 only while an LVM command is running.
 
@@ -822,8 +827,8 @@ While lvmlockd and clvmd are entirely different systems, LVM command usage
 remains similar.  Differences are more notable when using lvmlockd's
 sanlock option.
 
-Visible usage differences between lockd VGs with lvmlockd and clvm VGs
-with clvmd:
+Visible usage differences between lockd VGs (using lvmlockd) and clvm VGs
+(using clvmd):
 
 .IP \[bu] 2
 lvm.conf must be configured to use either lvmlockd (use_lvmlockd=1) or


