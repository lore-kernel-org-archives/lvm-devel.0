From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Jun 2015 12:13:37 +0000 (UTC)
Subject: master - cleanup: || instead of |
Message-ID: <20150617121337.B297760045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5577f2f4f0a5518662b9cedb6a373ccb67a71917
Commit:        5577f2f4f0a5518662b9cedb6a373ccb67a71917
Parent:        1e6a926e857d8df767415c6ff91d4dd1de74f363
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 17 14:12:18 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 17 14:12:58 2015 +0200

cleanup: || instead of |

More efficient with same result here.
---
 lib/activate/dev_manager.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8a54bec..43e006a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -502,13 +502,13 @@ static int _ignore_suspended_snapshot_component(struct device *dev)
 				log_error("Incorrect snapshot table found");
 				goto_out;
 			}
-			r = r | _device_is_suspended(major1, minor1) | _device_is_suspended(major2, minor2);
+			r = r || _device_is_suspended(major1, minor1) || _device_is_suspended(major2, minor2);
 		} else if (!strcmp(target_type, "snapshot-origin")) {
 			if (sscanf(params, "%d:%d", &major1, &minor1) != 2) {
 				log_error("Incorrect snapshot-origin table found");
 				goto_out;
 			}
-			r = r | _device_is_suspended(major1, minor1);
+			r = r || _device_is_suspended(major1, minor1);
 		}
 	} while (next);
 


