From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  2 Jun 2016 09:59:11 +0000 (UTC)
Subject: master - make: add generated parts of lvmdbusd to DISTCLEAN_TARGETS for make distclean
Message-ID: <20160602095911.43EFE60C4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc37ee63c0562d3f42b597d485495ee79a857dc5
Commit:        fc37ee63c0562d3f42b597d485495ee79a857dc5
Parent:        21cefd3f07f4c6408d5c59c5afd41d3056706513
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 2 11:58:54 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 2 11:58:54 2016 +0200

make: add generated parts of lvmdbusd to DISTCLEAN_TARGETS for make distclean

---
 daemons/lvmdbusd/Makefile.in |    2 ++
 scripts/Makefile.in          |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index 9ee5b0b..c781452 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -63,3 +63,5 @@ install_lvm2: install_lvmdbusd
 
 install: install_lvm2
 
+DISTCLEAN_TARGETS+= \
+	$(LVMDBUS_BUILDDIR_FILES)
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 6df7d05..9c3d72d 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -155,12 +155,14 @@ DISTCLEAN_TARGETS += \
 	blk_availability_systemd_red_hat.service \
 	clvmd_init_red_hat \
 	cmirrord_init_red_hat \
+	com.redhat.lvmdbus1.service \
 	dm_event_systemd_red_hat.service \
 	dm_event_systemd_red_hat.socket \
 	lvm2_cluster_activation_red_hat.sh \
 	lvm2_cluster_activation_systemd_red_hat.service \
 	lvm2_clvmd_systemd_red_hat.service \
 	lvm2_cmirrord_systemd_red_hat.service \
+	lvm2_lvmdbusd_systemd_red_hat.service \
 	lvm2_lvmetad_init_red_hat \
 	lvm2_lvmpolld_init_red_hat \
 	lvm2_lvmetad_systemd_red_hat.service \


