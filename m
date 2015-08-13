From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 13 Aug 2015 18:06:31 +0000 (UTC)
Subject: master - dmstats: do not use "region_id" in error messages
Message-ID: <20150813180631.79A806105B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3cd5d294503fcfa4b826456e17071a909d739e1
Commit:        b3cd5d294503fcfa4b826456e17071a909d739e1
Parent:        6b81ac5807bdbfdd0063db4f53cc6d310c2fe4fc
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Aug 13 18:12:56 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Aug 13 19:05:48 2015 +0100

dmstats: do not use "region_id" in error messages

Refer to either '--regionid' or '--allregions' when the user fails
to specify either a single region ID or the --allregions switch.
---
 tools/dmsetup.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 20ab3a0..1dcc7e3 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4216,7 +4216,7 @@ static int _stats_clear(CMD_ARGS)
 	}
 
 	if (!_switches[REGION_ID_ARG] && !_switches[ALL_REGIONS_ARG]) {
-		err("Please specify a region_id.");
+		err("Please specify a --regionid or use --allregions.");
 		return 0;
 	}
 
@@ -4499,7 +4499,7 @@ static int _stats_delete(CMD_ARGS)
 	}
 
 	if (!_switches[REGION_ID_ARG] && !allregions) {
-		err("Please specify a region_id.");
+		err("Please specify a --regionid or use --allregions.");
 		return 0;
 	}
 
@@ -4654,7 +4654,7 @@ static int _stats_print(CMD_ARGS)
 	}
 
 	if (!_switches[REGION_ID_ARG] && !allregions) {
-		err("Please specify a region_id.");
+		err("Please specify a --regionid or use --allregions.");
 		return 0;
 	}
 


