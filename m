From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 10 Feb 2014 13:53:21 +0000 (UTC)
Subject: master - libdevmapper-event: Print a deprecation warning for non-default plugins.
Message-ID: <20140210135321.D029C60643@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38457e1be9c3363126eadc3e04ae8b8780832668
Commit:        38457e1be9c3363126eadc3e04ae8b8780832668
Parent:        ed166a3b1d3290ad887d8f83c24a8d8877713d3c
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Mon Feb 10 14:51:14 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Mon Feb 10 14:52:59 2014 +0100

libdevmapper-event: Print a deprecation warning for non-default plugins.

---
 daemons/dmeventd/libdevmapper-event.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 1b5273d..db9200f 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -619,6 +619,13 @@ int dm_event_register_handler(const struct dm_event_handler *dmevh)
 
 	uuid = dm_task_get_uuid(dmt);
 
+	if (!strstr(dmevh->dso, "libdevmapper-event-lvm2thin.so") &&
+	    !strstr(dmevh->dso, "libdevmapper-event-lvm2snapshot.so") &&
+	    !strstr(dmevh->dso, "libdevmapper-event-lvm2mirror.so") &&
+	    !strstr(dmevh->dso, "libdevmapper-event-lvm2raid.so"))
+		log_warn("WARNING: %s: dmeventd plugins are deprecated", dmevh->dso);
+
+
 	if ((err = _do_event(DM_EVENT_CMD_REGISTER_FOR_EVENT, dmevh->dmeventd_path, &msg,
 			     dmevh->dso, uuid, dmevh->mask, dmevh->timeout)) < 0) {
 		log_error("%s: event registration failed: %s",


