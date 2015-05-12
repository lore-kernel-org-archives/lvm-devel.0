From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 May 2015 15:22:27 +0000 (UTC)
Subject: master - lvmpolld: dump cleanup
Message-ID: <20150512152227.20CA860F19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5cef7413fb63f42eadb9b1897194f5c2f07ef30
Commit:        d5cef7413fb63f42eadb9b1897194f5c2f07ef30
Parent:        8da7915222ecb8d9f6c1012caca3957e6c2306ca
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 12 17:05:45 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 12 17:17:07 2015 +0200

lvmpolld: dump cleanup

---
 daemons/lvmpolld/lvmpolld-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index a770f89..ede6fc2 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -713,7 +713,7 @@ static response dump_state(client_handle h, struct lvmpolld_state *ls, request r
 	buffer_append(b, "# Registered abort operations\n\n");
 	buffer_append(b, "abort {\n");
 	pdst_locked_dump(ls->id_to_pdlv_abort, b);
-	buffer_append(b, "}\n\n");
+	buffer_append(b, "}");
 
 	lvmpolld_global_unlock(ls);
 


