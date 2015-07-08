From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Jul 2015 12:43:26 +0000 (UTC)
Subject: master - coverity: previous commit - not "break" but "fall through"
Message-ID: <20150708124326.0FEA8601E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8dbaf62d3b3e2a175d3b0237a4d85c009d98038
Commit:        e8dbaf62d3b3e2a175d3b0237a4d85c009d98038
Parent:        705fee709fdb2f3f23a5a466d30cf36dab0a9c96
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 8 14:42:26 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 8 14:42:31 2015 +0200

coverity: previous commit - not "break" but "fall through"

---
 lib/lvmpolld/lvmpolld-client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index 6676ce9..8be2d7b 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -106,7 +106,7 @@ static void _explain_error_codes(int retcode)
 	/* lvmpolld specific return codes */
 	case LVMPD_RET_DUP_FAILED:
 		log_error("lvmpolld failed to duplicate file descriptors.");
-		break;
+		/* fall through */
 	case LVMPD_RET_EXC_FAILED:
 		log_error("lvmpolld failed to exec() lvm binary.");
 		break;


