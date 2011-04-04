From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 4 Apr 2011 16:11:11 -0000
Subject: LVM2/daemons/dmeventd .exported_symbols dmeven ...
Message-ID: <20110404161111.11125.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-04-04 16:11:10

Modified files:
	daemons/dmeventd: .exported_symbols dmeventd.c dmeventd.h 
	                  libdevmapper-event.c libdevmapper-event.h 

Log message:
	Add rudimentary versioning to the dmevend protocol, allowing us to detect the
	(protocol) version of the running dmeventd on the client side.
	
	Right now this is only used in dmeventd -R.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/.exported_symbols.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/daemons/dmeventd/.exported_symbols	2010/10/20 15:12:12	1.11
+++ LVM2/daemons/dmeventd/.exported_symbols	2011/04/04 16:11:09	1.12
@@ -1,3 +1,4 @@
 init_fifos
 fini_fifos
 daemon_talk
+dm_event_get_version
--- LVM2/daemons/dmeventd/dmeventd.c	2011/03/29 21:53:46	1.79
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/04/04 16:11:09	1.80
@@ -1424,8 +1424,9 @@
 		ret = 0;
 		answer = msg->data;
 		if (answer) {
-			msg->size = dm_asprintf(&(msg->data), "%s %s", answer,
-						msg->cmd == DM_EVENT_CMD_DIE ? "DYING" : "HELLO");
+			msg->size = dm_asprintf(&(msg->data), "%s %s %d", answer,
+						msg->cmd == DM_EVENT_CMD_DIE ? "DYING" : "HELLO",
+                                                DM_EVENT_PROTOCOL_VERSION);
 			dm_free(answer);
 		} else {
 			msg->size = 0;
@@ -1704,6 +1705,7 @@
 	int i, count = 0;
 	char *message;
 	int length;
+	int version;
 
 	/* Get the list of registrations from the running daemon. */
 
@@ -1712,12 +1714,19 @@
 		return;
 	}
 
-	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0)) {
+	if (!dm_event_get_version(&fifos, &version)) {
 		fprintf(stderr, "WARNING: Could not communicate with existing dmeventd.\n");
 		fini_fifos(&fifos);
 		return;
 	}
 
+	if (version < 1) {
+		fprintf(stderr, "WARNING: The running dmeventd instance is too old.\n"
+			        "Protocol version %d (required: 1). Action cancelled.\n",
+			        version);
+		exit(EXIT_FAILURE);
+	}
+
 	if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_GET_STATUS, "-", "-", 0, 0)) {
 		exit(EXIT_FAILURE);
 	}
--- LVM2/daemons/dmeventd/dmeventd.h	2011/01/17 19:02:44	1.8
+++ LVM2/daemons/dmeventd/dmeventd.h	2011/04/04 16:11:09	1.9
@@ -69,5 +69,6 @@
 		enum dm_event_mask evmask, uint32_t timeout);
 int init_fifos(struct dm_event_fifos *fifos);
 void fini_fifos(struct dm_event_fifos *fifos);
+int dm_event_get_version(struct dm_event_fifos *fifos, int *version);
 
 #endif /* __DMEVENTD_DOT_H__ */
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2011/03/01 20:17:56	1.40
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2011/04/04 16:11:09	1.41
@@ -782,6 +782,36 @@
 	return ret;
 }
 
+/*
+ * You can (and have to) call this at the stage of the protocol where
+ *     daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0)
+ *
+ * would be normally sent. This call will parse the version reply from
+ * dmeventd, in addition to above call. It is not safe to call this@any
+ * other place in the protocol.
+ *
+ * This is an internal function, not exposed in the public API.
+ */
+
+int dm_event_get_version(struct dm_event_fifos *fifos, int *version) {
+	char *p;
+	struct dm_event_daemon_message msg = { 0, 0, NULL };
+
+	if (daemon_talk(fifos, &msg, DM_EVENT_CMD_HELLO, NULL, NULL, 0, 0))
+		return 0;
+	p = msg.data;
+	*version = 0;
+
+	p = strchr(p, ' ') + 1; /* Message ID */
+        if (!p) return 0;
+	p = strchr(p, ' ') + 1; /* HELLO */
+        if (!p) return 0;
+	p = strchr(p, ' '); /* HELLO, once more */
+	if (p)
+		*version = atoi(p);
+	return 1;
+}
+
 #if 0				/* left out for now */
 
 static char *_skip_string(char *src, const int delimiter)
--- LVM2/daemons/dmeventd/libdevmapper-event.h	2010/08/16 22:54:36	1.15
+++ LVM2/daemons/dmeventd/libdevmapper-event.h	2011/04/04 16:11:09	1.16
@@ -46,6 +46,7 @@
 };
 
 #define DM_EVENT_ALL_ERRORS DM_EVENT_ERROR_MASK
+#define DM_EVENT_PROTOCOL_VERSION 1
 
 struct dm_event_handler;
 


