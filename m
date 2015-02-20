From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 20 Feb 2015 21:32:48 +0000 (UTC)
Subject: master - vgchange, vgcreate: add systemid option to command help
Message-ID: <20150220213248.080DD601EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37a47c0eec68fe3b7abf760be87e619aa51bc544
Commit:        37a47c0eec68fe3b7abf760be87e619aa51bc544
Parent:        3361e662f4b05096ca6cae9f4d96bbeec8ec4862
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 20 15:31:17 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 20 15:31:17 2015 -0600

vgchange, vgcreate: add systemid option to command help

---
 tools/commands.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index e82cfe4..15a1bb1 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -950,8 +950,10 @@ xx(vgchange,
    "\t[--[vg]metadatacopies #copies]\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
+   "\t[--systemid SystemID]\n"
    "\t[--refresh]\n"
    "\t[-S|--select Selection]\n"
+   "\t[--systemid SystemID]\n"
    "\t[--sysinit]\n"
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"


