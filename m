From: Petr Rockai <prockai@redhat.com>
Date: Fri, 06 Aug 2010 21:24:05 +0200
Subject: [PATCH] Don't use floor() in _bitset_with_random_bits
In-Reply-To: <20100730170535.GA21519@pld-linux.org> (Przemyslaw Iskra's
	message of "Fri, 30 Jul 2010 19:05:35 +0200")
References: <20100730170535.GA21519@pld-linux.org>
Message-ID: <87hbj7k0iy.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Przemyslaw Iskra <sparky@pld-linux.org> writes:
> Use _even_rand() function instead of floor() in
> _bitset_with_random_bits(). floor() function is missing in dietlibc (on
> architectures other than x86). Moreover using floor() to clip rand
> results does not assure even result distribution.
> _even_rand() uses integer arithmetic only and is designed to return evenly
> distributed results.
>
> Signed-off-by: Przemyslaw Iskra <sparky@pld-linux.org>

Reviewed-by: Petr Rockai <prockai@redhat.com>

Looks OK to me. It took a while to decipher what is the exact meaning of
the loop in _even_rand (to a non-pseudorandomness-expert) but I am
fairly comfortable with it now. If I understand this correctly, it
rejects numbers that come from an "incomplete" slice of the RAND_MAX
space (considering the number space [0, RAND_MAX] is divided into some
"max"-sized slices and at most a single smaller slice, between [n*max,
RAND_MAX] for suitable n -- numbers from this last slice are discarded
because they could distort the distribution in favour of smaller
numbers).

> diff --git a/configure.in b/configure.in
> index bd56136..6f6c67e 100644
> --- a/configure.in
> +++ b/configure.in
> @@ -125,8 +125,7 @@ AC_STRUCT_TM
>  
>  ################################################################################
>  dnl -- Check for functions
> -AC_SEARCH_LIBS([floor], [m], , [AC_MSG_ERROR(bailing out)])
> -AC_CHECK_FUNCS([floor ftruncate gethostname getpagesize \
> +AC_CHECK_FUNCS([ftruncate gethostname getpagesize \
>    gettimeofday memset mkdir mkfifo rmdir munmap nl_langinfo setenv setlocale \
>    strcasecmp strchr strcspn strspn strdup strncasecmp strerror strrchr \
>    strstr strtol strtoul uname], , [AC_MSG_ERROR(bailing out)])

OK, since floor is not used anywhere else in LVM.

> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index 07222a7..6ee7731 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -1018,6 +1018,20 @@ static int _recalc_extents(uint32_t *extents, const char *desc1,
>  	return 1;
>  }
>  
> +/* return random integer in [0,max) interval */
> +static unsigned _even_rand( unsigned *seed, unsigned max )
> +{
> +	unsigned r, ret;
> +
> +	/* make sure distribution is even */
> +	do {
> +		r = (unsigned) rand_r( seed );
> +		ret = r % max;
> +	} while ( r - ret >= RAND_MAX - max );
> +
> +	return ret;
> +}
OK as per above.

>  static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bits,
>  					    uint32_t num_set_bits, unsigned *seed)
>  {
> @@ -1040,7 +1054,7 @@ static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bi
>  	/* Perform loop num_set_bits times, selecting one bit each time */
>  	while (i++ < num_bits) {
>  		/* Select a random bit between 0 and (i-1) inclusive. */
> -		bit_selected = (unsigned) floor(i * (rand_r(seed) / (RAND_MAX + 1.0)));
> +		bit_selected = _even_rand( seed, i );

OK. Gets a random integer from [0, i). The previous code was doing the
same thing (less efficiently and less precisely).

Yours,
   Petr.


