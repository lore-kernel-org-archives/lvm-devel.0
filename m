From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri,  4 Oct 2013 12:34:10 +0000 (UTC)
Subject: master - lvmetad: Fix vgname->vgid hash updates w/ duplicate VG names.
Message-ID: <20131004123410.46CF46132C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d03503a453f91cee09fb3a1664d2136d58ac751
Commit:        0d03503a453f91cee09fb3a1664d2136d58ac751
Parent:        a7ff7aee4f49015db03536bbaee13b9795d63e6c
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Oct 4 14:30:00 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Fri Oct 4 14:31:45 2013 +0200

lvmetad: Fix vgname->vgid hash updates w/ duplicate VG names.

---
 daemons/lvmetad/lvmetad-core.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 4f7bf59..e1ec5a8 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -753,8 +753,11 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 		  dm_hash_insert(s->vgid_to_vgname, vgid, cfgname) &&
 		  dm_hash_insert(s->vgname_to_vgid, name, (void*) vgid)) ? 1 : 0;
 
-	if (retval && oldname && strcmp(name, oldname))
-		dm_hash_remove(s->vgname_to_vgid, oldname);
+	if (retval && oldname && strcmp(name, oldname)) {
+		const char *vgid_prev = dm_hash_lookup(s->vgname_to_vgid, oldname);
+		if (vgid_prev && !strcmp(vgid_prev, vgid))
+			dm_hash_remove(s->vgname_to_vgid, oldname);
+	}
 
 	if (haveseq >= 0 && haveseq < seq)
 		dm_config_destroy(old);


