From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 7 Dec 2018 09:19:43 -0500
Subject: 2018-06-01-stable - post-release
Message-ID: <201812071419.wB7EJhGq013404@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d077286b9c6b07fcdd62d834274ae9ab896b195
Commit:        2d077286b9c6b07fcdd62d834274ae9ab896b195
Parent:        f5ea02ffee3269a77e295d2b186ca81481f592d7
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Dec 7 15:19:10 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Dec 7 15:19:10 2018 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 3dc7946..9ae261d 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.183(2) (2018-12-07)
+2.02.184(2)-git (2018-12-07)
diff --git a/VERSION_DM b/VERSION_DM
index 2cf798e..0ccad6e 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.154 (2018-12-07)
+1.02.156-git (2018-12-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index 1bb2686..02f4ebf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.184 - 
+=====================================
+
 Version 2.02.183 - 07th December 2018
 =====================================
   Avoid disabling lvmetad when repair does nothing.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6fc667d..80b45be 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.156 - 
+=====================================
+
 Version 1.02.154 - 07th December 2018
 =====================================
   Do not add parameters for RESUME with DM_DEVICE_CREATE dm task.


