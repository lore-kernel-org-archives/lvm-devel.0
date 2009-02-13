From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 13 Feb 2009 06:42:06 -0500
Subject: [PATCH 02/13] Add lvm_create, lvm_destroy, lvm_reload_config() APIs.
In-Reply-To: <87pri077c5.fsf@eriador.mornfall.net>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<87pri077c5.fsf@eriador.mornfall.net>
Message-ID: <1234525326.2731.38.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2009-02-03 at 00:22 +0100, Petr Rockai wrote:
> Hi,
> 
> see comments inline.
> 
> Dave Wysochanski <dwysocha@redhat.com> writes:
> > +++ b/lib/lvm2.c
> > @@ -0,0 +1,70 @@
> > +/*
> > + * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
> > + *
> > + * This file is part of LVM2.
> > + *
> > + * This copyrighted material is made available to anyone wishing to use,
> > + * modify, copy, or redistribute it subject to the terms and conditions
> > + * of the GNU Lesser General Public License v.2.1.
> > + *
> > + * You should have received a copy of the GNU Lesser General Public License
> > + * along with this program; if not, write to the Free Software Foundation,
> > + * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> > + */
> > +
> > +#include "lvm2.h"
> > +#include "lib.h"
> > +#include "toolcontext.h"
> > +#include "locking.h"
> > +#include "metadata-exported.h"
> > +#include "report.h"
> > +
> > +
> > +lvm_handle_t lvm_create(const char *system_dir)
> > +{
> > +	struct cmd_context *cmd;
> > +
> > +	/* To be done:
> > +	 * logging bound to handle
> > +	 */
> > +
> > +	/* create context */
> > +	cmd = create_toolcontext(1, system_dir);
> > +
> > +	/* initilize remaining */
> > +	if (cmd) {
> > +		int locking_type;
> > +
> > +		/* initilization from lvm_run_command */
> > +		init_error_message_produced(0);
> > +		sigint_clear();
> > +
> > +		/* get locking type from config tree */
> > +		/* FIXME: config option needed? */
> > +		locking_type = find_config_tree_int(cmd, "global/locking_type",
> > +						    1);
> I'm wondering if it would make sense to unify the code reading the default
> locking type and the code reading the fallback options and such. As things are,
> half of the configuration processing is done here and the other half inside
> init_locking called below (cf lib/locking/locking.c, init_locking).
> 

I did submit a patch I thought was a simple cleanup but more work is
needed to clean up locking.  Ideally I'd like to place init_locking
inside create_toolcontext and just make this the initialization
function.  I ran into a problem with clvmd though being a "locking
implementor" or "locking backend".  Alasdair spent some time with me
brainstorming how we might solve this - splitting the API into different
portions:
1. Calls ok for a locking back-end
2. Calls ok for a locking front-end
3. Calls ok for both

I have temporarily put this on the back-burner while I try to solve some
other things but should make another attempt at cleanup soon.


> > +
> > +void lvm_destroy(lvm_handle_t libh)
> > +{
> > +	destroy_toolcontext((struct cmd_context *)libh);
> > +	/* no error handling here */
> > +}
> > +
> > +
> > +int lvm_reload_config(lvm_handle_t libh)
> > +{
> > +	return refresh_toolcontext((struct cmd_context *)libh);
> > +}
> Should this also cater for locking re-initialisation? I suppose if
> configuration changed, so might have locking.
> 

Indeed - thanks.


