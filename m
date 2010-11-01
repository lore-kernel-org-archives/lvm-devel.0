From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 01 Nov 2010 14:21:47 +0100
Subject: [PATCH] Use dynamic allocation for buffer when reporting tags
In-Reply-To: <4CCEBBBB.2050705@redhat.com>
References: <4CCEACE2.8060609@redhat.com> <4CCEBBBB.2050705@redhat.com>
Message-ID: <4CCEBEEB.6070002@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 1.11.2010 14:08, Peter Rajnoha napsal(a):
> OK, here's updated version (based on quick hints from Milan).
> 
> Peter
> ---
>  libdm/libdm-report.c |   52 ++++++++++++++++++++++++++++++++++++++++---------
>  1 files changed, 42 insertions(+), 10 deletions(-)
> 
> diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
> index 7631e21..951ecb3 100644
> --- a/libdm/libdm-report.c
> +++ b/libdm/libdm-report.c
> @@ -902,11 +919,13 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
>  
>  		if (!dm_pool_grow_object(rh->mem, rh->output_field_name_prefix, 0)) {
>  			log_error("dm_report: Unable to extend output line");
> +			free(field_id);
>  			return 0;
>  		}
>  
>  		if (!dm_pool_grow_object(rh->mem, _toupperstr(field_id), 0)) {
>  			log_error("dm_report: Unable to extend output line");
> +			free(field_id);
>  			return 0;
>  		}


Maybe swith to use dm_strdup() and dm_free()

Zdenek


