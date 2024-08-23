Received: from mout.gmx.net (mout.gmx.net [212.227.17.21])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3505915098A
	for <lvm-devel@lists.linux.dev>; Fri, 23 Aug 2024 22:15:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.17.21
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724451362; cv=none; b=RmqlFfqFmQ/8/wTWEK1cXI6krESfVujlJL9aWINVkzhYyoonk3hctbU6KM/QAUTNy+mq/TGSWcyM4PEMutYRYJ9HI+kV5mA50oKT41/qvvr783j8syVKSPZDNMq5REELRbPGupYjeFV8LiZIfFx0sNQBRFPSV242aaZsWEFkURk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724451362; c=relaxed/simple;
	bh=eiyr+t5R/dk2ih6ejK8AfKYC9ogdk3jK9xLyv2Zdkwo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=OvvxUNYqCR3r2u/TVs7wH+lKPX5E2+IWJZzv9jZxL0UIXtpqquhSaOYQVxgtdUmNxcmqLgYjXzYT6Pothjgtoa6Yf2bRs+zB896/JTxCD3kNEwElZj3POtUu9XBu0Tn9DSK6yTG4l6wjqM/UpDOnSn7mwVlsUbiLrxehddGWNh0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=j.neuschaefer@gmx.net header.b=aDx8cjCc; arc=none smtp.client-ip=212.227.17.21
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=j.neuschaefer@gmx.net header.b="aDx8cjCc"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1724451339; x=1725056139; i=j.neuschaefer@gmx.net;
	bh=paGp0WKaEbasNKAaskPRDh017qz5ocTTl1naIKrlS7A=;
	h=X-UI-Sender-Class:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:In-Reply-To:
	 cc:content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=aDx8cjCc5fx5eG53DQaLhTiAqQWCPj2AFtVvZNgO/gP/SbywQHc1iR7SPf+IxsOO
	 4c5umYjS4oLSdp+bO85NrUeWow6S22A9WBdiQal8y/Tp2lycFuZ8hZltV8kTlMt37
	 BCLZzfM/DLCWVxADE2KSaMgg+9gXZ8oN3O4asTNbiyTBVsKWXl2eUA9/Jy6sVIrYc
	 ZxPtAa+uBdTg7GUie09z3LwVo1FGmaHg+kKw0AuQ1OjGY8lmWqiU1rUwBF/OoSq28
	 Ka/z8arbgAZ+58p4LPkZGqYn3KgRUaxjS42rR1MbymFPZPQBpkYmF5aiWOowftcRt
	 ac8jg4HJWFaUxCw2Fg==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from probook ([84.44.134.213]) by mail.gmx.net (mrgmx104
 [212.227.17.168]) with ESMTPSA (Nemesis) id 1MTzb8-1sZTNw3img-00TWn8; Sat, 24
 Aug 2024 00:15:39 +0200
Date: Sat, 24 Aug 2024 00:15:37 +0200
From: =?utf-8?Q?J=2E_Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
To: Rich Felker <dalias@libc.org>
Cc: =?utf-8?Q?J=2E_Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>,
	lvm-devel@lists.linux.dev, buildroot@buildroot.org,
	musl@lists.openwall.com
Subject: Re: [musl] [PATCH lvm2] acinclude.m4: Link when trying CCFLAGS
Message-ID: <ZskKCSueNCn3Ltg-@probook>
References: <20240811-microblaze-v1-1-2781ba343e75@gmx.net>
 <20240811215226.GK10433@brightrain.aerifal.cx>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20240811215226.GK10433@brightrain.aerifal.cx>
