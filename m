From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:41 +0000 (UTC)
Subject: master - cleanup: initilization of vars
Message-ID: <20140325102341.2790560F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db71739f429f9bd12c93c6686292399f007ce4a9
Commit:        db71739f429f9bd12c93c6686292399f007ce4a9
Parent:        5c9165705a3303d6ac98c828420566e01c2d128e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 09:19:56 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:58 2014 +0100

cleanup: initilization of vars

---
 daemons/dmeventd/libdevmapper-event.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 8775449..80d4420 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -688,7 +688,7 @@ static char *_fetch_string(char **src, const int delimiter)
 static int _parse_message(struct dm_event_daemon_message *msg, char **dso_name,
 			 char **uuid, enum dm_event_mask *evmask)
 {
-	char *id = NULL;
+	char *id;
 	char *p = msg->data;
 
 	if ((id = _fetch_string(&p, ' ')) &&
@@ -841,7 +841,7 @@ static char *_skip_string(char *src, const int delimiter)
 
 int dm_event_set_timeout(const char *device_path, uint32_t timeout)
 {
-	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	struct dm_event_daemon_message msg = { 0 };
 
 	if (!device_exists(device_path))
 		return -ENODEV;
@@ -853,7 +853,7 @@ int dm_event_set_timeout(const char *device_path, uint32_t timeout)
 int dm_event_get_timeout(const char *device_path, uint32_t *timeout)
 {
 	int ret;
-	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	struct dm_event_daemon_message msg = { 0 };
 
 	if (!device_exists(device_path))
 		return -ENODEV;


