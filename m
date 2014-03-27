From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 12:50:09 +0000 (UTC)
Subject: master - fix spurios char
Message-ID: <20140327125009.1FE026129A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7a89323f53c791e907478a7338a1bdbbb151fe1
Commit:        c7a89323f53c791e907478a7338a1bdbbb151fe1
Parent:        4ebdfcfb596bc2611c8b54d46c0a4ce6cc05ba9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 27 13:49:24 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 27 13:49:24 2014 +0100

fix spurios char

Mistyped char left in code.
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e5ab4f7..7f042e3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3232,7 +3232,7 @@ static int _rename_sub_lv(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!validate_name(new_name)) {              *
+	if (!validate_name(new_name)) {
 		log_error("Cannot rename \"%s\". New logical volume name \"%s\" is invalid.",
 			  lv->name, new_name);
 		return 0;


