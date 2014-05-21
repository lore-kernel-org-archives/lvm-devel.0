From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 08:57:19 +0000 (UTC)
Subject: master - man: call installers only when there are set vars.
Message-ID: <20140521085719.2BE1060E23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ddc68ccd72036d00b6d89c1baa9fa544d093095
Commit:        1ddc68ccd72036d00b6d89c1baa9fa544d093095
Parent:        fca77a1ea4343ee6db18a36ffe15d6d4532ee6de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 10:50:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 10:52:33 2014 +0200

man: call installers only when there are set vars.

When MAN7, MAN8CLUSTER or MAN8SYSTEMD_GENERATORS would be empty,
don't call respective INSTALL tools.
On older systems they even generate error causing abort
of makefile target.
---
 man/Makefile.in |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index dd59555..15f0252 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -107,8 +107,10 @@ install_man5: $(MAN5)
 	$(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
 
 install_man7: $(MAN7)
+ifdef MAN7
 	$(INSTALL) -d $(MAN7DIR)
 	$(INSTALL_DATA) $(MAN7) $(MAN7DIR)/
+endif
 
 install_man8: $(MAN8)
 	$(INSTALL) -d $(MAN8DIR)
@@ -117,15 +119,19 @@ install_man8: $(MAN8)
 install_lvm2: install_man5 install_man7 install_man8
 
 install_cluster: $(MAN8CLUSTER)
+ifdef MAN8CLUSTER
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8CLUSTER) $(MAN8DIR)/
+endif
 
 install_device-mapper: $(MAN8DM)
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8DM) $(MAN8DIR)/
 
 install_systemd_generators: $(MAN8SYSTEMD_GENERATORS)
+ifdef MAN8SYSTEMD_GENERATORS
 	$(INSTALL) -d $(MAN8DIR)
 	$(INSTALL_DATA) $(MAN8SYSTEMD_GENERATORS) $(MAN8DIR)/
+endif
 
 install: install_lvm2 install_device-mapper


