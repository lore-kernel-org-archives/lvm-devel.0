From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  9 Oct 2012 05:53:04 +0000 (UTC)
Subject: master - lvmetad: Fix a leak in an error path in update_metadata.
Message-ID: <20121009055304.5C6A6241E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=665b6b308e4482a33fc5dd67e1e12066515e1424
Commit:        665b6b308e4482a33fc5dd67e1e12066515e1424
Parent:        556d2c920aacb857377c6cfdb0fa3f6c50f6721b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 20:33:03 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 23:52:44 2012 +0200

lvmetad: Fix a leak in an error path in update_metadata.

---
 daemons/lvmetad/lvmetad-core.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1dc05d6..466042b 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -737,6 +737,8 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 
 	unlock_pvid_to_vgid(s);
 out:
+	if (!retval && cft)
+		dm_config_destroy(cft);
 	unlock_vg(s, _vgid);
 	return retval;
 }


