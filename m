From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Jun 2017 09:06:35 -0400
Subject: master - command: we don't have all standard macros
Message-ID: <201706281306.v5SD6Z86017203@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ba6896962d8fe34139d3d6d49fc08430fbc641a
Commit:        7ba6896962d8fe34139d3d6d49fc08430fbc641a
Parent:        a533892cd3bcb6abd0d0ee3f35f059850e540238
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 15:05:16 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 28 15:05:16 2017 +0200

command: we don't have all standard macros

So just quite warning
---
 tools/command.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index e2e60a3..afd8831 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3304,8 +3304,7 @@ static int include_description_file(char *name, char *des_file)
 out_free:
 	dm_free(buf);
 out_close:
-	if (close(fd))
-		log_sys_debug("close", des_file);
+	(void) close(fd);
 
 	return r;
 }


