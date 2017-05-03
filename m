From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 3 May 2017 06:31:07 -0400
Subject: master - post-release
Message-ID: <201705031031.v43AV7Uh017488@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a946327bb7bc746e7b2ff3aa6d179d1e12925a4a
Commit:        a946327bb7bc746e7b2ff3aa6d179d1e12925a4a
Parent:        fb4bf1f4eae9ce49f9e0d606240867320dcb8dac
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed May 3 11:26:58 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed May 3 11:26:58 2017 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 4f7cf0e..1e823ec 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.171(2)-git (2017-05-03)
+2.02.172(2)-git (2017-05-03)
diff --git a/VERSION_DM b/VERSION_DM
index bc37b73..36b0104 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.140-git (2017-05-03)
+1.02.141-git (2017-05-03)
diff --git a/WHATS_NEW b/WHATS_NEW
index 33a27e8..003a9c7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.172 - 
+===============================
+
 Version 2.02.171 - 3rd May 2017
 ===============================
   Fix memory warnings by using mempools for command definition processing.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 20d6220..a8b721c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.141 - 
+===============================
+
 Version 1.02.140 - 3rd May 2017
 ===============================
   Add missing configure --enable-dmfilemapd status message and fix --disable.


