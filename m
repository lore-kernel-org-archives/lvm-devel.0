From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 16 Mar 2017 06:36:24 -0400
Subject: master - man: Handle empty MAN8GENERATED
Message-ID: <201703161036.v2GAaOvN029392@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=affe055462abde154a31eea0aa1775157c35bdcd
Commit:        affe055462abde154a31eea0aa1775157c35bdcd
Parent:        51b9de7249e912cdaa4508f5046d95d2c108b1c1
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Mar 16 11:33:07 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 16 11:35:08 2017 +0100

man: Handle empty MAN8GENERATED

---
 man/Makefile.in |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 1e521fd..6e4c846 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -190,8 +190,7 @@ install_man7: $(MAN7)
 
 install_man8: $(MAN8) $(MAN8GENERATED)
 	$(INSTALL) -d $(MAN8DIR)
-	$(INSTALL_DATA) $(MAN8) $(MAN8DIR)/
-	$(INSTALL_DATA) $(MAN8GENERATED) $(MAN8DIR)/
+	$(INSTALL_DATA) $(MAN8) $(MAN8GENERATED) $(MAN8DIR)/
 
 install_lvm2: install_man5 install_man7 install_man8
 


