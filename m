From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Feb 2017 21:34:19 +0000 (UTC)
Subject: master - man: print space before built-in name
Message-ID: <20170217213419.66CB260DC2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fab0d63121f0ac59996526db40b70cb1efceb306
Commit:        fab0d63121f0ac59996526db40b70cb1efceb306
Parent:        87fe9328d30660e2eecd990bfce893ae65817f44
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 17 15:33:04 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 17 15:33:35 2017 -0600

man: print space before built-in name

print 'lvm config' not 'lvm-config'
---
 tools/command.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 2897c65..0ec5176 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2636,8 +2636,11 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 	char *lvmname = name;
 	int i;
 
-	if (!strncmp(name, "lvm-", 4))
+	if (!strncmp(name, "lvm-", 4)) {
+		char *space = strchr(lvmname, '-');
+		*space = ' ';
 		name += 4;
+	}
 
 	cname = find_command_name(name);
 


