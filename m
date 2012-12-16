From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 16 Dec 2012 23:54:25 +0000 (UTC)
Subject: master - lvmetad: Fix a possible deadlock.
Message-ID: <20121216235425.9DA641292@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fae1a611d2f907aa23c237b9f84df5089d30f728
Commit:        fae1a611d2f907aa23c237b9f84df5089d30f728
Parent:        ed23da95b63308e11f8d680b189686a5d2d380d0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Dec 17 00:39:00 2012 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Dec 17 00:47:55 2012 +0100

lvmetad: Fix a possible deadlock.

If an update and a query were running in parallel, there was a slim but non-zero
chance of a deadlock due to (unnecessary) mutex nesting.
---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 4e02662..674ddea 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -671,8 +671,8 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 
 	lock_vgid_to_metadata(s);
 	old = dm_hash_lookup(s->vgid_to_metadata, _vgid);
-	lock_vg(s, _vgid);
 	unlock_vgid_to_metadata(s);
+	lock_vg(s, _vgid);
 
 	seq = dm_config_find_int(metadata, "metadata/seqno", -1);
 


