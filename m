From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:17:26 -0500
Subject: master - makefiles: correct libdm dependency
Message-ID: <201812141417.wBEEHQDx010298@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f5bdd4d316c0651f170ba73eca244caf71d8e70
Commit:        0f5bdd4d316c0651f170ba73eca244caf71d8e70
Parent:        63b0f0dab8b9a86b5cae6592f8cbea2eac0b70a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 13:12:27 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:14:32 2018 +0100

makefiles: correct libdm dependency

Correcting dependency tracking for libdm internal files.
---
 libdm/make.tmpl.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 451ef94..c88505f 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -277,11 +277,11 @@ LIB_VERSION_LVM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir
 
 LIB_VERSION_DM := $(shell $(AWK) -F '.' '{printf "%s.%s",$$1,$$2}' $(top_srcdir)/VERSION_DM)
 
-INCLUDES += -I$(top_srcdir) -I$(srcdir) -I$(top_builddir)/include
+INCLUDES += -I$(srcdir) -I$(top_srcdir) -I$(top_builddir)/include
 
 
-DEPS = $(top_builddir)/make.tmpl $(top_srcdir)/VERSION \
-       $(top_builddir)/Makefile
+DEPS = $(top_builddir)/libdm/make.tmpl $(top_srcdir)/VERSION \
+       $(top_builddir)/libdm/Makefile
 
 OBJECTS = $(SOURCES:%.c=%.o) $(CXXSOURCES:%.cpp=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)


