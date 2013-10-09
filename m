From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  9 Oct 2013 12:47:24 +0000 (UTC)
Subject: master - test: Make comma a separator as in make check T=lvconvert, lvcreate
Message-ID: <20131009124724.174D060FF5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fbb6de845e857cfb4144c40dca36456d27abdbe9
Commit:        fbb6de845e857cfb4144c40dca36456d27abdbe9
Parent:        863be9d9c6dbe84f072b77d37a64de601bd2f76b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 9 14:02:34 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 9 14:02:34 2013 +0200

test: Make comma a separator as in make check T=lvconvert,lvcreate

---
 test/Makefile.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 1b9789f..5685544 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -34,7 +34,8 @@ T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
 ALL = $(shell find $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) | sort)
-RUN = $(shell find $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(T)).*" -and -not -regex "$(srcdir)/.*($(S)).*" | sort)
+comma = ,
+RUN = $(shell find $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | sort)
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
 # Shell quote;


