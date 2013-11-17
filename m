From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:27 +0000 (UTC)
Subject: master - metadata: Do not try to check vg_name of a NULL PV.
Message-ID: <20131117222627.3C10560DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1a63905d14cc73352b905c70cb4084b7e521e33
Commit:        e1a63905d14cc73352b905c70cb4084b7e521e33
Parent:        803f8ca7146c548c271c04d432a3c68726a0d37d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Mar 20 14:34:05 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:26 2013 +0100

metadata: Do not try to check vg_name of a NULL PV.

---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8571e0a..869d368 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1842,7 +1842,7 @@ struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 		}
 	}
 
-	if (!allow_orphan && is_orphan_vg(pv->vg_name)) {
+	if (pv && !allow_orphan && is_orphan_vg(pv->vg_name)) {
 		log_error("Physical volume %s not in a volume group", pv_name);
 		goto bad;
 	}


