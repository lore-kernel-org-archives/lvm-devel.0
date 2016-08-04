From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  4 Aug 2016 18:05:23 +0000 (UTC)
Subject: master - lvconvert: add FIXME
Message-ID: <20160804180523.3843860733@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1a25fe597569fd15fd934f639d41d991d767219
Commit:        d1a25fe597569fd15fd934f639d41d991d767219
Parent:        4a15abe865c7087de5505388e9757623da282311
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 4 11:40:27 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 4 13:01:48 2016 -0500

lvconvert: add FIXME

operations are no longer identified correctly.
---
 tools/lvconvert.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8ea293d..5731558 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4337,7 +4337,14 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
  *	 for each arg_is_set(operation)
  *	     _convert_lvtype_operation();
  *
+ * FIXME: this code (identifying/routing each unique operation through
+ * _convert_lvtype_op) was designed to work based on the new type that
+ * the user entered after --type, not the final segment type in lp->type_str.
+ * Sometimes the two differ because tricks are played with lp->type_str.
+ * So, when the use of arg_type_str(type_ARG) here was replaced with
+ * lp->type_str, some commands are no longer identified/routed correctly.
  */
+
 static int _lvconvert(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct lvconvert_params *lp)
 {


