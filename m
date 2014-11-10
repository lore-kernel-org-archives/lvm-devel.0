From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:44 +0000 (UTC)
Subject: master - cleanup: gcc warnings
Message-ID: <20141110210644.AA28060C9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f12e3da6393376ed13370a45995bf1950081a954
Commit:        f12e3da6393376ed13370a45995bf1950081a954
Parent:        e5d3f812854b23ef5e7e51f96a3f89fa02c093fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 8 15:33:17 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

cleanup: gcc warnings

---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 libdm/libdm-deptree.c          |    2 +-
 python/liblvm.c                |    3 ++-
 tools/lvmcmdline.c             |    2 +-
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 5b23a56..693eb86 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1035,7 +1035,7 @@ static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char
 			   *val = dm_hash_get_data(ht, n);
 		buffer_append(buf, "    ");
 		if (int_key)
-			(void) dm_asprintf(&append, "%d = \"%s\"", *(int*)key, val);
+			(void) dm_asprintf(&append, "%d = \"%s\"", *(const int*)key, val);
 		else
 			(void) dm_asprintf(&append, "%s = \"%s\"", key, val);
 		if (append)
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6521360..70373a2 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3176,7 +3176,7 @@ int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 					     uint64_t size,
 					     struct dm_tree_node_raid_params *p)
 {
-	int i;
+	unsigned i;
 	struct load_segment *seg = NULL;
 
 	for (i = 0; i < DM_ARRAY_SIZE(_dm_segtypes) && !seg; ++i)
diff --git a/python/liblvm.c b/python/liblvm.c
index 9983135..1b0942d 100644
--- a/python/liblvm.c
+++ b/python/liblvm.c
@@ -1986,6 +1986,7 @@ static void _liblvm_cleanup(void)
 	}
 }
 
+PyMODINIT_FUNC initlvm(void);
 PyMODINIT_FUNC initlvm(void)
 {
 	PyObject *m;
@@ -2020,7 +2021,7 @@ PyMODINIT_FUNC initlvm(void)
 				    LVM_THIN_DISCARDS_PASSDOWN) < 0)
 		return;
 
-	if ((_LibLVMError = PyErr_NewException("lvm.LibLVMError", NULL, NULL))) {
+	if ((_LibLVMError = PyErr_NewException((char*)"lvm.LibLVMError", NULL, NULL))) {
 		/* Each call to PyModule_AddObject decrefs it; compensate: */
 		Py_INCREF(_LibLVMError);
 		Py_INCREF(_LibLVMError);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ce45eb4..6149dbc 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1500,8 +1500,8 @@ int lvm_return_code(int ret)
 int lvm_split(char *str, int *argc, char **argv, int max)
 {
 	char *b = str, *e;
-	*argc = 0;
 	char quote = 0;
+	*argc = 0;
 
 	while (*b) {
 		while (*b && isspace(*b))


