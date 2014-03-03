From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Mar 2014 10:24:52 +0000 (UTC)
Subject: master - lvmetad: fix minor gcc warning
Message-ID: <20140303102452.29F3E61370@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a92fae079be1486302343443a813df9ec5bfd2ff
Commit:        a92fae079be1486302343443a813df9ec5bfd2ff
Parent:        445c0a5585e196e29cfaef1447e3729ae925751f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 2 22:26:21 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 3 11:23:32 2014 +0100

lvmetad: fix minor gcc warning

Cast to pass in non-const pointer
---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index f1fb749..2bbf9e4 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -961,7 +961,7 @@ out_of_mem:
 		lock_vg(s, vgid_old);
 		vg_remove_if_missing(s, vgid_old, 1);
 		unlock_vg(s, vgid_old);
-		dm_free(vgid_old);
+		dm_free((char*)vgid_old);
 	}
 
 	return daemon_reply_simple("OK",


