From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 10 Apr 2014 16:13:43 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20140410161343.2574D60DAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2043f8c729b468ab28bdfcbad8d8040dd0391d2f
Commit:        2043f8c729b468ab28bdfcbad8d8040dd0391d2f
Parent:        35721ee134954ec328e8d20e51c13e2e70a438d1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 10 16:28:28 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 10 16:28:28 2014 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   25 +++++++++++--------------
 WHATS_NEW_DM |    4 ++--
 4 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/VERSION b/VERSION
index 13e0ce8..f590420 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.106(2)-git (2014-01-20)
+2.02.106(2)-git (2014-04-10)
diff --git a/VERSION_DM b/VERSION_DM
index 5c743b5..2151575 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.85-git (2014-01-20)
+1.02.85-git (2014-04-10)
diff --git a/WHATS_NEW b/WHATS_NEW
index 5023ba2..e46f65f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.106 - 
-====================================
+Version 2.02.106 - 10th April 2014
+==================================
   Fix ignored --dataalignment/dataalignment offset for pvcreate --restorefile.
   Fix lost information about bootloader area when using lvmetad.
   Don't require --major to be specified when using -My option on kernels > 2.4.
@@ -7,19 +7,17 @@ Version 2.02.106 -
   Use thin_check --clear-needs-check-flag by default.
   Export lvm_even_rand() for controlled provision of random numbers.
   Add lvmthin man page to section 7.
-  Extend internal validation of lv names size is less then 128 chars.
-  Fail in resume for lvrename will result in failing command.
-  Validate length of new LV name in lvrename to not exceed 127 characters.
-  Add explict error message when using lvdisplay -c -m.
-  Update man pages for pv/vg/lvdisplay.
-  Report error when running pvscan with free argument (i.e. PV name).
-  Fix error message for pvdisplay -c -m and add new for pvdisplay -c -s.
-  Return proper invalid cmd when vgimport/exports find error in parameters.
-  Obtain list of known VGs for pvchange --all when using lvmetad.
-  Add man page for lvm dumpconfig.
+  Ensure mapped device names are not too long in vg_validate and lvrename.
+  Ensure resume failure in lvrename results in command failure.
+  Add explicit error message when using lvdisplay -c -m.
+  Report error if superfluous argument (e.g. PV name) supplied to pvscan.
+  Fix error message for pvdisplay -c -m and add one for pvdisplay -c -s.
+  Use EINVALID_CMD_LINE correctly instead of ECMD_FAILED in vgimport/export.
+  Obtain list of known VGs from lvmetad for pvchange --all.
+  Add man page for lvm-dumpconfig to section 8.
   Drop unused cmd pointer for internal function for_each_sub_lv().
   Validate name for renamed sub LVs.
-  When lvrename fails on argument parsing return invalid cmd line error (5->3).
+  When lvrename fails on argument parsing return EINVALID_CMD_LINE.
   Fix exit code regression in failing pvchange command (2.02.66).
   Include 'lvm dumpconfig --type missing' and '--type diff' output to lvmdump.
   Return failure when specifying negative size for pvresize.
@@ -27,7 +25,6 @@ Version 2.02.106 -
   Reinitialise lvmcache properly on fork to fix premature polldaemon exit.
   Add 'lvm dumpconfig --type diff' to show differences from defaults.
   Fix swap signature detection for devices smaller then 2MB.
-  Reindent some clvmd.c code.
   Use dm_malloc function in clvmd.c.
   Resolve memory release order for clvmd shutdown.
   Report error when lvm2 activation is released in critical_section.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4004d98..502e2c1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.85 - 
-===================================
+Version 1.02.85 - 10th April 2014
+=================================
   Check for sprintf error when building internal device path.
   Check for sprintf error when creating path for dm control node.
   When buffer for dm_get_library_version() is too small, return error code.


