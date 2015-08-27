From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 27 Aug 2015 15:28:56 +0000 (UTC)
Subject: master - lvmlockd: detect when dlm lvb is invalidated
Message-ID: <20150827152856.53CD6603F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58713d34dd71873ab97378e96d7ab0b8e9bda8ef
Commit:        58713d34dd71873ab97378e96d7ab0b8e9bda8ef
Parent:        32e22a00378192f226932258d9c5b55b073b4528
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 26 14:55:27 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 27 10:27:24 2015 -0500

lvmlockd: detect when dlm lvb is invalidated

The lvb content can be lost during dlm recovery,
and we need to detect when this happens to revalidate.
---
 daemons/lvmlockd/lvmlockd-core.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 3d41bd2..ac2d224 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1057,7 +1057,18 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 
 	/* lm_lock() reads new r_version */
 
-	if ((r_version > r->version) || (!r->version && !r->version_zero_valid)) {
+	if ((r_version != r->version) || (!r->version && !r->version_zero_valid)) {
+
+		/*
+		 * r_version only increases, so if it goes down, it means the
+		 * dlm lvb became invalid (happens during recovery if the
+		 * resource master leaves).
+		 */
+		if (r_version < r->version) {
+			log_debug("S %s R %s res_lock lvb invalid r_version %u prev %u",
+				  ls->name, r->name, r_version, r->version);
+		}
+
 		/*
 		 * New r_version of the lock: means that another
 		 * host has changed data protected by this lock


