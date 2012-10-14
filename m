From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 14 Oct 2012 22:46:22 +0000 (UTC)
Subject: master - lvmetad: fix previous commit
Message-ID: <20121014224622.CCAA1A0D90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2393b468a4703be81f1d38ea7968931d30046087
Commit:        2393b468a4703be81f1d38ea7968931d30046087
Parent:        9bb210192dd5b60582633079d4769a582ac11074
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 00:44:31 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 00:44:31 2012 +0200

lvmetad: fix previous commit

Ooops patch conversion for gcc cleanup missed this line.
---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a3b45d5..f7d250e 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -677,7 +677,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *device, const struct
 	if (!pvmeta)
 		return_0;
 
-	info = lvmcache_info_from_pvid((const char *)&pvid, 0);
+	info = lvmcache_info_from_pvid((const char *)pvid, 0);
 
 	if (!(pvmeta->root = make_config_node(pvmeta, "pv", NULL, NULL))) {
 		dm_config_destroy(pvmeta);


