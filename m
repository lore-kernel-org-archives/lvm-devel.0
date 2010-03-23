From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Mar 2010 17:27:34 +0100
Subject: [PATCH 1/6] Reuse clean target for distclean
In-Reply-To: <cover.1269361453.git.zkabelac@redhat.com>
References: <cover.1269361453.git.zkabelac@redhat.com>
Message-ID: <fc778d3aa7c00eb91ea33a7fb142680c1409b581.1269361453.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Instead of duplicating clean target inside distclean target,
just use it as a subtarget and avoid add duplicating code.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 make.tmpl.in |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index ff4d1b2..df4eafa 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -257,12 +257,9 @@ clean: $(SUBDIRS.clean)
 	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
 	      $(SOURCES:%.c=%.gcda) $(LDDEPS)
 
-distclean: $(SUBDIRS.distclean)
+distclean: $(SUBDIRS.clean) $(SUBDIRS.distclean)
 	$(RM) -rf $(DISTCLEAN_DIRS)
-	$(RM) $(DISTCLEAN_TARGETS) \
-	      $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(SOURCES:%.c=%.d) \
-	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
-	      $(SOURCES:%.c=%.gcda) $(LDDEPS) \
+	$(RM) $(DISTCLEAN_TARGETS)  \
 	      config.cache config.log config.status \
 	      Makefile make.tmpl core \
 	      lvm-version.h
-- 
1.7.0.1


