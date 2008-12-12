From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 12 Dec 2008 01:33:02 +0000
Subject: [PATCH] New public functions lvm2_reload_config, lvm2_set_config_option and lvm2_reset_config_option.
In-Reply-To: <1229032195.20795.34.camel@localhost.localdomain>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
	<1229013822-10809-2-git-send-email-twoerner@redhat.com>
	<1229013822-10809-3-git-send-email-twoerner@redhat.com>
	<1229013822-10809-4-git-send-email-twoerner@redhat.com>
	<1229032195.20795.34.camel@localhost.localdomain>
Message-ID: <20081212013301.GV24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 11, 2008 at 04:49:55PM -0500, Dave Wysochanski wrote:
> On Thu, 2008-12-11 at 17:43 +0100, Thomas Woerner wrote:
> > +++ b/lib/lvm2.c
> > @@ -15,6 +15,30 @@
> > +#include "../tools/tools.h"
> Do we need the relative path here?

Indeed, that's a no-no.

> We should avoid duplicating this code with lvmcmdline.c.  Did you check
> the other callers to see if we could consolidate somehow?
 
Ditto.

> > @@ -30,6 +54,8 @@ lvm2_handle_t lvm2_create(const char *sys_dir)
> > +  _apply_settings(cmd);

Superfluous, due to the recent set of checkins from Dave.

> > +int lvm2_reload_config(lvm2_handle_t libh)

Again, these functions should be integrated into the library proper.

> > +int lvm2_set_config_option(lvm2_handle_t libh, const char *option,
> > +			   const char *value)
> > +{
> > +  return 1;
> > +}
> > +
> > +int lvm2_reset_config_option(lvm2_handle_t libh, const char *option)

Do we really need that yet?
How about just exposing a function that clears them all in one go for now?
To reset individual ones we could use the previous function with a value
of NULL as meaning to delete it from the tree.
(Arguably an option of NULL could mean to reset them all.)

> > + * Description: Load an lvm config option into the existing configuration.
> > + *   The formation of the option parameter is similar to the names
> > + *   in /etc/lvm/lvm.conf.
> > + *   An option within a section is specified with a '/' between the
> > + *   section name and option.  For example, the 'filter' option in the
> > + *   devices section is specified by 'devices/filter'

We do already handle that format to some extent:
# lvm dumpconfig log/verbose
verbose=0
# lvm dumpconfig log/file
file="/var/log/lvm2.log"

so let's try to extend the generic functionality to handle it?

Perhaps:
# lvm dumpconfig --config 'log/verbose=3' log/verbose
verbose=3

with a new cmdline option to make that output
log/verbose=3

(and as this is generic, it would also work in lvm.conf of course)

> > +int lvm2_set_config_option(lvm2_handle_t h, const char *option,
> > +			   const char *value);

> > + * lvm2_remove_config_option
> > +int lvm2_reset_config_option(lvm2_handle_t h, const char *option);

> We should probably be consistent with return code types - uint32_t?

Userspace library - int should be adequate, don't think there's a need for fixed-width
is there?

Alasdair
-- 
agk at redhat.com


