From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jun 2015 12:48:39 +0000 (UTC)
Subject: master - cleanup: drop double const
Message-ID: <20150615124839.B70356006F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ac6b3559780ccabc8cd46353e10520677b3c1277
Commit:        ac6b3559780ccabc8cd46353e10520677b3c1277
Parent:        edbdbddfb67990048512b6dbd6772fd69ad34f86
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 27 15:46:41 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 15 14:46:44 2015 +0200

cleanup: drop double const

Second const is unneeded.
Also always create whole array with MAX elements.
---
 daemons/lvmpolld/lvmpolld-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index c5b22d7..9d46c7e 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -852,7 +852,7 @@ enum action_index {
 	ACTION_MAX /* keep at the end */
 };
 
-static const action_fn_t const actions[] = { [ACTION_DUMP] = action_dump };
+static const action_fn_t actions[ACTION_MAX] = { [ACTION_DUMP] = action_dump };
 
 static int _make_action(enum action_index idx, void *args)
 {


