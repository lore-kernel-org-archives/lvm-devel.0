From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  3 Jun 2016 22:43:24 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160603224324.C8D2B60CD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c894911aee47662e8f85f4458d65baea97eb058
Commit:        7c894911aee47662e8f85f4458d65baea97eb058
Parent:        767c9d653eb9c6deec576c23823781c6f184dea0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 3 23:20:43 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 3 23:20:43 2016 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index c233b09..e2b1146 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.155(2)-git (2016-06-03)
+2.02.156(2)-git (2016-06-03)
diff --git a/VERSION_DM b/VERSION_DM
index d4bffcd..fddb2ee 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.126-git (2016-06-03)
+1.02.127-git (2016-06-03)
diff --git a/WHATS_NEW b/WHATS_NEW
index 2484ab2..c1b90af 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.156 - 
+================================
+
 Version 2.02.155 - 3rd June 2016
 ================================
   Reject PV tags on pvmove cmdline because only 1 PV is supported. (2.02.141)
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a86940b..9c84854 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.127 - 
+================================
+
 Version 1.02.126 - 3rd June 2016
 ================================
   Report passthrough caching mode when parsing cache mode.


