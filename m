From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 Jul 2020 18:19:25 +0000 (GMT)
Subject: master - cachevol: generate a unique name when creating
Message-ID: <20200723181925.3156C3857C4E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=085760992dc68efbda8fe8e1ad4a5a2eccef9139
Commit:        085760992dc68efbda8fe8e1ad4a5a2eccef9139
Parent:        3c9177fdc0b8f94c0ae335790a485477901b685d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 23 13:07:32 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 23 13:18:22 2020 -0500

cachevol: generate a unique name when creating

When a cachevol is automatically created, if the default name
conflicts with an existing name, generate a new unique name.
---
 test/shell/cachevol-cachedevice.sh | 10 ++++++++++
 tools/lvconvert.c                  | 14 ++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/test/shell/cachevol-cachedevice.sh b/test/shell/cachevol-cachedevice.sh
index 11a37d9cd..3831ee9d4 100644
--- a/test/shell/cachevol-cachedevice.sh
+++ b/test/shell/cachevol-cachedevice.sh
@@ -208,5 +208,15 @@ lvchange -ay $vg/$lv1
 lvchange -an $vg/$lv1
 lvremove $vg/$lv1
 
+# if the cache name is used generate a new name
+lvcreate -n $lv1 -l8 -an $vg @slow
+lvcreate -n ${lv1}_cache -l1 -an $vg @slow
+lvconvert -y --type writecache --cachedevice @fast --cachesize 8M $vg/$lv1
+check lv_field $vg/$lv1 segtype writecache
+check lv_field $vg/${lv1}_cache0_cvol lv_size "8.00m"
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvremove $vg/$lv1
+
 vgremove -ff $vg
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b6505c1a9..524ed5a33 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4267,6 +4267,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 			       struct logical_volume **cachevol_lv)
 {
 	char cvname[NAME_LEN];
+	char format[NAME_LEN];
 	struct dm_list *use_pvh;
 	struct pv_list *pvl;
 	char *dev_name;
@@ -4373,6 +4374,19 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (find_lv(vg, cvname)) {
+		memset(format, 0, sizeof(cvname));
+		memset(cvname, 0, sizeof(cvname));
+		if (dm_snprintf(format, sizeof(format), "%s_cache%%d", lv->name) < 0) {
+			log_error("Failed to generate cachevol LV format.");
+			return 0;
+		}
+		if (!generate_lv_name(vg, format, cvname, sizeof(cvname))) {
+			log_error("Failed to generate cachevol LV name.");
+			return 0;
+		}
+	}
+
 	lp.lv_name = cvname;
 	lp.pvh = use_pvh;
 	lp.extents = cache_size_sectors / vg->extent_size;


