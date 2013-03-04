From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 4 Mar 2013 18:33:17 -0500 (EST)
Subject: [PATCH] libdm: free memory when setting new values
Message-ID: <Pine.LNX.4.64.1303041832550.621@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

libdm: free memory when setting new values

This is needed so that dm_task can be reused for multiple requests.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 libdm/ioctl/libdm-iface.c |    3 +++
 libdm/libdm-common.c      |    1 +
 2 files changed, 4 insertions(+)

Index: lvm2-copy/libdm/ioctl/libdm-iface.c
===================================================================
--- lvm2-copy.orig/libdm/ioctl/libdm-iface.c	2013-03-04 14:42:27.000000000 +0100
+++ lvm2-copy/libdm/ioctl/libdm-iface.c	2013-03-04 23:37:07.000000000 +0100
@@ -762,6 +762,7 @@ int dm_task_set_newuuid(struct dm_task *
 		newuuid = mangled_uuid;
 	}
 
+	dm_free(dmt->newname);
 	if (!(dmt->newname = dm_strdup(newuuid))) {
 		log_error("dm_task_set_newuuid: strdup(%s) failed", newuuid);
 		return 0;
@@ -773,6 +774,7 @@ int dm_task_set_newuuid(struct dm_task *
 
 int dm_task_set_message(struct dm_task *dmt, const char *message)
 {
+	dm_free(dmt->message);
 	if (!(dmt->message = dm_strdup(message))) {
 		log_error("dm_task_set_message: strdup failed");
 		return 0;
@@ -791,6 +793,7 @@ int dm_task_set_sector(struct dm_task *d
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads,
 			 const char *sectors, const char *start)
 {
+	dm_free(dmt->geometry);
 	if (dm_asprintf(&(dmt->geometry), "%s %s %s %s",
 			cylinders, heads, sectors, start) < 0) {
 		log_error("dm_task_set_geometry: sprintf failed");
Index: lvm2-copy/libdm/libdm-common.c
===================================================================
--- lvm2-copy.orig/libdm/libdm-common.c	2013-03-04 14:42:27.000000000 +0100
+++ lvm2-copy/libdm/libdm-common.c	2013-03-04 23:37:07.000000000 +0100
@@ -710,6 +710,7 @@ int dm_task_set_newname(struct dm_task *
 		newname = mangled_name;
 	}
 
+	dm_free(dmt->newname);
 	if (!(dmt->newname = dm_strdup(newname))) {
 		log_error("dm_task_set_newname: strdup(%s) failed", newname);
 		return 0;


