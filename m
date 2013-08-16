From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 16 Aug 2013 14:26:13 +0000 (UTC)
Subject: master - dmsetup: display any message output from kernel
Message-ID: <20130816142613.EA99160FC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8b781e8ab9be0e54fa68834398bc42ce9465ba0
Commit:        d8b781e8ab9be0e54fa68834398bc42ce9465ba0
Parent:        cac49725c9a2a1f5c0e48235a07f168d98458ace
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 16 15:25:39 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 16 15:25:39 2013 +0100

dmsetup: display any message output from kernel

Recent kernels allow messages to respond with a string.
Add dm_task_get_message_response() to libdevmapper to perform some
basic sanity checks and return this.
Have 'dmsetup message' display any response.

DM statistics will make extensive use of this.

(From Mikulas.)
---
 WHATS_NEW_DM              |    2 ++
 libdm/ioctl/libdm-iface.c |   26 +++++++++++++++++++++++++-
 libdm/libdevmapper.h      |    1 +
 tools/dmsetup.c           |    8 ++++++++
 4 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 67b7d46..3995187 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.80 - 
 ==================================
+  Display any output returned by 'dmsetup message'.
+  Add dm_task_get_message_response to libdevmapper.
 
 Version 1.02.79 - 13th August 2013
 ==================================
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index b6f9d09..b0a2228 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -700,6 +700,29 @@ struct dm_versions *dm_task_get_versions(struct dm_task *dmt)
 				       dmt->dmi.v4->data_start);
 }
 
+const char *dm_task_get_message_response(struct dm_task *dmt)
+{
+	const char *start, *end;
+
+	if (!(dmt->dmi.v4->flags & DM_DATA_OUT_FLAG))
+		return NULL;
+
+	start = (const char *) dmt->dmi.v4 + dmt->dmi.v4->data_start;
+	end = (const char *) dmt->dmi.v4 + dmt->dmi.v4->data_size;
+
+	if (end < start) {
+		log_error(INTERNAL_ERROR "Corrupted message structure returned: start %d > end %d", (int)dmt->dmi.v4->data_start, (int)dmt->dmi.v4->data_size);
+		return NULL;
+	}
+
+	if (!memchr(start, 0, end - start)) {
+		log_error(INTERNAL_ERROR "Message response doesn't contain terminating NUL character");
+		return NULL;
+	}
+
+	return start;
+}
+
 int dm_task_set_ro(struct dm_task *dmt)
 {
 	dmt->read_only = 1;
@@ -1867,6 +1890,7 @@ repeat_ioctl:
 		case DM_DEVICE_STATUS:
 		case DM_DEVICE_TABLE:
 		case DM_DEVICE_WAITEVENT:
+		case DM_DEVICE_TARGET_MSG:
 			_ioctl_buffer_double_factor++;
 			_dm_zfree_dmi(dmi);
 			goto repeat_ioctl;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0b03eaf..b287eef 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -187,6 +187,7 @@ const char *dm_task_get_uuid(const struct dm_task *dmt);
 
 struct dm_deps *dm_task_get_deps(struct dm_task *dmt);
 struct dm_versions *dm_task_get_versions(struct dm_task *dmt);
+const char *dm_task_get_message_response(struct dm_task *dmt);
 
 /*
  * These functions return device-mapper names based on the value
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8f6b340..01f49c3 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -770,6 +770,7 @@ static int _message(CMD_ARGS)
 	size_t sz = 1;
 	struct dm_task *dmt;
 	char *str;
+	const char *response;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
 		return 0;
@@ -826,6 +827,13 @@ static int _message(CMD_ARGS)
 	if (!dm_task_run(dmt))
 		goto out;
 
+	if ((response = dm_task_get_message_response(dmt))) {
+		if (!*response || response[strlen(response) - 1] == '\n')
+			fputs(response, stdout);
+		else
+			puts(response);
+	}
+
 	r = 1;
 
       out:


