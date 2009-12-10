From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 10 Dec 2009 13:53:56 +0100
Subject: [PATCH 1/4] Fix coredump and memory leak for 'dmsetup help -c'
In-Reply-To: <cover.1260449368.git.zkabelac@redhat.com>
References: <cover.1260449368.git.zkabelac@redhat.com>
Message-ID: <fc67f51ffd717cb4b6a70e96e5b18ea9d55ae42d.1260449368.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/dmsetup.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 888edff..b5568f0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2402,7 +2402,7 @@ static int _report_init(struct command *c)
 	size_t len = 0;
 	int r = 0;
 
-	if (!strcmp(c->name, "splitname"))
+	if (c && !strcmp(c->name, "splitname"))
 		options = (char *) splitname_report_options;
 
 	/* emulate old dmsetup behaviour */
@@ -2591,7 +2591,9 @@ static int _help(int argc __attribute((unused)),
 		_switches[OPTIONS_ARG] = 1;
 		_string_args[OPTIONS_ARG] = (char *) "help";
 		_switches[SORT_ARG] = 0;
-	
+
+		if (_report)
+			dm_report_free(_report);
 		(void) _report_init(NULL);
 	}
 
-- 
1.6.5.3


