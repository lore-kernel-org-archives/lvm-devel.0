From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 11 Dec 2008 11:35:23 -0500
Subject: Re: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
In-Reply-To: <20081211162552.29826.qmail@sourceware.org>
References: <20081211162552.29826.qmail@sourceware.org>
Message-ID: <1229013323.20795.3.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


> +/* simplify string emiting code */
> +#define EMIT_PARAMS(p, str...)\
> +	do {\
> +		const size_t bufsize = paramsize - (size_t)p;\
> +		int w;\
> +		\
> +		if ((w = snprintf(params + p, bufsize, str)) < 0\
> +		    || ((size_t)w >= bufsize)) {\
> +			stack; /* Out of space */\
> +			return -1;\
> +		}\
> +		p += w;\
> +	} while (0)
> +

Do we have to do a macro here?  Macros like this are harder to debug...


