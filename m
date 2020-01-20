From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 20 Jan 2020 08:49:51 -0500
Subject: stable-2.02 - base: Get Makefile from master
Message-ID: <90763.120012008494700165@us-mta-211.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=440ced192a5ae6d5fa7c191981abcdf59926e90b
Commit:        440ced192a5ae6d5fa7c191981abcdf59926e90b
Parent:        d20490f76dd5a82b5fe61adc1c4e8044593e1c98
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Jan 20 14:36:16 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Jan 20 14:48:58 2020 +0100

base: Get Makefile from master

---
 base/Makefile | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/base/Makefile b/base/Makefile
new file mode 100644
index 000000000..056ea5910
--- /dev/null
+++ b/base/Makefile
@@ -0,0 +1,38 @@
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This file is part of the device-mapper userspace tools.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU Lesser General Public License v.2.1.
+#
+# You should have received a copy of the GNU Lesser General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Uncomment this to build the simple radix tree.  You'll need to make clean too.
+# Comment to build the advanced radix tree.
+#base/data-struct/radix-tree.o: CFLAGS += -DSIMPLE_RADIX_TREE
+
+# NOTE: this Makefile only works as 'include' for toplevel Makefile
+#       which defined all top_* variables
+
+BASE_SOURCE=\
+	base/data-struct/radix-tree.c
+
+BASE_TARGET = base/libbase.a
+BASE_DEPENDS = $(BASE_SOURCE:%.c=%.d)
+BASE_OBJECTS = $(BASE_SOURCE:%.c=%.o)
+CLEAN_TARGETS += $(BASE_DEPENDS) $(BASE_OBJECTS) \
+	$(BASE_SOURCE:%.c=%.gcda) \
+	$(BASE_SOURCE:%.c=%.gcno) \
+	$(BASE_TARGET)
+
+$(BASE_TARGET): $(BASE_OBJECTS)
+	@echo "    [AR] $@"
+	$(Q) $(RM) $@
+	$(Q) $(AR) rsv $@ $(BASE_OBJECTS) > /dev/null
+
+ifeq ("$(DEPENDS)","yes")
+-include $(BASE_DEPENDS)
+endif



