From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 May 2014 08:30:33 +0000 (UTC)
Subject: master - cleanup: remove duplicate --commandprofile reference in dumpconfig's help string
Message-ID: <20140521083033.DD1BE6100C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fca77a1ea4343ee6db18a36ffe15d6d4532ee6de
Commit:        fca77a1ea4343ee6db18a36ffe15d6d4532ee6de
Parent:        e9db11f387086787fb1aad5a853990e9e6034ad5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 21 10:30:02 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 21 10:30:02 2014 +0200

cleanup: remove duplicate --commandprofile reference in dumpconfig's help string

---
 tools/commands.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 50db8eb..0fa028d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -57,7 +57,6 @@ xx(dumpconfig,
    "Dump configuration",
    PERMITTED_READ_ONLY,
    "dumpconfig\n"
-   "\t[--commandprofile ProfileName]\n"
    "\t[-f|--file filename] \n"
    "\t[--type {current|default|diff|missing|new|profilable|profilable-command|profilable-metadata} \n"
    "\t[--atversion version]] \n"


