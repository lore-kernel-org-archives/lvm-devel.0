From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  5 Aug 2014 01:15:27 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20140805011527.9DD0B60F71@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d4e1e51a944c07bad56fe41407b84afefb39357
Commit:        9d4e1e51a944c07bad56fe41407b84afefb39357
Parent:        e94442bffa26d51a67b0102daac4d9f755fe5343
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 5 02:07:35 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 5 02:07:35 2014 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    7 ++++---
 WHATS_NEW_DM |    4 ++--
 4 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 79c463f..2eb161b 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.109(2)-git (2014-07-23)
+2.02.109(2)-git (2014-08-05)
diff --git a/VERSION_DM b/VERSION_DM
index a6ea805..e9787c1 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.88-git (2014-07-23)
+1.02.88-git (2014-08-05)
diff --git a/WHATS_NEW b/WHATS_NEW
index 8397d30..e63a3e8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
-Version 2.02.109 - 
-=================================
-  Fix a segfault in lvscan --cache when devices were already missing.
+Version 2.02.109 - 5th August 2014
+==================================
+  Remove lv_volume_type field from reports. (2.02.108)
+  Fix a segfault in lvscan --cache when devices were already missing. (2.02.108)
   Fix incorrect persistent .cache after vgcreate with PV creation. (2.02.108)
   Display actual size changed when resizing LV.
   Allow approximate allocation with +%FREE in lvextend.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b663bfc..7b19ea1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.88 - 
-================================
+Version 1.02.88 - 5th August 2014
+=================================
   Add dm_tree_set_optional_uuid_suffixes to handle upgrades.
 
 Version 1.02.87 - 23rd July 2014


