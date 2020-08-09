From: Marian Csontos <mcsontos@sourceware.org>
Date: Sun,  9 Aug 2020 15:01:26 +0000 (GMT)
Subject: master - post-release
Message-ID: <20200809150126.5BADB3857C4A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=231cdd0efbe73c7a2a4c69969df7e0f5b63f7f2c
Commit:        231cdd0efbe73c7a2a4c69969df7e0f5b63f7f2c
Parent:        4d9f0606beb0acb329794909560433c08b50875d
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Sun Aug 9 16:16:39 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Sun Aug 9 16:17:15 2020 +0200

post-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 4 ++++
 WHATS_NEW_DM | 3 +++
 4 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index c314d60ac..a6ba8f65a 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.10(2) (2020-08-09)
+2.03.11(2)-git (2020-08-09)
diff --git a/VERSION_DM b/VERSION_DM
index 698a0500f..f44bc5f06 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.173 (2020-08-09)
+1.02.175-git (2020-08-09)
diff --git a/WHATS_NEW b/WHATS_NEW
index c735f3466..05d9c0ac9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.03.11 - 
+==================================
+
 Version 2.03.10 - 09th August 2020
 ==================================
   Add writecache and integrity support to lvmdbusd.
@@ -8,6 +11,7 @@ Version 2.03.10 - 09th August 2020
   Fix conversion to 'mirrored' mirror log with larger regionsize.
   Zero pool metadata on allocation (disable with allocation/zero_metadata=0).
   Failure in zeroing or wiping will fail command (bypass with -Zn, -Wn).
+  Add lvcreate of new cache or writecache lv with single command.
   Fix running out of free buffers for async writing for larger writes.
   Add integrity with raid capability.
   Fix support for lvconvert --repair used by foreign apps (i.e. Docker).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 299997d10..2600ca308 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.175 - 
+===================================
+
 Version 1.02.173 - 09th August 2020
 ===================================
   Add support for VDO in blkdeactivate script.


