From: David Teigland <teigland@redhat.com>
Date: Mon, 27 Jun 2022 09:54:51 -0500
Subject: [PATCH] pvdisplay: support -a option
In-Reply-To: <0f4c62c2-ca98-3fef-b194-6c8a8b2fcd09@huawei.com>
References: <de2155b1-0831-3374-b54b-e7ad6ac57830@huawei.com>
 <0f4c62c2-ca98-3fef-b194-6c8a8b2fcd09@huawei.com>
Message-ID: <20220627145451.GA30741@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Jun 25, 2022 at 10:21:21AM +0800, Wu Guanghao wrote:
> > pvdisplay already supports the -a option, but it is filtered at the begining,
> > so delete the redundant judgment.
> > 
> > Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
> > ---
> >  tools/pvdisplay.c | 1 -
> >  1 file changed, 1 deletion(-)
> > 
> > diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
> > index 11f38ebd2..1ed9c0d3f 100644
> > --- a/tools/pvdisplay.c
> > +++ b/tools/pvdisplay.c
> > @@ -72,7 +72,6 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
> >         }
> > 
> >         if (arg_is_set(cmd, aligned_ARG) ||
> > -           arg_is_set(cmd, all_ARG) ||
> >             arg_is_set(cmd, binary_ARG) ||
> >             arg_is_set(cmd, noheadings_ARG) ||
> >             arg_is_set(cmd, options_ARG) ||

You've probably seen that tools/command-lines.in is where we now define
the options accepted by each command.  But, many commands still contain
redundant option checking that could be removed.  So, nearly all of the
option checks in pvdisplay can be removed, not just -a (and many of the
option combination rules can also be defined in command-lines.h.)  If
you'd like to send a larger patch for pvdisplay then we could apply
that instead.
Thanks, Dave

