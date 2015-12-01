From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Dec 2015 13:00:44 +0000 (UTC)
Subject: master - mirror: fix condition
Message-ID: <20151201130044.4557A60D28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68e2ea11a35b3c204aede9dce23ab99cdedcba32
Commit:        68e2ea11a35b3c204aede9dce23ab99cdedcba32
Parent:        86e7894ecceede2e4977cb9d8f39f5fa53e6f5ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 1 13:59:20 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 1 13:59:20 2015 +0100

mirror: fix condition

Recent patch tested wrong condition for error
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 68fe728..f3abb67 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -73,7 +73,7 @@ static int _get_mirror_event(struct dso_state *state, char *params)
 	unsigned i;
 	struct dm_status_mirror *ms;
 
-	if (dm_get_status_mirror(state->mem, params, &ms))
+	if (!dm_get_status_mirror(state->mem, params, &ms))
 		goto_out;
 
 	/* Check for bad mirror devices */


