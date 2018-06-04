From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 4 Jun 2018 10:38:41 -0400
Subject: master - build: base/Makefile
Message-ID: <201806041438.w54Ecf6O008610@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2eda683a205d1ad2463cf60d783bc63d9833717e
Commit:        2eda683a205d1ad2463cf60d783bc63d9833717e
Parent:        232918fb86e1ee254ae5e4c9aece4615d828c9bb
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Jun 4 15:37:35 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Jun 4 15:37:35 2018 +0100

build: base/Makefile

.gitignore hid it.
---
 base/Makefile |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/base/Makefile b/base/Makefile
new file mode 100644
index 0000000..27f539f
--- /dev/null
+++ b/base/Makefile
@@ -0,0 +1,29 @@
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
+BASE_SOURCE=\
+	base/data-struct/radix-tree.c \
+
+BASE_DEPENDS=$(addprefix $(top_builddir)/,$(subst .c,.d,$(BASE_SOURCE)))
+BASE_OBJECTS=$(addprefix $(top_builddir)/,$(subst .c,.o,$(BASE_SOURCE)))
+CLEAN_TARGETS+=$(BASE_DEPENDS) $(BASE_OBJECTS)
+
+-include $(BASE_DEPENDS)
+
+$(BASE_OBJECTS): INCLUDES+=-I$(top_srcdir)/base/
+
+$(top_builddir)/base/libbase.a: $(BASE_OBJECTS)
+	@echo "    [AR] $@"
+	$(Q) $(RM) $@
+	$(Q) $(AR) rsv $@ $(BASE_OBJECTS) > /dev/null
+
+CLEAN_TARGETS+=$(top_builddir)/base/libbase.a


