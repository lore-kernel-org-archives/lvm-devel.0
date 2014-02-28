From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:03 +0000 (UTC)
Subject: master - spec: Do not treat --with-?=none as having the thing.
Message-ID: <20140228102603.F194060F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d081f072fe5b6f96112196fbb52a9b5cda21c55
Commit:        4d081f072fe5b6f96112196fbb52a9b5cda21c55
Parent:        581eeaf9502a530351a6894ce6d8f6930711e0b2
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Dec 17 10:14:28 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

spec: Do not treat --with-?=none as having the thing.

---
 spec/macros.inc |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/spec/macros.inc b/spec/macros.inc
index 4041086..7b841dd 100644
--- a/spec/macros.inc
+++ b/spec/macros.inc
@@ -18,7 +18,7 @@
 
 %define with() \
 %global configure_flags %(echo -n "%{?configure_flags} " | sed -e "s,--with-%1=[^ ]*,,"; test -n "%{?2}" && echo --with-%1=%2) \
-%global with_flags %(echo -n "%{?with_flags} " | sed -e "s,%1,,"; test -n "%{?2}" && echo %1)
+%global with_flags %(echo -n "%{?with_flags} " | sed -e "s,%1,,"; test -n "%{?2}" && test "%{?2}" != none && echo %1)
 
 %global services monitor
 %define service() \


