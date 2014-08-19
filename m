From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:18:51 +0000 (UTC)
Subject: master - lv_manip: check for str_list_dup failure
Message-ID: <20140819141851.7663D6030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dec39b1a5f0f599fd751bc6cea8caaac8a211d31
Commit:        dec39b1a5f0f599fd751bc6cea8caaac8a211d31
Parent:        cdb16a603954a1a3771644a101d0b372f8e0826c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 19 14:27:03 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:06 2014 +0200

lv_manip: check for str_list_dup failure

---
 lib/metadata/lv_manip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c314377..db70818 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -470,8 +470,9 @@ int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
 	 * device that is not combined with any other type. So just copy what
 	 * we have set for "layout" and use it for "type" too.
 	 */
-	if (dm_list_empty(*type))
-		str_list_dup(mem, *type, *layout);
+	if (dm_list_empty(*type) &&
+	    !str_list_dup(mem, *type, *layout))
+                goto_bad;
 
 	return 1;
 bad:


