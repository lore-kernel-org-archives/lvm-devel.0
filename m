From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Dec 2015 20:50:01 +0100
Subject: [PATCH] fix static linking
In-Reply-To: <1449585608-4804-1-git-send-email-riku.voipio@linaro.org>
References: <1449585608-4804-1-git-send-email-riku.voipio@linaro.org>
Message-ID: <566B28E9.3070602@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 8.12.2015 v 15:40 Riku Voipio napsal(a):
> Static linking fails currently, as -lm and -lpthread are missing:
>
> gcc -O2  -fPIC -O2  -L../libdm -L../lib -L../libdaemon/client -static
> -L../libdm/ioctl \
>        -o dmsetup.static dmsetup.o -ldevmapper    -lrt
> ../libdm/ioctl/libdevmapper.a(libdm-stats.o): In function
> `dm_stats_create_region':
> libdm-stats.c:(.text+0x2d69): undefined reference to `log10'
> libdm-stats.c:(.text+0x2d6e): undefined reference to `lround'
> ../libdm/ioctl/libdevmapper.a(pool.o): In function `dm_pool_create':
> pool.c:(.text+0x134): undefined reference to `pthread_mutex_lock'
> pool.c:(.text+0x14f): undefined reference to `pthread_mutex_unlock'
>
> Signed-off-by: Riku Voipio <riku.voipio@linaro.org>
> ---
>   tools/Makefile.in | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/tools/Makefile.in b/tools/Makefile.in
> index d6e54f0..518a21a 100644
> --- a/tools/Makefile.in
> +++ b/tools/Makefile.in
> @@ -130,7 +130,7 @@ dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
>
>   dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
>   	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
> -	      -o $@ dmsetup.o -ldevmapper $(STATIC_LIBS) $(LIBS)
> +	      -o $@ dmsetup.o -ldevmapper $(M_LIBS) $(PTHREAD_LIBS) $(STATIC_LIBS) $(LIBS)
>
>   all: device-mapper


Hi

Thanks for the patch.

I've pushed to upstream, but it's worth to note - static linking is currently 
not really supported - for many packages it's getting a bit complex to do 
linking right.

So for a very limited 'subset' of linked libs this may work, but ATM we
cannot really provide static linking for all combination of options.

I assume however you just need 'static'  dmsetup right ?

Regards

Zdenek


