From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  3 Apr 2013 11:49:33 +0000 (UTC)
Subject: master - lvmetad: Fix a memory leak introduced in 15fdd5c90dd.
Message-ID: <20130403114933.22F9F946@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95372a852bbcacc9f194324832b94fcf1493f7c5
Commit:        95372a852bbcacc9f194324832b94fcf1493f7c5
Parent:        382fc878d7be5252d7ad93f2740ee25bd500d53e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 3 13:46:12 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Apr 3 13:46:12 2013 +0200

lvmetad: Fix a memory leak introduced in 15fdd5c90dd.

---
 daemons/lvmetad/lvmetad-core.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index a789bad..bbad69c 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -756,6 +756,9 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 	if (retval && oldname && strcmp(name, oldname))
 		dm_hash_remove(s->vgname_to_vgid, oldname);
 
+	if (haveseq >= 0 && haveseq < seq)
+		dm_config_destroy(old);
+
 	unlock_vgid_to_metadata(s);
 
 	if (retval)


