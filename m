From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:17:38 -0500
Subject: master - makefiles: local headers first
Message-ID: <201812141417.wBEEHcGi010329@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4801919b01de26df9c1940a997a54c47ca5fee5d
Commit:        4801919b01de26df9c1940a997a54c47ca5fee5d
Parent:        454024f9576e83dde7c2c2df9a201c3e680bd864
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 13:13:45 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:14:48 2018 +0100

makefiles: local headers first

---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index f52a65a..e52827b 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -309,7 +309,7 @@ LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)
 
 LIB_VERSION_APP := $(shell $(AWK) -F '[(). ]' '{printf "%s.%s",$$1,$$4}' $(top_srcdir)/VERSION)
 
-INCLUDES += -I$(top_srcdir) -I$(srcdir) -I$(top_builddir)/include
+INCLUDES += -I$(srcdir) -I$(top_srcdir) -I$(top_builddir)/include
 
 #VDO_INCLUDES=-I at VDO_INCLUDE@
 


