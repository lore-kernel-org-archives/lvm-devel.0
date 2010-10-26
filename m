From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 26 Oct 2010 11:47:23 +0100
Subject: LVM2/lib/misc util.h
In-Reply-To: <20101026100435.20019.qmail@sourceware.org>
References: <20101026100435.20019.qmail@sourceware.org>
Message-ID: <20101026104723.GE29400@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 26, 2010 at 10:04:35AM -0000, zkabelac at sourceware.org wrote:
> +#ifdef __clang__
> +#define uninitialized_var(x) x
> +#else
>  #define uninitialized_var(x) x = x
> +#endif
>  

Please add a comment.

Alasdair


