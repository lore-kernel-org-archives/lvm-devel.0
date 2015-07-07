From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Jul 2015 13:00:01 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150707130001.3347E611C5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3472910177c96780628c7d54dfb6b4aab735353c
Commit:        3472910177c96780628c7d54dfb6b4aab735353c
Parent:        088ee7618da48f473ab61b8e73f8d489b67a6900
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 7 13:54:37 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 7 13:54:37 2015 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 ++-
 WHATS_NEW_DM |    2 +-
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index c32ce9f..6e9667f 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.125(2)-git (2015-07-03)
+2.02.125(2)-git (2015-07-07)
diff --git a/VERSION_DM b/VERSION_DM
index 53b1ce1..e0980a8 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.102-git (2015-07-03)
+1.02.102-git (2015-07-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index f9ff8db..f792ffb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.02.125 -
+Version 2.02.125 - 7th July 2015
 ================================
+  Fix getline memory usage in lvmpolld.
   Add support --clear-needs-check-flag for cache_check of cache pool metadata.
   Add lvmetactl for developer use only.
   Rename global/lock_retries to lvmlockd_retries.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 728290f..8e38a24 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.102 -
+Version 1.02.102 - 7th July 2015
 ================================
   Include tool.h for default non-library use.
   Introduce format macros with embedded % such as FMTu64.


