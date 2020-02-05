From: David Teigland <teigland@sourceware.org>
Date: Wed, 5 Feb 2020 16:56:39 -0500
Subject: stable-2.02 - lvmetad: fix heap memory leak
Message-ID: <17183.120020516563500309@us-mta-220.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bcf9556b8fcd16ad8997f80cc92785f295c66701
Commit:        bcf9556b8fcd16ad8997f80cc92785f295c66701
Parent:        a1f06e2faebfbc091b4bbb900398cda05264c753
Author:        wangjufeng <wangjufeng@huawei.com>
AuthorDate:    Wed Feb 5 13:39:39 2020 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 5 15:30:17 2020 -0600

lvmetad: fix heap memory leak

error could be reproduced by calling pvs periodically:
    #!/bin/bash
    while :
    do
        pvs
        sleep 1
    done

use top command to watch RES memory of lvmetad. After a few minutes,
its RES memory will grow for a few KB. Then stop calling pvs, while
its RES will not decrease.

This is because, when lvmetad make reponse for clent request, it
will malloc new chunk for s->vgid_to_metadata, while actually the
new chunk should be added to the reponse dm_config_tree, or it will
make the chunk list of s->vgid_to_metadata keep growing.

Signed-off-by: wangjufeng <wangjufeng@huawei.com>
Reviewed-by: liuzhiqiang <liuzhiqiang26@huawei.com>
Reviewed-by: guiyao <guiyao@huawei.com>
---
 daemons/lvmetad/lvmetad-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 2628022..76aa62c 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -730,7 +730,7 @@ static response vg_lookup(lvmetad_state *s, request r)
 	if (!(res.cft->root = n = dm_config_create_node(res.cft, "response")))
 		goto nomem_un;
 
-	if (!(n->v = dm_config_create_value(cft)))
+	if (!(n->v = dm_config_create_value(res.cft)))
 		goto nomem_un;
 
 	n->parent = res.cft->root;



