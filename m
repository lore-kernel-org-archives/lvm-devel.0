From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 23 Sep 2016 10:49:19 +0000 (UTC)
Subject: master - make: also clean up lvmdump.sh with substitutions - there's original lvmdump.sh.in
Message-ID: <20160923104919.934A060A70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dbcfd59714bddb3162d97575e66e000d2d83acb6
Commit:        dbcfd59714bddb3162d97575e66e000d2d83acb6
Parent:        f2efd04052c9cdd86d636e77e645db778935fdc8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Sep 23 12:48:52 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Sep 23 12:48:52 2016 +0200

make: also clean up lvmdump.sh with substitutions - there's original lvmdump.sh.in

---
 scripts/Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index e674239..9c28956 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -158,6 +158,7 @@ DISTCLEAN_TARGETS += \
 	com.redhat.lvmdbus1.service \
 	dm_event_systemd_red_hat.service \
 	dm_event_systemd_red_hat.socket \
+	lvmdump.sh \
 	lvm2_cluster_activation_red_hat.sh \
 	lvm2_cluster_activation_systemd_red_hat.service \
 	lvm2_clvmd_systemd_red_hat.service \


