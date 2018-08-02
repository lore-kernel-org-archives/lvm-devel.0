From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 2 Aug 2018 02:23:28 -0400
Subject: 2018-06-01-stable - post-release
Message-ID: <201808020623.w726NS2P010239@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=acd2c6f256077f07e3f8d34b2b824bf2b6b3dc8a
Commit:        acd2c6f256077f07e3f8d34b2b824bf2b6b3dc8a
Parent:        b10b462fde6846d4bd667a36dd4c934b10c9a1a5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Aug 1 16:55:04 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 2 08:08:34 2018 +0200

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    5 ++++-
 WHATS_NEW_DM |    5 ++++-
 4 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 7da8561..0c7f8b5 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.181(2) (2018-08-01)
+2.02.182(2) (2018-08-01)
diff --git a/VERSION_DM b/VERSION_DM
index 5e05b03..8a9b53e 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.150 (2018-08-01)
+1.02.151-git (2018-08-01)
diff --git a/WHATS_NEW b/WHATS_NEW
index ee1987f..5e8b00d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
-Version 2.02.181 - 01 Aug 2018
+Version 2.02.182 - 
 ==============================
+
+Version 2.02.181 - 01 August 2018
+=================================
   Reject conversions on raid1 LVs with split tracked SubLVs.
   Reject conversions on raid1 split tracked SubLVs.
   Fix dmstats list failing when no regions exist.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1ef3d9e..72e945d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,8 @@
-Version 1.02.150 - 01 Aug 2018
+Version 1.02.151 - 
 ==============================
+
+Version 1.02.150 - 01 August 2018
+=================================
   Add vdo plugin for monitoring VDO devices.
 
 Version 1.02.149 - 19th July 2018


