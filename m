From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 13 Sep 2017 15:56:34 -0400
Subject: master - pre-release
Message-ID: <201709131956.v8DJuYCs008934@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=918f0a92daef84867e0df4b422c3de2a36997f17
Commit:        918f0a92daef84867e0df4b422c3de2a36997f17
Parent:        901c919d2208f9a13b1c46cc4755620c3b1b0a07
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 13 20:38:29 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 13 20:38:29 2017 +0100

pre-release

---
 VERSION                |    2 +-
 VERSION_DM             |    2 +-
 WHATS_NEW              |    4 ++--
 WHATS_NEW_DM           |    4 ++--
 man/lvmconfig.8_pregen |    4 ++--
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index cbce772..e9ea5c9 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.174(2)-git (2017-07-20)
+2.02.174(2)-git (2017-09-13)
diff --git a/VERSION_DM b/VERSION_DM
index a338597..0dd3535 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.143-git (2017-07-20)
+1.02.143-git (2017-09-13)
diff --git a/WHATS_NEW b/WHATS_NEW
index e6cc18d..090f377 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.174 - 
-=================================
+Version 2.02.174 - 13th September 2017
+======================================
   Prevent raid1 split with trackchanges in a shared VG.
   Avoid double unlocking of client & lockspace mutexes in lvmlockd.
   Fix leaking of file descriptor for non-blocking filebased locking.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 766eb20..fbf144c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.143 - 
-=================================
+Version 1.02.143 - 13th September 2017
+======================================
   Restore umask when creation of node fails.
   Add --concise to dmsetup create for many devices with tables in one command.
   Accept minor number without major in library when it knows dm major number.
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index c60f899..0b7fea6 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -399,13 +399,13 @@ settings, also display comments about deprecation.
 .ad l
 \fB--withgeneralpreamble\fP
 .br
-Display general file preamble at start of output.
+Include general config file preamble.
 .ad b
 .HP
 .ad l
 \fB--withlocalpreamble\fP
 .br
-Display local file preamble at start of output.
+Include local config file preamble.
 .ad b
 .HP
 .ad l


