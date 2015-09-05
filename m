From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Sep 2015 22:58:44 +0000 (UTC)
Subject: master - post-release
Message-ID: <20150905225844.6EA2C60D79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a022e9e6ef24741c5ebf1ebeaff6241cc505287
Commit:        2a022e9e6ef24741c5ebf1ebeaff6241cc505287
Parent:        fb123084166634e8f3b8550520391df369e9db70
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Sep 5 23:58:40 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Sep 5 23:58:40 2015 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index af427ed..4f600d1 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.130(2)-git (2015-09-05)
+2.02.131(2)-git (2015-09-05)
diff --git a/VERSION_DM b/VERSION_DM
index 60f6f69..25d799d 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.107-git (2015-09-05)
+1.02.108-git (2015-09-05)
diff --git a/WHATS_NEW b/WHATS_NEW
index e74fd55..3dc7384 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.131 - 
+=====================================
+
 Version 2.02.130 - 5th September 2015
 =====================================
   Fix use of uninitialized device status if reading outdated .cache record.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b509d68..db40deb 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.108 - 
+=====================================
+
 Version 1.02.107 - 5th September 2015
 =====================================
   Parse thin-pool status with one single routine internally.


