From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:32 -0500
Subject: master - makefiles: missing cleaning
Message-ID: <201812171008.wBHA8WFY024806@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a66520645395eb2ee19a8a9bc924a5a618330379
Commit:        a66520645395eb2ee19a8a9bc924a5a618330379
Parent:        f619cac598e9236dd16c7fd8d3465b981c4a4648
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 17 02:04:11 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:36:52 2018 +0100

makefiles: missing cleaning

---
 scripts/Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 6c8546d..ffca04a 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -138,6 +138,7 @@ DISTCLEAN_TARGETS += \
 	dm_event_systemd_red_hat.service \
 	dm_event_systemd_red_hat.socket \
 	lvmdump.sh \
+	lvm2-pvscan.service \
 	lvm2_cluster_activation_red_hat.sh \
 	lvm2_cluster_activation_systemd_red_hat.service \
 	lvm2_clvmd_systemd_red_hat.service \


