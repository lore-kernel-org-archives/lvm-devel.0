From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:13:12 -0500
Subject: master - tests: updates
Message-ID: <201811292213.wATMDCRH016681@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7da75f41edf15242f582d200e4e18379dc529db0
Commit:        7da75f41edf15242f582d200e4e18379dc529db0
Parent:        217d647a468c3111738e61e02e56b6744b788a2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 23 20:18:22 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:10:09 2018 +0100

tests: updates

---
 test/shell/dmsecuretest.sh |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/shell/dmsecuretest.sh b/test/shell/dmsecuretest.sh
index fca72bf..75ad56d 100644
--- a/test/shell/dmsecuretest.sh
+++ b/test/shell/dmsecuretest.sh
@@ -42,12 +42,11 @@ PID=$!
 sleep .5
 
 # crypt device should be loaded
-dmsetup table | tee tbl
-grep "$DMTEST" tbl
+dmsetup status "$DMTEST"
 
 # generate core file for running&sleeping binary
 gcore "$PID"
-kill "$PID"
+kill "$PID" || true
 wait
 
 cat cmdout


