From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Feb 2010 12:29:01 -0500
Subject: [PATCH 5/8] Add tag_list_copy() supporting function inside lvm2app.
In-Reply-To: <1266427744-30327-5-git-send-email-dwysocha@redhat.com>
References: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-2-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-3-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-4-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1266427744-30327-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a supporting function to copy a list of internal tags to lvm2app list.
We need to put this here because of the lvm_str_list_t type which we export
in lvm2app.h.  If we didn't export this type, we could put this in the
internal library and use struct str_list.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/Makefile.in |    1 +
 liblvm/lvm_misc.c  |   43 +++++++++++++++++++++++++++++++++++++++++++
 liblvm/lvm_misc.h  |   29 +++++++++++++++++++++++++++++
 3 files changed, 73 insertions(+), 0 deletions(-)
 create mode 100644 liblvm/lvm_misc.c
 create mode 100644 liblvm/lvm_misc.h

diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index d9afc40..5e6dfd4 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -18,6 +18,7 @@ top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES =\
+	lvm_misc.c \
 	lvm_base.c \
 	lvm_lv.c \
 	lvm_pv.c \
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
new file mode 100644
index 0000000..f52c563
--- /dev/null
+++ b/liblvm/lvm_misc.c
@@ -0,0 +1,43 @@
+/*
+ * Copyright (C) 2008,2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lvm_misc.h"
+
+struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
+{
+	struct dm_list *list;
+	lvm_str_list_t *lsl;
+	struct str_list *sl;
+
+	if (!(list = dm_pool_zalloc(p, sizeof(*list)))) {
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(sl, tag_list) {
+		if (!(lsl = dm_pool_zalloc(p, sizeof(*lsl)))) {
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_lv_list.");
+			return NULL;
+		}
+		if (!(lsl->str = dm_pool_strdup(p, sl->str))) {
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_lv_list->str.");
+			return NULL;
+		}
+		dm_list_add(list, &lsl->list);
+	}
+	return list;
+}
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
new file mode 100644
index 0000000..1d73532
--- /dev/null
+++ b/liblvm/lvm_misc.h
@@ -0,0 +1,29 @@
+/*
+ * Copyright (C) 2008,2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#ifndef _LVM2APP_MISC_H
+#define _LVM2APP_MISC_H
+
+#include "lib.h"
+#include "lvm2app.h"
+#include "toolcontext.h"
+#include "metadata-exported.h"
+#include "archiver.h"
+#include "locking.h"
+#include "lvm-string.h"
+#include "lvmcache.h"
+#include "metadata.h"
+
+struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
+
+#endif
-- 
1.6.0.6


