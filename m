From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Jul 2013 15:18:19 +0000 (UTC)
Subject: master - libdm: move new added field to structure end
Message-ID: <20130724151819.88C5B612BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb9256111a8635b354c5b0ac3f3ab8fdab6068e3
Commit:        cb9256111a8635b354c5b0ac3f3ab8fdab6068e3
Parent:        da5284a500338b458ade34c1a88d461acde52b71
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 24 16:49:48 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 24 17:17:37 2013 +0200

libdm: move new added field to structure end

For backwared compatibility add new struct field to the end.

(in release fix)
---
 libdm/libdevmapper.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 66396ce..0c415c6 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1581,10 +1581,10 @@ struct dm_config_value {
 };
 
 struct dm_config_node {
-	int id;
 	const char *key;
 	struct dm_config_node *parent, *sib, *child;
 	struct dm_config_value *v;
+	int id;
 };
 
 struct dm_config_tree {


