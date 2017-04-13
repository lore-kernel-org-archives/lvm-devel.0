From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 12 Apr 2017 21:20:53 -0400
Subject: master - pre-release
Message-ID: <201704130120.v3D1KrRU020241@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9a16fe73bdbed8a9bece3fb33fb754d62ffb8d4
Commit:        b9a16fe73bdbed8a9bece3fb33fb754d62ffb8d4
Parent:        9ed518f19fff387d3b843bcdf4fa900f89ab98d8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 13 00:43:31 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 13 00:43:31 2017 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    2 +-
 WHATS_NEW_DM |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 3b0a11f..204e69d 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.170(2)-git (2017-03-28)
+2.02.170(2)-git (2017-04-13)
diff --git a/VERSION_DM b/VERSION_DM
index 72fc3fe..5387a46 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.139-git (2017-03-28)
+1.02.139-git (2017-04-13)
diff --git a/WHATS_NEW b/WHATS_NEW
index b0fc86f..f2482f3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.170 - 
+Version 2.02.170 - 13th April 2017
 ==================================
   Introduce global/fsadm_executable to make fsadm path configurable.
   Look for limited thin pool metadata size when using 16G metadata.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2fa2566..fe1aeb1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.139 - 
+Version 1.02.139 - 13th April 2017
 ==================================
   Fix assignment in _target_version() when dm task can't run.
   Flush stdout on each iteration when using --count or --interval.


