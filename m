From: heinzm@redhat.com <heinzm@redhat.com>
Date: Fri, 26 Sep 2014 12:42:24 +0200
Subject: [PATCH] Return proper type from _raidsyncaction()
Message-ID: <1411728144-31025-1-git-send-email-heinzm@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Heinz Mauelshagen <heinzm@redhat.com>

Signed-off-by: Heinz Mauelshagen <heinzm@redhat.com>

---
 lib/report/properties.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index e0092db..0218108 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2010-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2010-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -71,7 +71,7 @@ static char *_raidsyncaction(const struct logical_volume *lv)
 	char *action;
 
 	if (!lv_raid_sync_action(lv, &action))
-		return 0;
+		return NULL;
 
 	return action;
 }
-- 
1.9.3


