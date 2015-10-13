From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:17 +0000 (UTC)
Subject: master - dmeventd: introduce macro for init
Message-ID: <20151013140417.D67E7602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9926e7e6c102319575c186e8eef0012cb9c36cc
Commit:        f9926e7e6c102319575c186e8eef0012cb9c36cc
Parent:        76ea01dd207ce185891418c3f8ffdcff14bf2672
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 12 11:37:36 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:56:03 2015 +0200

dmeventd: introduce macro for init

Simplify commonly used pool creation.
---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h |   34 +++++++++++++++++++++++++-
 1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h
index 5691c87..d193eda 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -39,4 +39,36 @@ struct dm_pool *dmeventd_lvm2_pool(void);
 int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
 			  const char *cmd, const char *device);
 
+#define dmeventd_lvm2_run_with_lock(cmdline) \
+	({\
+		int rc;\
+		dmeventd_lvm2_lock();\
+		rc = dmeventd_lvm2_run(cmdline);\
+		dmeventd_lvm2_unlock();\
+		rc;\
+	})
+
+#define dmeventd_lvm2_init_with_pool(name, st) \
+	({\
+		struct dm_pool *mem;\
+		st = NULL;\
+		if (dmeventd_lvm2_init()) {\
+			if ((mem = dm_pool_create(name, 2048)) &&\
+			    (st = dm_pool_zalloc(mem, sizeof(*st))))\
+				st->mem = mem;\
+			else {\
+				if (mem)\
+					dm_pool_destroy(mem);\
+				dmeventd_lvm2_exit();\
+			}\
+		}\
+		st;\
+	})
+
+#define dmeventd_lvm2_exit_with_pool(pool) \
+	do {\
+		dm_pool_destroy(pool->mem);\
+		dmeventd_lvm2_exit();\
+	} while(0)
+
 #endif /* _DMEVENTD_LVMWRAP_H */


