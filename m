From: David Teigland <teigland@redhat.com>
Date: Mon, 1 Apr 2013 17:13:39 -0400
Subject: [PATCH] clvmd: detect 3.7 dlm kernel bug
Message-ID: <20130401211339.GB11525@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Kernel commit 2b75bc9121e54e22537207b47b71373bcb0be41c
included a bug that causes dlm lock requests on max len
resources to return an EINVAL error, on CONFIG_COMPAT systems.
This bug was included in 3.7 and fixed in 3.8 by commit
d4b0bcf32b946590afd29e202d6a399b84fe6c67.

This clvmd patch acquires a new dlm lock on a per-node max len
resource during startup.  If this fails with EINVAL, and the
system may be config compat, then we try taking a dlm lock
on a non-max len resource.  If the second lock is successful,
then log a message stating that the kernel may include the
dlm bug above.  The other reasons for the dlm to return EINVAL
do not appear likely to apply to this case.

(I don't know if the 3.7 kernel is still used widely enough
to include this patch.)

---
 daemons/clvmd/clvmd-corosync.c | 77 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)

diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index d85ec1e..6fbc652 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -42,6 +42,7 @@
 #include <libdlm.h>
 
 #include <syslog.h>
+#include <sys/utsname.h>
 
 /* Timeout value for several corosync calls */
 #define LOCKSPACE_NAME "clvmd"
@@ -75,6 +76,9 @@ static quorum_handle_t quorum_handle;
 /* DLM Handle */
 static dlm_lshandle_t *lockspace;
 
+static char node_resource_str[DLM_RESNAME_MAXLEN + 1];
+static uint32_t node_resource_lkid;
+
 static struct cpg_name cpg_group_name;
 
 /* Corosync callback structs */
@@ -278,6 +282,72 @@ static void corosync_cpg_confchg_callback(cpg_handle_t handle,
 	num_nodes = member_list_entries;
 }
 
+static int _lock_node_resource(void)
+{
+	struct dlm_lksb lksb;
+	int i, rv, error;
+
+	memset(node_resource_str, 0, DLM_RESNAME_MAXLEN);
+	sprintf(node_resource_str, "node%08x", our_nodeid);
+
+	/* make the resource name the max length */
+	for (i = strlen(node_resource_str); i < DLM_RESNAME_MAXLEN; i++)
+		node_resource_str[i] = '.';
+
+	DEBUGLOG("lock_node_resource len %zu %s\n",
+		 strlen(node_resource_str), node_resource_str);
+
+	memset(&lksb, 0, sizeof(lksb));
+
+	rv = dlm_ls_lock_wait(lockspace, LKM_EXMODE, &lksb, 0,
+			      node_resource_str, DLM_RESNAME_MAXLEN,
+			      0, NULL, NULL, NULL);
+	if (!rv) {
+		node_resource_lkid = lksb.sb_lkid;
+		return 0;
+	}
+
+	error = errno;
+
+	/*
+	 * Check if this may be the 3.7 dlm kernel bug so we can
+	 * log an informative error message.  Remove this check
+	 * once 3.7 kernels are not being used.
+	 */
+
+	if ((error == EINVAL) && (sizeof(long) != sizeof(long long))) {
+		struct utsname un;
+
+		/*
+		 * Do not make resource name the max length; the shorter
+		 * length should pass the buggy size check.  If the max
+		 * len fails with EINVAL and the short len succeeds, then
+		 * this is probably the buggy size check in the kernel.
+		 */
+
+		memset(node_resource_str, 0, DLM_RESNAME_MAXLEN);
+		sprintf(node_resource_str, "test%08x", our_nodeid);
+
+		memset(&lksb, 0, sizeof(lksb));
+
+		rv = dlm_ls_lock_wait(lockspace, LKM_NLMODE, &lksb, 0,
+				      node_resource_str, strlen(node_resource_str),
+				      0, NULL, NULL, NULL);
+		if (!rv) {
+			memset(&un, 0, sizeof(un));
+			uname(&un);
+
+			DEBUGLOG("dlm 3.7 CONFIG_COMPAT bug may exist in kernel %s\n", un.release);
+			syslog(LOG_ERR, "dlm 3.7 CONFIG_COMPAT bug may exist in kernel %s\n", un.release);
+		}
+	}
+
+	DEBUGLOG("dlm lock error %d on node %d resource\n", error, our_nodeid);
+	syslog(LOG_ERR, "dlm lock error %d on node %d resource\n", error, our_nodeid);
+
+	return error;
+}
+
 static int _init_cluster(void)
 {
 	cs_error_t err;
@@ -358,6 +428,13 @@ static int _init_cluster(void)
 	}
 	DEBUGLOG("Our local node id is %d\n", our_nodeid);
 
+	if (_lock_node_resource()) {
+		dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
+		cpg_finalize(cpg_handle);
+		quorum_finalize(quorum_handle);
+		return -1;
+	}
+
 	DEBUGLOG("Connected to Corosync\n");
 
 	return 0;
-- 
1.8.1.rc1.5.g7e0651a


