From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:54 +0200
Subject: [PATCH 08/14] Fix C function definition
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <51b11d8a40c9951fc949361ca9ee9e7d55ada2b0.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix gcc prototype warnings

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-singlenode.c |    6 +++---
 daemons/clvmd/lvm-functions.c    |    4 ++--
 lib/format_text/import.c         |    2 +-
 lib/locking/file_locking.c       |    2 +-
 libdm/ioctl/libdm-iface.c        |    2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index ec98f2c..8624077 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -29,7 +29,7 @@
 static const char SINGLENODE_CLVMD_SOCKNAME[] = "\0singlenode_clvmd";
 static int listen_fd = -1;
 
-static int init_comms()
+static int init_comms(void)
 {
 	struct sockaddr_un addr;
 
@@ -97,7 +97,7 @@ static int _name_from_csid(const char *csid, char *name)
 	return 0;
 }
 
-static int _get_num_nodes()
+static int _get_num_nodes(void)
 {
 	return 1;
 }
@@ -207,7 +207,7 @@ static int _unlock_resource(const char *resource, int lockid)
 	return 0;
 }
 
-static int _is_quorate()
+static int _is_quorate(void)
 {
 	return 1;
 }
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index e7db685..aedc923 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -624,7 +624,7 @@ int do_refresh_cache()
 /* Only called at gulm startup. Drop any leftover VG or P_orphan locks
    that might be hanging around if we died for any reason
 */
-static void drop_vg_locks()
+static void drop_vg_locks(void)
 {
 	char vg[128];
 	char line[255];
@@ -810,7 +810,7 @@ static void lvm2_log_fn(int level, const char *file, int line, int dm_errno,
 }
 
 /* This checks some basic cluster-LVM configuration stuff */
-static void check_config()
+static void check_config(void)
 {
 	int locking_type;
 
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index f686418..3e0df94 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -25,7 +25,7 @@ static struct text_vg_version_ops *(_text_vsn_list[2]);
 
 static int _text_import_initialised = 0;
 
-static void _init_text_import()
+static void _init_text_import(void)
 {
 	if (_text_import_initialised)
 		return;
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 627cb68..1bf8f1b 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -118,7 +118,7 @@ static void _trap_ctrl_c(int sig __attribute__((unused)))
 	log_error("CTRL-c detected: giving up waiting for lock");
 }
 
-static void _install_ctrl_c_handler()
+static void _install_ctrl_c_handler(void)
 {
 	_handler_installed = 1;
 
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 5f71098..d2579ad 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -139,7 +139,7 @@ static void *_align(void *ptr, unsigned int a)
 	return (void *) (((unsigned long) ptr + agn) & ~agn);
 }
 
-static int _uname()
+static int _uname(void)
 {
 	static int _uts_set = 0;
 	struct utsname _uts;
-- 
1.7.2


