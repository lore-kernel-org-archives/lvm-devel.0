From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 22 Apr 2015 14:38:16 +0000 (UTC)
Subject: master - make: let generate use the just built libdm
Message-ID: <20150422143816.2DF02602DF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=808f88f9f0db2f744c0f2517fa4aa4f7b9c138ec
Commit:        808f88f9f0db2f744c0f2517fa4aa4f7b9c138ec
Parent:        81d03b46b01de3f082e4dcd0eb9993c64be0686e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 22 09:35:50 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 22 09:37:56 2015 -0500

make: let generate use the just built libdm

---
 conf/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/Makefile.in b/conf/Makefile.in
index 33f91c4..5e8a0b5 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -27,10 +27,10 @@ include $(top_builddir)/make.tmpl
 .PHONY: install_conf install_localconf install_profiles
 
 generate:
-	$(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments --ignorelocal > example.conf.gen
+	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments --ignorelocal > example.conf.gen
 	cat example.conf.base example.conf.gen > example.conf.in
 	rm example.conf.gen
-	$(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments local > lvmlocal.conf.gen
+	LD_LIBRARY_PATH=$(top_builddir)/libdm:$(LD_LIBRARY_PATH) $(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments local > lvmlocal.conf.gen
 	cat lvmlocal.conf.base lvmlocal.conf.gen > lvmlocal.conf.in
 	rm lvmlocal.conf.gen
 


