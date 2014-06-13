From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Jun 2014 07:59:46 +0000 (UTC)
Subject: master - profile: add thin-generic.profile
Message-ID: <20140613075946.4B2D76033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e0687ca690f9c5aa009e4b1963d46a03f8ba54c
Commit:        8e0687ca690f9c5aa009e4b1963d46a03f8ba54c
Parent:        cf4d5ead0210aa12dfd73fed2061d4d9febce827
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 13 09:45:26 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 13 09:56:29 2014 +0200

profile: add thin-generic.profile

The thin-generic.profile contains settings for thin/thin pool volumes
suitable for generic environment/use containing default settings.
This allows users to change the global lvm.conf settings at will
and still keep the original settings for volumes that have this
thin profile assigned already.
---
 WHATS_NEW                 |    1 +
 conf/Makefile.in          |    2 +-
 conf/thin-generic.profile |    4 ++++
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b77d404..6791f34 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Add thin-generic configuration profile for generic thin settings.
   Fix crash when reporting of empty labels on pvs.
   Use retry_deactivation also when cleaning orphan devices.
   Prompt when setting the VG cluster attr if the cluster is not setup.
diff --git a/conf/Makefile.in b/conf/Makefile.in
index 54852e2..e56b25e 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -19,7 +19,7 @@ CONFSRC=example.conf
 CONFDEST=lvm.conf
 
 PROFILE_TEMPLATES=command_profile_template.profile metadata_profile_template.profile
-PROFILES=$(PROFILE_TEMPLATES) $(srcdir)/thin-performance.profile
+PROFILES=$(PROFILE_TEMPLATES) $(srcdir)/thin-generic.profile $(srcdir)/thin-performance.profile
 
 include $(top_builddir)/make.tmpl
 
diff --git a/conf/thin-generic.profile b/conf/thin-generic.profile
new file mode 100644
index 0000000..229a7fc
--- /dev/null
+++ b/conf/thin-generic.profile
@@ -0,0 +1,4 @@
+allocation {
+	thin_pool_chunk_size_policy = "generic"
+	thin_pool_zero = 1
+}


