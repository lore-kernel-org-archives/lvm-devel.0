From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 16 Jan 2016 02:15:05 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160116021505.CF118600EE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0faa27d4f55abcda5fa94ef92343eb44e95ada89
Commit:        0faa27d4f55abcda5fa94ef92343eb44e95ada89
Parent:        7559af2334a619bc3dcbf558152841b2695c8616
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jan 16 02:11:21 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jan 16 02:11:21 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    3 ---
 4 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 37dcbe0..9b00fee 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.140(2)-git (2016-01-08)
+2.02.140(2)-git (2016-01-16)
diff --git a/VERSION_DM b/VERSION_DM
index 43446ef..6ef4620 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.115-git (2016-01-08)
+1.02.114-git (2016-01-16)
diff --git a/WHATS_NEW b/WHATS_NEW
index 7023510..2bb3493 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.140 -
-===================================
+Version 2.02.140 - 16th January 2016
+====================================
   Fix lvm2app to return either 0 or 1 for lvm_vg_is_{clustered,exported}.
   Add kernel_discards report field to display thin pool discard used in kernel.
   Correct checking of target presence when driver access is disabled.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f9c808f..4ab492a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.115 - 
-=====================================
-
 Version 1.02.114 - 14th December 2015
 =====================================
   Better support for dmsetup static linkage.


