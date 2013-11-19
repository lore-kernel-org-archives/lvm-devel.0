From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:45 +0000 (UTC)
Subject: master - lvm2app: Reset buffer after retrieving error message
Message-ID: <20131119205645.CC33660EA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe5b538c14c47e2e206d13c17f0225e39470d720
Commit:        fe5b538c14c47e2e206d13c17f0225e39470d720
Parent:        0c7a7d4d8433965313120254b68199525871b6a6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 26 12:19:18 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:40:42 2013 -0600

lvm2app: Reset buffer after retrieving error message

The error buffer will stack error messages which is fine.  However,
once you retrieve the error messages it doesn't make sense to keep
appending for each additional error message when running in the
context of a library call.

This patch clears and resets the buffer after the user retrieves
the error message.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/log/log.c         |    7 +++++++
 lib/log/lvm-logging.h |    1 +
 liblvm/lvm_base.c     |    9 ++++++++-
 python/liblvm.c       |    5 ++++-
 4 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index e0c1e73..1af9616 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -170,6 +170,13 @@ const char *stored_errmsg(void)
 	return _lvm_errmsg ? : "";
 }
 
+const char *stored_errmsg_with_clear(void)
+{
+	const char *rc = strdup(stored_errmsg());
+	reset_lvm_errno(1);
+	return rc;
+}
+
 static struct dm_hash_table *_duplicated = NULL;
 
 void reset_log_duplicated(void) {
diff --git a/lib/log/lvm-logging.h b/lib/log/lvm-logging.h
index 52cd895..145e2a1 100644
--- a/lib/log/lvm-logging.h
+++ b/lib/log/lvm-logging.h
@@ -55,6 +55,7 @@ int error_message_produced(void);
 void reset_lvm_errno(int store_errmsg);
 int stored_errno(void);
 const char *stored_errmsg(void);
+const char *stored_errmsg_with_clear(void);
 
 /* Suppress messages to stdout/stderr (1) or everywhere (2) */
 /* Returns previous setting */
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 139cc97..d694173 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -115,7 +115,14 @@ int lvm_errno(lvm_t libh)
 
 const char *lvm_errmsg(lvm_t libh)
 {
-	return stored_errmsg();
+	const char *rc = NULL;
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+	const char *msg = stored_errmsg_with_clear();
+	if (msg) {
+		rc = dm_pool_strdup(cmd->mem, msg);
+		free((void *)msg);
+	}
+	return rc;
 }
 
 const char *lvm_vgname_from_pvid(lvm_t libh, const char *pvid)
diff --git a/python/liblvm.c b/python/liblvm.c
index 330ef14..6abd5ff 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -141,6 +141,7 @@ static lvobject *_create_py_lv(vgobject *parent, lv_t lv)
 static PyObject *_liblvm_get_last_error(void)
 {
 	PyObject *info;
+	const char *msg = NULL;
 
 	LVM_VALID(NULL);
 
@@ -148,7 +149,9 @@ static PyObject *_liblvm_get_last_error(void)
 		return NULL;
 
 	PyTuple_SetItem(info, 0, PyInt_FromLong((long) lvm_errno(_libh)));
-	PyTuple_SetItem(info, 1, PyString_FromString(lvm_errmsg(_libh)));
+	msg = lvm_errmsg(_libh);
+	PyTuple_SetItem(info, 1, ((msg) ? PyString_FromString(msg) :
+			PyString_FromString("Memory error while retrieving error message")));
 
 	return info;
 }


