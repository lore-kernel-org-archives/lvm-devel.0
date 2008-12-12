From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 12 Dec 2008 08:04:35 -0500
Subject: [PATCH] New public functions lvm2_reload_config, lvm2_set_config_option and lvm2_reset_config_option.
In-Reply-To: <49424CBE.6020204@redhat.com>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
	<1229013822-10809-2-git-send-email-twoerner@redhat.com>
	<1229013822-10809-3-git-send-email-twoerner@redhat.com>
	<1229013822-10809-4-git-send-email-twoerner@redhat.com>
	<1229032195.20795.34.camel@localhost.localdomain>
	<49424CBE.6020204@redhat.com>
Message-ID: <1229087075.16499.2.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Fri, 2008-12-12 at 12:36 +0100, Thomas Woerner wrote:
> >> diff --git a/lib/lvm2.c b/lib/lvm2.c
> >> index daf9a79..ac5e583 100644
> >> --- a/lib/lvm2.c
> >> +++ b/lib/lvm2.c
> >> @@ -15,6 +15,30 @@
> >>  #include "lvm2.h"
> >>  #include "lib.h"
> >>  #include "toolcontext.h"
> >> +#include "archiver.h"
> >> +#include "activate.h"
> >> +#include "../tools/tools.h"
> >> +
> > 
> > Do we need the relative path here?
> > 
> Ok, I will add tools/tools.h, tools/toollib.h, tools/commands.h and 
> tools/args.h to include/.smylinks. Then it is possible to use
> #include 
> "tools.h".

Actually, including tools/*.h header files in a library file is not
good.  If we need to do that we should probably try to refactor
something.


