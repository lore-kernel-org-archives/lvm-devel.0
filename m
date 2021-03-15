From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:01 +0000 (GMT)
Subject: main - signals: add interruptible usleep
Message-ID: <20210315101401.3B2713857C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=941f67ed09155011f13bb75db6aed621f94e2374
Commit:        941f67ed09155011f13bb75db6aed621f94e2374
Parent:        bbac843268ab353bb80a7f09841ff467bdcdeb04
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 12 11:18:53 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 14 16:34:38 2021 +0100

signals: add interruptible usleep

Add small wrapper that temporarily enables signal handling during
usleep() and return  '0' when interrupted.
---
 lib/misc/lvm-signal.c | 13 +++++++++++++
 lib/misc/lvm-signal.h |  3 +++
 2 files changed, 16 insertions(+)

diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index b90a2db81..b1653a85c 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -153,3 +153,16 @@ void unblock_signals(void)
 
 	_signals_blocked = 0;
 }
+
+/* usleep with enabled signal handler.
+ * Returns 1 when there was interruption */
+int interruptible_usleep(useconds_t usec)
+{
+	int r;
+
+	sigint_allow();
+	r = usleep(usec);
+	sigint_restore();
+
+	return (sigint_caught() || r) ? 1 : 0;
+}
diff --git a/lib/misc/lvm-signal.h b/lib/misc/lvm-signal.h
index 2f7309f5d..a39f77eb2 100644
--- a/lib/misc/lvm-signal.h
+++ b/lib/misc/lvm-signal.h
@@ -16,6 +16,8 @@
 #ifndef _LVM_SIGNAL_H
 #define _LVM_SIGNAL_H
 
+#include <unistd.h>
+
 void remove_ctrl_c_handler(void);
 void install_ctrl_c_handler(void);
 int init_signals(int suppress_messages);
@@ -28,4 +30,5 @@ void sigint_clear(void);
 void block_signals(uint32_t flags);
 void unblock_signals(void);
 
+int interruptible_usleep(useconds_t usec);
 #endif


