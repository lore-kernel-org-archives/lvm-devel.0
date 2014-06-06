From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:02:55 +0000 (UTC)
Subject: dev-prajnoha-report-select - configure: accept 'none' as mangling mode
Message-ID: <20140606120255.9AAC960F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b3ace4f9afaf36688820b72fdca7dcc54928151f
Commit:        b3ace4f9afaf36688820b72fdca7dcc54928151f
Parent:        93c2614e566c1aafae178c34838da21caf8ea16a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 14:38:10 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:47:23 2014 +0200

configure: accept 'none' as mangling mode

Since we advertise 'none' as mangling name, accept it.
Keep it backward compatible and leave disabled option still working
(though I guess there is likely no user of this option...)
---
 configure.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index 807ad32..b16d34a 100644
--- a/configure.in
+++ b/configure.in
@@ -244,7 +244,7 @@ AC_ARG_WITH(default-name-mangling,
 	    MANGLING=$withval, MANGLING=auto)
 case "$MANGLING" in
  auto) mangling=DM_STRING_MANGLING_AUTO;;
- disabled) mangling=DM_STRING_MANGLING_NONE;;
+ none|disabled) mangling=DM_STRING_MANGLING_NONE;;
  hex) mangling=DM_STRING_MANGLING_HEX;;
  *) AC_MSG_ERROR([--with-default-name-mangling parameter invalid]);;
 esac


