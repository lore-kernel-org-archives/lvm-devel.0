From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 28 Mar 2017 15:53:25 -0400
Subject: master - dmfilemapd: Fix install target
Message-ID: <201703281953.v2SJrPQn022763@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a41d5b6491e197a690cb18fa1a0c28ea6ccb029e
Commit:        a41d5b6491e197a690cb18fa1a0c28ea6ccb029e
Parent:        3aab8731990605182d88d4f3d141b05d6f0e71e6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 28 21:27:30 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 28 21:52:30 2017 +0200

dmfilemapd: Fix install target

---
 daemons/dmfilemapd/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/Makefile.in b/daemons/dmfilemapd/Makefile.in
index 28326d2..53dc09b 100644
--- a/daemons/dmfilemapd/Makefile.in
+++ b/daemons/dmfilemapd/Makefile.in
@@ -60,7 +60,7 @@ install_dmfilemapd_dynamic: dmfilemapd
 install_dmfilemapd_static: dmfilemapd.static
 	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 
-install_dmfilemapd: $(INSTALL_DMEVENTD_TARGETS)
+install_dmfilemapd: $(INSTALL_DMFILEMAPD_TARGETS)
 
 install: install_dmfilemapd
 


