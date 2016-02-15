From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Feb 2016 10:48:55 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160215104855.631FA60BBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=952498ef4d1d9aada0f81ba367d870c7aa1a0413
Commit:        952498ef4d1d9aada0f81ba367d870c7aa1a0413
Parent:        228b8245e4fbae92968feeb8ded57697b567ceed
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 15 10:48:55 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 15 10:48:55 2016 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 6ac1ce6..3dc718b 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.142(2)-git (2016-02-15)
+2.02.143(2)-git (2016-02-15)
diff --git a/VERSION_DM b/VERSION_DM
index 73eb926..621718a 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.116-git (2016-02-15)
+1.02.117-git (2016-02-15)
diff --git a/WHATS_NEW b/WHATS_NEW
index 9207fca..c7ffcf7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.143 - 
+=====================================
+
 Version 2.02.142 - 15th February 2016
 =====================================
   Fix memory pool corruption in pvmove (2.02.141).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9e30e66..d82ebf3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.117 - 
+=====================================
+
 Version 1.02.116 - 15th February 2016
 =====================================
   Use fully aligned allocations for dm_pool_strdup/strndup() (1.02.64).


