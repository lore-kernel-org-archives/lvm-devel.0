From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 31 May 2013 09:36:25 +0200
Subject: [PATCH] DM RAID: Add ability to throttle sync operations for RAID LVs.
In-Reply-To: <1369948507.8964.3.camel@f16>
References: <1369948507.8964.3.camel@f16>
Message-ID: <51A852F9.2080208@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.5.2013 23:15, Jonathan Brassow napsal(a):
> Please take a look at the following patch that adds throttling for RAID
> sync operations.  Any feedback on what the 'lvs' header should look like
> when reporting the min/max recovery rate would be helpful also.  (Right
> now it is MinSync and MaxSync.)
>
>   brassow
>
>
> This patch adds the ability to set the minimum and maximum I/O rate for
> sync operations in RAID LVs.  The options are available for 'lvcreate' and
> 'lvchange' and are as follows:
>    --minrecoveryrate <Rate>
>    --maxrecoveryrate <Rate>
> The rate is specified in kiB/sec/disk.  Setting the rate to 0 removes the
> preference.
>

Patch seems to be missing  libdm API extension to set min/max rates.

Maybe the argument for min/max should be specified in 'size' units/second.
So you could easily say   1M   - just like with other args where we give size.


> +.RB [ \-\-maxrecoveryrate " " \fIRate\fP ]
> +.RB [ \-\-minrecoveryrate " " \fIRate\fP ]

.RB [ \-\-minrecoveryrate
.IB Rate ]

is a bit better - since you give roff a change to insert spaces more evenly.


> --- lvm2.orig/man/lvcreate.8.in
> +++ lvm2/man/lvcreate.8.in
> @@ -19,6 +19,8 @@ lvcreate \- create a logical volume in a
>   .RB [ \-\-ignoremonitoring ]
>   .RB [ \-\-monitor
>   .RI { y | n }]
> +.RB [ \-\-maxrecoveryrate " " \fIRate\fP ]
> +.RB [ \-\-minrecoveryrate " " \fIRate\fP ]

- " -



> +arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", int_arg, 0)
> +arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", int_arg, 0)

I'd vote for 'size_arg'


Zdenek


