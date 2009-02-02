From: Petr Rockai <prockai@redhat.com>
Date: Tue, 03 Feb 2009 00:22:02 +0100
Subject: [PATCH 02/13] Add lvm_create, lvm_destroy, lvm_reload_config() APIs.
In-Reply-To: <1233607809-1087-3-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 2 Feb 2009 15:49:58 -0500")
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
Message-ID: <87pri077c5.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

see comments inline.

Dave Wysochanski <dwysocha@redhat.com> writes:
> +++ b/lib/lvm2.c
> @@ -0,0 +1,70 @@
> +/*
> + * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
> + *
> + * This file is part of LVM2.
> + *
> + * This copyrighted material is made available to anyone wishing to use,
> + * modify, copy, or redistribute it subject to the terms and conditions
> + * of the GNU Lesser General Public License v.2.1.
> + *
> + * You should have received a copy of the GNU Lesser General Public License
> + * along with this program; if not, write to the Free Software Foundation,
> + * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + */
> +
> +#include "lvm2.h"
> +#include "lib.h"
> +#include "toolcontext.h"
> +#include "locking.h"
> +#include "metadata-exported.h"
> +#include "report.h"
> +
> +
> +lvm_handle_t lvm_create(const char *system_dir)
> +{
> +	struct cmd_context *cmd;
> +
> +	/* To be done:
> +	 * logging bound to handle
> +	 */
> +
> +	/* create context */
> +	cmd = create_toolcontext(1, system_dir);
> +
> +	/* initilize remaining */
> +	if (cmd) {
> +		int locking_type;
> +
> +		/* initilization from lvm_run_command */
> +		init_error_message_produced(0);
> +		sigint_clear();
> +
> +		/* get locking type from config tree */
> +		/* FIXME: config option needed? */
> +		locking_type = find_config_tree_int(cmd, "global/locking_type",
> +						    1);
I'm wondering if it would make sense to unify the code reading the default
locking type and the code reading the fallback options and such. As things are,
half of the configuration processing is done here and the other half inside
init_locking called below (cf lib/locking/locking.c, init_locking).

> +
> +		/* initialize locking */
> +		if (! init_locking(locking_type, cmd)) {
> +			printf("Locking type %d initialisation failed.",
> +			       locking_type);
> +			lvm_destroy((lvm_handle_t) cmd);
> +			return NULL;
> +		}
> +	}
> +
> +	return (lvm_handle_t) cmd;
I'm also wondering if the explicit cast is such a great idea afterall. (I know
this has been brought up before with my patches.) I would probably prefer to
see a comment saying /* lvm_handle_t is an alias for struct cmd_context * */ --
that way, when that fact changes, we will hopefully get a warning from the
compiler on all the places this is assumed (which might be suppressed by the
explicit cast). Or am I wrong on that count?

> +}
> +
> +
> +void lvm_destroy(lvm_handle_t libh)
> +{
> +	destroy_toolcontext((struct cmd_context *)libh);
> +	/* no error handling here */
> +}
> +
> +
> +int lvm_reload_config(lvm_handle_t libh)
> +{
> +	return refresh_toolcontext((struct cmd_context *)libh);
> +}
Should this also cater for locking re-initialisation? I suppose if
configuration changed, so might have locking.

[snip lvm2.h changes, no comments]
[snip test.c changes, no comment either]

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


