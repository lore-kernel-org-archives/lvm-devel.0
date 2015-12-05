From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Dec 2015 15:57:08 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20151205155708.216C96072D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=063b353b286652d5ccc692cf636824b9b3270fe9
Commit:        063b353b286652d5ccc692cf636824b9b3270fe9
Parent:        fedf15ffb0237d0bc44c13b0ce62122a2aed64ec
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Dec 5 15:33:19 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Dec 5 15:33:19 2015 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    9 +++++++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 759b847..a504b04 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.137(2)-git (2015-11-28)
+2.02.137(2)-git (2015-12-05)
diff --git a/VERSION_DM b/VERSION_DM
index 04ea29b..27520ef 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.113-git (2015-11-28)
+1.02.113-git (2015-12-05)
diff --git a/WHATS_NEW b/WHATS_NEW
index 4b33708..95839a2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,12 +1,17 @@
-Version 2.02.137 -
-=====================================
+Version 2.02.137 - 5th December 2015
+====================================
   Restore archiving before changing metadata in vgextend (2.02.117).
   Dropped internal usage of log_suppress(2).
   Cleaned logging code for buffer size usage.
   Added internal id_read_format_try() function to check and read valid UUID.
+  Change lvcreate, lvrename, lvresize to use process_each_vg.
+  Change process_each_vg to handle single VG as separate arg.
+  Issue error if ambiguous VG name is supplied in most commands.
+  Make process_each fns always work through full list of known VG names.
   Use dm_get_status_mirror() instead of individual parsers.
   Add mem pool arg for check_transient_status() target function.
   Avoid misleading error with -m is omitted with lvconvert to raid types.
+  Add system_id to vginfo cache.
 
 Version 2.02.136 - 28th November 2015
 =====================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3357cec..4b119af 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.113 - 
-=====================================
+Version 1.02.113 - 5th December 2015
+====================================
   Mirror plugin in dmeventd uses dm_get_status_mirror().
   Add dm_get_status_mirror() for parsing mirror status line.
 


