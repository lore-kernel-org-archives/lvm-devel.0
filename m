From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:25:51 +0000 (UTC)
Subject: dev-mornfall-activate - pvscan: missing test for id_read_format
Message-ID: <20130604192551.BB8156115D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dacc340cc89e9be5cb88986a444466edb3a06e52
Commit:        dacc340cc89e9be5cb88986a444466edb3a06e52
Parent:        f319a61e9c374bd3277deba90216f67fdcb505e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 29 12:34:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 15:42:44 2013 +0200

pvscan: missing test for id_read_format

(in release fix)
---
 tools/pvscan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index ab58c5f..7c55faa 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -103,7 +103,9 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	if (partial)
 		return 1;
 
-	id_read_format(&vgid_raw, vgid);
+	if (!id_read_format(&vgid_raw, vgid))
+		return_0;
+
 	/* NB. This is safe because we know lvmetad is running and we won't hit
 	 * disk. */
 	if (!(vg = vg_read_internal(cmd, NULL, (const char *) &vgid_raw, 0, &consistent)))


