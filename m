From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:13 +0000 (UTC)
Subject: master - cleanup: typo in comment
Message-ID: <20151013140413.B0A59602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=362558cd66bc08f8a46ababef66f2df21e8bd6fc
Commit:        362558cd66bc08f8a46ababef66f2df21e8bd6fc
Parent:        09a8479cb70ea2761ebd6988926017aa13fc5f5d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 12 11:37:04 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:22:58 2015 +0200

cleanup: typo in comment

---
 libdm/libdm-targets.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index f22ad9c..166396c 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -82,7 +82,7 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		return_0;
 
 	if (!(s->raid_type = dm_pool_zalloc(mem, p - params)))
-		goto_bad; /* memory is freed went pool is destroyed */
+		goto_bad; /* memory is freed when pool is destroyed */
 
 	if (!(s->dev_health = dm_pool_zalloc(mem, i + 1)))
 		goto_bad;


