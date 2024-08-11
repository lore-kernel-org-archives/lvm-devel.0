Received: from brightrain.aerifal.cx (brightrain.aerifal.cx [104.156.224.86])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D927841C75
	for <lvm-devel@lists.linux.dev>; Sun, 11 Aug 2024 22:07:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=104.156.224.86
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1723414066; cv=none; b=G7uTNsi4+ZtFJkorh27lykunK+B5zieNWboWbirs2zMCb/kwi4g4OzCp3lyJ0Qo+ymr7reI4m6ZIqxa0eU447ic2qEvR7SPA+LyPk0G1V9/h9Oi8aeR3Fo3wcwwlgObnODHbZOzybpmJ/NTbNoVFOcVp8UHhTr2XCf02YChyqFo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1723414066; c=relaxed/simple;
	bh=k2v5eUc2yixl/CQnBmnoKClXpFvYb6bLKeOq+DP8Xss=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=hS02wecvLaAyXjBINHwV223aQa/ch3tRBGYT+kZgtsamzvNFqL6qL15J2qsIbpIZ6NzG22iazsYxNFdEatMxqD0N2uU6fiEQcl5vozInXUUYr6Utm4S+u9nYtBQ82dqSf+SkwiTP59ihuQwMJNAdXOGSbetk/jFb8VQRhhRGPC8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=libc.org; spf=pass smtp.mailfrom=aerifal.cx; arc=none smtp.client-ip=104.156.224.86
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=libc.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=aerifal.cx
Date: Sun, 11 Aug 2024 17:52:29 -0400
From: Rich Felker <dalias@libc.org>
To: =?utf-8?Q?J=2E_Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Cc: lvm-devel@lists.linux.dev, buildroot@buildroot.org,
	musl@lists.openwall.com
Subject: Re: [musl] [PATCH lvm2] acinclude.m4: Link when trying CCFLAGS
Message-ID: <20240811215226.GK10433@brightrain.aerifal.cx>
References: <20240811-microblaze-v1-1-2781ba343e75@gmx.net>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20240811-microblaze-v1-1-2781ba343e75@gmx.net>
User-Agent: Mutt/1.5.21 (2010-09-15)

On Sun, Aug 11, 2024 at 11:04:38AM +0200, J. Neuschäfer wrote:
> Through a build failure of LVM2 on musl-libc 1.2.5 in the Buildroot
> autobuild service[1], I noticed that musl-libc's Scrt1 for microblaze
> produces a relocation targeting the .text section, which subsequently
> leads to a crash at run-time because musl-libc does not support
> textrels[2]. Buildroot uses the "-z text" linker option to catch
> textrels early, on musl-libc.
> 
> The error can be reduced to the following test case:
> 
>   $ cat hello.c
>   #include <stdio.h>
>   int main(void) { puts("Hello world!"); return 0; }
>   $ host/bin/microblaze-buildroot-linux-musl-gcc hello.c -z text -pie -fPIC
>   microblaze-buildroot-linux-musl/bin/ld: microblaze-buildroot-linux-musl/sysroot/lib/Scrt1.o:
>     warning: relocation against `_start_c' in read-only section `.text'
>   microblaze-buildroot-linux-musl/bin/ld: read-only segment has dynamic relocations
>   collect2: error: ld returned 1 exit status
> 
> LVM2 uses -pie only after the AC_TRY_CCFLAG macro has determined that it
> can be used. This is where the problem begins: AC_TRY_CCFLAG only tries
> compiling, it does not try linking the resulting object file.
> 
> To catch problems like this, this patch changes AC_TRY_CCFLAG to link in
> addition to compiling. By detecting correctly that -pie does not work on
> musl-libc/microblaze with -ztext, the build failure in Buildroot is fixed.
> 
> [1]: http://autobuild.buildroot.net/results/dc4/dc4fc33eaeafe5d6707d26a373560402533954f6/build-end.log
> [2]: https://www.openwall.com/lists/musl/2020/09/25/4
> 
> Signed-off-by: J. Neuschäfer <j.neuschaefer@gmx.net>
> ---
> Hi, I'm cross-posting this to the LVM2, Buildroot, and musl mailing
> lists to get potential feedback early on.
> ---
>  acinclude.m4 | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/acinclude.m4 b/acinclude.m4
> index 47fdd59c3..9b1d3a605 100644
> --- a/acinclude.m4
> +++ b/acinclude.m4
> @@ -25,7 +25,7 @@ AC_DEFUN([AC_TRY_CCFLAG],
>      ac_save_CFLAGS=$CFLAGS
>      CFLAGS=$1
>      AC_CACHE_CHECK([whether $CC accepts $1 flag], [ac_cv_flag_$2],
> -	[AC_COMPILE_IFELSE([AC_LANG_PROGRAM()],
> +	[AC_LINK_IFELSE([AC_LANG_PROGRAM()],
>  			   [AS_VAR_SET([ac_cv_flag_$2], [yes])],
>  			   [AS_VAR_SET([ac_cv_flag_$2], [no])])])
>      CFLAGS=$ac_save_CFLAGS
> 
> ---

No objection, but this is a bug in the tooling (ld) that we could also
avoid on the musl side. So there are probably 3 places things should
be changed here.

Rich
