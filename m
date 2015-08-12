From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:40:51 +0000 (UTC)
Subject: master - cache: introduce mq and smq profiles
Message-ID: <20150812124051.BC35261086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=694c88e031fb44f957c75bea369b898e1dedf932
Commit:        694c88e031fb44f957c75bea369b898e1dedf932
Parent:        036d90bba6c1ac76195302bc5c7f2f5ce8ad89b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 20 16:46:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:11:16 2015 +0200

cache: introduce mq and smq profiles

Add 2 demo profiles for mq and smq policies.
Show all support profilable params.

Use with: lvcreate --policy cache-mq ....
---
 WHATS_NEW              |    1 +
 conf/Makefile.in       |    8 ++++++--
 conf/cache-mq.profile  |   20 ++++++++++++++++++++
 conf/cache-smq.profile |   14 ++++++++++++++
 4 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9c8a103..347fcd4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.128 - 
 ===================================
+  Add demo cache-mq  and cache-smq profiles.
   Add cmd profilable allocation/cache_policy,cache_settings,cache_mode.
   Require cache_check 0.5.4 for use of --clear-needs-check-flag.
   Fix lvmetad udev rules to not override SYSTEMD_WANTS, add the service instead.
diff --git a/conf/Makefile.in b/conf/Makefile.in
index 43d5f75..128395e 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -20,7 +20,11 @@ CONFDEST=lvm.conf
 CONFLOCAL=lvmlocal.conf
 
 PROFILE_TEMPLATES=command_profile_template.profile metadata_profile_template.profile
-PROFILES=$(PROFILE_TEMPLATES) $(srcdir)/thin-generic.profile $(srcdir)/thin-performance.profile
+PROFILES=$(PROFILE_TEMPLATES) \
+	$(srcdir)/cache-mq.profile \
+	$(srcdir)/cache-smq.profile \
+	$(srcdir)/thin-generic.profile \
+	$(srcdir)/thin-performance.profile
 
 include $(top_builddir)/make.tmpl
 
diff --git a/conf/cache-mq.profile b/conf/cache-mq.profile
new file mode 100644
index 0000000..3c90331
--- /dev/null
+++ b/conf/cache-mq.profile
@@ -0,0 +1,20 @@
+# Demo configuration 'mq' cache policy
+#
+# Note: This policy has been deprecated in favor of the smq policy
+# keyword "default" means, setting is left with kernel defaults.
+#
+
+allocation {
+	cache_pool_chunk_size = 64
+	cache_mode = "writethrough"
+	cache_policy = "mq"
+	cache_settings {
+		mq {
+			sequential_threshold = "default"	#  #nr_sequential_ios
+			random_threshold = "default"		#  #nr_random_ios
+			read_promote_adjustment = "default"
+			write_promote_adjustment = "default"
+			discard_promote_adjustment = "default"
+		}
+	}
+}
diff --git a/conf/cache-smq.profile b/conf/cache-smq.profile
new file mode 100644
index 0000000..c0d6266
--- /dev/null
+++ b/conf/cache-smq.profile
@@ -0,0 +1,14 @@
+# Demo configuration 'smq' cache policy
+#
+# The stochastic multi-queue (smq) policy addresses some of the problems
+# with the multiqueue (mq) policy and uses less memory.
+#
+
+allocation {
+	cache_pool_chunk_size = 64
+	cache_mode = "writethrough"
+	cache_policy = "smq"
+	cache_settings {
+	        # currently no settins for "smq" policy
+	}
+}


