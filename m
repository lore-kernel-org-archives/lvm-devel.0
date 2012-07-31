From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 31 Jul 2012 09:49:22 +0000 (UTC)
Subject: master - lvmetad: Fix an obscure error message.
Message-ID: <20120731094922.60A6330E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8791d01fee7f5977b037400020db97a40821b94a
Commit:        8791d01fee7f5977b037400020db97a40821b94a
Parent:        e0c2211c34f49784e30c6001b383e5a493d991a5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 31 11:43:35 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jul 31 11:43:35 2012 +0200

lvmetad: Fix an obscure error message.

---
 daemons/lvmetad/lvmetad-core.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index d41a905..0b0ec73 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -918,8 +918,7 @@ static response pv_found(lvmetad_state *s, request r)
 		else {
 			unlock_vg(s, vgid);
 			return daemon_reply_simple("failed", "reason = %s",
-// FIXME provide meaningful-to-user error message
-						   "internal treason!", NULL);
+						   "non-orphan VG without metadata encountered", NULL);
 		}
 		unlock_vg(s, vgid);
 	}


