From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 26 Jul 2013 11:05:51 +0000 (UTC)
Subject: master - filters: fix segfault on incorrect global_filter
Message-ID: <20130726110551.C6F19612C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ecc9f74988f7e18a24741e3bf55753383cc904b6
Commit:        ecc9f74988f7e18a24741e3bf55753383cc904b6
Parent:        06dce7d5398cf44a4502ff730987e99bc8b3b78a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 26 12:47:28 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 26 13:04:53 2013 +0200

filters: fix segfault on incorrect global_filter

When using a global_filter and if this filter is incorrectly
specified, we ended up with a segfault:

  raw/~ $ pvs
    Invalid filter pattern "r|/dev/sda".
  Segmentation fault (core dumped)

In the example above a closing '|' character is missing at the end
of the regex. The segfault itself was caused by trying to destroy
the same filter twice in _init_filters fn within the error path
(the "bad" goto target):

bad:
        if (f3)
                f3->destroy(f3);
        if (f4)
                f4->destroy(f4);

Where f3 is the composite filter (sysfs + regex + type + md + mpath filter)
and f4 is the persistent filter which encompasses this composite filter
within persistent filter's 'real' field in 'struct pfilter'.

So in the end, we need to destroy the persistent filter only as
this will also destroy any 'real' filter attached to it.
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |    7 +++----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3544f87..3318454 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Fix segfault if devices/global_filter is not specified correctly.
 
 Version 2.02.99 - 24th July 2013
 ================================
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index b284ce5..48fc489 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -940,8 +940,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 
 	if (!(f4 = persistent_filter_create(cmd->dev_types, f3, dev_cache))) {
 		log_verbose("Failed to create persistent device filter.");
-		f3->destroy(f3);
-		return_0;
+		goto bad;
 	}
 
 	/* Should we ever dump persistent filter state? */
@@ -977,10 +976,10 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 
 	return 1;
 bad:
-	if (f3)
-		f3->destroy(f3);
 	if (f4)
 		f4->destroy(f4);
+	else if (f3)
+		f3->destroy(f3);
 	if (toplevel_components[0])
 		toplevel_components[0]->destroy(toplevel_components[0]);
 	return 0;


