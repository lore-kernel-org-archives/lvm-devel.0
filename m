From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:51 +0000 (UTC)
Subject: dev-mornfall-lvmcache - metadata: Do not try to check vg_name of a NULL PV.
Message-ID: <20130605120551.164F360F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f49180ea7eb6d0464a9a85d58a56b4c7f9273b6
Commit:        0f49180ea7eb6d0464a9a85d58a56b4c7f9273b6
Parent:        eb2c68590b766e25ada9d425ad0b6602cd724fcc
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Mar 20 14:34:05 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:31:18 2013 +0200

metadata: Do not try to check vg_name of a NULL PV.

---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 62b5c3f..aea593a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1822,7 +1822,7 @@ struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 		}
 	}
 
-	if (!allow_orphan && is_orphan_vg(pv->vg_name)) {
+	if (pv && !allow_orphan && is_orphan_vg(pv->vg_name)) {
 		log_error("Physical volume %s not in a volume group", pv_name);
 		goto bad;
 	}


