From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 19 Mar 2016 01:20:22 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160319012022.D6279600DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d4b6bdfc0bfc6939a70bd6ee4b15dad3cae09f5
Commit:        0d4b6bdfc0bfc6939a70bd6ee4b15dad3cae09f5
Parent:        6c10d1f3d95dc0f7ac55fe55be0115a9fc438da5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Mar 19 01:14:29 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Mar 19 01:14:29 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    2 +-
 WHATS_NEW_DM |    3 ---
 4 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index f56f978..54a274a 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.147(2)-git (2016-03-11)
+2.02.147(2)-git (2016-03-19)
diff --git a/VERSION_DM b/VERSION_DM
index c66683d..75e9e89 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.121-git (2016-03-11)
+1.02.120-git (2016-03-19)
diff --git a/WHATS_NEW b/WHATS_NEW
index 96023c8..0db5526 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.147 - 
+Version 2.02.147 - 19th March 2016
 ==================================
   If available, use /proc/self/mountinfo to detect mounted volume in fsadm.
   Fix resize of stacked raid thin data volume (2.02.141).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9ddf5e1..ec27a19 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.121 - 
-==================================
-
 Version 1.02.120 - 11th March 2016
 ==================================
   Improve parsing of cache status and report Fail, Error, needs_check, ro.


