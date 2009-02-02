From: Petr Rockai <prockai@redhat.com>
Date: Tue, 03 Feb 2009 00:25:10 +0100
Subject: [PATCH 03/13] Move vg_t, lv_t, and pv_t from metadata-exported.h into lvm2.h
In-Reply-To: <1233607809-1087-4-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 2 Feb 2009 15:49:59 -0500")
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
Message-ID: <87ljso776x.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:

> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  lib/lvm2.h                       |    9 +++++++++
>  lib/metadata/metadata-exported.h |    8 +-------
>  2 files changed, 10 insertions(+), 7 deletions(-)
>
> diff --git a/lib/lvm2.h b/lib/lvm2.h
> index f348035..bfa1852 100644
> --- a/lib/lvm2.h
> +++ b/lib/lvm2.h
> @@ -60,4 +60,13 @@ void lvm_destroy(lvm_handle_t libh);
>   */
>  int lvm_reload_config(lvm_handle_t libh);
>  
> +struct volume_group;
> +typedef struct volume_group vg_t;
> +
> +struct physical_volume;
> +typedef struct physical_volume pv_t;
> +
> +struct logical_volume;
> +typedef struct logical_volume lv_t;
Did you mean to make all of those pointers? Or is the plan to expose the actual
structures instead of just handles? (I don't know, I'm just asking.)

I see you use vg_t * later on. Maybe thats' because we want to make the fact
that these are pointers explicit? Just thinking aloud...

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


