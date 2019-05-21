From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 May 2019 16:16:05 -0400
Subject: stable-2.02 - man: updates to lvmlockd
Message-ID: <201905212016.x4LKG5Nh013851@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c733e9644537c7901caf245c1b3fdcdeba76cc12
Commit:        c733e9644537c7901caf245c1b3fdcdeba76cc12
Parent:        3669c33af4279c93c8a9104de9501ba9cf6a2745
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 15:14:24 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 21 15:14:24 2019 -0500

man: updates to lvmlockd

- remove references to adopting locks which is not used
- move some sanlock-specific info out of a general section
- remove info about doing automatic lockstart by the system
  since this was never used (the resource agent does it)
---
 man/lvmlockd.8_main |   61 ++++++++++++--------------------------------------
 1 files changed, 15 insertions(+), 46 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 3f0e3ed..b917d93 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -76,9 +76,6 @@ For default settings, see lvmlockd -h.
 .I seconds
         Override the default sanlock I/O timeout.
 
-.B  --adopt | -A 0|1
-        Adopt locks from a previous instance of lvmlockd.
-
 
 .SH USAGE
 
@@ -261,6 +258,16 @@ does for foreign VGs.
 
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
@@ -288,19 +295,7 @@ See below for more information about managing the sanlock global lock.
 
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
@@ -379,31 +374,6 @@ activation {
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
@@ -411,8 +381,8 @@ locks and when they are used:
 
 .I Global lock
 
-The global lock s associated with global information, which is information
-not isolated to a single VG.  This includes:
+The global lock is associated with global information, which is
+information not isolated to a single VG.  This includes:
 
 \[bu]
 The global VG namespace.
@@ -456,7 +426,7 @@ held only while an LVM command is running.)
 
 .I lock retries
 
-If a request for a Global or VG lock fails due to a lock conflict with
+If a request for a global or VG lock fails due to a lock conflict with
 another host, lvmlockd automatically retries for a short time before
 returning a failure to the LVM command.  If those retries are
 insufficient, the LVM command will retry the entire lock request a number
@@ -579,8 +549,7 @@ necessary locks.
 .B lvmlockd failure
 
 If lvmlockd fails or is killed while holding locks, the locks are orphaned
-in the lock manager.  lvmlockd can be restarted with an option to adopt
-locks in the lock manager that had been held by the previous instance.
+in the lock manager.
 
 .B dlm/corosync failure
 


