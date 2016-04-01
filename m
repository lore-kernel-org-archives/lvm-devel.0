From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  1 Apr 2016 19:36:40 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160401193640.D370160E5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d0d58b8679f0d071c194db34660a112ae0f3204
Commit:        2d0d58b8679f0d071c194db34660a112ae0f3204
Parent:        60befab7732d33bc29f796b6ff3743969b328240
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 1 20:29:52 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 1 20:29:52 2016 +0100

pre-release

---
 VERSION           |    2 +-
 VERSION_DM        |    2 +-
 WHATS_NEW         |    4 ++--
 WHATS_NEW_DM      |    3 ---
 man/vgcreate.8.in |    2 +-
 5 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index 48f77ed..084a9cd 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.149(2)-git (2016-03-26)
+2.02.149(2)-git (2016-04-01)
diff --git a/VERSION_DM b/VERSION_DM
index defda54..7fab3bb 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.122-git (2016-03-26)
+1.02.121-git (2016-04-01)
diff --git a/WHATS_NEW b/WHATS_NEW
index 3237e0a..32bb212 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.149 - 
-==================================
+Version 2.02.149 - 1st April 2016
+=================================
   Do not flush thin-pool when checking metadata fullness.
   Remove spurious error about no value in /sys/dev/block/major:minor/dm/uuid.
   Fix device mismatch detection for LV if persistent .cache file is used.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d84f8cf..3f044da 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.122 - 
-==================================
-
 Version 1.02.121 - 26th March 2016
 ==================================
   Adjust raid status function.
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index b0b01e4..764d76e 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -130,7 +130,7 @@ The 2.4 kernel has a limitation of 2TiB per block device.
 
 .TP
 .B \-\-shared
-Create a shared VG using lvmlockd if LVM is copiled with lockd support.
+Create a shared VG using lvmlockd if LVM is compiled with lockd support.
  lvmlockd will select lock type sanlock or dlm depending on which lock
 manager is running.  This allows multiple hosts to share a VG on shared
 devices.  lvmlockd and a lock manager must be configured and running.  See


