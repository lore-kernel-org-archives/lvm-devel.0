From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:00 -0400
Subject: master - lvmlockd: accept repeated global lock requests
Message-ID: <201805311414.w4VEE03W031126@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c1d3db8dbe45df9f4311f5c19014680ecf26613
Commit:        0c1d3db8dbe45df9f4311f5c19014680ecf26613
Parent:        6a44dceb4895fc3e1b89cad0050bc766250d91a4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 23 13:16:48 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

lvmlockd: accept repeated global lock requests

It's not an error if a command requests the global lock
when it has already acquired it.  It shouldn't happen,
but there could be cases we've not found.
---
 lib/locking/lvmlockd.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index d78b35c..bf9b7a9 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1547,6 +1547,16 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 		}
 	}
 
+	if (result == -EALREADY) {
+		/*
+		 * This should generally not happen because commands should be coded
+		 * to avoid reacquiring the global lock.  If there is a case that's
+		 * missed which causes the command to request the gl when it's already
+		 * held, it's not a problem, so let it go.
+		 */
+		log_debug("lockd global mode %s already held.", mode);
+		return 1;
+	}
 
 	if (!strcmp(mode, "un"))
 		return 1;


