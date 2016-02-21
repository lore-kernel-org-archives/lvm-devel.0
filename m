From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sun, 21 Feb 2016 23:38:17 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160221233817.F1FFF60756@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ef36f05b6269f752a6d8fb62e098e89843958fa
Commit:        3ef36f05b6269f752a6d8fb62e098e89843958fa
Parent:        8b6cad32199dd08d8f56d5f0cec0f5e24928211c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Feb 21 23:17:24 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Feb 21 23:17:24 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    2 +-
 WHATS_NEW_DM |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 3dc718b..b7455e6 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.143(2)-git (2016-02-15)
+2.02.143(2)-git (2016-02-21)
diff --git a/VERSION_DM b/VERSION_DM
index 621718a..505ccd5 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.117-git (2016-02-15)
+1.02.117-git (2016-02-21)
diff --git a/WHATS_NEW b/WHATS_NEW
index 654f0a1..9097ce9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.143 -
+Version 2.02.143 - 21st February 2016
 =====================================
   Fix error path when sending thin-pool message fails in update_pool_lv().
   Support reporting CheckNeeded and Fail state for thin-pool and thin LV.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 984d7fa..f23c541 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.117 - 
+Version 1.02.117 - 21st February 2016
 =====================================
   Improve status parsing for thin-pool and thin devices.
 


