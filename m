From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 04:56:42 -0400
Subject: master - [metadata-liblvm.c] comment out some dead code and add a FIXME
Message-ID: <201804300856.w3U8ugaO018966@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=65d6118e4773940529063b4e6515673f88b54edb
Commit:        65d6118e4773940529063b4e6515673f88b54edb
Parent:        513e9e3264d6499630ba863ead3fe3701fc8ac29
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Feb 12 14:14:40 2018 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 09:45:39 2018 +0100

[metadata-liblvm.c] comment out some dead code and add a FIXME

---
 lib/metadata/metadata-liblvm.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index b0b678a..2dc3757 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -575,7 +575,7 @@ static int _pvremove_single(struct cmd_context *cmd, const char *pv_name,
 			    unsigned prompt, struct dm_list *pvslist)
 {
 	struct device *dev;
-	struct lvmcache_info *info;
+	//struct lvmcache_info *info;
 	int r = 0;
 
 	if (!_pvremove_check(cmd, pv_name, force_count, prompt, pvslist))
@@ -587,7 +587,8 @@ static int _pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto out;
 	}
 
-	info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
+	// FIXME: why is this called if info is not used?
+	//info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
 
 	if (!dev_test_excl(dev)) {
 		/* FIXME Detect whether device-mapper is still using the device */


