From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 09 May 2013 09:13:26 +0200
Subject: [PATCH 05/19] lvm2app: Move core lv re-size code (v2)
In-Reply-To: <1368053141-13836-6-git-send-email-tasleson@redhat.com>
References: <1368053141-13836-1-git-send-email-tasleson@redhat.com>
	<1368053141-13836-6-git-send-email-tasleson@redhat.com>
Message-ID: <518B4C96.5020601@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 9.5.2013 00:45, Tony Asleson napsal(a):
> Moved to allow use from command line and for library use.
>
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>   lib/metadata/lv_manip.c          | 734 +++++++++++++++++++++++++++++++++++++
>   lib/metadata/metadata-exported.h |  46 +++
>   tools/lvresize.c                 | 773 +--------------------------------------
>   3 files changed, 781 insertions(+), 772 deletions(-)
>
> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
> index 42e0fab..587cbd2 100644
> --- a/lib/metadata/lv_manip.c
> +++ b/lib/metadata/lv_manip.c
> @@ -27,6 +27,8 @@
>   #include "activate.h"
>   #include "str_list.h"
>   #include "defaults.h"
> +#include "lvm-exec.h"
> +#include "errors.h"
>

This '/tools' error from   '/lib'  needs some solution.

Currently /lib reports  1 success, 0 error - and potential error state is
returned via some other mechanism (i.e. setting struct member...)

On the other hand the lvm2app is seriously missing error reporting - since
the user of this API is usually not seeing typical lvm2 log_error messages.

Zdenek


