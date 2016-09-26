From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 26 Sep 2016 13:29:51 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160926132951.4785660F19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5233a3468c8b50847ac4347539fcf6f748fcf2cc
Commit:        5233a3468c8b50847ac4347539fcf6f748fcf2cc
Parent:        f93cddeafd3d30a2645b0f47c3910a0f1c555b63
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 26 14:20:08 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 26 14:20:08 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    5 +++--
 WHATS_NEW_DM |    5 +++--
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index eb664c4..4678ea0 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.166(2)-git (2016-09-07)
+2.02.166(2)-git (2016-09-26)
diff --git a/VERSION_DM b/VERSION_DM
index 55887fc..27a6d66 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.135-git (2016-09-07)
+1.02.135-git (2016-09-26)
diff --git a/WHATS_NEW b/WHATS_NEW
index d3953ff..25f6742 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.166 - 
-=====================================
+Version 2.02.166 - 26th September 2016
+======================================
   Fix lvm2-activation-generator to read all LVM2 config sources. (2.02.155)
   Fix lvchange-rebuild-raid.sh to cope with older target versions.
   Use dm_config_parse_without_dup_node_check() to speedup metadata reading.
@@ -11,6 +11,7 @@ Version 2.02.166 -
   Fix lock-holder device for thin pool with inactive thin volumes.
   Use --alloc normal for mirror logs even if the mimages were stricter.
   Use O_DIRECT to gather metadata in lvmdump.
+  Ignore creation_time when checking for matching metadata for lvmetad.
   Fix possible NULL pointer derefence when checking for monitoring.
   Add lvmreport(7) man page.
   Don't install lvmraid(7) man page when raid excluded. (2.02.165)
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3ab03b2..9699f63 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,7 +1,8 @@
-Version 1.02.135 - 
-=====================================
+Version 1.02.135 - 26th September 2016
+======================================
   Fix man entry for dmsetup status.
   Introduce new dm_config_parse_without_dup_node_check().
+  Don't omit last entry in dmstats list --group.
 
 Version 1.02.134 - 7th September 2016
 =====================================


