From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 7 Jun 2019 11:30:22 -0400
Subject: master - post-release
Message-ID: <201906071530.x57FUMMS029639@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d11bf8d50e72476c09e813ffc1144150f0552e0
Commit:        4d11bf8d50e72476c09e813ffc1144150f0552e0
Parent:        cb6277aa8a1f6d0dedf2082995b1673da1eb46f9
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jun 7 16:33:29 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jun 7 17:24:51 2019 +0200

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    5 ++++-
 4 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/VERSION b/VERSION
index d2f613b..3a0456f 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.03(2) (2019-06-07)
+2.03.04(2)-git (2019-06-07)
diff --git a/VERSION_DM b/VERSION_DM
index 78eb98d..79067a8 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.159 (2019-06-07)
+1.02.161-git (2019-06-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index 1062c27..c2d3600 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.03.04 - 
+================================
+
 Version 2.03.03 - 07th June 2019
 ================================
   Report no_discard_passdown for cache LVs with lvs -o+kernel_discards.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8edd76c..49b9a7e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,8 @@
-Version 1.02.159 - 07th June 2019
+Version 1.02.161 - 
 ====================================
+
+Version 1.02.159 - 07th June 2019
+=================================
   Parsing of cache status understand no_discard_passdown.
   Ensure migration_threshold for cache is at least 8 chunks.
 


