From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 Jan 2015 10:29:29 +0000 (UTC)
Subject: master - cleanup: for commit 7bcb3fb02d6aacc566871326c0d01c331497a5b2
Message-ID: <20150121102929.D97DB60D25@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=338d98be97428bd9202391abe705e7fe10ec5ce8
Commit:        338d98be97428bd9202391abe705e7fe10ec5ce8
Parent:        7bcb3fb02d6aacc566871326c0d01c331497a5b2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 21 11:28:58 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 21 11:29:12 2015 +0100

cleanup: for commit 7bcb3fb02d6aacc566871326c0d01c331497a5b2

---
 lib/metadata/lv.h |    1 -
 man/lvmthin.7.in  |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index cb5885d..4475085 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -91,7 +91,6 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
-uint32_t lv_error_when_full(const struct logical_volume *lv);
 char *lv_time_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_set_creation(struct logical_volume *lv,
diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index b2db5a7..86456a5 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -727,8 +727,7 @@ thin pool LV:
 
 .B lvchange --errorwhenfull {y|n} VG/ThinPoolLV
 
-The current setting can be displayed with the lvs -o+error_when_full
-command.
+The current setting can be displayed with the lvs -o+lv_when_full command.
 
 .B errorwhenfull n
 


