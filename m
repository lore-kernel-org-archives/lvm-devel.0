From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 23 Mar 2017 20:40:17 -0400
Subject: master - man: revert erouneous '-' escapes in Makefine.in
Message-ID: <201703240040.v2O0eHUG009911@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93467f0d9f08333a7b7c9e0e112a9c9df454f887
Commit:        93467f0d9f08333a7b7c9e0e112a9c9df454f887
Parent:        a29bb6a14b5e920092495fb9a1623e527d22daac
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 24 01:39:50 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 24 01:39:50 2017 +0100

man: revert erouneous '-' escapes in Makefine.in

---
 man/Makefile.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 3266f1a..57d9627 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -143,7 +143,7 @@ $(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS): Make
 
 # Test whether or not the man page generator works
 $(TESTMAN): $(MANGENERATOR) Makefile
-	- $(MANGENERATOR) \-\-primary lvmconfig > $@
+	- $(MANGENERATOR) --primary lvmconfig > $@
 
 SEE_ALSO=$(srcdir)/see_also.end
 
@@ -162,8 +162,8 @@ SEE_ALSO=$(srcdir)/see_also.end
 		cat $(srcdir)/$(@:%.8_gen=%.8_pregen) ; \
 	    else \
 		MANCMD=$(basename $@) && \
-		$(MANGENERATOR) \-\-primary $$MANCMD $< && \
-		$(MANGENERATOR) \-\-secondary $$MANCMD && \
+		$(MANGENERATOR) --primary $$MANCMD $< && \
+		$(MANGENERATOR) --secondary $$MANCMD && \
 		cat $(srcdir)/$(basename $@).8_end && \
 		cat $(SEE_ALSO) ; \
 	    fi \


