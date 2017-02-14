From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 14 Feb 2017 09:25:42 +0000 (UTC)
Subject: master - makefiles: missing deps
Message-ID: <20170214092542.0AF1C608FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22457ed4d97e0fdb13b15b44facf21521e8a1549
Commit:        22457ed4d97e0fdb13b15b44facf21521e8a1549
Parent:        fc0e49297d6a6818b82169d1059084770c29b9d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 14 10:24:25 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 14 10:24:56 2017 +0100

makefiles: missing deps

---
 Makefile.in       |    1 +
 tools/Makefile.in |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 52441f1..e0a30f3 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -59,6 +59,7 @@ liblvm: lib
 daemons: lib libdaemon tools
 tools: lib libdaemon device-mapper
 po: tools daemons
+man: tools
 scripts: liblvm libdm
 
 lib.device-mapper: include.device-mapper
diff --git a/tools/Makefile.in b/tools/Makefile.in
index ed359ea..9e1ccba 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -175,8 +175,6 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
 		$(EGREP) -v '^ *(|#.*|config|devtypes|dumpconfig|formats|fullreport|help|lastlog|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
-.DELETE_ON_ERROR:
-
 command-count.h: $(srcdir)/command-lines.in Makefile
 	set -o pipefail && \
 	( cat $(top_srcdir)/doc/license.txt && \
@@ -204,6 +202,7 @@ command-lines-input.h: $(srcdir)/command-lines.in Makefile
 	) > $@
 
 $(SOURCES:%.c=%.d) $(SOURCES2:%.c=%.d): command-lines-input.h command-count.h cmds.h
+$(SOURCES:%.c=%.o) $(SOURCES2:%.c=%.o): command-lines-input.h command-count.h cmds.h
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))