X-Provags-ID: V03:K1:tL8F7XtaymuUwsRVWAvHgy0za+FCFEAPy3LV78xd+VvCgCKJyYm
 bA9rOlBN3tDEQ+xU9MLRAGZM4qGUcf8HfXFEzmSVeafn0ECrwG2kEozbv9RyE3BRGz/w4M5
 kXHFQ4VVgBQhBfl+1Y723qt6DkC+aXSGafaYCl7N4kh7I1R49bbR3e4jxfyLcGbvlhLhzdQ
 3ymTSLMT9ydMuNd5cqUyQ==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:l+TDhp1UiSQ=;rYAtVOIChtUcfmzLl3j5OUIM9Gp
 KldbPaar7/lSLyMKxwoZjIRuOd3wy+gatTHGfZ0K7ga+6ZN15gF4J0KvF0hwnDGioDDngwmlx
 gvPeyLZDbiNM5vLZevUr5Di+Jq9nxPMJQzI7NkEU99GB0gGSi5SWq5rVlgq9vq2ubaP7mZVCN
 Doia2He3sSvsbXJP8fmsl8T8zoucsDM9rq+9B8DsNMMQxY0fu/RnAfFmSpSKVaMS9mnIBca/3
 dScHjwD43RL32UrMyxXFyND2S6BSsrRlaF41kdAyq4g6oh3Vyy0ln2cBk4O/u3EJhR8rDSNFW
 iFcBTHDfvtPzN9hVPQX72akQLrGJFG0+ivwmPXYoSfl1UtIh6XEYMWLzdyypgs2/PpozZ0rvD
 Q5Qlg++OHloc+vGB6Md+LyjGdbiOysVkpg/vkdWdNKdsyavriKdJ9APFkvDpyocaec06/nNKy
 N8QjjO361yek77+/CjJXcjzhf/lBY8pzqp23bo+K0+gXURma+k5jqLdwmhLNemt4qZDV1ZKXB
 6FKFk504skt0N+AKhCz0ktPEmaBoOjn+iIRL/sUlgdXJJwHBc1r+v3vIObchI+Nd94psVBUmn
 JW9RgF85BgDI/nzjRwDyH3b6F5RIkSXqzPSTs6GYy1vIlzfGIGkHu2/hlCS4h3+U/8J/NTiJf
 vfuk0mXNLCoDcDiWqppNhB/Y+97u8naa8rfYAd+GnNdonVTyG4HBsJitViGoYYOQxFcl5sIWB
 AafeDjSE9NUAUdttTVXVhMeID9YTi20AWv6gpSen38T+oDHCA9j10kUpCJgO8KC+Wk7YSyIFm
 jXZVpJxVrRydL+1RGE7z8jtXyltAmZk2lZjCi3NtlwLmkBHybpsNFvRt5tgGhSOgtG5ZtI+8X
 EQazU3fF4tcZn/w==

On Sun, Aug 11, 2024 at 05:52:29PM -0400, Rich Felker wrote:
> On Sun, Aug 11, 2024 at 11:04:38AM +0200, J. Neusch=C3=A4fer wrote:
> > Through a build failure of LVM2 on musl-libc 1.2.5 in the Buildroot
> > autobuild service[1], I noticed that musl-libc's Scrt1 for microblaze
> > produces a relocation targeting the .text section, which subsequently
> > leads to a crash at run-time because musl-libc does not support
> > textrels[2]. Buildroot uses the "-z text" linker option to catch
> > textrels early, on musl-libc.
> >
> > The error can be reduced to the following test case:
> >
> >   $ cat hello.c
> >   #include <stdio.h>
> >   int main(void) { puts("Hello world!"); return 0; }
> >   $ host/bin/microblaze-buildroot-linux-musl-gcc hello.c -z text -pie =
-fPIC
> >   microblaze-buildroot-linux-musl/bin/ld: microblaze-buildroot-linux-m=
usl/sysroot/lib/Scrt1.o:
> >     warning: relocation against `_start_c' in read-only section `.text=
'
> >   microblaze-buildroot-linux-musl/bin/ld: read-only segment has dynami=
c relocations
> >   collect2: error: ld returned 1 exit status
[...]
>
> No objection, but this is a bug in the tooling (ld) that we could also
> avoid on the musl side. So there are probably 3 places things should
> be changed here.
>
> Rich

I finally got around to testing your musl patch (http://0x0.st/XWB9.diff -
"use hidden visibility for C entry point function _start_c").
It solves the immediate problem for microblaze(el) as far as I can see.

I'm not familiar enough with linker intricacies to write a binutils/ld
bug report though.


=2D- jn
