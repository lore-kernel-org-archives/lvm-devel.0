From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 31 Jul 2015 15:58:59 +0000 (UTC)
Subject: master - dmsetup: _find_command returns const
Message-ID: <20150731155859.1CCB661032@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e06d188f0d9763195c9e6040ffb26b7203e39df2
Commit:        e06d188f0d9763195c9e6040ffb26b7203e39df2
Parent:        fef3cb3f21cba9e88add8ffd1aad8d6691c77109
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 31 16:58:14 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 31 16:58:14 2015 +0100

dmsetup: _find_command returns const

---
 tools/dmsetup.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b803e44..2f62d70 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3149,8 +3149,8 @@ static int _dmsetup_help(CMD_ARGS)
 	return 1;
 }
 
-static struct command *_find_command(const struct command *commands,
-				     const char *name)
+static const struct command *_find_command(const struct command *commands,
+					   const char *name)
 {
 	int i;
 
@@ -3161,7 +3161,7 @@ static struct command *_find_command(const struct command *commands,
 	return NULL;
 }
 
-static struct command *_find_dmsetup_command(const char *name)
+static const struct command *_find_dmsetup_command(const char *name)
 {
 	return _find_command(_dmsetup_commands, name);
 }


