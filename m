From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Mar 2020 12:46:42 +0000 (GMT)
Subject: master - pre-release
Message-ID: <20200326124642.31B35385E006@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e1c2b4126520f05a5d2d515121e89263ec45a2bf
Commit:        e1c2b4126520f05a5d2d515121e89263ec45a2bf
Parent:        caff31df192bc4b06c8b0e9c75cbe93ff79581a5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Mar 26 12:21:16 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 26 12:21:16 2020 +0100

pre-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 4 ++--
 WHATS_NEW_DM | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index d19920bf8..8c4a9a8e0 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.09(2)-git (2020-02-11)
+2.03.09(2) (2020-03-26)
diff --git a/VERSION_DM b/VERSION_DM
index b3b975d24..0ae62fd7e 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.171-git (2020-02-11)
+1.02.171 (2020-03-26)
diff --git a/WHATS_NEW b/WHATS_NEW
index 664df6138..db914c073 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.03.09 - 
-====================================
+Version 2.03.09 - 26th March 2020
+=================================
   Fix formating of vdopool (vdo_slab_size_mb was smaller by 2 bits).
   Fix showing of a dm kernel error when uncaching a volume with cachevol.
 
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4cb0bd33b..12bdceac3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.171 - 
-=====================================
+Version 1.02.171 - 26th March 2020
+==================================
   Fix dm_list interators with gcc 10 optimization (-ftree-pta).
   Dmeventd handles timer without looping on short intervals.
 



