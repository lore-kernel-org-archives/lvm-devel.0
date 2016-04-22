From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 22 Apr 2016 23:47:30 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160422234731.0009E60DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=546b2006dd4bc888a08631d6cb66245b0374eab2
Commit:        546b2006dd4bc888a08631d6cb66245b0374eab2
Parent:        31b11d02281a3d141fa2c69d9155baacd158bf50
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Apr 23 00:33:59 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Apr 23 00:41:55 2016 +0100

pre-release

---
 VERSION              |    2 +-
 VERSION_DM           |    2 +-
 WHATS_NEW            |    4 ++--
 WHATS_NEW_DM         |    5 ++++-
 conf/example.conf.in |    7 +++++++
 5 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/VERSION b/VERSION
index 4731ad0..3af3f8c 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.151(2)-git (2016-04-09)
+2.02.151(2)-git (2016-04-23)
diff --git a/VERSION_DM b/VERSION_DM
index 359ada7..74d6f61 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.123-git (2016-04-09)
+1.02.123-git (2016-04-23)
diff --git a/WHATS_NEW b/WHATS_NEW
index d088560..bf72aaa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.151 -
-=================================
+Version 2.02.151 - 23rd April 2016
+==================================
   Fix error path after reusing of _setup_task (2.02.150).
   Fix memory access for empty sysfs values (2.02.149).
   Disable lvmetad when lvm1 metadata is seen, so commands revert to scanning.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e2301ea..3c1ca53 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,9 @@
+Version 1.02.123 - 23rd April 2016
+==================================
+  Do not strip LVM- when debug reporting not found uuid.
+
 Version 1.02.122 - 9th April 2016
 =================================
-  Do not strip LVM- when debug reporting not found uuid.
   Change log_debug ioctl flags from single characters into words.
 
 Version 1.02.121 - 26th March 2016
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 255d329..a6a6762 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -851,6 +851,13 @@ global {
 	# devices/global_filter.
 	use_lvmetad = @DEFAULT_USE_LVMETAD@
 
+	# Configuration option global/lvmetad_update_wait_time.
+	# The number of seconds a command will wait for lvmetad update to finish.
+	# After waiting for this period, a command will not use lvmetad, and
+	# will revert to disk scanning.
+	# This configuration option has an automatic default value.
+	# lvmetad_update_wait_time = 10
+
 	# Configuration option global/use_lvmlockd.
 	# Use lvmlockd for locking among hosts using LVM on shared storage.
 	# Applicable only if LVM is compiled with lockd support in which


