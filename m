From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Sep 2015 22:57:28 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150905225728.7852A61255@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5a3b05c7ac8474cd323558399d2886f8edb5731
Commit:        f5a3b05c7ac8474cd323558399d2886f8edb5731
Parent:        f868624f85059d935ec32a90f89a7d8266d7a6ca
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Sep 5 23:46:22 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Sep 5 23:46:22 2015 +0100

pre-release

---
 VERSION         |    2 +-
 VERSION_DM      |    2 +-
 WHATS_NEW       |    4 ++--
 WHATS_NEW_DM    |    4 ++--
 man/Makefile.in |    2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 2a11501..af427ed 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.130(2)-git (2015-08-26)
+2.02.130(2)-git (2015-09-05)
diff --git a/VERSION_DM b/VERSION_DM
index 3f3ab57..60f6f69 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.107-git (2015-08-26)
+1.02.107-git (2015-09-05)
diff --git a/WHATS_NEW b/WHATS_NEW
index 9ff1ce2..e74fd55 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.130 - 
-===================================
+Version 2.02.130 - 5th September 2015
+=====================================
   Fix use of uninitialized device status if reading outdated .cache record.
   Restore support for --monitor option in lvcreate (2.02.112).
   Read thin-pool data and metadata percent without flush.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a8db0ac..b509d68 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.107 - 
-===================================
+Version 1.02.107 - 5th September 2015
+=====================================
   Parse thin-pool status with one single routine internally.
   Add --histogram to select default histogram fields for list and report.
   Add report fields for displaying latency histogram configuration and data.
diff --git a/man/Makefile.in b/man/Makefile.in
index 995438f..6ddbaa9 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -21,7 +21,7 @@ BLKDEACTIVATEMAN = blkdeactivate.8
 DMEVENTDMAN = dmeventd.8
 LVMETADMAN = lvmetad.8
 LVMPOLLDMAN = lvmpolld.8
-LVMLOCKDMAN = lvmlockd.8
+LVMLOCKDMAN = lvmlockd.8 lvmlockctl.8
 CLVMDMAN = clvmd.8
 CMIRRORDMAN = cmirrord.8
 LVMCACHEMAN = lvmcache.7


