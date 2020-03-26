From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Mar 2020 12:46:43 +0000 (GMT)
Subject: master - post-release
Message-ID: <20200326124643.5602C385E00B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=06cbe3cfc6958b016d97243b807aaf29b9908b23
Commit:        06cbe3cfc6958b016d97243b807aaf29b9908b23
Parent:        e1c2b4126520f05a5d2d515121e89263ec45a2bf
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Mar 26 12:22:09 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 26 12:22:09 2020 +0100

post-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 3 +++
 WHATS_NEW_DM | 3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 8c4a9a8e0..0fc8da873 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.09(2) (2020-03-26)
+2.03.10(2)-git (2020-03-26)
diff --git a/VERSION_DM b/VERSION_DM
index 0ae62fd7e..c6a11602b 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.171 (2020-03-26)
+1.02.173-git (2020-03-26)
diff --git a/WHATS_NEW b/WHATS_NEW
index db914c073..bdeab78e4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.03.10 - 
+=================================
+
 Version 2.03.09 - 26th March 2020
 =================================
   Fix formating of vdopool (vdo_slab_size_mb was smaller by 2 bits).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 12bdceac3..ef0461fad 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.173 - 
+==================================
+
 Version 1.02.171 - 26th March 2020
 ==================================
   Fix dm_list interators with gcc 10 optimization (-ftree-pta).



