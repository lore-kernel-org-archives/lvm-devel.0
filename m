From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:12:40 -0500
Subject: master - makefiles: add missing srcdir
Message-ID: <201811292212.wATMCeOK016610@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4ddd756d6f0729d5f339b0165745cbf61d4ca931
Commit:        4ddd756d6f0729d5f339b0165745cbf61d4ca931
Parent:        98c21e98b2537d171d558363aaf6adeecc685aea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 29 22:52:10 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:05:43 2018 +0100

makefiles: add missing srcdir

---
 Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 2561e4b..85dfeac 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -173,7 +173,7 @@ endif
 endif
 
 # FIXME: Drop once top-level make is resolved
--include test/unit/Makefile
+-include $(top_srcdir)/test/unit/Makefile
 include $(top_srcdir)/device_mapper/Makefile
 include $(top_srcdir)/base/Makefile
 


