From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  3 Sep 2013 07:52:41 +0000 (UTC)
Subject: master - pvscan: show -aay with --cache for help
Message-ID: <20130903075241.4691460EC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a5838a69ccd0b6eb2f6c69ec9a12de37c7ba73c
Commit:        6a5838a69ccd0b6eb2f6c69ec9a12de37c7ba73c
Parent:        44c1a02c1805ec4487af1bc3057fcd8e40f8a375
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 3 09:51:30 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 3 09:51:30 2013 +0200

pvscan: show -aay with --cache for help

---
 tools/commands.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 841a6b6..f9f81c5 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -724,8 +724,7 @@ xx(pvscan,
    "List all physical volumes",
    PERMITTED_READ_ONLY,
    "pvscan " "\n"
-   "\t[-a|--activate ay]\n"
-   "\t[--cache [ DevicePath | --major major --minor minor]...]\n"
+   "\t[--cache [-a|--activate ay] [ DevicePath | --major major --minor minor]...]\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
    "\t[-h|-?|--help]" "\n"


