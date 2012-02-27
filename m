From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:46:26 -0000
Subject: LVM2/daemons/dmeventd dmeventd.h libdevmapper- ...
Message-ID: <20120227114626.31697.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:46:26

Modified files:
	daemons/dmeventd: dmeventd.h libdevmapper-event.h 

Log message:
	Add FIXME for misuse in case of dm_event_mask enum.
	
	Using enum for bitmask is not proper solution here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/daemons/dmeventd/dmeventd.h	2011/04/04 16:11:09	1.9
+++ LVM2/daemons/dmeventd/dmeventd.h	2012/02/27 11:46:25	1.10
@@ -63,6 +63,7 @@
 #define EXIT_CHDIR_FAILURE       7
 
 /* Implemented in libdevmapper-event.c, but not part of public API. */
+// FIXME  misuse of bitmask as enum
 int daemon_talk(struct dm_event_fifos *fifos,
 		struct dm_event_daemon_message *msg, int cmd,
 		const char *dso_name, const char *dev_name,
--- LVM2/daemons/dmeventd/libdevmapper-event.h	2011/04/04 16:11:09	1.16
+++ LVM2/daemons/dmeventd/libdevmapper-event.h	2012/02/27 11:46:25	1.17
@@ -82,6 +82,7 @@
 /*
  * Specify mask for events to monitor.
  */
+// FIXME  misuse of bitmask as enum
 void dm_event_handler_set_event_mask(struct dm_event_handler *dmevh,
 				     enum dm_event_mask evmask);
 
@@ -91,6 +92,7 @@
 int dm_event_handler_get_major(const struct dm_event_handler *dmevh);
 int dm_event_handler_get_minor(const struct dm_event_handler *dmevh);
 int dm_event_handler_get_timeout(const struct dm_event_handler *dmevh);
+// FIXME  misuse of bitmask as enum
 enum dm_event_mask dm_event_handler_get_event_mask(const struct dm_event_handler *dmevh);
 
 /* FIXME Review interface (what about this next thing?) */
@@ -104,6 +106,7 @@
 
 /* Prototypes for DSO interface, see dmeventd.c, struct dso_data for
    detailed descriptions. */
+// FIXME  misuse of bitmask as enum
 void process_event(struct dm_task *dmt, enum dm_event_mask evmask, void **user);
 int register_device(const char *device_name, const char *uuid, int major, int minor, void **user);
 int unregister_device(const char *device_name, const char *uuid, int major,


