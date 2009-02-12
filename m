From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 12 Feb 2009 14:30:40 -0500
Subject: [PATCH 11/12] Add lvm_vgname_from_vgid() and lvm_get_vgids()
In-Reply-To: <1234467041-21522-11-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-2-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-3-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-4-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-5-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-6-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-7-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-8-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-9-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-10-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-11-git-send-email-dwysocha@redhat.com>
Message-ID: <1234467041-21522-12-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.c |   10 ++++++++++
 lib/lvm2.h |    7 ++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/lib/lvm2.c b/lib/lvm2.c
index c8c65ab..603669e 100644
--- a/lib/lvm2.c
+++ b/lib/lvm2.c
@@ -41,6 +41,16 @@ char *lvm_strerror(lvm_handle_t libh)
 	return strerror(libh->lvm_errno);
 }
 
+struct dm_list *lvm_get_vgids(lvm_handle_t libh)
+{
+	return get_vgids(libh->cmd, 0);
+}
+
+char *lvm_vgname_from_vgid(lvm_handle_t libh, const char *vgid)
+{
+	return vgname_from_vgid(libh->cmd->mem, vgid);
+}
+
 static int _vg_attribute_init(vg_t *vg)
 {
 	report_type_t report_type = VGS;
diff --git a/lib/lvm2.h b/lib/lvm2.h
index 92f60fc..77544a7 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,6 +17,7 @@
 
 #include <stdint.h>
 #include <fcntl.h>
+#include "libdevmapper.h"
 #include "lvm-types.h" /* needed for str_list */
 
 /*
@@ -97,4 +98,8 @@ void lvm_vg_close(vg_t *vg);
 int lvm_errno(lvm_handle_t libh);
 char *lvm_strerror(lvm_handle_t libh);
 mode_t lvm_vg_mode(vg_t *vg);
+
+char *lvm_vgname_from_vgid(lvm_handle_t libh, const char *vgid);
+struct dm_list *lvm_get_vgids(lvm_handle_t libh);
+
 #endif
-- 
1.6.0.6


