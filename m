From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:52:09 -0500
Subject: master - makefiles: also fix build of unit test
Message-ID: <201812171052.wBHAq9NB032518@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2076dda0b8e6a33eec92a8e6b4616f8ab5a9b495
Commit:        2076dda0b8e6a33eec92a8e6b4616f8ab5a9b495
Parent:        5db56b36f168bddc4364fbffab1fcee07eb1d664
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 17 11:51:17 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 11:51:38 2018 +0100

makefiles: also fix build of unit test

---
 test/unit/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/unit/Makefile b/test/unit/Makefile
index 0ff128d..7bc7117 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -45,7 +45,7 @@ CLEAN_TARGETS += $(UNIT_DEPENDS) $(UNIT_OBJECTS) \
 $(UNIT_TARGET): $(UNIT_OBJECTS) $(LVMINTERNAL_LIBS)
 	@echo "    [LD] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
-	      -o $@ $+ $(DMEVENT_LIBS) $(LIBS) -laio
+	      -o $@ $+ $(DMEVENT_LIBS) $(SYSTEMD_LIBS) -L$(top_builddir)/libdm -ldevmapper $(LIBS) -laio
 
 .PHONEY: run-unit-test unit-test
 unit-test: $(UNIT_TARGET)


