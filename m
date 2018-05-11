From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 11 May 2018 01:47:03 -0400
Subject: master - doc: add a little document describing new directory structure.
Message-ID: <201805110547.w4B5l3Kf000380@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0a31fb4aa323e0e8636d9c0b9332d14df86afda5
Commit:        0a31fb4aa323e0e8636d9c0b9332d14df86afda5
Parent:        576dd1fc41259a9ed3d95b2385305fc035058618
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 11 06:46:25 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 11 06:46:25 2018 +0100

doc: add a little document describing new directory structure.

---
 doc/refactoring.txt |  158 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 158 insertions(+), 0 deletions(-)

diff --git a/doc/refactoring.txt b/doc/refactoring.txt
new file mode 100644
index 0000000..2e9df21
--- /dev/null
+++ b/doc/refactoring.txt
@@ -0,0 +1,158 @@
+Over time, I'd like to refactor the LVM code into these high level modules.
+
+
+         +-------------------------------------------+
+         |                                           |
+         |   User Interface                          |
+         |                                           |
+         |                                           |
+         +-------------------+-----------------------+
+                             |
+        +--------------------v-----------------------+
+        |                                            |
+        |   LVM Core                                 |
+        |                                            |
+        |                                            |
+        +----+----------------+-----------------+----+
+             |                |                 |
+       +-----v-----+    +-----v------+   +------v----+
+       |           |    |            |   |           |
+       |  Device   |    |  Metadata  |   |  System   |
+       |  Mapper   |    |            |   |           |
+       |           |    |            |   |           |
+       |           |    |            |   |           |
+       |           |    |            |   |           |
+       +-----------+    +------------+   +-----------+
+
++---------------------------------------------------------+
+
+
+       +------------------------------------+
+       |                                    |
+       |   Base                             |
+       |                                    |
+       |                                    |
+       |                                    |
+       |                                    |
+       +------------------------------------+
+
+Going from the bottom up we have:
+
+Base
+----
+
+This holds all our general purpose code such as data structures, regex engine,
+memory allocators.  In fact pretty much everything in libdevmapper apart from
+the dm code and config.
+
+This can be used by any code in the system, which is why I've drawn a line
+between it and the code above rather than using arrows.
+
+If anyone can come up with a better name please do.  I'm trying to stay away
+from 'utils'.
+
+
+Device mapper
+-------------
+
+As well as the low level dm-ioctl driving code we need to have all our dm 'best
+practise' stuff in here.  For instance this is the code that decides to use the
+mirror target to move some data around; that knows to suspend a thin volume
+before taking a snapshot of it.  This module is going to have a lot more code
+in it than the current libdevmapper.
+
+It should not know anything about the LVM abstractions or metadata (no PVs, LVs
+or VGs).  It just knows about the dm world.
+
+Code in here is only allowed to use base.
+
+
+Metadata model
+--------------
+
+Here we have all the format handling, labelling, config parsing etc.  We try
+and put *everything* to do with LVM in here that doesn't actually require dm.
+
+
+System
+------
+
+Code that interfaces with the system (udev etc).
+
+
+LVM Core
+--------
+
+[terrible name]
+
+This ties together the last 3 units.  It should just be glue.  We need to be
+strict about pushing code down from here to keep this as small as possible.
+
+
+User interface
+--------------
+
+Self explanatory.
+
+
+Headers
+-------
+
+Headers will be included using sub directories to make it clearer where they
+are in the tree.
+
+eg,
+  #include "base/mm/pool.h"
+  #include "base/data-struct/list.h"
+  #include "dm/thin-provisioning.h"
+  #include "core/pvmove.h"
+
+
+Getting there
+=============
+
++-------------------------------------------+
+|                                           |
+|                                           |
+|    Tools                                  |
+|                                           |
+|                                           |
+|                                           |
++---------+------------------------------+--+
+          |                              |
+          |              +---------------v---------------------------+
+          |              |                                           |
+          |              |                                           |
+          |              |    Lib                                    |
+          |              |                                           |
+          |              |                                           |
+          |              |                                           |
+          |              |                                           |
+          |              +----------------+--------------------------+
+          |                               |
+          |                               |
+    +-----v-------------------------------v-----+
+    |                                           |
+    |                                           |
+    |    libdevmapper                           |
+    |                                           |
+    |                                           |
+    |                                           |
+    |                                           |
+    +-------------------------------------------+
+
+This is where I see us now.
+
+'base' should be easy to factor out, it's just the non-dm part of libdevmapper
+(ie. the bulk of it).  But we have the problem that libdevmapper is a public
+interface to get round.
+
+'lib' is where the bulk of our code currently is.  Dependency-wise the code is
+a bit like a ball of string.  So splitting it up is going to take time.  We can
+probably pull code pretty quickly into the 'metadata model' dir.  But factoring
+out the dm best practises stuff is going to require splitting at least
+files, and probably functions.  Certainly not something that can be done in one
+go.  System should just be a question of cherry picking functions.
+
+I'm not too familiar with the tools dir.  Hopefully it just corresponds with
+the User Interface module and doesn't contain any business logic.


