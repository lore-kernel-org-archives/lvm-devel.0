From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 23 Jul 2014 15:20:46 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20140723152046.4DE2860460@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25fa725b05a83dd67e907802d1938bf983ffaad8
Commit:        25fa725b05a83dd67e907802d1938bf983ffaad8
Parent:        8d63d94d853b9675f9d3a86de8b34c68db5d5226
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 23 16:05:22 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 23 16:05:22 2014 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    2 +-
 WHATS_NEW_DM |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 4695aab..fa96924 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.108(2)-git (2014-06-23)
+2.02.108(2)-git (2014-07-23)
diff --git a/VERSION_DM b/VERSION_DM
index 12a8c3d..307f41d 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.87-git (2014-06-23)
+1.02.87-git (2014-07-23)
diff --git a/WHATS_NEW b/WHATS_NEW
index 3595517..e443834 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.108 -
+Version 2.02.108 - 23rd July 2014
 =================================
   Add lvscan --cache which re-scans constituents of a particular LV.
   Make dmeventd's RAID plugin re-scan failed PVs when lvmetad is in use.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ab94bc4..a39099f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.87 -
+Version 1.02.87 - 23rd July 2014
 ================================
   Fix dm_report_field_string_list to handle delimiter with multiple chars.
   Add dm_report_field_reserved_value for per-field reserved value definition.


