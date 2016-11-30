From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 30 Nov 2016 23:22:26 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20161130232226.9FCAA6035D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57e24817b70cf577eea5e57e30a6c3d21ac550fc
Commit:        57e24817b70cf577eea5e57e30a6c3d21ac550fc
Parent:        745250073cf9902a561c116e89e535c86aab231e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Nov 30 23:14:34 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Nov 30 23:14:34 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    5 +++--
 WHATS_NEW_DM |    5 +++--
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index e4ee244..a0333ee 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.168(2)-git (2016-11-05)
+2.02.168(2)-git (2016-11-30)
diff --git a/VERSION_DM b/VERSION_DM
index e8c90bb..26e5e57 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.137-git (2016-11-05)
+1.02.137-git (2016-11-30)
diff --git a/WHATS_NEW b/WHATS_NEW
index 8df3565..1219042 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.168 - 
-====================================
+Version 2.02.168 - 30th November 2016
+=====================================
   Display correct sync_percent on large RaidLVs
   lvmdbusd --blackboxsize <n> added, used to override default size of 16
   Allow a transiently failed RaidLV to be refreshed
@@ -8,6 +8,7 @@ Version 2.02.168 -
   Use transient raid check before repairing raid volume.
   Implement transient status check for raid volumes.
   Only log msg as debug if lvm2-lvmdbusd unit missing for D-Bus notification.
+  Avoid duplicated underscore in name of extracted LV image.
   Missing stripe filler now could be also 'zero'.
   lvconvert --repair accepts --interval and --background option.
   More efficiently prepare _rmeta devices when creating a new raid LV.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a8dd4f5..ee1851a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,7 @@
-Version 1.02.137 - 
-====================================
+Version 1.02.137 - 30th November 2016
+=====================================
   Document raid status values.
+  Always exit dmsetup with success when asked to display help/version.
 
 Version 1.02.136 - 5th November 2016
 ====================================


