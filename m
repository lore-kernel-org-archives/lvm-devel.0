From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 25 Nov 2014 14:09:59 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20141125140959.8951160D02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2aca8347243b64751a98052d1a9801b489d48c4c
Commit:        2aca8347243b64751a98052d1a9801b489d48c4c
Parent:        e50c9bd7cdf22690ee9d6de853a07d743806c3d8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 24 17:46:50 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 24 17:46:50 2014 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 +++---
 WHATS_NEW_DM |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 2acba4f..77c461d 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.113(2)-git (2014-11-11)
+2.02.113(2)-git (2014-11-24)
diff --git a/VERSION_DM b/VERSION_DM
index 5b592b1..1b591a5 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.92-git (2014-11-11)
+1.02.92-git (2014-11-24)
diff --git a/WHATS_NEW b/WHATS_NEW
index fc6ba69..780050d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
-Version 2.02.113 - 
+Version 2.02.113 - 24th November 2014
 =====================================
-  Validate converted volume and specified pool volume differ.
+  Add --cachepolicy and --cachesettings options to lvchange.
+  Validate that converted volume and specified pool volume differ in lvconvert.
   Fix regression in vgscan --mknodes usage (2.02.112).
   Respect --prefix when setting CLMVD_PATH configure (2.02.89).
   Default to configure --enable-udev-systemd-background-jobs for systemd>=205.
@@ -8,7 +9,6 @@ Version 2.02.113 -
   Failed recovery returns FAILED_RECOVERY status flag for vg_read().
   Exit with non-zero status code when pvck encounters a problem.
   Fix clean_tree after activation/resume for cache target (2.02.112).
-  Add --cachepolicy and --cachesettings options to lvchange.
 
 Version 2.02.112 - 11th November 2014
 =====================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ba4e679..45d3ece 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,8 +1,8 @@
-Version 1.02.92 - 
+Version 1.02.92 - 24th November 2014
 ====================================
   Fix memory corruption with sorting empty string lists (1.02.86).
   Fix man dmsetup.8 syntax warning of Groff
-  Relax rules in the config file parser.
+  Accept unquoted strings and / in place of {} when parsing configs.
 
 Version 1.02.91 - 11th November 2014
 ====================================


