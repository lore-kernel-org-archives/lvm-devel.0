From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:47 +0000 (GMT)
Subject: main - makefiles: generate only needed text
Message-ID: <20210419130047.088FA396901B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54f98c94b45629dccc5588a54fa7fa448ea40d0c
Commit:        54f98c94b45629dccc5588a54fa7fa448ea40d0c
Parent:        adfdfd9c58aa2bb24d675eaa5f33e0101015d10f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 18 20:37:37 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:37:07 2021 +0200

makefiles: generate only needed text

Avoid storing see_also & _end parts in  generated doc,
since these we can easily 'cat' while making man pages.
---
 man/Makefile.in | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index d716deb58..7ad533980 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -122,13 +122,13 @@ SEE_ALSO=$(srcdir)/see_also.end
 %.8_gen: $(srcdir)/%.8_des $(srcdir)/%.8_end $(MANGENERATOR) $(TESTMAN)
 	$(Q)set -e ; ( \
 	    if [ ! -s $(TESTMAN) ] ; then \
-		cat $(srcdir)/$(@:%.8_gen=%.8_pregen) ; \
+		cat $(srcdir)/$(@:%.8_gen=%.8_pregen) \
+		    $(srcdir)/$(basename $@).8_end $(SEE_ALSO) ; \
 	    else \
 		MANCMD=$(basename $@) && \
 		$(MANGENERATOR) --primary $$MANCMD $< && \
 		$(MANGENERATOR) --secondary $$MANCMD && \
-		cat $(srcdir)/$(basename $@).8_end && \
-		cat $(SEE_ALSO) ; \
+		cat $(srcdir)/$(basename $@).8_end $(SEE_ALSO) ; \
 	    fi \
 	) > $@
 
@@ -262,11 +262,13 @@ install: install_lvm2 install_device-mapper install_cluster
 install_all_man: install install_systemd_generators
 
 # Copy generated man pages back to source tree as fallback for machines where generator doesn't work
-pregenerated_man: all
+pregenerated_man: $(MANGENERATOR) $(TESTMAN)
 	@echo "    [GENERATE] $^"
-	$(Q) set -e ; for i in $(srcdir)/*.8_des; do \
+	$(Q) set -e ; test -s $(TESTMAN) && for i in $(srcdir)/*.8_des; do \
 		CMD=`basename $$i .8_des`; \
-		cat $${CMD}.8_gen > $(srcdir)/$$CMD.8_pregen ; \
+		( $(MANGENERATOR) --primary $$CMD $$i && \
+		$(MANGENERATOR) --secondary $$CMD )  \
+		> $(srcdir)/$$CMD.8_pregen ; \
 	done
 
 generate: pregenerated_man


