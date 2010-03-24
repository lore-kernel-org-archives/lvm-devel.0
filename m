From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 24 Mar 2010 11:44:05 -0400
Subject: [PATCH v2] improve activation monitoring option processing
In-Reply-To: <20100324130736.GA19258@redhat.com>
References: <1269372233-4199-1-git-send-email-snitzer@redhat.com>
	<4BA9D905.9090107@redhat.com> <20100324130736.GA19258@redhat.com>
Message-ID: <20100324154359.GA845@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 24 2010 at  9:07am -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Wed, Mar 24 2010 at  5:19am -0400,
> Milan Broz <mbroz@redhat.com> wrote:
> 
> > 
> > 
> > On 03/23/2010 08:23 PM, Mike Snitzer wrote:
> > > Add "monitoring" option to "activation" section of lvm.conf
> > >
> > > Have clvmd consult the lvm.conf "activation/monitoring" too.
> > please do it something like this... (untested)
> 
> OK, I already committed that other patch (got ack to do so).
> 
> Your patch looks good.  I had some doubts about checking lvm.conf like I
> did in do_lock_query (but didn't explicitly share as much).

Update _process_config() to establish '_dmeventd_monitor' global based
on lvm.conf.  This allows clvmd's calls to create_toolcontext() and
refresh_toolcontext() to (re)establish dmeventd monitoring based on
lvm.conf (rather than always using DEFAULT_DMEVENTD_MONITOR).

clvmd's do_lock_lv() already properly controls dmeventd monitoring based
on LCK_DMEVENTD_MONITOR_MODE in lock_flags -- which currently gets set
based on the '_dmeventd_monitor' global.

Follow-on work will tie command line overrides into the command context
to allow clvmd's dmeventd monitoring to be controlled from the
commandline.  So clvmd will consult the command context for dmeventd
monitoring mode rather than looking at the global (which is process
specific).

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 60b6db4..3060954 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -542,12 +542,8 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(0);
 
-	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE)) {
-		int dmeventd_mode =
-			find_config_tree_bool(cmd, "activation/monitoring",
-					      DEFAULT_DMEVENTD_MONITOR);
-		init_dmeventd_monitor(dmeventd_mode);
-	}
+	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
+		init_dmeventd_monitor(1);
 
 	cmd->partial_activation = 0;
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 7aac361..94375de 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -281,6 +281,10 @@ static int _process_config(struct cmd_context *cmd)
 						  "activation/missing_stripe_filler",
 						  DEFAULT_STRIPE_FILLER);
 
+	init_dmeventd_monitor(find_config_tree_bool(cmd,
+						    "activation/monitoring",
+						    DEFAULT_DMEVENTD_MONITOR));
+
 	/* FIXME Missing error code checks from the stats, not log_warn?, notify if setting overridden, delay message/check till it is actually used (eg consider if lvm shell - file could appear later after this check)? */
 	if (!strcmp(cmd->stripe_filler, "/dev/ioerror") &&
 	    stat(cmd->stripe_filler, &st))


