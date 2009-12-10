From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 10 Dec 2009 14:33:04 +0100
Subject: Re: [PATCH 1/4] Fix coredump and memory leak for 'dmsetup help -c'
In-Reply-To: <fc67f51ffd717cb4b6a70e96e5b18ea9d55ae42d.1260449368.git.zkabelac@redhat.com>
References: <cover.1260449368.git.zkabelac@redhat.com>
	<fc67f51ffd717cb4b6a70e96e5b18ea9d55ae42d.1260449368.git.zkabelac@redhat.com>
Message-ID: <hfqtag$mgi$1@ger.gmane.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Dne 10.12.2009 13:53, Zdenek Kabelac napsal(a):
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---
>  tools/dmsetup.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/dmsetup.c b/tools/dmsetup.c
> index 888edff..b5568f0 100644
> --- a/tools/dmsetup.c
> +++ b/tools/dmsetup.c
> @@ -2402,7 +2402,7 @@ static int _report_init(struct command *c)
>  	size_t len = 0;
>  	int r = 0;
>  
> -	if (!strcmp(c->name, "splitname"))
> +	if (c && !strcmp(c->name, "splitname"))
>  		options = (char *) splitname_report_options;
>  
>  	/* emulate old dmsetup behaviour */
> @@ -2591,7 +2591,9 @@ static int _help(int argc __attribute((unused)),
>  		_switches[OPTIONS_ARG] = 1;
>  		_string_args[OPTIONS_ARG] = (char *) "help";
>  		_switches[SORT_ARG] = 0;
> -	
> +
> +		if (_report)
> +			dm_report_free(_report);
>  		(void) _report_init(NULL);
>  	}
>  

To stay safe even in case of memory failure inside of _report_init:
- --
- -	
+
+		if (_report) {
+			dm_report_free(_report);
+			_report = NULL;
+		}
- --

Zdenek


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.13 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org/

iQIcBAEBAgAGBQJLIPiQAAoJEBiFrTh9QvFuPIwQALCWEqesTlha+wVDWzXY4We5
Xr6DRXZwYZpFQJS8fJWceOiU1QBHAArPizrpASLWLnC4vvVjqP4vAk+ifSE5mktz
qEDu+rSbJW2GBvEsyo2C3dm3tIqvd9GN7Z5OQ8ECgLqdqeN+oz4WUf8Jk/s5RYvI
Y8eIC2UVrPEEE0MjGgogPc5nH8mrBr27IPmqa7TXOLFht9RajTfcJkFlrilVnaSs
vLPpj2w4xWMcNzqHDlvV+AHU92KZA8fFq72dgzNEsRuXFxpfMKMXALT9pMLE1oAv
5KOMWdSsG+qtoyr3Ivb1YFQUgHdOLhLJIz0RbTd51K6NH8NIdmCxeuyjCBErS/Yo
L5AbO6VlhNyx7BWwFaOP6s3MVBkLgmo62KsAy1cJoBqFc/KbgSvZLWNbnwP0DqkS
jHZ4vhEU907A+99h1HM0Oze40ngNqUbSIunA+/pyKuqCjDjYoQNYMPHNYaZCMHb7
rS/r+RWU5zJAqXipXXD0YbMEb0CFRJqjTQ4YTUoIVULZ5hNRKOs2dO0ARh/C8lx/
lLy2eRz1ROb8GR4De76bCec4TUVBQSoqqLXwBU2Jy/XLw3vZB+ve66VYXBtoqsj1
4hbjSOzqduixO2mL7Ll3KQVJL66ocKmLOgNlbLJcgLYJwPw9Pw/bvxvk4VZ8eS2H
mAF1XWnA8IavteF8wVlF
=7rFB
-----END PGP SIGNATURE-----


