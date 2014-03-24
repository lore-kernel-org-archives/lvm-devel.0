From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 24 Mar 2014 15:34:25 +0000 (UTC)
Subject: master - config: also check empty arrays for difference against default values
Message-ID: <20140324153425.3011D60B61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e47c34ffc6f1c7750b21074b733cf6356002c11
Commit:        4e47c34ffc6f1c7750b21074b733cf6356002c11
Parent:        5dcec1734e653ca137975bdfd4556e93447f10a0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 24 16:30:47 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 24 16:30:47 2014 +0100

config: also check empty arrays for difference against default values

---
 lib/config/config.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 161241e..a751d3e 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -740,6 +740,9 @@ static int _check_value_differs_from_default(struct cft_check_handle *handle,
 					diff = strcmp(str, v->v.str);
 				}
 				break;
+			case DM_CFG_EMPTY_ARRAY:
+				diff = v_def->type != DM_CFG_EMPTY_ARRAY;
+				break;
 			default:
 				log_error(INTERNAL_ERROR "inconsistent state reached in _check_value_differs_from_default");
 				return 0;


