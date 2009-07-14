From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 14 Jul 2009 16:57:06 -0400 (EDT)
Subject: [PATCHES] dmeventd and dynamic library segtypes
Message-ID: <Pine.LNX.4.64.0907141652130.8166@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

Here are two patches to make dmeventd work with library segtypes.

The first one makes dmeventd debuggable (it always attempted to kill the 
parent process, even if it didn't work), the second one fixes exported 
symbols.

I also attach a stacktrace where it tried to load the segtypes, as 
Alasdair wanted.

Mikulas
-------------- next part --------------
Don't kill the parent process if we don't fork.

This makes dmeventd undebuggable (it kills gdb) and also can cause
various other script errors when run with -d from a script or some
other program (interactive shell catches SIGTERM, so the bug is not
visible with it).

Signed-off-by: Mikulas Patocka <mpatocka at redhat.com

---
 daemons/dmeventd/dmeventd.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: LVM2.2.02.48/daemons/dmeventd/dmeventd.c
===================================================================
--- LVM2.2.02.48.orig/daemons/dmeventd/dmeventd.c	2009-07-14 22:15:06.000000000 +0200
+++ LVM2.2.02.48/daemons/dmeventd/dmeventd.c	2009-07-14 22:27:59.000000000 +0200
@@ -1734,7 +1734,8 @@ int main(int argc, char *argv[])
 		exit(EXIT_FIFO_FAILURE);
 
 	/* Signal parent, letting them know we are ready to go. */
-	kill(getppid(), SIGTERM);
+	if (!_debug)
+		kill(getppid(), SIGTERM);
 	syslog(LOG_NOTICE, "dmeventd ready for processing.");
 
 	while (!_exit_now) {
-------------- next part --------------
Make dmeventd work when snapshot segtype library is compiled as a module.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com

---
 daemons/dmeventd/dmeventd.c |    2 +-
 tools/.export.sym           |    2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: LVM2.2.02.48/tools/.export.sym
===================================================================
--- LVM2.2.02.48.orig/tools/.export.sym	2009-07-14 22:31:17.000000000 +0200
+++ LVM2.2.02.48/tools/.export.sym	2009-07-14 22:40:25.000000000 +0200
@@ -5,6 +5,8 @@ Base {
 		lvm2_log_level;
 		lvm2_log_fn;
 		lvm2_exit;
+		find_config_tree_str;
+		print_log;
 	local:
 		*;
 };
Index: LVM2.2.02.48/daemons/dmeventd/dmeventd.c
===================================================================
--- LVM2.2.02.48.orig/daemons/dmeventd/dmeventd.c	2009-07-14 22:36:08.000000000 +0200
+++ LVM2.2.02.48/daemons/dmeventd/dmeventd.c	2009-07-14 22:37:03.000000000 +0200
@@ -873,7 +873,7 @@ static struct dso_data *_load_dso(struct
 	void *dl;
 	struct dso_data *ret = NULL;
 
-	if (!(dl = dlopen(data->dso_name, RTLD_NOW))) {
+	if (!(dl = dlopen(data->dso_name, RTLD_NOW | RTLD_GLOBAL))) {
 		const char *dlerr = dlerror();
 		syslog(LOG_ERR, "dmeventd %s dlopen failed: %s", data->dso_name,
 		       dlerr);
-------------- next part --------------
Breakpoint 1, _init_segtypes (cmd=0x2b048) at commands/toolcontext.c:822
822             if (!(segtype = init_striped_segtype(cmd)))
(gdb) bt
#0  _init_segtypes (cmd=0x2b048) at commands/toolcontext.c:822
#1  0xf7ba7154 in create_toolcontext (is_long_lived=0, system_dir=0x0)
    at commands/toolcontext.c:1106
#2  0xf7c22a50 in init_lvm () at lvmcmdline.c:1162
#3  0xf7c42634 in cmdlib_lvm2_init (static_compile=0) at lvmcmdlib.c:38
#4  0xf7c429c8 in lvm2_init () at lvm2cmd.c:20
#5  0xf7c8163c in register_device (device=0x28a00 "vg1-m",
    uuid=0x288f8 "LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRgTM5gQeKumcDlvMPxa3S4Z36BpXsdgYH",
    major=254, minor=11, unused=0x288c8) at dmeventd_mirror.c:255
#6  0x0001342c in _do_register_device (thread=0x28880) at dmeventd.c:654
#7  0x000140cc in _register_for_event (message_data=0x276cc) at dmeventd.c:972
#8  0x000154f4 in _handle_request (msg=0xffd57b9c, message_data=0x276cc) at dmeventd.c:1374
#9  0x000156f8 in _do_process_request (msg=0xffd57b9c) at dmeventd.c:1403
#10 0x00015810 in _process_request (fifos=0xffd57c20) at dmeventd.c:1430
#11 0x00016700 in main (argc=2, argv=0xffd57d34) at dmeventd.c:1742

