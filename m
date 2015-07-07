From: okozina <okozina@fedoraproject.org>
Date: Tue,  7 Jul 2015 12:50:21 +0000 (UTC)
Subject: master - lvmpolld: fix possible memory corruption with mem debug
Message-ID: <20150707125021.8B56860EF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=088ee7618da48f473ab61b8e73f8d489b67a6900
Commit:        088ee7618da48f473ab61b8e73f8d489b67a6900
Parent:        a405b89555c8a525900d9d81a413cc240ff6c840
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Jul 7 14:03:15 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Jul 7 14:49:53 2015 +0200

lvmpolld: fix possible memory corruption with mem debug

if lvm2 is built with debug memory options dm_free() is not
mapped directly to std library's free(). This may cause memory corruption
as a line buffer may get reallocated in getline with realloc.

This is a temporary hotfix. Other debug memory failure needs to
be investigated and explained.
---
 daemons/lvmpolld/lvmpolld-data-utils.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-data-utils.c b/daemons/lvmpolld/lvmpolld-data-utils.c
index 0720718..f28bc51 100644
--- a/daemons/lvmpolld/lvmpolld-data-utils.c
+++ b/daemons/lvmpolld/lvmpolld-data-utils.c
@@ -325,6 +325,7 @@ struct lvmpolld_thread_data *lvmpolld_thread_data_constructor(struct lvmpolld_lv
 
 	data->pdlv = NULL;
 	data->line = NULL;
+	data->line_size = 0;
 	data->fout = data->ferr = NULL;
 	data->outpipe[0] = data->outpipe[1] = data->errpipe[0] = data->errpipe[1] = -1;
 
@@ -365,7 +366,8 @@ void lvmpolld_thread_data_destroy(void *thread_private)
 		pdst_unlock(data->pdlv->pdst);
 	}
 
-	dm_free(data->line);
+	/* may get reallocated in getline(). dm_free must not be used */
+	free(data->line);
 
 	if (data->fout && !fclose(data->fout))
 		data->outpipe[0] = -1;


