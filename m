From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 20 Jan 2009 17:53:46 +0000
Subject: LVM2 ./configure ./configure.in tools/lvm-static.c
In-Reply-To: <20090120170754.30736.qmail@sourceware.org>
References: <20090120170754.30736.qmail@sourceware.org>
Message-ID: <20090120175346.GJ9859@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jan 20, 2009 at 05:07:54PM -0000, mbroz at sourceware.org wrote:
> 	Fix problems with static build
> 	- compiler warning (missing header)
 	
> +++ LVM2/tools/lvm-static.c	2009/01/20 17:07:53	1.7
> @@ -14,6 +14,7 @@
>   */
>  
>  #include "lvm2cmdline.h"
> +#include "lib.h"

Two problems here:

  Firsly, lib.h is only for library code - tools use tools.h.

  Secondly, this file must be the first to be included because
it is setting options that might change how files included later
behave.

Alasdair
-- 
agk at redhat.com


