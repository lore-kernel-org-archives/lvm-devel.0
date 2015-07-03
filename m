From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  3 Jul 2015 15:58:55 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150703155855.04C5860EA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36ce97c6250a513c73e388261ccb376cd351e11f
Commit:        36ce97c6250a513c73e388261ccb376cd351e11f
Parent:        3dbb9a57ca684271dbbc26300aa2e35da9608aa3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 3 16:34:40 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 3 16:34:40 2015 +0100

pre-release

---
 VERSION                              |    2 +-
 VERSION_DM                           |    2 +-
 WHATS_NEW                            |    5 +++--
 WHATS_NEW_DM                         |    4 ++--
 daemons/lvmlockd/lvmlockctl.c        |   11 ++++++++++-
 daemons/lvmlockd/lvmlockd-client.h   |    4 ++--
 daemons/lvmlockd/lvmlockd-core.c     |    2 +-
 daemons/lvmlockd/lvmlockd-dlm.c      |    2 +-
 daemons/lvmlockd/lvmlockd-internal.h |    4 ++--
 daemons/lvmlockd/lvmlockd-sanlock.c  |    3 +--
 lib/locking/lvmlockd.c               |    3 +--
 lib/locking/lvmlockd.h               |    7 +++----
 12 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/VERSION b/VERSION
index a75fbd2..48674ea 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.124(2)-git (2015-06-30)
+2.02.124(2)-git (2015-07-03)
diff --git a/VERSION_DM b/VERSION_DM
index 5c2fe02..61632f7 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.101-git (2015-06-30)
+1.02.101-git (2015-07-03)
diff --git a/WHATS_NEW b/WHATS_NEW
index 382f290..cec1980 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,9 @@
-Version 2.02.124 -
-=================================
+Version 2.02.124 - 3rd July 2015
+================================
   Move sending thin pool messages from resume to suspend phase.
   Report warning when pool is overprovisioned and not auto resized.
   Recognize free-form date/time values for lv_time field in selection criteria.
+  Added experimental lvmlockd with configure --enable-lvmlockd.
   Fix regression in select to match string fields if using synonyms (2.02.123).
   Fix regression when printing more lv names via display_lvname (2.02.122).
   Add missing error logging to unlock_vg and sync_local_dev_names callers.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f4537d9..0e3b648 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.101 -
-=================================
+Version 1.02.101 - 3rd July 2015
+================================
   Add experimental support to passing messages in suspend tree.
   Add dm_report_value_cache_{set,get} to support caching during report/select.
   Add dm_report_reserved_handler to handle report reserved value actions.
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index b8ab9ed..9349ced 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -1,3 +1,13 @@
+/*
+ * Copyright (C) 2014-2015 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+
 #define _GNU_SOURCE
 #include "configure.h"
 #include "lvmlockd-client.h"
@@ -632,4 +642,3 @@ out:
 	lvmlockd_close(_lvmlockd);
 	return rv;
 }
-
diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index 0a3e4b2..e1d69d2 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2014 Red Hat, Inc.
+ * Copyright (C) 2014-2015 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -46,4 +46,4 @@ static inline void lvmlockd_close(daemon_handle h)
 #define EPREPARE  215
 #define ELOCKD    216
 
-#endif
+#endif	/* _LVM_LVMLOCKD_CLIENT_H */
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index d058ea1..87daaaf 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2014 Red Hat, Inc.
+ * Copyright (C) 2014-2015 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 5542968..4b4f433 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2014 Red Hat, Inc.
+ * Copyright (C) 2014-2015 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 54d0a05..f1aaa7e 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2014 Red Hat, Inc.
+ * Copyright (C) 2014-2015 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -370,4 +370,4 @@ void log_level(int level, const char *fmt, ...)  __attribute__((format(printf, 2
 #define log_error(fmt, args...) log_level(LOG_ERR, fmt, ##args)
 #define log_warn(fmt, args...) log_level(LOG_WARNING, fmt, ##args)
 
-#endif
+#endif	/* _LVM_LVMLOCKD_INTERNAL_H */
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 8f3ecff..5a31edd 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2014 Red Hat, Inc.
+ * Copyright (C) 2014-2015 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -1713,4 +1713,3 @@ int lm_is_running_sanlock(void)
 		return 0;
 	return 1;
 }
-
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 55a64a1..5d0cc07 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2014 Red Hat, Inc.
+ * Copyright (C) 2014-2015 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -2585,4 +2585,3 @@ int lockd_lv_uses_lock(struct logical_volume *lv)
 		return 0;
 	return 1;
 }
-
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 17c7222..2bd2fcc 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2014 Red Hat, Inc.
+ * Copyright (C) 2014-2015 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
@@ -233,7 +233,6 @@ static inline int lockd_lv_uses_lock(struct logical_volume *lv)
 	return 0;
 }
 
-#endif /* LVMLOCKD_SUPPORT */
-
-#endif
+#endif	/* LVMLOCKD_SUPPORT */
 
+#endif	/* _LVMLOCKD_H */


