From: Jim Meyering <jim@meyering.net>
Date: Tue, 09 Oct 2007 13:43:22 +0200
Subject: Allow $DM_DEVDIR envvar to override default of "/dev".
In-Reply-To: <20071009020040.GR10006@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Tue, 9 Oct 2007 03:00:40 +0100")
References: <87przp1psr.fsf@rho.meyering.net>
	<20071009020040.GR10006@agk.fab.redhat.com>
Message-ID: <87wstwy0md.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> On Mon, Oct 08, 2007 at 07:25:56PM +0200, Jim Meyering wrote:
>> any existing LVM set-up, I've been using LVM_SYSTEM_DIR to specify
>
>> Here's a patch to make dmsetup honor a new DM_DEVDIR envvar,
>
> Small point, but should that be DM_DEV_DIR for consistency with
> LVM_SYSTEM_DIR ?

Yep.  I prefer that, too.

>> +	} else {
>> +		dev_dir = "/dev";

> Can you make that a #define at the top of the file?
Ok.

>> +	if (*dev_dir != '/')
>> +		return 0;
>
> log_error ?
> (Functions should produce an error message as close as possible to the
> place the problem is detected; all functions that return failure must
> log a message before returning - using a macro like 'stack' if you don't
> want the user to see it.  The only exceptions (very rare) are functions
> expected to fail frequently that would produce too many log messages.)
>
>> +	if (snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR)
>> +	    >= sizeof _dm_dir)
>> +		return 0;
>
> and here

I can do that, but then the diagnostic can no longer say that
the DM_DEV_DIR envvar is at fault.  There is a slight advantage
to diagnosing "too long" and "dir name is not absolute" separately,
but nonetheless, I have a slight preference for being able to point
directly to the DM_DEV_DIR envvar.

With my original patch, I got this diagnostic:

    Invalid DM_DEVDIR envvar value.

with the patch below, I get one of these

    Invalid dev_dir value, x: not an absolute name.
    Invalid dev_dir value, ...: name too long.

> Also consider dm_snprintf rather than snprintf.
> [lvm2 uses this, but bits of dm haven't been converted]

Sounds like a good idea for a separate patch.
There are many uses of snprintf.  IMHO, it'd be best to change
them all at once.

Here's the incremental patch, then the full one:

diff --git a/dmsetup/dmsetup.c b/dmsetup/dmsetup.c
index ca864b8..6244959 100644
--- a/dmsetup/dmsetup.c
+++ b/dmsetup/dmsetup.c
@@ -90,6 +90,8 @@ extern char *optarg;
 #define ARGS_MAX 256
 #define LOOP_TABLE_SIZE (PATH_MAX + 255)
 
+#define DEFAULT_DM_DEV_DIR "/dev"
+
 /* FIXME Should be imported */
 #ifndef DM_MAX_TYPE_NAME
 #  define DM_MAX_TYPE_NAME 16
@@ -2549,14 +2551,12 @@ int main(int argc, char **argv)
 
 	(void) setlocale(LC_ALL, "");
 
-	dev_dir = getenv ("DM_DEVDIR");
+	dev_dir = getenv ("DM_DEV_DIR");
 	if (dev_dir && *dev_dir) {
-		if (!dm_set_dev_dir(dev_dir)) {
-			fprintf(stderr, "Invalid DM_DEVDIR envvar value.\n");
+		if (!dm_set_dev_dir(dev_dir))
 			goto out;
-		}
 	} else {
-		dev_dir = "/dev";
+		dev_dir = DEFAULT_DM_DEV_DIR;
 	}
 
 	if (!_process_switches(&argc, &argv, dev_dir)) {
diff --git a/lib/libdm-common.c b/lib/libdm-common.c
index c87903a..577bbd8 100644
--- a/lib/libdm-common.c
+++ b/lib/libdm-common.c
@@ -467,15 +467,20 @@ int dm_set_dev_dir(const char *dev_dir)
 {
 	size_t len;
 	const char *slash;
-	if (*dev_dir != '/')
+	if (*dev_dir != '/') {
+		log_error("Invalid dev_dir value, %s: "
+			  "not an absolute name.", dev_dir);
 		return 0;
+	}
 
 	len = strlen(dev_dir);
 	slash = dev_dir[len-1] == '/' ? "" : "/";
 
 	if (snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR)
-	    >= sizeof _dm_dir)
+	    >= sizeof _dm_dir) {
+		log_error("Invalid dev_dir value, %s: name too long.", dev_dir);
 		return 0;
+	}
 
 	return 1;
 }
======================================================================

        Allow $DM_DEV_DIR envvar to override default of "/dev".

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
        (main): Set dev_dir from the DM_DEV_DIR envvar, else to "/dev".
        Call dm_set_dev_dir.
        * lib/libdm-common.c (dm_set_dev_dir): Rewrite to be careful
        about boundary conditions, now that dev_dir may be tainted.

