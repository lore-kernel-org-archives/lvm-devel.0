From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Jun 2018 16:27:56 -0400
Subject: master - build: use internal libs for lvm2cmd
Message-ID: <201806112027.w5BKRucp030000@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e82b70e7399b20dd201e8d7fad182ce276596fb2
Commit:        e82b70e7399b20dd201e8d7fad182ce276596fb2
Parent:        9c7ee1e1c4e436060d3b1970c73084d41012f108
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 11 22:15:49 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 11 22:25:42 2018 +0200

build: use internal libs for lvm2cmd

---
 tools/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index 2dbd93b..9742842 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -177,7 +177,7 @@ liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 	$(Q) $(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
 		$(CFLAGS) $(CLDFLAGS) -o $@ \
 		@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@ \
-		$(LVMLIBS) $(LIBS)
+		$(LVMLIBS) $(INTERNAL_LIBS) $(LIBS)
 
 liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 	@echo "    [LN] $@"


