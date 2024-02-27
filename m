Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E16AA14830F;
	Tue, 27 Feb 2024 21:50:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709070633; cv=none; b=A41mrCYM9/BbKNsL8d1bxLrFmKbtRZ2pYxBTPOzYrLN3PQXPqGwCuL9iB6UNiso5kbOIqH05qbJrdl7mVvkeQkqtkevKvdIPYMwsUq5HtvidgNl7D6cEhEgx0NhmgvMjVXmLjgBSggh5o2f/q+ikggbBIZkurxMr8go1Le2gnxc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709070633; c=relaxed/simple;
	bh=3wQ66r0HaUYRf9nPdNYetRmJANeDByL+SzkElXixSBo=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=doPhNuv/+oTd1uOzT1RIa/SfZAsvWNv2U1bsy+rJ1TzPNwgAstGvudkgWfdJ69/q1bbkJ2fHWKKJf//aNIZcf+6oho2X3hFqp6hsC5sVBg/fcqmknCdh1axB2n5933IDmyW4egug79j/yncoGjM+8iw/+0QlI8Ce6fKxeXA7ti4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OdGRcBQ2; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OdGRcBQ2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8146EC433F1;
	Tue, 27 Feb 2024 21:50:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1709070632;
	bh=3wQ66r0HaUYRf9nPdNYetRmJANeDByL+SzkElXixSBo=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=OdGRcBQ2oEdmUZ9vTXjPYrcTFBlk4qAkgTpvoQQQr/ITqgdX7wqJsm+Fxg81RsNnD
	 0KpZ84t3TBHyzpCdVM2HfmlmXq2LTSkHZGYd6PlCFAca+Wn7+JEHnVqBEfjag3GdA/
	 gFQAUDo9TgI5j/s+2HHNxv7n7jCGMX4x8n3lXyjaJ79lQK2wbw8ONkgoHRxUldmT/y
	 dVu4PaDfYnSEFUjM27oJotPhAEokeaUlBSgbYoZ6Wg6rJXAZQmQAXWUrrYVqqHb5rg
	 iVav3pA1Ew9bQ4Vl+91/3jh+vMVdQh/MhJTAlrNXY0nuPvr35luePkvS09OJMrZBEh
	 0AhbUBWqH5+yg==
Received: by mail-lf1-f54.google.com with SMTP id 2adb3069b0e04-513181719easo305871e87.3;
        Tue, 27 Feb 2024 13:50:32 -0800 (PST)
X-Forwarded-Encrypted: i=1; AJvYcCVZiMRW9CUTg9+ZxQ9T1XUNPwfghkx7oJINTaB35BZRbV3RhWDznQAAKKImvYDDOQmhUbaHV6In1BWm5sy0Ee2LQxqASL0mQtTXkDr4stpaGkalPREkH0Mu1f/uUpwDdVnHP5M=
X-Gm-Message-State: AOJu0YzM4kiLruxqoCDdlYnIh8yKTcKGjsbAnJRcpIeUXTK/aD/8W+UU
	OWj3wQUlOYH9wxJjkjMIkAmRfScw+lnaMrnTBhGpWgOos6ER1BjHypqx8O+5Gfp9cH7w8aFM/sb
	cjs97v8XL9eOQ+nYtKS98uJrLGB0=
X-Google-Smtp-Source: AGHT+IGQtmhDCa3mLjVs/YPfOc6etTR6h86inDnZMXmkenFLVmQTGf8H8Ok2us2uo/Qy/4TS20k0HGc1yUTOJWyKErA=
X-Received: by 2002:a19:f812:0:b0:513:d8b:956d with SMTP id
 a18-20020a19f812000000b005130d8b956dmr1763250lff.24.1709070630756; Tue, 27
 Feb 2024 13:50:30 -0800 (PST)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20240223161247.3998821-1-hch@lst.de> <ZdjXsm9jwQlKpM87@redhat.com>
 <ZdjYJrKCLBF8Gw8D@redhat.com> <20240227151016.GC14335@lst.de>
 <Zd38193LQCpF3-D0@redhat.com> <20240227151734.GA14628@lst.de> <Zd4BhQ66dC_d7Mn0@redhat.com>
In-Reply-To: <Zd4BhQ66dC_d7Mn0@redhat.com>
From: Song Liu <song@kernel.org>
Date: Tue, 27 Feb 2024 13:50:19 -0800
X-Gmail-Original-Message-ID: <CAPhsuW69mM3tEBR=SgKy_SYE+NUsNO+8H6toyk+5mKcSfGMjmg@mail.gmail.com>
Message-ID: <CAPhsuW69mM3tEBR=SgKy_SYE+NUsNO+8H6toyk+5mKcSfGMjmg@mail.gmail.com>
Subject: Re: atomic queue limit updates for stackable devices
To: Mike Snitzer <snitzer@kernel.org>, Benjamin Marzinski <bmarzins@redhat.com>, Xiao Ni <xni@redhat.com>, 
	Zdenek Kabelac <zkabelac@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Mikulas Patocka <mpatocka@redhat.com>, 
	Yu Kuai <yukuai3@huawei.com>, dm-devel@lists.linux.dev, linux-block@vger.kernel.org, 
	linux-raid@vger.kernel.org, lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

CC Benjamin, Zdenek, and Xiao, who are running the lvm tests.

On Tue, Feb 27, 2024 at 7:36=E2=80=AFAM Mike Snitzer <snitzer@kernel.org> w=
rote:
>
> On Tue, Feb 27 2024 at 10:17P -0500,
> Christoph Hellwig <hch@lst.de> wrote:
>
> > On Tue, Feb 27, 2024 at 10:16:39AM -0500, Mike Snitzer wrote:
> > > That's the mainline issue a bunch of MD (and dm-raid) oriented
> > > engineers are working hard to fix, they've been discussing on
> > > linux-raid (with many iterations of proposed patches).
> > >
> > > It regressed due to 6.8 MD changes (maybe earlier).
> >
> >
> > Do you know if there is a way to skip specific tests to get a useful
> > baseline value (and to complete the run?)
>
> I only know to sprinkle 'skip' code around to explicitly force the
> test to get skipped (e.g. in test/shell/, adding 'skip' at the top of
> each test as needed).

I think we can do something like:

make check S=3D<list of test to skip>

I don't have a reliable list to skip at the moment, as some of the tests
fail on some systems but not on others. However, per early report,
I guess we can start with the following skip list:

shell/integrity-caching.sh
shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
shell/lvconvert-raid-reshape.sh

Thanks,
Song
