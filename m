From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 10 Oct 2018 07:28:52 -0400
Subject: master - pre-release
Message-ID: <201810101128.w9ABSqEJ031704@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8462cff9224594385c3b9f89785c28995151824
Commit:        f8462cff9224594385c3b9f89785c28995151824
Parent:        37366ec3b061c86ce897560213df5769c5d91eb6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Aug 21 17:18:20 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 10 11:26:53 2018 +0200

pre-release

---
 README       |    3 +++
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    5 +++--
 WHATS_NEW_DM |   15 ++++++++++++++-
 5 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/README b/README
index 9fe0a0d..38a9778 100644
--- a/README
+++ b/README
@@ -1,5 +1,8 @@
 This tree contains the LVM2 and device-mapper tools and libraries.
 
+This is development branch, for stable 2.02 release see 2018-06-01-stable
+branch.
+
 For more information about LVM2 read the changelog in the WHATS_NEW file.
 Installation instructions are in INSTALL.
 
diff --git a/VERSION b/VERSION
index 51e0d33..b95f3cd 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.178(2)-git (2018-05-24)
+2.03.00(2) (2018-10-10)
diff --git a/VERSION_DM b/VERSION_DM
index 1c2b36c..07addfa 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.147-git (2018-05-24)
+1.02.151 (2018-10-10)
diff --git a/WHATS_NEW b/WHATS_NEW
index db5f212..2e24996 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 3.0.0
-=============
+Version 2.03.00 - 10th October 2018
+===================================
   Add hot fix to avoiding locking collision when monitoring thin-pools.
   Allow raid4 -> linear conversion request.
   Fix lvconvert striped/raid0/raid0_meta -> raid6 regression.
@@ -24,6 +24,7 @@ Version 3.0.0
   Avoid showing internal error in lvs output or pvmoved LVs.
   Remove clvmd
   Remove lvmlib (api)
+  Remove lvmetad
   lvconvert: provide possible layouts between linear and striped/raid
   Use versionsort to fix archive file expiry beyond 100000 files.
 
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ac4868c..c659871 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,7 +1,20 @@
-Version 1.02.147 -
+Version 1.02.151 - 10th October 2018
 ====================================
+  Add hot fix to avoiding locking collision when monitoring thin-pools.
+
+Version 1.02.150 - 01 August 2018
+=================================
   Add vdo plugin for monitoring VDO devices.
 
+Version 1.02.149 - 19th July 2018
+=================================
+
+Version 1.02.148 - 18th June 2018
+=================================
+
+Version 1.02.147 - 13th June 2018
+=================================
+
 Version 1.02.147-rc1 - 24th May 2018
 ====================================
   Reuse uname() result for mirror target.


