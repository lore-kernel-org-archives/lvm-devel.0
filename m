From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 24 May 2018 07:32:42 -0400
Subject: master - release note: typos
Message-ID: <201805241132.w4OBWgiL020035@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e85361c34ec539880fe8e764e4b49fc55f78a09
Commit:        7e85361c34ec539880fe8e764e4b49fc55f78a09
Parent:        fab063cfcbbe2e3801ba2af7d061059eb37a7eaa
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 24 12:32:16 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 24 12:32:16 2018 +0100

release note: typos

---
 doc/release-notes/2.02.178 |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/doc/release-notes/2.02.178 b/doc/release-notes/2.02.178
index f986d1d..5b4319e 100644
--- a/doc/release-notes/2.02.178
+++ b/doc/release-notes/2.02.178
@@ -23,7 +23,7 @@ Rewrite label scanning
 ----------------------
 
 Dave Teigland has reworked the label scanning and metadata reading
-logic to minimise the amount a IOs issued.  Combined with the aio changes 
+logic to minimise the amount of IOs issued.  Combined with the aio changes 
 this can greatly improve scanning speed for some systems.
 
 ./configure options
@@ -31,16 +31,16 @@ this can greatly improve scanning speed for some systems.
 
 We're going to try and remove as many options from ./configure as we
 can.  Each option multiplies the number of possible configurations
-that we should test (this testing is currently not occuring).
+that we should test (this testing is currently not occurring).
 
 The first batch to be removed are:
 
-  --enable-testing switch for ./configure has been removed.
-  --with-snapshots switch for ./configure has been removed.
-  --with-mirrors switch for ./configure has been removed.
-  --with-raid switch for ./configure has been removed.
-  --with-thin switch for ./configure has been removed.
-  --with-cache switch for ./configure has been removed.
+  --enable-testing
+  --with-snapshots
+  --with-mirrors
+  --with-raid
+  --with-thin
+  --with-cache
 
 Stable targets that are in the upstream kernel will just be supported.
 


