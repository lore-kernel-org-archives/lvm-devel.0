From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 29 Jun 2015 07:45:54 +0000 (UTC)
Subject: master - cleanup: remove unused tags.c file
Message-ID: <20150629074554.B01A360300@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f143ad3a9340eb3c90fa37cf912ce163ad107e1a
Commit:        f143ad3a9340eb3c90fa37cf912ce163ad107e1a
Parent:        e29d4773f4de731d8483a12684d5f4b96092088b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 6 13:59:49 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 29 09:43:47 2015 +0200

cleanup: remove unused tags.c file

---
 lib/Makefile.in        |    1 -
 lib/format_text/tags.c |   21 ---------------------
 2 files changed, 0 insertions(+), 22 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 4a282eb..ffe18f0 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -82,7 +82,6 @@ SOURCES =\
 	format_text/format-text.c \
 	format_text/import.c \
 	format_text/import_vsn1.c \
-	format_text/tags.c \
 	format_text/text_label.c \
 	freeseg/freeseg.c \
 	label/label.c \
diff --git a/lib/format_text/tags.c b/lib/format_text/tags.c
deleted file mode 100644
index e22ca28..0000000
--- a/lib/format_text/tags.c
+++ /dev/null
@@ -1,21 +0,0 @@
-/*
- * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-#include "lib.h"
-#include "metadata.h"
-#include "import-export.h"
-#include "str_list.h"
-#include "lvm-string.h"
-


