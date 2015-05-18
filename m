From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 May 2015 10:52:29 +0000 (UTC)
Subject: master - makefiles: use := for shell calls
Message-ID: <20150518105229.428CA60EEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bed578535f9f2442916ce7da060132233502bcb
Commit:        1bed578535f9f2442916ce7da060132233502bcb
Parent:        bf2b1986c20ca8fccaac0d328d3530dacf5e40f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 18 10:27:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 18 12:45:42 2015 +0200

makefiles: use := for shell calls

---
 test/Makefile.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index ecd510a..5b9d5ad 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -36,9 +36,9 @@ include $(top_builddir)/make.tmpl
 T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
-ALL = $(shell find $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) | sort)
+ALL := $(shell find $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) | sort)
 comma = ,
-RUN = $(shell find $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | sort)
+RUN := $(shell find $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | sort)
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
 ifeq ("@BUILD_LVMETAD@", "yes")
@@ -54,7 +54,7 @@ LVMPOLLD_UDEV_FLAVOUR = ,udev-lvmpolld,udev-cluster-lvmpolld,udev-lvmetad-lvmpol
 endif
 
 # Shell quote;
-SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
+SHELL_PATH_SQ := $(subst ','\'',$(SHELL_PATH))
 
 ifeq ("@UDEV_SYNC@", "yes")
 dm_udev_synchronisation = 1


