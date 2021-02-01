From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:41 +0000 (GMT)
Subject: main - lvconvert: ensure device_name is defined
Message-ID: <20210201114741.E20A23836C02@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9fa4c099fb036883ee4abec200406824687372b8
Commit:        9fa4c099fb036883ee4abec200406824687372b8
Parent:        a9fd207192fe81c1f89ca265c1fe0bcc54335694
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 21:45:05 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:13:49 2021 +0100

lvconvert: ensure device_name is defined

---
 tools/lvconvert.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 416e8a73a..e37172a5e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4283,7 +4283,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 	char format[NAME_LEN];
 	struct dm_list *use_pvh;
 	struct pv_list *pvl;
-	char *device_name;
+	const char *device_name = "";
 	struct device *dev_fast;
 	char *dev_argv[MAX_CACHEDEVS];
 	int dev_argc = 0;
@@ -4317,7 +4317,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 		if (!grouped_arg_is_set(group->arg_values, cachedevice_ARG))
 			continue;
 
-		if (!(device_name = (char *)grouped_arg_str_value(group->arg_values, cachedevice_ARG, NULL)))
+		if (!(device_name = grouped_arg_str_value(group->arg_values, cachedevice_ARG, NULL)))
 			break;
 
 		if (device_name[0] == '@') {
@@ -4366,7 +4366,7 @@ static int _lv_create_cachevol(struct cmd_context *cmd,
 			return 0;
 		}
 
-		dev_argv[dev_argc++] = device_name;
+		dev_argv[dev_argc++] = (char*)device_name;
 	}
 
 	if (!cache_size_sectors)


