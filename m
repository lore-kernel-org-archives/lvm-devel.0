From: Petr Rockai <prockai@redhat.com>
Date: Thu, 15 Mar 2012 18:32:03 +0100
Subject: LVM2 ./WHATS_NEW man/pvscan.8.in tools/args.h ...
In-Reply-To: <20120306023051.13816.qmail@sourceware.org> (agk@sourceware.org's
	message of "6 Mar 2012 02:30:51 -0000")
References: <20120306023051.13816.qmail@sourceware.org>
Message-ID: <87y5r1srcc.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> --- LVM2/tools/args.h	2012/03/02 18:09:48	1.88
> +++ LVM2/tools/args.h	2012/03/06 02:30:50	1.89
> @@ -44,7 +44,7 @@
>  arg(deltag_ARG, '\0', "deltag", tag_arg, ARG_GROUPABLE)
>  arg(refresh_ARG, '\0', "refresh", NULL, 0)
>  arg(mknodes_ARG, '\0', "mknodes", NULL, 0)
> -arg(minor_ARG, '\0', "minor", minor_arg, 0)
> +arg(minor_ARG, '\0', "minor", minor_arg, ARG_GROUPABLE)

>  arg(type_ARG, '\0', "type", segtype_arg, 0)
>  arg(alloc_ARG, '\0', "alloc", alloc_arg, 0)
>  arg(separator_ARG, '\0', "separator", string_arg, 0)
> @@ -115,7 +115,7 @@
>  arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0)
>  arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0)
>  arg(merge_ARG, '\0', "merge", NULL, 0)
> -arg(major_ARG, 'j', "major", major_arg, 0)
> +arg(major_ARG, 'j', "major", major_arg, ARG_GROUPABLE)
>  arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0)
>  arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0)
>  arg(maps_ARG, 'm', "maps", NULL, 0)

These two changes are responsible for RHBZ 801205, since we use
arg_int_value on the major/minor _ARG in lvchange/lvcreate etc., but it
won't work with groupable options.

We can probably:
- either add explicit loops to all the lvchange/lvcreate commands
OR
- add a new first_grouped_arg_int_value and use that

Opinions? (I'll try the latter, even though both are very ugly.) Maybe
we could contrive a way for arg_int_value to behave like
first_grouped_arg_int_value on groupable options, although I am not
entirely sure it's easy to extract that information at that point.

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


