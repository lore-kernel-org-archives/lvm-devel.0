From: Jim Meyering <jim@meyering.net>
Date: Wed, 11 Jul 2007 16:18:12 +0200
Subject: avoid trouble with failed strdup
Message-ID: <87sl7vowgr.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

There are three uses of basename in the lvm2/cvs tree.  The two uses
in lvmcmdline.c operate on strdup'd copies, presumably to avoid the
portability problem whereby an old basename implementation would modify
its argument string.  The third use (in tools/fsadm/fsadm.c) operates
on a "const" string but has no such protection.  Here's one of the uses
from lvmcmdline.c:

       namebase = strdup(name);
       base = basename(namebase);

Note that if strdup fails, basename will dereference the NULL pointer.
The same happens with the other use of strdup in that file.

The patch at the end of this message removes both strdup calls
(and the related decl and free).

If you would like the code to continue to work even when linked
with a buggy (er, ancient at least) basename implementation, here's
a function you can use in place of basename.
Just change each of the three uses of "basename" to "last_component".
If you're interested in using that, tell me where you'd like the new
function, and I'll submit a patch with that addition.
Hmm... I see there are no other uses of "bool", or inclusion
of <stdbool.h>, so I'd also change it to use "int".


BTW, this last_component function is based on the GPL'd basename.c from gnulib.
All of the ifdefs are to accommodate certain "other" types of systems.
=========================================================
#include <stdbool.h>

#ifndef DIRECTORY_SEPARATOR
# define DIRECTORY_SEPARATOR '/'
#endif

#ifndef ISSLASH
# define ISSLASH(C) ((C) == DIRECTORY_SEPARATOR)
#endif

#ifndef FILE_SYSTEM_PREFIX_LEN
# if FILE_SYSTEM_ACCEPTS_DRIVE_LETTER_PREFIX
    /* This internal macro assumes ASCII, but all hosts that support drive
       letters use ASCII.  */
#  define _IS_DRIVE_LETTER(c) (((unsigned int) (c) | ('a' - 'A')) - 'a' \
				<= 'z' - 'a')
#  define FILE_SYSTEM_PREFIX_LEN(Filename) \
	   (_IS_DRIVE_LETTER ((Filename)[0]) && (Filename)[1] == ':' ? 2 : 0)
# else
#  define FILE_SYSTEM_PREFIX_LEN(Filename) 0
# endif
#endif

/* Return the address of the last file name component of NAME.
   If NAME has no relative file name components because it is
   a file system root, return the empty string.  */

char *
last_component (char const *name)
{
  char const *base = name + FILE_SYSTEM_PREFIX_LEN (name);
  char const *p;
  bool saw_slash = false;

  while (ISSLASH (*base))
    base++;

  for (p = base; *p; p++)
    {
      if (ISSLASH (*p))
	saw_slash = true;
      else if (saw_slash)
	{
	  base = p;
	  saw_slash = false;
	}
    }

  return (char *) base;
}
=========================================================

Here's the patch.

	Remove unchecked strdup that worked around buggy basename.
	* tools/lvmcmdline.c (_find_command, lvm2_main): Let basename
	operate directly on its argument.

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 039eb51..7fbabb2 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -479,18 +479,15 @@ void lvm_register_commands(void)
 static struct command *_find_command(const char *name)
 {
 	int i;
-	char *namebase, *base;
+	char *base;

-	namebase = strdup(name);
-	base = basename(namebase);
+	base = basename(name);

 	for (i = 0; i < _cmdline.num_commands; i++) {
 		if (!strcmp(base, _cmdline.commands[i].name))
 			break;
 	}

-	free(namebase);
-
 	if (i >= _cmdline.num_commands)
 		return 0;

@@ -1138,14 +1135,13 @@ static void _exec_lvm1_command(char **argv)

 int lvm2_main(int argc, char **argv, unsigned is_static)
 {
-	char *namebase, *base;
+	char *base;
 	int ret, alias = 0;
 	struct cmd_context *cmd;

 	_close_stray_fds();

-	namebase = strdup(argv[0]);
-	base = basename(namebase);
+	base = basename(argv[0]);
 	while (*base == '/')
 		base++;
 	if (strcmp(base, "lvm") && strcmp(base, "lvm.static") &&
@@ -1160,8 +1156,6 @@ int lvm2_main(int argc, char **argv, unsigned is_static)
 		unsetenv("LVM_DID_EXEC");
 	}

-	free(namebase);
-
 	if (!(cmd = init_lvm(is_static)))
 		return -1;


