From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 19 Feb 2009 13:15:12 -0500
Subject: [PATCH 2/3] Added more version defines to tools/version.h.in.
In-Reply-To: <1235070093-23387-3-git-send-email-twoerner@redhat.com>
References: <1235070093-23387-1-git-send-email-twoerner@redhat.com>
	<1235070093-23387-2-git-send-email-twoerner@redhat.com>
	<1235070093-23387-3-git-send-email-twoerner@redhat.com>
Message-ID: <1235067312.19308.1.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2009-02-19 at 20:01 +0100, Thomas Woerner wrote:
> Modified tools/version.h.in and configure.in:
> New defines LVM_MAJOR, LVM_MINOR, LVM_PATCHLEVEL and LVM_RELEASE generated in
> configure. Maybe a rename of version.h.in to lvm_version.h.in would be good to
> prevent name conflicts with other projects. Added GPL header to version.h.in.
> 
> TODO: recreate configure
> 
> Signed-off-by: Thomas Woerner <twoerner@redhat.com>
> ---
>  configure.in       |   13 ++++++++++++-
>  tools/version.h.in |   27 +++++++++++++++++++++++++++
>  2 files changed, 39 insertions(+), 1 deletions(-)
> 
> diff --git a/configure.in b/configure.in
> index ea77eff..02a9bbb 100644
> --- a/configure.in
> +++ b/configure.in
> @@ -1,6 +1,6 @@
>  ###############################################################################
>  ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
> -## Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
> +## Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
>  ##
>  ## This copyrighted material is made available to anyone wishing to use,
>  ## modify, copy, or redistribute it subject to the terms and conditions
> @@ -723,6 +723,13 @@ DM_LIB_PATCHLEVEL=`cat VERSION_DM | awk -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$
>  
>  LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
>  
> +VER=`cat VERSION | awk '{print $1}'`
> +echo "$VER" | grep -qi "cvs" && LVM_RELEASE=\"cvs\" || LVM_RELEASE=\"\"
> +VER=`echo "$VER" | awk -F '-' '{print $1}'`
> +LVM_MAJOR=`echo "$VER" | awk -F '.' '{printf "%s",$1}'`
> +LVM_MINOR=`echo "$VER" | awk -F '.' '{printf "%s",$2}'`
> +LVM_PATCHLEVEL=`echo "$VER" | awk -F '.' '{printf "%s",$3}'`
> +
>  ################################################################################
>  AC_SUBST(BUILD_DMEVENTD)
>  AC_SUBST(CFLAGS)
> @@ -761,6 +768,10 @@ AC_SUBST(LVM1)
>  AC_SUBST(LVM1_FALLBACK)
>  AC_SUBST(CONFDIR)
>  AC_SUBST(LVM_VERSION)
> +AC_SUBST(LVM_MAJOR)
> +AC_SUBST(LVM_MINOR)
> +AC_SUBST(LVM_PATCHLEVEL)
> +AC_SUBST(LVM_RELEASE)
>  AC_SUBST(MIRRORS)
>  AC_SUBST(MSGFMT)
>  AC_SUBST(OWNER)
> diff --git a/tools/version.h.in b/tools/version.h.in
> index a122792..f41fcae 100644
> --- a/tools/version.h.in
> +++ b/tools/version.h.in
> @@ -1,3 +1,30 @@
> +/*
> + * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
> + * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
> + *
> + * This file is part of LVM2.
> + *
> + * This copyrighted material is made available to anyone wishing to use,
> + * modify, copy, or redistribute it subject to the terms and conditions
> + * of the GNU Lesser General Public License v.2.1.
> + *
> + * You should have received a copy of the GNU Lesser General Public License
> + * along with this program; if not, write to the Free Software Foundation,
> + * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + */
> +
>  #ifndef _LVM_VERSION_H
> +/**
> + * The LVM version number
> + *
> + * LVM_MAJOR.LVM_MINOR.LVM_PATCHLEVEL[-LVM_RELEASE]
> + *
> + * If the LVM release tag contains "cvs" then it is a development snapshot.
> + */
> +
>  #define LVM_VERSION @LVM_VERSION@
> +#define LVM_MAJOR @LVM_MAJOR@
> +#define LVM_MINOR @LVM_MINOR@
> +#define LVM_PATCHLEVEL @LVM_PATCHLEVEL@
> +#define LVM_RELEASE @LVM_RELEASE@
>  #endif

Ack.  Will you generate configure or someone else?


