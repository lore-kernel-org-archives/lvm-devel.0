From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sun,  9 Aug 2015 23:39:38 +0000 (UTC)
Subject: master - dmsetup: Also install dmstats.
Message-ID: <20150809233938.343AE60F71@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=41001dbfdd54674ead6051d06a8b89701dce68c5
Commit:        41001dbfdd54674ead6051d06a8b89701dce68c5
Parent:        d62a8d2f1535468c75379b877844bdb7666c8c9e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 10 00:35:15 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 10 00:35:15 2015 +0100

dmsetup: Also install dmstats.

---
 spec/packages.inc |    2 ++
 tools/Makefile.in |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 2c0caa8..d781067 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -398,7 +398,9 @@ for the kernel device-mapper.
 %defattr(-,root,root,-)
 %doc COPYING COPYING.LIB WHATS_NEW_DM VERSION_DM README INSTALL
 %attr(755,root,root) %{_sbindir}/dmsetup
+%{_sbindir}/dmstats
 %{_mandir}/man8/dmsetup.8.gz
+%{_mandir}/man8/dmstats.8.gz
 %if %{enable_udev}
 %doc udev/12-dm-permissions.rules
 %dir %{_udevbasedir}
diff --git a/tools/Makefile.in b/tools/Makefile.in
index cec74a9..d6e54f0 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -204,9 +204,11 @@ install_tools_static: lvm.static
 
 install_dmsetup_dynamic: dmsetup
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+	$(LN_S) -f $(<F) $(sbindir)/dmstats
 
 install_dmsetup_static: dmsetup.static
 	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
+	$(LN_S) -f $(<F) $(sbindir)/dmstats
 
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 


