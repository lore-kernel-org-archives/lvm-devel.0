From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:18:47 +0000 (UTC)
Subject: master - metadata: check result of refresh and rescan
Message-ID: <20140819141847.3F9816020C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ad9aee9af46690032a0480ebd1023f400ea15841
Commit:        ad9aee9af46690032a0480ebd1023f400ea15841
Parent:        6d7f260f92329d394ece7447e58a46cd26d9a5a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 19 14:25:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:06 2014 +0200

metadata: check result of refresh and rescan

Detect failure in case refresh_filters of lvmcache_label_scan fails.
---
 lib/metadata/metadata.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d483225..168c110 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1414,10 +1414,16 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 
 out:
 	if (filter_refresh_needed)
-		refresh_filters(cmd);
+		if (!refresh_filters(cmd)) {
+			stack;
+			r = 0;
+		}
 
 	if (scan_needed)
-		lvmcache_label_scan(cmd, 2);
+		if (!lvmcache_label_scan(cmd, 2)) {
+			stack;
+			r = 0;
+		}
 
 	free_pv_fid(pv);
 	return r;


