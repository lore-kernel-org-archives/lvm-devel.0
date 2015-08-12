From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 17:47:07 +0000 (UTC)
Subject: master - lvcreate: fix return value
Message-ID: <20150812174707.66B93603FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cf3336130b01dc40e89bdd83fceabf057b4a03c
Commit:        2cf3336130b01dc40e89bdd83fceabf057b4a03c
Parent:        a8b9e2eccdfccd63bc8816cea66f157b0257e351
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 12 14:53:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 19:46:43 2015 +0200

lvcreate: fix return value

Return correct 0 instead of NULL.
---
 tools/lvcreate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index cc4ef20..2a94f3b 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -574,7 +574,7 @@ static int _read_cache_params(struct cmd_context *cmd,
 			      &lp->cache_mode,
 			      &lp->policy_name,
 			      &lp->policy_settings))
-		return_NULL;
+		return_0;
 
 	return 1;
 }


