From: David Teigland <teigland@sourceware.org>
Date: Thu, 4 Apr 2019 15:41:16 -0400
Subject: master - man: updates to lvmlockd
Message-ID: <201904041941.x34JfGmO002737@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6f408f68d2094490ad28df2844889d4e9c1d1dbc
Commit:        6f408f68d2094490ad28df2844889d4e9c1d1dbc
Parent:        c33770c02d9d6b9deddbc1b3c52c77c1a17ea246
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 4 14:36:28 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 4 14:36:28 2019 -0500

man: updates to lvmlockd

- remove reference to locking_type which is no longer used
- remove references to adopting locks which has been disabled
- move some sanlock-specific info out of a general section
- remove info about doing automatic lockstart by the system
  since this was never used (the resource agent does it)
- replace info about lvextend and manual refresh under gfs2
  with a description about the automatic remote refresh
---
 man/lvmlockd.8_main |   92 +++++++++++++++-----------------------------------
 1 files changed, 28 insertions(+), 64 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 0feab80..8ed5400 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -76,9 +76,6 @@ For default settings, see lvmlockd -h.
 .I seconds
         Override the default sanlock I/O timeout.
 
-.B  --adopt | -A 0|1
-        Adopt locks from a previous instance of lvmlockd.
-
 
 .SH USAGE
 
@@ -105,7 +102,6 @@ sanlock does not depend on any clustering software or configuration.
 
 On all hosts running lvmlockd, configure lvm.conf:
 .nf
-locking_type = 1
 use_lvmlockd = 1
 .fi
 
@@ -261,6 +257,16 @@ does for foreign VGs.
 
 .SS creating the first sanlock VG
 
+When use_lvmlockd is first enabled in lvm.conf, and before the first
+sanlock VG is created, no global lock will exist.  In this initial state,
+LVM commands try and fail to acquire the global lock, producing a warning,
+and some commands are disallowed.  Once the first sanlock VG is created,
+the global lock will be available, and LVM will be fully operational.
+
+When a new sanlock VG is created, its lockspace is automatically started on
+the host that creates it.  Other hosts need to run 'vgchange --lock-start'
+to start the new VG before they can use it.
+
 Creating the first sanlock VG is not protected by locking, so it requires
 special attention.  This is because sanlock locks exist on storage within
 the VG, so they are not available until after the VG is created.  The
@@ -288,19 +294,7 @@ See below for more information about managing the sanlock global lock.
 
 .SS using shared VGs
 
-There are some special considerations when using shared VGs.
-
-When use_lvmlockd is first enabled in lvm.conf, and before the first
-shared VG is created, no global lock will exist.  In this initial state,
-LVM commands try and fail to acquire the global lock, producing a warning,
-and some commands are disallowed.  Once the first shared VG is created,
-the global lock will be available, and LVM will be fully operational.
-
-When a new shared VG is created, its lockspace is automatically started on
-the host that creates it.  Other hosts need to run 'vgchange --lock-start'
-to start the new VG before they can use it.
-
-From the 'vgs' command, shared VGs are indicated by "s" (for shared) in
+In the 'vgs' command, shared VGs are indicated by "s" (for shared) in
 the sixth attr field, and by "shared" in the "--options shared" report
 field.  The specific lock type and lock args for a shared VG can be
 displayed with 'vgs -o+locktype,lockargs'.
@@ -379,31 +373,6 @@ activation {
 .fi
 
 
-.SS automatic starting and automatic activation
-
-When system-level scripts/programs automatically start VGs, they should
-use the "auto" option.  This option indicates that the command is being
-run automatically by the system:
-
-vgchange --lock-start --lock-opt auto [<vgname> ...]
-
-The "auto" option causes the command to follow the lvm.conf
-activation/auto_lock_start_list.  If auto_lock_start_list is undefined,
-all VGs are started, just as if the auto option was not used.
-
-When auto_lock_start_list is defined, it lists the shared VGs that should
-be started by the auto command.  VG names that do not match an item in the
-list will be ignored by the auto start command.
-
-(The lock_start_list is also still used to filter VG names from all start
-commands, i.e. with or without the auto option.  When the lock_start_list
-is defined, only VGs matching a list item can be started with vgchange.)
-
-The auto_lock_start_list allows a user to select certain shared VGs that
-should be automatically started by the system (or indirectly, those that
-should not).
-
-
 .SS internal command locking
 
 To optimize the use of LVM with lvmlockd, be aware of the three kinds of
@@ -411,8 +380,8 @@ locks and when they are used:
 
 .I Global lock
 
-The global lock s associated with global information, which is information
-not isolated to a single VG.  This includes:
+The global lock is associated with global information, which is
+information not isolated to a single VG.  This includes:
 
 \[bu]
 The global VG namespace.
@@ -456,7 +425,7 @@ held only while an LVM command is running.)
 
 .I lock retries
 
-If a request for a Global or VG lock fails due to a lock conflict with
+If a request for a global or VG lock fails due to a lock conflict with
 another host, lvmlockd automatically retries for a short time before
 returning a failure to the LVM command.  If those retries are
 insufficient, the LVM command will retry the entire lock request a number
@@ -579,8 +548,7 @@ necessary locks.
 .B lvmlockd failure
 
 If lvmlockd fails or is killed while holding locks, the locks are orphaned
-in the lock manager.  lvmlockd can be restarted with an option to adopt
-locks in the lock manager that had been held by the previous instance.
+in the lock manager.
 
 .B dlm/corosync failure
 
@@ -775,26 +743,22 @@ to a shared VG".
 
 .SS extending an LV active on multiple hosts
 
-With lvmlockd, a new procedure is required to extend an LV while it is
-active on multiple hosts (e.g. when used under gfs2):
+With lvmlockd and dlm, a special clustering procedure is used to refresh a
+shared LV on remote cluster nodes after it has been extended on one node.
 
-1. On one node run the lvextend command:
-.br
-.nf
-   lvextend --lockopt skiplv -L Size VG/LV
-.fi
+When an LV holding gfs2 or ocfs2 is active on multiple hosts with a shared
+lock, lvextend is permitted to run with an existing shared LV lock in
+place of the normal exclusive LV lock.
 
-2. On each node using the LV, refresh the LV:
-.br
-.nf
-   lvchange --refresh VG/LV
-.fi
+After lvextend has finished extending the LV, it sends a remote request to
+other nodes running the dlm to run 'lvchange --refresh' on the LV.  This
+uses dlm_controld and corosync features.
+
+Some special --lockopt values can be used to modify this process.
+"shupdate" permits the lvextend update with an existing shared lock if it
+isn't otherwise permitted.  "norefresh" prevents the remote refresh
+operation.
 
-3. On one node extend gfs2 (or comparable for other applications):
-.br
-.nf
-   gfs2_grow VG/LV
-.fi
 
 .SS limitations of shared VGs
 


