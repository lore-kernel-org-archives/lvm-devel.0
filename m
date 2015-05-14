From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 13:02:02 +0000 (UTC)
Subject: master - makefiles: disable po file targes
Message-ID: <20150514130202.B6D7C6107C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64a999097747316dcfea8c8b7b91778aed56b585
Commit:        64a999097747316dcfea8c8b7b91778aed56b585
Parent:        a929606f2b5076f3cde546764664da4e39cefd56
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 14:18:36 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 14:19:40 2015 +0200

makefiles: disable po file targes

po targets are not correct - so disable them for now.
---
 po/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/po/Makefile.in b/po/Makefile.in
index ff5db17..96e932b 100644
--- a/po/Makefile.in
+++ b/po/Makefile.in
@@ -17,7 +17,7 @@ top_builddir = @top_builddir@
 
 LANGS=de
 
-TARGETS=$(LANGS:%=lvm2_%.mo) $(LANGS:%=dm_%.mo)
+#TARGETS=$(LANGS:%=lvm2_%.mo) $(LANGS:%=dm_%.mo)
 
 DM_POSOURCES = $(top_builddir)/tools/dmsetup.pot $(top_builddir)/libdm/*.pot \
 	       $(top_builddir)/libdm/*/*.pot


