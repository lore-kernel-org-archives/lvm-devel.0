From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 20 Apr 2016 15:24:39 +0200
Subject: [PATCH] convert major/minor/makedev handling
In-Reply-To: <1461124442-31152-1-git-send-email-vapier@gentoo.org>
References: <1461124442-31152-1-git-send-email-vapier@gentoo.org>
Message-ID: <57178317.6040401@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 20.4.2016 05:54, Mike Frysinger wrote:
> Most of the files in here use MAJOR/MINOR/MKDEV macros, but a few
> missed it.  Update the defines in those files to match them.

Hi

Unfortunately - it's more tricky then it may look at the first sight, so ATM 
NACK  - as that needs some extra thinking.

Basic issue is -   glibc   major()/minor() is different then kernel MAJOR/MINOR.

lvm2/dm IOCTLS do work with kernel  MAJOR/MINOR, while glibc functions are 
operating with glibc logic - which is unfortunately not bit match for kernel 
logic.

Don't ask me what would have happened if there would be a mismatch ;), but the 
logic should be - whenever working with kernel parameters for ioctl - use 
MAJOR/MINOR, when dealing with outputs form  i.e. 'stat()' glibc calls - use 
major()/minor() lib functions.

All of this has different types and signs...
(glibc deploys unsigned long long)



> ---
>   daemons/cmirrord/functions.c                          | 16 ++++++++++++----
>   daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c | 12 ++++++++++--
>   lib/filters/filter-sysfs.c                            |  6 ++++--
>   3 files changed, 26 insertions(+), 8 deletions(-)
>
> diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
> index e9d3c09..5b3cb38 100644
> --- a/daemons/cmirrord/functions.c
> +++ b/daemons/cmirrord/functions.c
> @@ -20,6 +20,14 @@
>   #include <time.h>
>   #include <unistd.h>
>
> +#ifdef __linux__
> +#  include "kdev_t.h"
> +#else
> +#  define MAJOR(x) major((x))
> +#  define MINOR(x) minor((x))
> +#  define MKDEV(x,y) makedev((x),(y))
> +#endif
> +
>   #define BYTE_SHIFT 3
>
>   /*
> @@ -333,8 +341,8 @@ static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_pat
>   			continue;
>   		}
>   		if (S_ISBLK(statbuf.st_mode) &&
> -		    (major(statbuf.st_rdev) == major) &&
> -		    (minor(statbuf.st_rdev) == minor)) {
> +		    (MAJOR(statbuf.st_rdev) == major) &&
> +		    (MINOR(statbuf.st_rdev) == minor)) {

i.e. dealing with  glibc output  ->  major()/minor()

Regards

Zdenek


