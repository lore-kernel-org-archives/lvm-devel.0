From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 7 Dec 2008 12:17:31 +0000
Subject: [PATCH] Add liblvm interactive test infrastructure to build.
In-Reply-To: <1228624391-904-1-git-send-email-dwysocha@redhat.com>
References: <1228624391-904-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081207121730.GJ26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Dec 06, 2008 at 11:33:11PM -0500, Dave Wysochanski wrote:
>  configure            |    3 +-
>  configure.in         |    1 +

>  lib/liblvm2.h        |   43 +++++++++++++++++++++
include/.symlinks missing from patch

>  test/api/Makefile.in |   38 ++++++++++++++++++
>  test/api/test.c      |  102 ++++++++++++++++++++++++++++++++++++++++++++++++++


> diff --git a/lib/liblvm2.h b/lib/liblvm2.h

Try just "lvm2.h" ?
(i.e. It can be /usr/include/lvm2.h alongside the existing /usr/include/lvm2cmd.h)

> new file mode 100644
> index 0000000..757cd31
> --- /dev/null
> +++ b/lib/liblvm2.h

Missing copyright notice (also applies to some other new files).

> @@ -0,0 +1,43 @@
> +#ifndef _LIBLVM_API_H_

Try _LIB_LVM2_H ?

> +/*
> + * lvm2_close
> +int lvm2_close(lvm_context_t h);
> + *
> + * Description: Close an LVM2 context allocated with lvm2_open
> + *
> + * Parameters:
> + * - h (IN): context obtained from lvm2_open
> + *
> + * Returns:
> + * 0 - fail
> + * 1 - success
> + */

For the public library, I think 0 = success fits better - that's what we
have in our one other public library so far, liblvm2cmd, and fits in with
the idea we mentioned of trying errno values for errors.

(I'm not that keen on open/close here - personally I find create/new & destroy matches
the functionality better - and I prefer 'handle' to 'context'.)

And in what way is this function allowed to fail, anyway - what stops it from
being void?

> +++ b/test/api/test.c

> +#include "../../lib/liblvm2.h"

Try to avoid relative paths - use -I<dir> instead.

Alasdair
-- 
agk at redhat.com


