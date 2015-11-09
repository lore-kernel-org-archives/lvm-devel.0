From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Nov 2015 01:53:40 +0000 (UTC)
Subject: master - post-release
Message-ID: <20151109015340.A20A66160D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=af6adec7cc1e4229a88cc9d7951a51d0d22c5032
Commit:        af6adec7cc1e4229a88cc9d7951a51d0d22c5032
Parent:        a3f77ed4ba4b6d35638f81cf9f58db2a730246e7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 9 01:48:57 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 9 01:48:57 2015 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index e7542bf..81a0997 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.134(2)-git (2015-11-09)
+2.02.135(2)-git (2015-11-09)
diff --git a/VERSION_DM b/VERSION_DM
index 661545a..934b030 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.110-git (2015-11-09)
+1.02.111-git (2015-11-09)
diff --git a/WHATS_NEW b/WHATS_NEW
index f414e92..5e89eca 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.135 - 
+====================================
+
 Version 2.02.134 - 9th November 2015
 ====================================
   Refactor some lvmetad code and adjust some duplicate PV messages.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5004f84..113a4bb 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.111 - 
+====================================
+
 Version 1.02.110 - 30th October 2015
 ====================================
   Disable thin monitoring plugin when it fails too often (>10 times).


