From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 29 Mar 2017 18:39:28 -0400
Subject: master - tests: fix typo in makefile
Message-ID: <201703292239.v2TMdS11016014@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df86ee8c2198abfbc8429813614636511be66402
Commit:        df86ee8c2198abfbc8429813614636511be66402
Parent:        a66411bd7acd129a61f6b3dde4c8ac448e27e4c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 30 00:19:02 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 30 00:38:41 2017 +0200

tests: fix typo in makefile

Use properly $(SORT)
---
 test/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 3cb0f18..c399596 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -37,9 +37,9 @@ include $(top_builddir)/make.tmpl
 T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
-ALL := $(shell find -L $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) | sort)
+ALL := $(shell find -L $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) | $(SORT))
 comma = ,
-RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | ($SORT))
+RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | $(SORT))
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
 ifeq ("@BUILD_LVMETAD@", "yes")


