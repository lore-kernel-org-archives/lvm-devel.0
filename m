From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:28:07 +0000 (UTC)
Subject: master - cleanup: indent in devmapper-event
Message-ID: <20140430082807.946E460D93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cbdf63fdd21216af78077ae2d02ac307a3deec0a
Commit:        cbdf63fdd21216af78077ae2d02ac307a3deec0a
Parent:        b56aef1915c5cf5eddb8b415d204843fc1192812
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 13:21:15 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:30 2014 +0200

cleanup: indent in devmapper-event

Drop header inclusion - this file is already included.
Shorten code.
---
 daemons/dmeventd/libdevmapper-event.c |   27 ++++++++++++---------------
 1 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 57185b9..6b7338f 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -20,7 +20,6 @@
 #include <errno.h>
 #include <fcntl.h>
 #include <stdio.h>
-#include <stdint.h>
 #include <stdlib.h>
 #include <string.h>
 #include <sys/file.h>
@@ -57,7 +56,7 @@ static void _dm_event_handler_clear_dev_info(struct dm_event_handler *dmevh)
 
 struct dm_event_handler *dm_event_handler_create(void)
 {
-	struct dm_event_handler *dmevh = NULL;
+	struct dm_event_handler *dmevh;
 
 	if (!(dmevh = dm_zalloc(sizeof(*dmevh)))) {
 		log_error("Failed to allocate event handler.");
@@ -82,8 +81,7 @@ int dm_event_handler_set_dmeventd_path(struct dm_event_handler *dmevh, const cha
 
 	dm_free(dmevh->dmeventd_path);
 
-	dmevh->dmeventd_path = dm_strdup(dmeventd_path);
-	if (!dmevh->dmeventd_path)
+	if (!(dmevh->dmeventd_path = dm_strdup(dmeventd_path)))
 		return -ENOMEM;
 
 	return 0;
@@ -93,10 +91,10 @@ int dm_event_handler_set_dso(struct dm_event_handler *dmevh, const char *path)
 {
 	if (!path) /* noop */
 		return 0;
+
 	dm_free(dmevh->dso);
 
-	dmevh->dso = dm_strdup(path);
-	if (!dmevh->dso)
+	if (!(dmevh->dso = dm_strdup(path)))
 		return -ENOMEM;
 
 	return 0;
@@ -109,9 +107,9 @@ int dm_event_handler_set_dev_name(struct dm_event_handler *dmevh, const char *de
 
 	_dm_event_handler_clear_dev_info(dmevh);
 
-	dmevh->dev_name = dm_strdup(dev_name);
-	if (!dmevh->dev_name)
+	if (!(dmevh->dev_name = dm_strdup(dev_name)))
 		return -ENOMEM;
+
 	return 0;
 }
 
@@ -122,9 +120,9 @@ int dm_event_handler_set_uuid(struct dm_event_handler *dmevh, const char *uuid)
 
 	_dm_event_handler_clear_dev_info(dmevh);
 
-	dmevh->uuid = dm_strdup(uuid);
-	if (!dmevh->uuid)
+	if (!(dmevh->uuid = dm_strdup(uuid)))
 		return -ENOMEM;
+
 	return 0;
 }
 
@@ -691,7 +689,6 @@ static int _parse_message(struct dm_event_daemon_message *msg, char **dso_name,
 	    (*dso_name = _fetch_string(&p, ' ')) &&
 	    (*uuid = _fetch_string(&p, ' '))) {
 		*evmask = atoi(p);
-
 		dm_free(id);
 		return 0;
 	}
@@ -746,8 +743,8 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 		ret = -ENXIO; /* dmeventd probably gave us bogus uuid back */
 		goto fail;
 	}
-	dmevh->uuid = dm_strdup(reply_uuid);
-	if (!dmevh->uuid) {
+
+	if (!(dmevh->uuid = dm_strdup(reply_uuid))) {
 		ret = -ENOMEM;
 		goto fail;
 	}
@@ -766,8 +763,7 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 	dm_free(reply_uuid);
 	reply_uuid = NULL;
 
-	dmevh->dev_name = dm_strdup(dm_task_get_name(dmt));
-	if (!dmevh->dev_name) {
+	if (!(dmevh->dev_name = dm_strdup(dm_task_get_name(dmt)))) {
 		ret = -ENOMEM;
 		goto fail;
 	}
@@ -852,6 +848,7 @@ int dm_event_get_timeout(const char *device_path, uint32_t *timeout)
 
 	if (!device_exists(device_path))
 		return -ENODEV;
+
 	if (!(ret = _do_event(DM_EVENT_CMD_GET_TIMEOUT, &msg, NULL, device_path,
 			     0, 0))) {
 		char *p = _skip_string(msg.data, ' ');


