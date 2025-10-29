Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25AF735470C
	for <lvm-devel@lists.linux.dev>; Wed, 29 Oct 2025 13:31:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1761744679; cv=none; b=ZAGUJgVXvNx9lumlD0bTyqBldoxEfOP5cLcGxPVenPWYPH0R1Eqsk+bah3phY1+ZUjTwSXYbazb2wGFpM0bRJZVLxw7/jrddgnfPt1ALTnLziUQDmKjGmcAu5sHTJKZ37GhFb77qHjuS9B3H/1bA0uLSIEQ14OzsyTxMfX/UcY0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1761744679; c=relaxed/simple;
	bh=H4STyYQkAuprklyTlY2BjwuSs1iXn17miHrAUSvF+TM=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=AcO0MGR9QNyNGb5pEacrU57qRTF3IhsCkMeSFXMk/9GsuCnhex9J/G3rd2DzZ2qiJqmHi8SLltUZCa0Inc0EWBuRqqHt532uQyblF7tfKBEwyCMoVi0+ArgbKEuBl0m1qJjBZ6kubQ4LwmPaS7l2vkCerGC/uRT4coxXOXcSyyM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=k/YUzPJY; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="k/YUzPJY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6157CC2BCB2
	for <lvm-devel@lists.linux.dev>; Wed, 29 Oct 2025 13:31:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1761744677;
	bh=H4STyYQkAuprklyTlY2BjwuSs1iXn17miHrAUSvF+TM=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=k/YUzPJYNKtOchZEqmQ2MNC4VR8TnxopP0fpnEkTWlWsfz9tx8ThePcktS069B0t4
	 fmcgrYYMrzyXGrbyzar22eouO9Ja3+s8CSZZsdNrDEGINsJysImL8I38EzDlt8mQKs
	 kGJvCzZje3ZdtNXHUnKVBnXd5esJ+BfuAnzsuRoVkCrsxJMkJ9vqHst9Fve9f9trsm
	 oLr8pwHCar8rp567vTcxlFJjsQN5QzBt06MZnNFU9uUOzjlAMY3qQrwDt5YhIfog7b
	 eMvlTyVyC/KzAFBM5H6gHZS6w+lQLG56w53bfIXPd1o3RWZ29qIKSBnB/2IzmVVhRk
	 uFejWm6Tr2+xQ==
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-7c67d9577b3so1287972a34.2
        for <lvm-devel@lists.linux.dev>; Wed, 29 Oct 2025 06:31:17 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AJvYcCVQpfXFCH0u0B5Cmfjrr5oyBlY+snnV6gsMUayRgcFXmqwVr6Lar78Tt/aQmAISnU29i6HEWtQG/BA=@lists.linux.dev
X-Gm-Message-State: AOJu0Yy6qPAR+HJOf80+2wWG7rRwHOyZOy3xADykNnU9XkRyHMtmohOM
	xey/b4ttAg7T2lzmeVHKexgp6dC8c+4Psr5Oe9HxbMlPVR+DwQFD+TpBwnR14JdDhjPKDgmx5nA
	Ivc4ACvxvJaJulBiMAAHqdX78dyKsGbE=
X-Google-Smtp-Source: AGHT+IEi0R7W8u+k9kuQ+Q/TOuonlY+thu2InbF4UTFVllbZ//+bkXdFiNu5AHmFd0ihQtxuffxUIcoyOHNos6JMUKo=
X-Received: by 2002:a05:6830:82e9:b0:7c5:3afb:79db with SMTP id
 46e09a7af769-7c6831898admr1590559a34.35.1761744676587; Wed, 29 Oct 2025
 06:31:16 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20251023112920.133897-1-safinaskar@gmail.com> <4cd2d217-f97d-4923-b852-4f8746456704@mazyland.cz>
 <03e58462-5045-e12f-9af6-be2aaf19f32c@redhat.com>