Signed-off-by: Jim Meyering <meyering@redhat.com>
---
 dmsetup/dmsetup.c  |   35 ++++++++++++++++++++++++++---------
 lib/libdm-common.c |   20 ++++++++++++++++++--
 2 files changed, 44 insertions(+), 11 deletions(-)

diff --git a/dmsetup/dmsetup.c b/dmsetup/dmsetup.c
index 562f628..6244959 100644
--- a/dmsetup/dmsetup.c
+++ b/dmsetup/dmsetup.c
@@ -90,6 +90,8 @@ extern char *optarg;
 #define ARGS_MAX 256
 #define LOOP_TABLE_SIZE (PATH_MAX + 255)
 
+#define DEFAULT_DM_DEV_DIR "/dev"
+
 /* FIXME Should be imported */
 #ifndef DM_MAX_TYPE_NAME
 #  define DM_MAX_TYPE_NAME 16
@@ -97,7 +99,6 @@ extern char *optarg;
 
 /* FIXME Should be elsewhere */
 #define SECTOR_SHIFT 9L
-#define DEV_PATH "/dev/"
 
 #define err(msg, x...) fprintf(stderr, msg "\n", ##x)
 
@@ -2129,7 +2130,7 @@ static int _process_tree_options(const char *options)
  * Returns the full absolute path, or NULL if the path could
  * not be resolved.
  */
-static char *_get_abspath(char *path)
+static char *_get_abspath(const char *path)
 {
 	char *_path;
 
@@ -2141,7 +2142,7 @@ static char *_get_abspath(char *path)
 	return _path;
 }
 
-static char *parse_loop_device_name(char *dev)
+static char *parse_loop_device_name(const char *dev, const char *dev_dir)
 {
 	char *buf;
 	char *device;
@@ -2153,7 +2154,13 @@ static char *parse_loop_device_name(char *dev)
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
@@ -2234,7 +2241,8 @@ error:
 	return 0;
 }
 
-static int _process_losetup_switches(const char *base, int *argc, char ***argv)
+static int _process_losetup_switches(const char *base, int *argc, char ***argv,
+				     const char *dev_dir)
 {
 	static int ind;
 	int c;
@@ -2297,7 +2305,7 @@ static int _process_losetup_switches(const char *base, int *argc, char ***argv)
 		return 0;
 	}
 
-	if (!(device_name = parse_loop_device_name((*argv)[0]))) {
+	if (!(device_name = parse_loop_device_name((*argv)[0], dev_dir))) {
 		fprintf(stderr, "%s: Could not parse loop_device %s\n",
 			base, (*argv)[0]);
 		_losetup_usage(stderr);
@@ -2344,7 +2352,7 @@ static int _process_losetup_switches(const char *base, int *argc, char ***argv)
 	return 1;
 }
 
-static int _process_switches(int *argc, char ***argv)
+static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 {
 	char *base, *namebase;
 	static int ind;
@@ -2422,7 +2430,7 @@ static int _process_switches(int *argc, char ***argv)
 	}
 
 	if (!strcmp(base, "losetup") || !strcmp(base, "dmlosetup")){
-		r = _process_losetup_switches(base, argc, argv);
+		r = _process_losetup_switches(base, argc, argv, dev_dir);
 		free(namebase);
 		return r;
 	}
@@ -2539,10 +2547,19 @@ int main(int argc, char **argv)
 {
 	struct command *c;
 	int r = 1;
+	const char *dev_dir;
 
 	(void) setlocale(LC_ALL, "");
 
-	if (!_process_switches(&argc, &argv)) {
+	dev_dir = getenv ("DM_DEV_DIR");
+	if (dev_dir && *dev_dir) {
+		if (!dm_set_dev_dir(dev_dir))
+			goto out;
+	} else {
+		dev_dir = DEFAULT_DM_DEV_DIR;
+	}
+
+	if (!_process_switches(&argc, &argv, dev_dir)) {
 		fprintf(stderr, "Couldn't process command line.\n");
 		goto out;
 	}
diff --git a/lib/libdm-common.c b/lib/libdm-common.c
index c8c3500..577bbd8 100644
--- a/lib/libdm-common.c
+++ b/lib/libdm-common.c
@@ -463,9 +463,25 @@ void update_devs(void)
 	_pop_node_ops();
 }
 
-int dm_set_dev_dir(const char *dir)
+int dm_set_dev_dir(const char *dev_dir)
 {
-	snprintf(_dm_dir, sizeof(_dm_dir), "%s%s", dir, DM_DIR);
+	size_t len;
+	const char *slash;
+	if (*dev_dir != '/') {
+		log_error("Invalid dev_dir value, %s: "
+			  "not an absolute name.", dev_dir);
+		return 0;
+	}
+
+	len = strlen(dev_dir);
+	slash = dev_dir[len-1] == '/' ? "" : "/";
+
+	if (snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR)
+	    >= sizeof _dm_dir) {
+		log_error("Invalid dev_dir value, %s: name too long.", dev_dir);
+		return 0;
+	}
+
 	return 1;
 }
 
-- 
1.5.3.4.206.g58ba4


