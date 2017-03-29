From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 29 Mar 2017 03:12:30 -0400
Subject: master - dmstats: Fix path to static dmstats
Message-ID: <201703290712.v2T7CUmp032327@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5dfd35f2f8ec14398a5d5586b8000e16065bf96f
Commit:        5dfd35f2f8ec14398a5d5586b8000e16065bf96f
Parent:        5012be326dbadad811620b1584e46144b3c47722
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 29 09:03:57 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 29 09:04:56 2017 +0200

dmstats: Fix path to static dmstats

---
 tools/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 3b7b63d..e18c8d7 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -251,7 +251,7 @@ install_dmsetup_dynamic: dmsetup
 
 install_dmsetup_static: dmsetup.static
 	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
-	$(LN_S) -f $(<F) $(sbindir)/dmstats
+	$(LN_S) -f $(<F) $(staticdir)/dmstats
 
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 


