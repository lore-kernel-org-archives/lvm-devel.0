From: David Teigland <teigland@sourceware.org>
Date: Tue, 27 Nov 2018 14:43:12 -0500
Subject: master - lvmlockctl: wait by default when stopping
Message-ID: <201811271943.wARJhCMZ019573@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d8284beb23f7a81b27e5acb0ecb90d76809df736
Commit:        d8284beb23f7a81b27e5acb0ecb90d76809df736
Parent:        904e1e3d26ccb43c19266e96e67f8c10f93eaaa4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 27 13:41:33 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 27 13:41:33 2018 -0600

lvmlockctl: wait by default when stopping

lvmlockctl --stop-lockspaces was by default not waiting
for all the lockspaces to be gone.
---
 daemons/lvmlockd/lvmlockctl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 2442b46..0dfc3e6 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -24,7 +24,7 @@
 static int quit = 0;
 static int info = 0;
 static int dump = 0;
-static int wait_opt = 0;
+static int wait_opt = 1;
 static int force_opt = 0;
 static int kill_vg = 0;
 static int drop_vg = 0;


