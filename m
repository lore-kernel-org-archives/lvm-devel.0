From: Jim Meyering <jim@meyering.net>
Date: Tue, 18 Sep 2007 15:03:58 +0200
Subject: RFC: testing framework
In-Reply-To: <20070917190424.GL18444@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Mon, 17 Sep 2007 20:04:24 +0100")
References: <87y7f9krex.fsf@rho.meyering.net> <87ejgxcxpn.fsf@rho.meyering.net>
	<20070917190424.GL18444@agk.fab.redhat.com>
Message-ID: <87sl5c6s75.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> On Mon, Sep 17, 2007 at 01:56:04PM +0200, Jim Meyering wrote:
>> +++ b/test/Makefile.in
>> @@ -0,0 +1,75 @@
>> +#TEST_OPTS=--verbose --debug
>> +SHELL_PATH ?= $(SHELL)
>> +TAR ?= $(TAR)
>> +RM ?= rm -f
>> +
>> +subdir := $(shell pwd|sed 's,.*/,,')
>> +
>> +srcdir = .
>> +top_srcdir = ..
>> +top_builddir = ..
>
> I'd prefer to see this handled consistently across all our Makefiles.
> Elsewhere we have srcdir = @srcdir@, for example.
>
>> +dmdir = $(abs_top_srcdir)/../device-mapper
>> +so_name = $(dmdir)/lib/ioctl/libdevmapper.so.1.02
>
> Please avoid the 1.02 hard-coding:-)
> (Include a symlink within the dm tree if you want at build time - maybe
> from lib/libdevmapper.so -> ioctl/libdevmapper.so.*)

I've just checked this in:

	Create a symlink, e.g., libdevmapper.so.1.02, in the build dir,
	alongside the .so file.  This helps build dynamically linked LVM.

	* lib/Makefile.in (VERSIONED_SHLIB): Define.
	* make.tmpl.in (TARGETS): Append $(VERSIONED_SHLIB).
	($(VERSIONED_SHLIB)): New rule.

Signed-off-by: Jim Meyering <jim@meyering.net>
---
 WHATS_NEW       |    1 +
 lib/Makefile.in |    1 +
 make.tmpl.in    |    8 ++++++--
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 87b8c0f..32b9680 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 1.02.23 - 
 ==================================
+  Create e.g., libdevmapper.so.1.02, in build dir alongside the .so file.
   Avoid static link failure with some SELinux libraries.
   Remove obsolete dmfs code from tree and update INSTALL.
 
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 9bf514d..1e0a017 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -41,6 +41,7 @@ ifeq ("@LIB_SUFFIX@","dylib")
 else
   LIB_SHARED = $(interface)/libdevmapper.so
 endif
+VERSIONED_SHLIB = $(interface)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION)
 
 DEFS += -DDEVICE_UID=@DEVICE_UID@ -DDEVICE_GID=@DEVICE_GID@ \
 	-DDEVICE_MODE=@DEVICE_MODE@
diff --git a/make.tmpl.in b/make.tmpl.in
index 9f0b091..1f4517a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -1,7 +1,7 @@
 # @configure_input@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004, 2007 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the device-mapper userspace tools.
 #
@@ -123,7 +123,7 @@ SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile)
 
-TARGETS += $(LIB_SHARED) $(LIB_STATIC)
+TARGETS += $(LIB_SHARED) $(LIB_STATIC) $(VERSIONED_SHLIB)
 
 all: $(SUBDIRS) $(TARGETS)
 
@@ -172,6 +172,10 @@ $(LIB_SHARED): $(OBJECTS) $(LDDEPS)
 	$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
 endif
 
+$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION): %.$(LIB_SUFFIX)
+	rm -f $@
+	$(LN_S) $< $@
+
 $(LIB_STATIC): $(OBJECTS)
 	$(RM) $@
 	$(AR) rs $@ $(OBJECTS)
-- 
1.5.3.1.19.gb5ef6-dirty


