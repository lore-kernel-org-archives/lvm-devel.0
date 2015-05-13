From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 22:19:49 +0000 (UTC)
Subject: master - makefiles: drop way too generic deps
Message-ID: <20150513221949.D56D160F52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea846f1ca2910f03d66e2859b8189a215b3d8d4c
Commit:        ea846f1ca2910f03d66e2859b8189a215b3d8d4c
Parent:        02e10f4ccd60f66a00d5406452459317baba7c62
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 13 14:22:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 00:19:32 2015 +0200

makefiles: drop way too generic deps

---
 make.tmpl.in |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index dce5b2c..d85dd69 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -398,8 +398,6 @@ cflow: $(CFLOW_TARGET).cflow $(CFLOW_TARGET).tree $(CFLOW_TARGET).rxref $(CFLOW_
 endif
 endif
 
-$(TARGETS): $(OBJECTS)
-
 %.o: %.c
 	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 


