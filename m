From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:47:17 -0500
Subject: master - cov: looks like cut&paste error
Message-ID: <201812212047.wBLKlHVj021507@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a355aeb17a4fda7fab76a2c85bdc7ff03159424a
Commit:        a355aeb17a4fda7fab76a2c85bdc7ff03159424a
Parent:        8db2527c6edec81d3b90d30384e32784ab2ec687
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 20:22:55 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:45:08 2018 +0100

cov: looks like cut&paste error

Fua and nofua code path should have different compares.
---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index baabb00..b63dc34 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5292,7 +5292,7 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 	}
 
 	if (!strncmp(key, "nofua", strlen("nofua"))) {
-		if (settings->nofua_set) {
+		if (settings->fua_set) {
 			log_error("Setting fua and nofua cannot both be set.");
 			return 0;
 		}


