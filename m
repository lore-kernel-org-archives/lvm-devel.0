From: David Teigland <teigland@redhat.com>
Date: Thu, 6 Aug 2015 10:24:09 -0500
Subject: [PATCH] man: typo fix about lvmthin
In-Reply-To: <1438842122-8831-1-git-send-email-lzhong@suse.com>
References: <1438842122-8831-1-git-send-email-lzhong@suse.com>
Message-ID: <20150806152409.GB32414@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 06, 2015 at 02:22:02PM +0800, Lidong Zhong wrote:
> ---
>  man/lvmthin.7.in | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
> index eb791f0..76597a9 100644
> --- a/man/lvmthin.7.in
> +++ b/man/lvmthin.7.in
> @@ -1047,7 +1047,7 @@ Command to display the current discard mode of a thin pool LV:
>  
>  Command to set the discard mode when creating a thin pool LV:
>  .br
> -.B lvconvert \-\-discards {ignore|nopassdown|passdown}
> +.B lvcreate \-\-discards {ignore|nopassdown|passdown}

It's using lvconvert to create a thin pool from existing LVs.


