From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:14 +0000 (UTC)
Subject: master - dmsetup: fix memleak in _get_split_name
Message-ID: <20120823124214.D19BEA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e318dad427c7d2e6787f9412cf7c4ee761faf9f
Commit:        7e318dad427c7d2e6787f9412cf7c4ee761faf9f
Parent:        59ca324c35f3898070a5ad4cb0ec267a1eb4a292
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 16 20:12:38 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:36:10 2012 +0200

dmsetup: fix memleak in _get_split_name

Free allocated buffer in _get_split_name error path.
---
 WHATS_NEW_DM    |    4 ++++
 tools/dmsetup.c |    4 +++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3890ea4..186a2e1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,7 @@
+Version 1.02.77 -
+=================================
+  Fix memory leak in dmsetup _get_split_name() error path.
+
 Version 1.02.76 - 7th August 2012
 =================================
   Add dm_vasprintf to libdevmapper.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5422f0b..7a632c7 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -380,8 +380,10 @@ static struct dm_split_name *_get_split_name(const char *uuid, const char *name,
 		return NULL;
 	}
 
-	if (!(split_name->subsystem = _extract_uuid_prefix(uuid, separator)))
+	if (!(split_name->subsystem = _extract_uuid_prefix(uuid, separator))) {
+		dm_free(split_name);
 		return_NULL;
+	}
 
 	split_name->vg_name = split_name->lv_name =
 	    split_name->lv_layer = (char *) "";


