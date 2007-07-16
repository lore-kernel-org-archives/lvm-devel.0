From: Jim Meyering <jim@meyering.net>
Date: Mon, 16 Jul 2007 19:35:56 +0200
Subject: SAME_INODE comparison
Message-ID: <87k5t0z1xf.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In the context of the preceding message, I saw code using memcmp
to compare two stat buffers to see if they refer to the same inode.

Any objection to using this macro,

# define SAME_INODE(Stat_buf_1, Stat_buf_2) \
   ((Stat_buf_1).st_ino == (Stat_buf_2).st_ino \
    && (Stat_buf_1).st_dev == (Stat_buf_2).st_dev)

in the three places where that is done?

                if (!memcmp(&info.st_ino, &info2.st_ino, sizeof(ino_t)))
                            !memcmp(&buf1.st_ino, &buf2.st_ino, sizeof(ino_t)))
                    !memcmp(&buf1.st_ino, &buf2.st_ino, sizeof(ino_t)))

Using the macro makes the code more readable, and also adds the st_dev
comparison, so that if by some bizarre chance (or mischief) you get
two files with the same st_ino value, but from *different* devices,
it won't get a false positive.  E.g., the above would become

                if (SAME_INODE(info, info2)
                            SAME_INODE(&buf1, &buf2))
                    SAME_INODE(buf1, buf2))

FYI, those uses are from these two files:
  lib/filters/filter-persistent.c
  lib/locking/file_locking.c

Here are the two .h files directly included by both of those .c files:
      #include "lib.h"
      #include "config.h"

So, I'm inclined to put the #define (or an equivalent static inline function)
in e.g., lib/misc/misc.h and let lib/misc/lib.h include misc.h.

Alternative: put the macro/function directly in lib.h.

Preferences?


