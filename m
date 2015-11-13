From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:10 +0000 (UTC)
Subject: master - cleanup: drop unneded check for mem
Message-ID: <20151113101910.DF362610A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0828e885b298537554d8b751fb52e1a69a04c9d
Commit:        e0828e885b298537554d8b751fb52e1a69a04c9d
Parent:        112c0592ad0d25bae0cea04275d201d72187f85b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 11 20:45:53 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:17:06 2015 +0100

cleanup: drop unneded check for mem

Revert missed to drop this extra check.
---
 lib/datastruct/str_list.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index cf7457b..9dd0576 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -239,7 +239,7 @@ struct dm_list *str_to_str_list(struct dm_pool *mem, const char *str,
 
 	return list;
 bad:
-	if (mem)
-		dm_pool_free(mem, list);
+	dm_pool_free(mem, list);
+
 	return NULL;
 }


