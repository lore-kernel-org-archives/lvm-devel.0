From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 21 Jan 2010 12:27:54 -0500
Subject: [PATCH] Locking type do not use ignorelockingfailure, fix message.
In-Reply-To: <1264090528-2960-1-git-send-email-mbroz@redhat.com>
References: <1264090528-2960-1-git-send-email-mbroz@redhat.com>
Message-ID: <1264094874.4120.4.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2010-01-21 at 17:15 +0100, Milan Broz wrote:
> ---
>  lib/locking/no_locking.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
> index 85374b3..9de143b 100644
> --- a/lib/locking/no_locking.c
> +++ b/lib/locking/no_locking.c
> @@ -72,7 +72,7 @@ static int _readonly_lock_resource(struct cmd_context *cmd,
>  	    (flags & LCK_SCOPE_MASK) == LCK_VG &&
>  	    !(flags & LCK_CACHE) &&
>  	    strcmp(resource, VG_GLOBAL)) {
> -		log_error("Write locks are prohibited with --ignorelockingfailure.");
> +		log_error("Write locks are prohibited with read-only locking.");
>  		return 0;
>  	}
>  
Ack.


