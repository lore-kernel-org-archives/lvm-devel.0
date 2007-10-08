From: Jim Meyering <jim@meyering.net>
Date: Mon, 08 Oct 2007 19:25:56 +0200
Subject: Allow $DM_DEVDIR envvar to override default of "/dev".
Message-ID: <87przp1psr.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In making LVM tests more reproducible and insulating them from
any existing LVM set-up, I've been using LVM_SYSTEM_DIR to specify
a different /dev directory.  However, that broke down for tests
that ran dmsetup, since dmsetup hard-codes /dev.

Here's a patch to make dmsetup honor a new DM_DEVDIR envvar,
in using that value in place of "/dev":

        Allow $DM_DEVDIR envvar to override default of "/dev".

        * dmsetup/dmsetup.c (DEV_PATH): Remove definition.
        (parse_loop_device_name): Add parameter: dev_dir.
        Declare the "dev" parameter to be "const".
        Use dev_dir, not DEV_PATH.  Handle the case in which dev_dir
        does not end in a "/".
        (_get_abspath): Declare "path" parameter "const", to match.
        (_process_losetup_switches): Add parameter: dev_dir.
        Pass dev_dir to parse_loop_device_name.
        (_process_switches): Add parameter: dev_dir.
        Pass dev_dir to _process_losetup_switches.
        (main): Set dev_dir from the DM_DEVDIR envvar, else to "/dev".
        Call dm_set_dev_dir.
        * lib/libdm-common.c (dm_set_dev_dir): Rewrite to be careful
        about boundary conditions, now that dev_dir may be tainted.

As for the way I call dm_set_dev_dir in main, note that I call
it only when using a value from DM_DEVDIR, and not when using
the default of "/dev".  That's sort of ugly, but using "/dev"
is the default that is hard-coded into libdevmapper, via this:

    lib/libdm-common.c:
      #define DEV_DIR "/dev/"
      static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;

Ideally, libdevmapper wouldn't rely on any such static variable,
of course, but there may well be existing callers, so I won't
try to change that.

Signed-off-by: Jim Meyering <meyering@redhat.com>
---
 dmsetup/dmsetup.c  |   35 ++++++++++++++++++++++++++---------
 lib/libdm-common.c |   15 +++++++++++++--
 2 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/dmsetup/dmsetup.c b/dmsetup/dmsetup.c
index 562f628..ca864b8 100644
--- a/dmsetup/dmsetup.c
+++ b/dmsetup/dmsetup.c
@@ -97,7 +97,6 @@ extern char *optarg;
 
 /* FIXME Should be elsewhere */
 #define SECTOR_SHIFT 9L
-#define DEV_PATH "/dev/"
 
 #define err(msg, x...) fprintf(stderr, msg "\n", ##x)
 
@@ -2129,7 +2128,7 @@ static int _process_tree_options(const char *options)
  * Returns the full absolute path, or NULL if the path could
  * not be resolved.
  */
-static char *_get_abspath(char *path)
+static char *_get_abspath(const char *path)
 {
 	char *_path;
 
@@ -2141,7 +2140,7 @@ static char *_get_abspath(char *path)
 	return _path;
 }
 
-static char *parse_loop_device_name(char *dev)
+static char *parse_loop_device_name(const char *dev, const char *dev_dir)
 {
 	char *buf;
 	char *device;
@@ -2153,7 +2152,13 @@ static char *parse_loop_device_name(char *dev)
 		if (!(device = _get_abspath(dev)))
 			goto error;
 
-		if (strncmp(device, DEV_PATH, strlen(DEV_PATH)))
+		if (strncmp(device, dev_dir, strlen(dev_dir)))
+			goto error;
+
+		/* If dev_dir does not end in a slash, ensure that the
+		   following byte in the device string is "/".  */
+		if (dev_dir[strlen(dev_dir) - 1] != '/'
+		    && device[strlen(dev_dir)] != '/')
 			goto error;
 
 		strncpy(buf, strrchr(device, '/') + 1, (size_t) PATH_MAX);
@@ -2234,7 +2239,8 @@ error:
 	return 0;
 }
 
-static int _process_losetup_switches(const char *base, int *argc, char ***argv)
+static int _process_losetup_switches(const char *base, int *argc, char ***argv,
+				     const char *dev_dir)
 {
 	static int ind;
 	int c;
@@ -2297,7 +2303,7 @@ static int _process_losetup_switches(const char *base, int *argc, char ***argv)
 		return 0;
 	}
 
-	if (!(device_name = parse_loop_device_name((*argv)[0]))) {
+	if (!(device_name = parse_loop_device_name((*argv)[0], dev_dir))) {
 		fprintf(stderr, "%s: Could not parse loop_device %s\n",
 			base, (*argv)[0]);
 		_losetup_usage(stderr);
@@ -2344,7 +2350,7 @@ static int _process_losetup_switches(const char *base, int *argc, char ***argv)
 	return 1;
 }
 
-static int _process_switches(int *argc, char ***argv)
+static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 {
 	char *base, *namebase;
 	static int ind;
@@ -2422,7 +2428,7 @@ static int _process_switches(int *argc, char ***argv)
 	}
 
 	if (!strcmp(base, "losetup") || !strcmp(base, "dmlosetup")){
-		r = _process_losetup_switches(base, argc, argv);
+		r = _process_losetup_switches(base, argc, argv, dev_dir);
 		free(namebase);
 		return r;
 	}
@@ -2539,10 +2545,21 @@ int main(int argc, char **argv)
 {
 	struct command *c;
 	int r = 1;
+	const char *dev_dir;
 
 	(void) setlocale(LC_ALL, "");
 
-	if (!_process_switches(&argc, &argv)) {
+	dev_dir = getenv ("DM_DEVDIR");
+	if (dev_dir && *dev_dir) {
+		if (!dm_set_dev_dir(dev_dir)) {
+			fprintf(stderr, "Invalid DM_DEVDIR envvar value.\n");
+			goto out;
+		}
+	} else {
+		dev_dir = "/dev";
+	}
+
+	if (!_process_switches(&argc, &argv, dev_dir)) {
 		fprintf(stderr, "Couldn't process command line.\n");
 		goto out;
 	}
diff --git a/lib/libdm-common.c b/lib/libdm-common.c
index c8c3500..c87903a 100644
--- a/lib/libdm-common.c
+++ b/lib/libdm-common.c
@@ -463,9 +463,20 @@ void update_devs(void)
 	_pop_node_ops();
 }
 
-int dm_set_dev_dir(const char *dir)
+int dm_set_dev_dir(const char *dev_dir)
 {
-	snprintf(_dm_dir, sizeof(_dm_dir), "%s%s", dir, DM_DIR);
+	size_t len;
+	const char *slash;
+	if (*dev_dir != '/')
+		return 0;
+
+	len = strlen(dev_dir);
+	slash = dev_dir[len-1] == '/' ? "" : "/";
+
+	if (snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR)
+	    >= sizeof _dm_dir)
+		return 0;
+
 	return 1;
 }
 
-- 
1.5.3.4.206.g58ba4


