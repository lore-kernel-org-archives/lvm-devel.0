From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 10 Aug 2016 02:03:07 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160810020307.4ACAB60F1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37b8b84fee7459f0a78562c281c405484f25b9db
Commit:        37b8b84fee7459f0a78562c281c405484f25b9db
Parent:        b4f0503d1b55f0f28dbb0d53192aa0ed77423c37
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 10 02:42:35 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 10 02:42:35 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    9 +++++++--
 WHATS_NEW_DM |    6 ++++--
 4 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 32cef62..ed95ad7 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.163(2)-git (2016-07-28)
+2.02.163(2)-git (2016-08-10)
diff --git a/VERSION_DM b/VERSION_DM
index 41ac4ce..aecc584 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.133-git (2016-07-28)
+1.02.133-git (2016-08-10)
diff --git a/WHATS_NEW b/WHATS_NEW
index b51cb79..36bac09 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
-Version 2.02.163 - 
-=================================
+Version 2.02.163 - 10th August 2016
+===================================
+  Add profile for lvmdbusd which uses lvm shell json report output.
+  Restrict in-command modification of some parms in lvm shell.
+  Apply LVM_COMMAND_PROFILE early for lvm shell.
+  Refactor reporting so lvm shell log report collects whole of cmd execution.
+  Support LVM_*_FD envvars to redirect output to file descriptors.
   Limit use of --corelog and --mirrorlog to mirrors in lvconvert.
   Reject --nosync option for RAID6 LVs in lvcreate.
   Do not refresh whole cmd context if profile dropped after processing LVM cmd.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 74722c5..2b32d76 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
-Version 1.02.133 - 
-=================================
+Version 1.02.133 - 10th August 2016
+===================================
+  Add dm_report_destroy_rows/dm_report_group_output_and_pop_all for lvm shell.
+  Adjust group handling and json production for lvm shell.
 
 Version 1.02.132 - 28th July 2016
 =================================


