From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 13 Oct 2012 17:22:14 +0000 (UTC)
Subject: master - cleanup: used old C standard
Message-ID: <20121013172214.56E0522CC@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5df6ec24bffc2df7028639f06b580eda46d894df
Commit:        5df6ec24bffc2df7028639f06b580eda46d894df
Parent:        9effc6ab316db0f3f7122019ccdc546972ea1e94
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 13 19:18:33 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 13 19:18:33 2012 +0200

cleanup: used old C standard

---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 64820d8..81b6f04 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -52,7 +52,7 @@ void lvmetad_init(struct cmd_context *cmd)
 	}
 }
 
-void lvmetad_warning()
+void lvmetad_warning(void)
 {
 	if (_lvmetad_use && (_lvmetad.socket_fd < 0 || _lvmetad.error))
 		log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.",


