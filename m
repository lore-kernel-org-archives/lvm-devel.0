From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 19 Mar 2016 01:20:25 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160319012025.0CA6F60515@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e58d24293f10b6e29825113cadab8aa70099a128
Commit:        e58d24293f10b6e29825113cadab8aa70099a128
Parent:        0d4b6bdfc0bfc6939a70bd6ee4b15dad3cae09f5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Mar 19 01:18:28 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Mar 19 01:18:28 2016 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 54a274a..5482ec4 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.147(2)-git (2016-03-19)
+2.02.148(2)-git (2016-03-19)
diff --git a/VERSION_DM b/VERSION_DM
index 75e9e89..156b4b5 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.120-git (2016-03-19)
+1.02.121-git (2016-03-19)
diff --git a/WHATS_NEW b/WHATS_NEW
index 0db5526..d096a52 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.148 - 
+==================================
+
 Version 2.02.147 - 19th March 2016
 ==================================
   If available, use /proc/self/mountinfo to detect mounted volume in fsadm.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ec27a19..9ddf5e1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.121 - 
+==================================
+
 Version 1.02.120 - 11th March 2016
 ==================================
   Improve parsing of cache status and report Fail, Error, needs_check, ro.


