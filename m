From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 12 Aug 2015 14:13:45 +0000 (UTC)
Subject: master - libdm: add dm_timestamp_copy()
Message-ID: <20150812141345.BD66660FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99f55abc56bf1ce6b6f0e7d9cae67e347ace16b2
Commit:        99f55abc56bf1ce6b6f0e7d9cae67e347ace16b2
Parent:        c2d814e78d17320a557c1c0fe40440cda896ea2d
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 7 13:09:56 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Aug 12 15:09:57 2015 +0100

libdm: add dm_timestamp_copy()

---
 libdm/.exported_symbols.DM_1_02_104 |    1 +
 libdm/libdevmapper.h                |    5 +++++
 libdm/libdm-timestamp.c             |    5 +++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index 712fcf2..411ab2a 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -72,6 +72,7 @@ dm_task_get_ioctl_timestamp
 dm_task_set_record_timestamp
 dm_timestamp_alloc
 dm_timestamp_compare
+dm_timestamp_copy
 dm_timestamp_delta
 dm_timestamp_destroy
 dm_timestamp_get
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 18df90a..192fd0f 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2183,6 +2183,11 @@ struct dm_timestamp *dm_timestamp_alloc(void);
 int dm_timestamp_get(struct dm_timestamp *ts);
 
 /*
+ * Copy a timestamp from ts_old to ts_new.
+ */
+void dm_timestamp_copy(struct dm_timestamp *ts_new, struct dm_timestamp *ts_old);
+
+/*
  * Compare two timestamps.
  *
  * Return: -1 if ts1 is less than ts2
diff --git a/libdm/libdm-timestamp.c b/libdm/libdm-timestamp.c
index fe006d5..3e01442 100644
--- a/libdm/libdm-timestamp.c
+++ b/libdm/libdm-timestamp.c
@@ -168,6 +168,11 @@ uint64_t dm_timestamp_delta(struct dm_timestamp *ts1, struct dm_timestamp *ts2)
 	return t2 - t1;
 }
 
+void dm_timestamp_copy(struct dm_timestamp *ts_new, struct dm_timestamp *ts_old)
+{
+	*ts_new = *ts_old;
+}
+
 void dm_timestamp_destroy(struct dm_timestamp *ts)
 {
 	dm_free(ts);


