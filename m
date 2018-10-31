From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 31 Oct 2018 03:51:18 -0400
Subject: 2018-06-01-stable - pre-release
Message-ID: <201810310751.w9V7pIj6003681@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b93aded0212a903f8a1e9e897dada1f34aa3de43
Commit:        b93aded0212a903f8a1e9e897dada1f34aa3de43
Parent:        efa281685a4e2861973d131ccc31313ba31a97ef
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Oct 29 18:38:57 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Oct 30 10:00:58 2018 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 0c7f8b5..65f29e1 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.182(2) (2018-08-01)
+2.02.182(2) (2018-10-30)
diff --git a/VERSION_DM b/VERSION_DM
index 8a9b53e..798a0b9 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.151-git (2018-08-01)
+1.02.152 (2018-10-30)
diff --git a/WHATS_NEW b/WHATS_NEW
index 79a8716..09fc0a6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.182 - 
-==============================
+Version 2.02.182 - 30th October 2018
+====================================
   Fix possible write race between last metadata block and the first extent.
   Fix filtering of md 1.0 devices so they are not seen as duplicate PVs.
   Fix lvconvert striped/raid0/raid0_meta -> raid6 regression.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 91bbc57..b36e3cf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.151 - 
-==============================
+Version 1.02.152 - 30th October 2018
+====================================
   Add hot fix to avoiding locking collision when monitoring thin-pools.
 
 Version 1.02.150 - 01 August 2018


