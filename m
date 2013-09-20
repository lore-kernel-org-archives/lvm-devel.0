From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 20 Sep 2013 13:04:50 +0000 (UTC)
Subject: master - release 2.02.101
Message-ID: <20130920130450.AE83D60E11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd75844024ad4a2e66c7743c50e189a00c233284
Commit:        bd75844024ad4a2e66c7743c50e189a00c233284
Parent:        f393a5c15631f883883df41e85b3209b33005cd6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Sep 20 13:56:29 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Sep 20 13:56:29 2013 +0100

release 2.02.101

112 files changed, 4131 insertions(+), 1312 deletions(-)
---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 ++++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 4aa9105..8c1db53 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.101(2)-git (2013-08-13)
+2.02.101(2)-git (2013-09-20)
diff --git a/VERSION_DM b/VERSION_DM
index 2fe4e25..10b2320 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.80-git (2013-08-13)
+1.02.80-git (2013-09-20)
diff --git a/WHATS_NEW b/WHATS_NEW
index 0b53a9e..e969620 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
-Version 2.02.101 - 
-===================================
+Version 2.02.101 - 20th September 2013
+======================================
+  Fix 3-thread clvmd deadlock triggered by cleanup on EOF from client.
+  Remove VG from lvmetad before restoring it with vgcfgrestore.
   Use strtoull instead of strtol in _get_int_arg.
   Add devtypes report command to display built-in recognised block device types.
   Fix CC Makefile override which had reverted to using built-in value. (2.02.75)
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 51c771c..176234c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.80 - 
-==================================
+Version 1.02.80 - 20th September 2013
+=====================================
   Detect invalid sector supplied to 'dmsetup message'.
   Free any previously-set string if a dm_task_set_* function is called again.
   Do not allow passing empty new name for dmsetup rename.


