From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 17 Aug 2015 16:30:05 +0000 (UTC)
Subject: master - post-release
Message-ID: <20150817163005.2360D60789@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1c65d1b28c8942b4296da30dc95b7e7de33e5fe
Commit:        d1c65d1b28c8942b4296da30dc95b7e7de33e5fe
Parent:        be1db6b6c17226894233f7d9629117b0cd554b88
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 17 17:26:20 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 17 17:26:20 2015 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 1f01f85..256a299 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.128(2)-git (2015-08-17)
+2.02.129(2)-git (2015-08-17)
diff --git a/VERSION_DM b/VERSION_DM
index c8c6485..84f6bdb 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.105-git (2015-08-17)
+1.02.106-git (2015-08-17)
diff --git a/WHATS_NEW b/WHATS_NEW
index a65fd7b..25cea03 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.129 -
+===================================
+
 Version 2.02.128 - 17th August 2015
 ===================================
   Allocation setting cache_pool_cachemode is replaced by cache_mode.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 32b333b..363f7bf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.106 -
+===================================
+
 Version 1.02.105 - 17th August 2015
 ===================================
   Fix 'dmstats list -o all' segfault.


