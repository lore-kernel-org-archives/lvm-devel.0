From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Jul 2015 13:43:11 +0000 (UTC)
Subject: master - tests: follow symlinks
Message-ID: <20150708134311.35AE2602F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e1f421a6d3a515a9720514bbcceb6789f96dd44
Commit:        6e1f421a6d3a515a9720514bbcceb6789f96dd44
Parent:        fd37eeddd6b3901da806d536f44d43070e4fb660
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 8 15:14:09 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 8 15:41:48 2015 +0200

tests: follow symlinks

If the srcdir itself is a symlink the find would not return expected
value. So support also this config and use -L.
---
 test/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index bba33db..72eb4e6 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -36,9 +36,9 @@ include $(top_builddir)/make.tmpl
 T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
-ALL := $(shell find $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) | sort)
+ALL := $(shell find -L $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) | sort)
 comma = ,
-RUN := $(shell find $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | sort)
+RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | sort)
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
 ifeq ("@BUILD_LVMETAD@", "yes")


