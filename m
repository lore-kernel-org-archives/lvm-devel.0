From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:41 +0100
Subject: [PATCH 09/23] Add test for errors in _setup_task
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <1647ec7c4651efc13dfc7125038082fcf7157765.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a11d918..2c2fc19 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -75,19 +75,22 @@ static struct dm_task *_setup_task(const char *name, const char *uuid,
 	if (!(dmt = dm_task_create(task)))
 		return_NULL;
 
-	if (name)
-		dm_task_set_name(dmt, name);
+	if (name && !dm_task_set_name(dmt, name))
+		goto_out;
 
-	if (uuid && *uuid)
-		dm_task_set_uuid(dmt, uuid);
+	if (uuid && *uuid && !dm_task_set_uuid(dmt, uuid))
+		goto_out;
 
-	if (event_nr)
-		dm_task_set_event_nr(dmt, *event_nr);
+	if (event_nr && !dm_task_set_event_nr(dmt, *event_nr))
+		goto_out;
 
-	if (major)
-		dm_task_set_major_minor(dmt, major, minor, 1);
+	if (major && !dm_task_set_major_minor(dmt, major, minor, 1))
+		goto_out;
 
 	return dmt;
+      out:
+	dm_task_destroy(dmt);
+	return NULL;
 }
 
 static int _info_run(const char *name, const char *dlid, struct dm_info *info,
-- 
1.7.3.4


