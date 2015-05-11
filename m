From: okozina <okozina@fedoraproject.org>
Date: Mon, 11 May 2015 17:08:50 +0000 (UTC)
Subject: master - lvmpolld: set use counters properly in lvmpolld_store
Message-ID: <20150511170850.EAACF60222@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5cfd7074afb03c4e34ced4008e0d706d9f4b36ba
Commit:        5cfd7074afb03c4e34ced4008e0d706d9f4b36ba
Parent:        5e0a8fa981d9e9d76be565482e4c0d225ff4cb60
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon May 11 14:19:11 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 11 19:08:00 2015 +0200

lvmpolld: set use counters properly in lvmpolld_store

set active_polling_count to zero in pdst_init fn
---
 daemons/lvmpolld/lvmpolld-data-utils.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-data-utils.c b/daemons/lvmpolld/lvmpolld-data-utils.c
index 92147df..0720718 100644
--- a/daemons/lvmpolld/lvmpolld-data-utils.c
+++ b/daemons/lvmpolld/lvmpolld-data-utils.c
@@ -203,6 +203,7 @@ struct lvmpolld_store *pdst_init(const char *name)
 		goto err_mutex;
 
 	pdst->name = name;
+	pdst->active_polling_count = 0;
 
 	return pdst;
 


