From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 Oct 2015 08:55:11 +0000 (UTC)
Subject: master - cleanup: gcc warning for old-style
Message-ID: <20151023085511.4809660F92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21748a86309443ddaefe1fcc0644f0b9a6ea138e
Commit:        21748a86309443ddaefe1fcc0644f0b9a6ea138e
Parent:        e5b686d6932be9931a386d15e8d452153225952b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 23 09:42:38 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 23 10:54:13 2015 +0200

cleanup: gcc warning for old-style

---
 lib/mm/memlock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 34a6eff..c17ae13 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -639,7 +639,7 @@ void memlock_unlock(struct cmd_context *cmd)
 
 #endif
 
-int memlock_count_daemon()
+int memlock_count_daemon(void)
 {
 	return _memlock_count_daemon;
 }


