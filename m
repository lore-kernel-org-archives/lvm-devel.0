From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:16 +0000 (UTC)
Subject: master - lvmetad: require meta_lookup
Message-ID: <20151109092816.370A161102@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f66fe2c444a4a8c9dccf16ad8bf470a96de1305d
Commit:        f66fe2c444a4a8c9dccf16ad8bf470a96de1305d
Parent:        91bde0f4a105fb0d2ad8407b63942f2790447846
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:24:13 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

lvmetad: require meta_lookup

Coverity: do not call update_pvid_to_vgid() with
meta_lookup == NULL since it is dereferencing it.
---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1de2ad3..78af69b 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -931,7 +931,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 	unlock_vgid_to_metadata(s);
 
 	/* update_pvid_to_vgid will clear/free the pvid_to_vgid hash */
-	if (update_pvids)
+	if (update_pvids && meta_lookup)
 		update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
 
 	/* free the unmapped data */


