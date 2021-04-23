From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:11 +0000 (GMT)
Subject: main - makefiles: add target for man-generator
Message-ID: <20210423210611.1BF743B08C2B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fccd6e034625dade9ca302f2fcd99eb32d90974f
Commit:        fccd6e034625dade9ca302f2fcd99eb32d90974f
Parent:        348c46c8fcc285b1c7495a3792f2c3b1c2939e8e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 13:49:52 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

makefiles: add target for man-generator

Add supporting target for recreating man-generator when dependencies needs it.
---
 man/Makefile.in | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/man/Makefile.in b/man/Makefile.in
index 7f4664b01..29afc776b 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -128,6 +128,10 @@ all_man: man
 
 $(MAN5) $(MAN7) $(MAN8) $(MAN8SO) $(MAN8DM) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS): Makefile
 
+$(MANGENERATOR):
+	@echo "    [MAKE] $<"
+	$(Q) $(MAKE) -C $(top_builddir) tools
+
 # Test whether or not the man page generator works
 $(TESTMAN): $(MANGENERATOR) Makefile
 	@echo "    [TSTMAN] $@"


