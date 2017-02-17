From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Feb 2017 21:44:51 +0000 (UTC)
Subject: master - man/help: fix description of r|R unit
Message-ID: <20170217214451.B3E08602D6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13944738d49ee420cb8b6b9eab4984b0a01b700d
Commit:        13944738d49ee420cb8b6b9eab4984b0a01b700d
Parent:        fab0d63121f0ac59996526db40b70cb1efceb306
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 17 15:44:26 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 17 15:44:26 2017 -0600

man/help: fix description of r|R unit

---
 tools/args.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 0575a2f..e7a1ab2 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -673,12 +673,11 @@ arg(unconfigured_ARG, '\0', "unconfigured", 0, 0, 0,
 
 arg(units_ARG, '\0', "units", units_VAL, 0, 0,
     "All sizes are output in these units:\n"
-    "human-(r)eadable with rounding,\n"
+    "human-(r)eadable with '<' rounding indicator,\n"
     "(h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,\n"
     "(g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.\n"
     "Capitalise to use multiples of 1000 (S.I.) instead of 1024.\n"
-    "Custom units can be specified, e.g. --units 3M.\n"
-    "r|R rounds numbers and displays the '<' prefix before rounded values.\n")
+    "Custom units can be specified, e.g. --units 3M.\n")
 
 arg(unquoted_ARG, '\0', "unquoted", 0, 0, 0,
     "When used with --nameprefixes, output values in the field=value\n"


