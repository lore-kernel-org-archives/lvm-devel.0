From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 Jan 2015 15:46:41 +0000 (UTC)
Subject: master - config: improve config validation to check if setting with string value can be empty.
Message-ID: <20150121154641.84E08610E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bea003e94ceec717c2c5b847a9a28ea3f8f42dad
Commit:        bea003e94ceec717c2c5b847a9a28ea3f8f42dad
Parent:        57f67ce8558d9688d1e743aba5d65d1e1545aad6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 21 16:44:02 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 21 16:44:02 2015 +0100

config: improve config validation to check if setting with string value can be empty.

For example, with dmeventd/executable set to "" which is not allowed for
this setting, the config validation now ends up with:

$ lvm dumpconfig --validate
  Configuration setting "dmeventd/executable" invalid. It cannot be set to an empty value.
  LVM configuration invalid.

This check for empty values for string config settings was not
done before (we only checked empty arrays, but not scalar strings).
---
 WHATS_NEW           |    1 +
 lib/config/config.c |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 15ab94f..02f76be 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Improve config validation to check if setting with string value can be empty.
 
 Version 2.02.115 - 21st January 2015
 ====================================
diff --git a/lib/config/config.c b/lib/config/config.c
index 58efb31..b47984f 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -790,6 +790,11 @@ static int _config_def_check_node_single_value(struct cft_check_handle *handle,
 			} else if  (!(def->type & CFG_TYPE_STRING)) {
 				_log_type_error(rp, CFG_TYPE_STRING, def->type, handle->suppress_messages);
 				return 0;
+			} else if (!(def->flags & CFG_ALLOW_EMPTY) && !*v->v.str) {
+				log_warn_suppress(handle->suppress_messages,
+						  "Configuration setting \"%s\" invalid. "
+						  "It cannot be set to an empty value.", rp);
+				return 0;
 			}
 			break;
 		default: ;


