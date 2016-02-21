From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sun, 21 Feb 2016 23:38:20 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160221233820.21CA060756@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=44b3909e588bc8d1896b4a94cf7d0ce85e251960
Commit:        44b3909e588bc8d1896b4a94cf7d0ce85e251960
Parent:        3ef36f05b6269f752a6d8fb62e098e89843958fa
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sun Feb 21 23:37:48 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sun Feb 21 23:37:48 2016 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index b7455e6..d831047 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.143(2)-git (2016-02-21)
+2.02.144(2)-git (2016-02-21)
diff --git a/VERSION_DM b/VERSION_DM
index 505ccd5..c19e2b5 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.117-git (2016-02-21)
+1.02.118-git (2016-02-21)
diff --git a/WHATS_NEW b/WHATS_NEW
index 9097ce9..f94cabd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.144 - 
+=====================================
+
 Version 2.02.143 - 21st February 2016
 =====================================
   Fix error path when sending thin-pool message fails in update_pool_lv().
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f23c541..dd47c6b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.118 -
+=====================================
+
 Version 1.02.117 - 21st February 2016
 =====================================
   Improve status parsing for thin-pool and thin devices.


