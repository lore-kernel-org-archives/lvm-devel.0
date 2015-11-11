From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Nov 2015 18:57:34 +0000 (UTC)
Subject: master - dmeventd: fix check for failing open.
Message-ID: <20151111185734.8446F60334@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=058725c72149e9f852390ca1d52e932ddb745a82
Commit:        058725c72149e9f852390ca1d52e932ddb745a82
Parent:        1e729c47d2cdc6591a41f159f84be39ffcc6c200
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 11 19:54:08 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 11 19:54:55 2015 +0100

dmeventd: fix check for failing open.

Recent change 2c8d6f5c90d5be62b48ba2881f2a6631091dc5af
actually droped restart when the reason of failing open is missing
device completely - check for ENOENT now as another reason
to start new dmeventd server  (when there is no systemd to maintain it).
---
 daemons/dmeventd/libdevmapper-event.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 359dfdd..f1441f5 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -425,7 +425,7 @@ static int _start_daemon(char *dmeventd_path, struct dm_event_fifos *fifos)
 		if (close(fifos->client))
 			log_sys_debug("close", fifos->client_path);
 		return 1;
-	} else if (errno != ENXIO) {
+	} else if (errno != ENXIO && errno != ENOENT)  {
 		/* problem */
 		log_sys_error("open", fifos->client_path);
 		return 0;


