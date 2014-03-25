From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:00:52 +0000 (UTC)
Subject: master - WHATS_NEW: commit f12ee43
Message-ID: <20140325100052.D15FD60E70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d29fe919e6a4000d0d78d2f3c88b291a303b82ac
Commit:        d29fe919e6a4000d0d78d2f3c88b291a303b82ac
Parent:        c84face8ceec82123a5d4ecc309ab9bb7fbbfddf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 25 11:00:44 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 25 11:00:44 2014 +0100

WHATS_NEW: commit f12ee43

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4ac1fa2..4448717 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Reinitialise lvmcache properly on fork to fix premature polldaemon exit.
   Add 'lvm dumpconfig --type diff' to show differences from defaults.
   Fix swap signature detection for devices smaller then 2MB.
   Reindent some clvmd.c code.


