From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 25 Sep 2013 14:08:33 +0000 (UTC)
Subject: master - profile: add thin-performance.profile
Message-ID: <20130925140833.CF2D760F43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd796d6a9485287973e61c427ee45694965203a0
Commit:        dd796d6a9485287973e61c427ee45694965203a0
Parent:        78cba8eb3fa262c2c4e1a5c5a3db3e4e0d7e6900
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 25 16:02:38 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 25 16:07:35 2013 +0200

profile: add thin-performance.profile

Define a "performance" profile for thin pools which is exactly:
  - allocation/thin_pool_zero = 0
  - thin_pool_chunk_size_calculation = "performance"
---
 WHATS_NEW                     |    1 +
 conf/Makefile.in              |    2 +-
 conf/thin-performance.profile |    4 ++++
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 04906f0..14ae12e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Add thin-performance configuration profile.
   Add lvm.conf allocation/thin_pool_chunk_size_calculation option.
   Fix contiguous & cling allocation policies for parity RAID.  (2.02.100)
   Set use_lvmetad=0 on lvmconf --enable-cluster, reset to default on --disable-cluster.
diff --git a/conf/Makefile.in b/conf/Makefile.in
index f9947b1..8b5238a 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -19,7 +19,7 @@ CONFSRC=example.conf
 CONFDEST=lvm.conf
 
 DEFAULT_PROFILE=default.profile
-PROFILES=$(DEFAULT_PROFILE)
+PROFILES=$(DEFAULT_PROFILE) thin-performance.profile
 
 include $(top_builddir)/make.tmpl
 
diff --git a/conf/thin-performance.profile b/conf/thin-performance.profile
new file mode 100644
index 0000000..fbd46aa
--- /dev/null
+++ b/conf/thin-performance.profile
@@ -0,0 +1,4 @@
+allocation {
+	thin_pool_chunk_size_calculation = "performance"
+	thin_pool_zero = 0
+}


