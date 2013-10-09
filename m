From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Oct 2013 08:07:21 +0000 (UTC)
Subject: master - cleanup: remove 'discards 'const' qualifier' compilation warning
Message-ID: <20131009080721.1374C61007@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7c73154ea4f751cfd7e72162d355844993d72fa
Commit:        a7c73154ea4f751cfd7e72162d355844993d72fa
Parent:        808a5d945e3af27c7e79093f38d2dbe8370fee39
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 9 10:05:02 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 9 10:05:02 2013 +0200

cleanup: remove 'discards 'const' qualifier' compilation warning

---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index cfbf279..b7a3023 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -796,7 +796,7 @@ static response pv_gone(lvmetad_state *s, request r)
 
 	pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, pvid);
 	pvid_old = dm_hash_lookup_binary(s->device_to_pvid, &device, sizeof(device));
-	const char *vgid = dm_strdup(dm_hash_lookup(s->pvid_to_vgid, pvid));
+	char *vgid = dm_strdup(dm_hash_lookup(s->pvid_to_vgid, pvid));
 
 	if (!vgid) {
 		unlock_pvid_to_pvmeta(s);


