From: Nix <nix@esperi.org.uk>
Date: Wed, 12 Sep 2007 12:39:08 -0000
Subject: [PATCH] trivial build fix: link fsadm against liblvm.a
Message-ID: <87642ggisc.fsf@hades.wkstn.nix>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently it's not, which means that since the introduction of
last_path_component(), it hasn't built.

Fix is trivial:

Index: lvm/tools/fsadm/Makefile.in
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/fsadm/Makefile.in,v
retrieving revision 1.2
diff -u -r1.2 Makefile.in
--- lvm/tools/fsadm/Makefile.in	11 Jan 2007 17:12:27 -0000	1.2
+++ lvm/tools/fsadm/Makefile.in	12 Sep 2007 12:38:07 -0000
@@ -20,10 +20,12 @@
 
 TARGETS = fsadm
 
+LVMLIBS = -llvm
+
 include $(top_srcdir)/make.tmpl
 
 fsadm: $(OBJECTS)
-	$(CC) -o $@ $(CFLAGS) $(OBJECTS) -rdynamic
+	$(CC) -o $@ $(CFLAGS) $(OBJECTS) $(LDFLAGS) $(LVMLIBS) -rdynamic
 
 install: fsadm
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) fsadm \


-- 
`Some people don't think performance issues are "real bugs", and I think 
such people shouldn't be allowed to program.' --- Linus Torvalds


