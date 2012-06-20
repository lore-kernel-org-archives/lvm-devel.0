From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jun 2012 12:49:10 +0000 (UTC)
Subject: master - cmirrord: fix cut&paste
Message-ID: <20120620124910.C51E9168A@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=865b9d3701e075484888ac23ceb5c29d73b06154
Commit:        865b9d3701e075484888ac23ceb5c29d73b06154
Parent:        fb4584b83ddfe645ac1b8c16385e9a4632171d96
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 19 23:47:02 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 20 14:41:57 2012 +0200

cmirrord: fix cut&paste

---
 WHATS_NEW                    |    1 +
 daemons/cmirrord/functions.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 10fd724..34da256 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Print clean_bits in pull_state, fix cut&paste typo in cmirrord.
   Add tests for errors from closedir(), close() in cmirrord.
   Fix missing sync of filesystem when creating thin volume snapshot.
 
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 40b4bad..3e8fd20 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -1875,7 +1875,7 @@ int pull_state(const char *uuid, uint64_t luid,
 
 		LOG_DBG("[%s] loading clean_bits:", SHORT_UUID(lc->uuid));
 
-		print_bits(lc->sync_bits, 0);
+		print_bits(lc->clean_bits, 0);
 	}
 
 	return 0;


