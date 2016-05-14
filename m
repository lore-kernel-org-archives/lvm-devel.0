From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 14 May 2016 01:12:31 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160514011231.2DFC560FCF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15ca5883fb7911d231a3931d085cc593eab95a39
Commit:        15ca5883fb7911d231a3931d085cc593eab95a39
Parent:        87d9406725b23e6c01e55014606ff047d7375951
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat May 14 01:57:42 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat May 14 01:57:42 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 ++++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index ebf6c49..2380bd8 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.154(2)-git (2016-05-07)
+2.02.154(2)-git (2016-05-14)
diff --git a/VERSION_DM b/VERSION_DM
index 5f973c5..41b15b7 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.125-git (2016-05-07)
+1.02.125-git (2016-05-14)
diff --git a/WHATS_NEW b/WHATS_NEW
index e11a40a..8ab4800 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,8 @@
-Version 2.02.154 - 
-===============================
+Version 2.02.154 - 14th May 2016
+================================
+  Fix liblvm segfault after failure initialising lvmetad connection.
   Retry open without O_NOATIME if it fails (not file owner/CAP_FOWNER).
+  Split _report into one fn for options and arguments and one for processing.
 
 Version 2.02.153 - 7th May 2016
 ===============================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a1d935e..beb3d46 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.125 - 
-==================================
+Version 1.02.125 - 14th May 2016
+================================
   Show library version in message even if dm driver version is unavailable.
 
 Version 1.02.124 - 30th April 2016


