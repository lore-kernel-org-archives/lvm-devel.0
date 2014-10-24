From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:45 +0000 (UTC)
Subject: master - cleanup: use arg_is_set
Message-ID: <20141024144045.2A67260CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=958cae8fd8e03a1b3d060c07d49953bbdc419b9c
Commit:        958cae8fd8e03a1b3d060c07d49953bbdc419b9c
Parent:        f2ea8904239752df231023a4a3aad704ed8edc73
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 21 12:03:07 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: use arg_is_set

---
 tools/lvcreate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 8b3255c..7ccd9aa 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -790,13 +790,13 @@ static int _read_activation_params(struct lvcreate_params *lp,
 		return 0;
 	}
 
-	if (arg_count(cmd, setactivationskip_ARG)) {
+	if (arg_is_set(cmd, setactivationskip_ARG)) {
 		lp->activation_skip |= ACTIVATION_SKIP_SET;
 		if (arg_int_value(cmd, setactivationskip_ARG, 0))
 			lp->activation_skip |= ACTIVATION_SKIP_SET_ENABLED;
 	}
 
-	if (arg_count(cmd, ignoreactivationskip_ARG))
+	if (arg_is_set(cmd, ignoreactivationskip_ARG))
 		lp->activation_skip |= ACTIVATION_SKIP_IGNORE;
 
 	if (lp->zero && (lp->activation_skip & ACTIVATION_SKIP_SET_ENABLED)


