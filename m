From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Jan 2014 12:50:55 +0000 (UTC)
Subject: master - hosttags: add missing file to define "hosttags" cmd
Message-ID: <20140130125055.5598D6151A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c27e1503a6eed2faa2300e1b25c8910c6346eda5
Commit:        c27e1503a6eed2faa2300e1b25c8910c6346eda5
Parent:        7a9e7a57e37d6fbab2dcd3c03192fd092811756f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jan 30 13:49:47 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jan 30 13:49:47 2014 +0100

hosttags: add missing file to define "hosttags" cmd

---
 tools/hosttags.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/tools/hosttags.c b/tools/hosttags.c
new file mode 100644
index 0000000..11fa7ef
--- /dev/null
+++ b/tools/hosttags.c
@@ -0,0 +1,23 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc. All rights reserved.
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
+#include "tools.h"
+
+int hosttags(struct cmd_context *cmd, int argc __attribute__((unused)),
+	    char **argv __attribute__((unused)))
+{
+	display_hosttags(cmd);
+
+	return ECMD_PROCESSED;
+}


