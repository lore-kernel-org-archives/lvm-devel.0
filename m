From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:17:06 +0000 (UTC)
Subject: master - config: check vdef pointer before dereference
Message-ID: <20151116001706.362236106E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=193e7f5973e8a0ff7a4f8ebc542fcb9853a30d0d
Commit:        193e7f5973e8a0ff7a4f8ebc542fcb9853a30d0d
Parent:        96d73dc6ea3016a80b5041ee0252e8473481b91e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 16 00:42:29 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:16:11 2015 +0100

config: check vdef pointer before dereference

Coverity notices we check for v_def != NULL elsewhere, so it thinks
it may be possibly NULL also here.
---
 lib/config/config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 1298b40..d69f1f7 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -891,7 +891,7 @@ static int _check_value_differs_from_default(struct cft_check_handle *handle,
 				}
 				break;
 			case DM_CFG_EMPTY_ARRAY:
-				diff = v_def->type != DM_CFG_EMPTY_ARRAY;
+				diff = (v_def && (v_def->type != DM_CFG_EMPTY_ARRAY));
 				break;
 			default:
 				log_error(INTERNAL_ERROR "inconsistent state reached in _check_value_differs_from_default");


