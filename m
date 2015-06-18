From: Liuhua Wang <lwang@suse.com>
Date: Thu, 18 Jun 2015 16:55:22 +0800
Subject: [PATCH] unit-test fix make error
Message-ID: <1434617722-16159-1-git-send-email-lwang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 unit-tests/regex/Makefile.in | 1 +
 1 file changed, 1 insertion(+)

diff --git a/unit-tests/regex/Makefile.in b/unit-tests/regex/Makefile.in
index b15b231..f963146 100644
--- a/unit-tests/regex/Makefile.in
+++ b/unit-tests/regex/Makefile.in
@@ -27,6 +27,7 @@ TARGETS=\
 include $(top_builddir)/make.tmpl
 
 INCLUDES += -I$(top_srcdir)/libdm
+INCLUDES += -I$(top_srcdir)/lib/log
 DM_DEPS = $(top_builddir)/libdm/libdevmapper.so
 DM_LIBS = -ldevmapper $(LIBS)
 
-- 
1.8.4.5


