From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 19 Jul 2018 12:44:05 -0400
Subject: 2018-06-01-stable - WHATS_NEW
Message-ID: <201807191644.w6JGi5jD006386@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82feb5f11103267e1e42c3732f42567810fdf1e0
Commit:        82feb5f11103267e1e42c3732f42567810fdf1e0
Parent:        66990bc7c80059dff76faebd4c1d50254f3804b5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jul 19 18:33:59 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jul 19 18:33:59 2018 +0200

WHATS_NEW

---
 WHATS_NEW |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5c5aac6..79006f9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -10,8 +10,10 @@ Version 2.02.180 -
   Cache can uses metadata format 2 with cleaner policy.
   Avoid showing internal error in lvs output or pvmoved LVs.
   Fix check if resized PV can also fit metadata area.
-  Reopen devices RDWR before writing to avoid udev issues.
-  Fix mem leak in clvmd.
+  Reopen devices RDWR only before writing to avoid udev issues.
+  Change pvresize output confusing when no resize took place.
+  Fix lvmetad hanging on shutdown.
+  Fix mem leak in clvmd and more coverity issues.
 
 Version 2.02.179 - 18th June 2018
 =================================


