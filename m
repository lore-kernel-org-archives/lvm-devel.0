From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Jul 2015 12:36:33 +0000 (UTC)
Subject: master - coverity: missing break in switch expression
Message-ID: <20150708123633.2F64E60E06@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=705fee709fdb2f3f23a5a466d30cf36dab0a9c96
Commit:        705fee709fdb2f3f23a5a466d30cf36dab0a9c96
Parent:        71f4fbfbde720795995abffa1bd8aeaa00706a6b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 8 14:36:02 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 8 14:36:02 2015 +0200

coverity: missing break in switch expression

lib/lvmpolld/lvmpolld-client.c:109: fallthrough: The above case falls through to this one
---
 lib/lvmpolld/lvmpolld-client.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index d770e74..6676ce9 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -106,6 +106,7 @@ static void _explain_error_codes(int retcode)
 	/* lvmpolld specific return codes */
 	case LVMPD_RET_DUP_FAILED:
 		log_error("lvmpolld failed to duplicate file descriptors.");
+		break;
 	case LVMPD_RET_EXC_FAILED:
 		log_error("lvmpolld failed to exec() lvm binary.");
 		break;


