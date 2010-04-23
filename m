From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 23 Apr 2010 11:39:29 -0400
Subject: LVM2 ./WHATS_NEW tools/toollib.c
In-Reply-To: <20100414021950.27930.qmail@sourceware.org>
References: <20100414021950.27930.qmail@sourceware.org>
Message-ID: <20100423153929.GA26872@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 13 2010 at 10:19pm -0400,
agk at sourceware.org <agk@sourceware.org> wrote:

> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	agk at sourceware.org	2010-04-14 02:19:49
> 
> Modified files:
> 	.              : WHATS_NEW 
> 	tools          : toollib.c 
> 
> Log message:
> 	Only pass visible LVs to tools in cmdline VG name/tag expansions without -a
> 
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1516&r2=1.1517
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.193&r2=1.194
> 
> --- LVM2/WHATS_NEW	2010/04/13 23:57:41	1.1516
> +++ LVM2/WHATS_NEW	2010/04/14 02:19:49	1.1517
> @@ -1,5 +1,6 @@
>  Version 2.02.63 -  
>  ================================
> +  Only pass visible LVs to tools in cmdline VG name/tag expansions without -a.
>    Use typedefs for toollib process_each functions.
>    Use C locales and use_mlockall for clvmd.
>    Refactor code related to vg->pvs list and add pv->vg link.
> --- LVM2/tools/toollib.c	2010/04/13 23:57:41	1.193
> +++ LVM2/tools/toollib.c	2010/04/14 02:19:49	1.194
> @@ -125,6 +125,13 @@
>  		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
>  			continue;
>  
> +		/*
> +		 * Only let hidden LVs through it --all was used or the LVs 
> +		 * were specifically named on the command line.
> +		 */
> +		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
> +			continue;
> +
>  		/* Should we process this LV? */
>  		if (process_all)
>  			process_lv = 1;

Given that you've now made this check at a higher level I believe the
following check in _lvs_single() is redundant.  It also serves to
disallow displaying hidden LVs that were specifically named on the
command line:

diff --git a/tools/reporter.c b/tools/reporter.c
index bd3c116..1332cc3 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -33,9 +33,6 @@ static int _vgs_single(struct cmd_context *cmd __attribute((unused)),
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
 		       void *handle)
 {
-	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
-		return ECMD_PROCESSED;
-
 	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL)) {
 		stack;
 		return ECMD_FAILED;