In-Reply-To: <03e58462-5045-e12f-9af6-be2aaf19f32c@redhat.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Wed, 29 Oct 2025 14:31:05 +0100
X-Gmail-Original-Message-ID: <CAJZ5v0gcEjZPVtKrysS=ek7kHpH3afinwY-apKm3Yd4PmKDHdA@mail.gmail.com>
X-Gm-Features: AWmQ_bnfFqqg5xNQkg3Ut6H7tX7EttVRgAcRKjLdiyhAs_brzIkV0t-kTKujKfc
Message-ID: <CAJZ5v0gcEjZPVtKrysS=ek7kHpH3afinwY-apKm3Yd4PmKDHdA@mail.gmail.com>
Subject: Re: [PATCH] pm-hibernate: flush block device cache when hibernating
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Askar Safin <safinaskar@gmail.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, 
	linux-block@vger.kernel.org, linux-crypto@vger.kernel.org, 
	linux-lvm@lists.linux.dev, lvm-devel@lists.linux.dev, 
	linux-raid@vger.kernel.org, DellClientKernel <Dell.Client.Kernel@dell.com>, 
	dm-devel@lists.linux.dev, linux-btrfs@vger.kernel.org, 
	Nhat Pham <nphamcs@gmail.com>, Kairui Song <ryncsn@gmail.com>, Pavel Machek <pavel@ucw.cz>, 
	=?UTF-8?Q?Rodolfo_Garc=C3=ADa_Pe=C3=B1as?= <kix@kix.es>, 
	"Rafael J. Wysocki" <rafael@kernel.org>, Eric Biggers <ebiggers@kernel.org>, 
	Lennart Poettering <mzxreary@0pointer.de>, Christian Brauner <brauner@kernel.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Milan Broz <milan@mazyland.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 24, 2025 at 12:23=E2=80=AFPM Mikulas Patocka <mpatocka@redhat.c=
om> wrote:
>
>
>
> On Fri, 24 Oct 2025, Askar Safin wrote:
>
> > Hi.
> >
> > Hibernate to swap located on dm-integrity doesn't work.
> > Let me first describe why I need this, then I will describe a bug with =
steps
> > to reproduce
> > (and some speculation on cause of the bug).
>
> Hi
>
> Does this patch fix it?
>
> Mikulas
>
>
> From: Mikulas Patocka <mpatocka@redhat.com>
>
> There was reported failure that hibernation doesn't work with
> dm-integrity. The reason for the failure is that the hibernation code
> doesn't issue the FLUSH bio - the data still sits in the dm-integrity
> cache and they are lost when poweroff happens.
>
> This commit fixes the suspend code so that it issues flushes before
> writing the header and after writing the header.

Hmm, shouldn't it flush every time it does a sync write, and not just
in these two cases?

>
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Reported-by: Askar Safin <safinaskar@gmail.com>
> Link: https://lore.kernel.org/dm-devel/a48a37e3-2c22-44fb-97a4-0e57dc2042=
1a@gmail.com/T/
> Cc: stable@vger.kernel.org
>
> ---
>  kernel/power/swap.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> Index: linux-2.6/kernel/power/swap.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/kernel/power/swap.c  2025-10-13 21:42:48.000000000 +02=
00
> +++ linux-2.6/kernel/power/swap.c       2025-10-24 12:01:32.000000000 +02=
00
> @@ -320,8 +320,10 @@ static int mark_swapfiles(struct swap_ma
>                 swsusp_header->flags =3D flags;
>                 if (flags & SF_CRC32_MODE)
>                         swsusp_header->crc32 =3D handle->crc32;
> -               error =3D hib_submit_io_sync(REQ_OP_WRITE | REQ_SYNC,
> +               error =3D hib_submit_io_sync(REQ_OP_WRITE | REQ_SYNC | RE=
Q_PREFLUSH,
>                                       swsusp_resume_block, swsusp_header)=
;
> +               if (!error)
> +                       error =3D blkdev_issue_flush(file_bdev(hib_resume=
_bdev_file));
>         } else {
>                 pr_err("Swap header not found!\n");
>                 error =3D -ENODEV;
>
