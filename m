From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Nov 2014 08:37:10 +0000 (UTC)
Subject: master - makefiles: avoid regeneration of Makefile
Message-ID: <20141126083710.DB4D16055B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cd98b27825b00459bd8e2c0539ffe5c09ed5b62
Commit:        2cd98b27825b00459bd8e2c0539ffe5c09ed5b62
Parent:        2de11c9e9e9513fb7d9ab0323370e584d3d3acde
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 25 23:01:28 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 26 09:36:12 2014 +0100

makefiles: avoid regeneration of Makefile

When Makefile.in is touched, it's been matched by 'man' rule
and it's been wrongly regnerated.

Put in explicit rules to avoid Makefile sed processing.
---
 man/Makefile.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 40bf7a2..c42f07a 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -92,6 +92,9 @@ man: $(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS)
 
 $(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER):	Makefile
 
+Makefile: Makefile.in
+	@:
+
 %: %.in
 	@case "$@" in \
 	  */*) ;; \


