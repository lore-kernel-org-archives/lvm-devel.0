From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 22 Feb 2013 13:50:06 +0000 (UTC)
Subject: master - configure: Respect pkg-config --cflags for udev.
Message-ID: <20130222135006.94B29674@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a995bac43f8ddcdbb5075053943aa8189df3170
Commit:        6a995bac43f8ddcdbb5075053943aa8189df3170
Parent:        ae6fae9b26b61bcd9cc031ec021224cb4ac28cba
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Feb 18 16:18:41 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 22 14:49:31 2013 +0100

configure: Respect pkg-config --cflags for udev.

---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 8b56f01..b33ddb3 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -34,7 +34,7 @@ LIBS = @LIBS@
 # Extra libraries always linked with static binaries
 STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS)
 DEFS += @DEFS@
-CFLAGS += @CFLAGS@
+CFLAGS += @CFLAGS@ @UDEV_CFLAGS@
 CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@


