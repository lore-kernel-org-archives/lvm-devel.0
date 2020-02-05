From: wangjufeng <wangjufeng@huawei.com>
Date: Wed, 5 Feb 2020 13:12:50 +0000
Subject: stable-2.02 - lvmetadlvmetad: fix heap memory leak
Message-ID: <723608783F175343AAB90DD84928BC3405AD35F8@dggeml510-mbs.china.huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>From 00e750b9e645f7a7fab9ce464419c72bd8535df0 Mon Sep 17 00:00:00 2001
From: wangjufeng <wangjufeng@huawei.com>
Date: Wed, 5 Feb 2020 13:39:39 +0800
Subject: [PATCH] lvmetad: fix heap memory leak

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
index ef43b47..659d85c 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -730,7 +730,7 @@ static response vg_lookup(lvmetad_state *s, request r)
       if (!(res.cft->root = n = dm_config_create_node(res.cft, "response")))
                goto nomem_un;
-        if (!(n->v = dm_config_create_value(cft)))
+       if (!(n->v = dm_config_create_value(res.cft)))
                goto nomem_un;
        n->parent = res.cft->root;
--
1.8.3.1

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20200205/03a47f45/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvmetad-fix-heap-memory-leak.patch
Type: application/octet-stream
Size: 1485 bytes
Desc: lvmetad-fix-heap-memory-leak.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20200205/03a47f45/attachment.obj>
