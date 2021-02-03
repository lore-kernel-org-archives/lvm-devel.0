From: David Teigland <teigland@sourceware.org>
Date: Wed,  3 Feb 2021 19:45:51 +0000 (GMT)
Subject: main - dm: add debugging to include table differences
Message-ID: <20210203194551.78EC03890437@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67d8fb1e83002f702f9c995ec96ffc723ea0d6ce
Commit:        67d8fb1e83002f702f9c995ec96ffc723ea0d6ce
Parent:        834cba000a68675909844865f56e77ab62c1943b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 3 13:44:10 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 3 13:44:10 2021 -0600

dm: add debugging to include table differences

When dm tables are reloaded, include log_debug info
that will show the details of why the reload is needed.
---
 device_mapper/ioctl/libdm-iface.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 8e7240673..1140798e6 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -1582,23 +1582,30 @@ static int _reload_with_suppression_v4(struct dm_task *dmt)
 			t2->params[len] = '\0';
 
 		if (t1->start != t2->start) {
-			log_debug("reload %u:%u start diff", task->major, task->minor);
+			log_debug("reload %u:%u diff start %llu %llu type %s %s", task->major, task->minor,
+				   (unsigned long long)t1->start, (unsigned long long)t2->start, t1->type, t2->type);
 			goto no_match;
 		}
 		if (t1->length != t2->length) {
-			log_debug("reload %u:%u length diff", task->major, task->minor);
+			log_debug("reload %u:%u diff length %llu %llu type %s %s", task->major, task->minor,
+				  (unsigned long long)t1->length, (unsigned long long)t2->length, t1->type, t2->type);
 			goto no_match;
 		}
 		if (strcmp(t1->type, t2->type)) {
-			log_debug("reload %u:%u type diff %s %s", task->major, task->minor, t1->type, t2->type);
+			log_debug("reload %u:%u diff type %s %s", task->major, task->minor, t1->type, t2->type);
 			goto no_match;
 		}
 		if (strcmp(t1->params, t2->params)) {
-			if (dmt->skip_reload_params_compare)
-				log_debug("reload %u:%u skip params ignore %s %s",
-					  task->major, task->minor, t1->params, t2->params);
-			else {
-				log_debug("reload %u:%u params diff", task->major, task->minor);
+			if (dmt->skip_reload_params_compare) {
+				log_debug("reload %u:%u diff params ignore for type %s",
+					  task->major, task->minor, t1->type);
+				log_debug("reload params1 %s", t1->params);
+				log_debug("reload params2 %s", t2->params);
+			} else {
+				log_debug("reload %u:%u diff params for type %s",
+					  task->major, task->minor, t1->type);
+				log_debug("reload params1 %s", t1->params);
+				log_debug("reload params2 %s", t2->params);
 				goto no_match;
 			}
 		}


