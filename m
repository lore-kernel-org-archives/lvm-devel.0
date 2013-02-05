From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:44 +0000 (UTC)
Subject: master - report: leave empty report field for 0
Message-ID: <20130205134744.02124A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d445f371c7658969d6580748233dc33c3ba0453
Commit:        9d445f371c7658969d6580748233dc33c3ba0453
Parent:        15115b61c0893a4abc660b1625b96fb14d073993
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 13:59:15 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:32:37 2013 +0100

report: leave empty report field for 0

Since we do not support LVs with 0 size, use this value
as 'error' value for devices without origin, and leave this
field blank as in other cases.
---
 WHATS_NEW           |    1 +
 lib/report/report.c |    7 +++++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 84a3590..64b811e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Report blank field if the LV doesn't have an origin instead of 0.
   Do not take a free lv name argument for lvconvert --thinpool option.
   Avoid flushing thin pool when quering for transaction_id.
   Add internal function lv_layer() to obtain layer name for LV.
diff --git a/lib/report/report.c b/lib/report/report.c
index 1833458..5a4e4df 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -590,7 +590,10 @@ static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint64_t size;
 
-	size = lv_origin_size(lv);
+	if (!(size = lv_origin_size(lv))) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
 
 	return _size64_disp(rh, mem, field, &size, private);
 }


