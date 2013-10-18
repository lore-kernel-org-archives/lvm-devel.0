From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Fri, 18 Oct 2013 09:47:35 +0200
Subject: [PATCH] libdm: Fix memory corruption if dm_asprintf fails.
In-Reply-To: <alpine.LRH.2.02.1310172030470.5268@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1310172030470.5268@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <5260E797.5060709@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.10.2013 02:31, Mikulas Patocka napsal(a):
> I found this bug when reading through my lvm changes.
>
> We must set the variable dmt->geometry to NULL after freeing it.
>
> dm_asprintf may fail, on failure it may not set dmt->geometry, thus
> dmt->geometry would be pointing to a free string.
>
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
>
> ---
>   libdm/ioctl/libdm-iface.c |    1 +
>   1 file changed, 1 insertion(+)
>
> Index: lvm2-copy/libdm/ioctl/libdm-iface.c
> ===================================================================
> --- lvm2-copy.orig/libdm/ioctl/libdm-iface.c	2013-10-18 02:26:07.000000000 +0200
> +++ lvm2-copy/libdm/ioctl/libdm-iface.c	2013-10-18 02:26:16.000000000 +0200
> @@ -817,6 +817,7 @@ int dm_task_set_geometry(struct dm_task
>   			 const char *sectors, const char *start)
>   {
>   	dm_free(dmt->geometry);
> +	dmt->geometry = NULL;
>   	if (dm_asprintf(&(dmt->geometry), "%s %s %s %s",
>   			cylinders, heads, sectors, start) < 0) {

Hi

dm_asprintf() ->  dm_vasprintf() ->  first thing it does is:  *result = 0;

So it should never return failure and leave  &dmt->geometry in undefined 
state. On error path it should always be set to NULL - unless there is a bug
in  dm_vasprintf() which would need to be fixed.

Zdenek


