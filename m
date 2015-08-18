From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:01:45 +0000 (UTC)
Subject: master - cleanup: check pthread result codes
Message-ID: <20150818130145.8B9456072C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a3e17d603698967e5febb84036923dc7e8da674
Commit:        3a3e17d603698967e5febb84036923dc7e8da674
Parent:        40af31729fc3400809e618b5cb5b2ff7c116b6f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 13:42:52 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 15:00:08 2015 +0200

cleanup: check pthread result codes

---
 daemons/lvmpolld/lvmpolld-core.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index 1402373..7d2a98b 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -585,12 +585,16 @@ static int spawn_detached_thread(struct lvmpolld_lv *pdlv)
 	int r;
 	pthread_attr_t attr;
 
-	pthread_attr_init(&attr);
-	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
+	if (pthread_attr_init(&attr) != 0)
+		return 0;
+
+	if (pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED) != 0)
+		return 0;
 
 	r = pthread_create(&pdlv->tid, &attr, fork_and_poll, (void *)pdlv);
 
-	pthread_attr_destroy(&attr);
+	if (pthread_attr_destroy(&attr) != 0)
+		return 0;
 
 	return !r;
 }


