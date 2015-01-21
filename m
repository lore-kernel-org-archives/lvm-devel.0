From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 21 Jan 2015 13:25:19 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150121132519.1D5AA602D7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa01faaa4aa96de834ba7e8fbb9d9aff908571c3
Commit:        fa01faaa4aa96de834ba7e8fbb9d9aff908571c3
Parent:        25d906dbde45bc64c5a0978e40c810b3b070cb0d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 21 13:08:12 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 21 13:08:12 2015 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 +++---
 WHATS_NEW_DM |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 539cce1..6a4aebc 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.115(2)-git (2014-11-28)
+2.02.115(2)-git (2015-01-21)
diff --git a/VERSION_DM b/VERSION_DM
index e38dae6..3a73cd9 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.93-git (2014-11-28)
+1.02.93-git (2015-01-21)
diff --git a/WHATS_NEW b/WHATS_NEW
index f0b6991..75c4569 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.115 -
-=====================================
+Version 2.02.115 - 21st January 2015
+====================================
   Report segment types without monitoring support as undefined.
   Support lvchange --errorwhenfull for thin pools.
   Improve the processing and reporting of duplicate PVs.
@@ -12,7 +12,7 @@ Version 2.02.115 -
   Use LVM's own selection instead of awk expressions in clvmd startup scripts.
   Do not filter out snapshot origin LVs as unusable devices for an LVM stack.
   Fix incorrect rimage names when converting from mirror to raid1 LV (2.02.112).
-  Avoid excessive re-reading of metadata and related error messages in pvremove.
+  Introduce pvremove_many to avoid excessive metadata re-reading and messages.
   Check for cmirror availability during cluster mirror creation and activation.
   Add cache_policy and cache_settings reporting fields.
   Add missing recognition for --binary option with {pv,vg,lv}display -C.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8cbb6b6..169831c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.93 -
-====================================
+Version 1.02.93 - 21st January 2015
+===================================
   Reduce severity of ioctl error message when dmeventd waitevent is interrupted.
   Report 'unknown version' when incompatible version numbers were not obtained.
   Report more info from thin pool status (out of data, metadata-ro, fail).


