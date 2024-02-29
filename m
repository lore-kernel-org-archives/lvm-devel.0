Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F8A4364A4;
	Thu, 29 Feb 2024 02:02:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709172167; cv=none; b=NBZvG8GYPUfUYcubGt7YMa3kd6YIeRJ5hYK5Mtxvj0/ocIL1l/U+DeD1nNj4pJIgO3PwzX96WKy/x+8tIxxd4dSujCEitJ8v/D299YumQnTjeZ7wPLle7XwImyZEKUi2tgof6L6oLTvnI790oJwLjqT5B88vd4aq0btEL+OtjEg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709172167; c=relaxed/simple;
	bh=AAyTW9eIWug5bOe5GvlKrcB1mn0cXjvPHZrWdE4Zouk=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=oJaF/HjnkLkCNGMdI7X7yNAXn3xxkYPIDCfpDLzINGe3r8KDnIKJ/dXwjbcE/8dTxbdHuPEjGaqJgFMpS4mGr2O+i0Gg02jZI0fhsdAcsEFJ/45dsXgNuyHQXqmmqN5XmLye2tKHJfSBLBMS+VklcVrHGKtsLtoVAZ18NoyZyhU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=plwzO2wL; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="plwzO2wL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E197EC433A6;
	Thu, 29 Feb 2024 02:02:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1709172166;
	bh=AAyTW9eIWug5bOe5GvlKrcB1mn0cXjvPHZrWdE4Zouk=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=plwzO2wLumif19xoPVvDhwHlHO/t/n5BZTdMN3HACJNHL6ZWsvihdowzV0+qo3C7L
	 oUBbvup9rPeQ82h+xyBU8QOmV4zZhYVifigEXkD/hFxNr1Uq/ViWvg4ZjJRUGD9p0q
	 y8iBz/BvKfiUocmUDN7x16W8elxa504EDyUl8fBiejWX0VBBEdfbAMlDl/XTWhbKRn
	 dfKgI3Bm/bNpRUXs1GDMhhavO5SYMx+uEUIpG7SVvj5Tr+JE88yDftw7DwfXw9Y0ji
	 jxiFkfmFJUeKAbo4ynwlwGEJFSMnoTjp8P1XNbfIlsE67yZKKp2jVzaocWtZvvjBuT
	 FxHpM5zHLNWgw==
Received: by mail-lf1-f41.google.com with SMTP id 2adb3069b0e04-51318531af4so1523498e87.0;
        Wed, 28 Feb 2024 18:02:46 -0800 (PST)
X-Forwarded-Encrypted: i=1; AJvYcCUZsnEX3/XVTuibFoM8fMTuQ1MdBSOtrpjuNzE7aYppzrQkthtN1QUqhflSZAv9JQqMT/oT/eyFhRWb9HopdGK6oRYXp8C5QBz9IrShAvqKh7hhh2ts0E29VlzSlCMxyZsIy9A=
X-Gm-Message-State: AOJu0Yxu4YXuSc4Qn743M1e+FnKubIQPStIVHsAiKZmUCui9IPZREyiI
	w+libHHgvrlfTHkjxJqokdAEgKWXyQmvUfQZY+Cze+OhW90LL8vfZPja7jllR1P+Q1e/hwrbBki
	nvwismbkpkSeHXSK85m6oL4QavkQ=
X-Google-Smtp-Source: AGHT+IGmxKdSG3kJ4IDEg6gxeL8TqreGpHHwstO1UoR6gX7sqGEm+89EqGWLN8lB7Fse50dVYq+jL6R7NkL3BeNNRW8=
X-Received: by 2002:a19:c514:0:b0:512:f4d6:7163 with SMTP id
 w20-20020a19c514000000b00512f4d67163mr178406lfe.6.1709172165035; Wed, 28 Feb
 2024 18:02:45 -0800 (PST)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20240223161247.3998821-1-hch@lst.de> <ZdjXsm9jwQlKpM87@redhat.com>
 <ZdjYJrKCLBF8Gw8D@redhat.com> <20240227151016.GC14335@lst.de>
 <Zd38193LQCpF3-D0@redhat.com> <20240227151734.GA14628@lst.de>
 <Zd4BhQ66dC_d7Mn0@redhat.com> <CAPhsuW69mM3tEBR=SgKy_SYE+NUsNO+8H6toyk+5mKcSfGMjmg@mail.gmail.com>
 <20240228195632.GA20077@lst.de>
In-Reply-To: <20240228195632.GA20077@lst.de>
From: Song Liu <song@kernel.org>
Date: Wed, 28 Feb 2024 18:02:33 -0800
X-Gmail-Original-Message-ID: <CAPhsuW5c5o8JS9T8CCGU811jpxrbepjJHnYpDbge+1rT6j8NbA@mail.gmail.com>
Message-ID: <CAPhsuW5c5o8JS9T8CCGU811jpxrbepjJHnYpDbge+1rT6j8NbA@mail.gmail.com>
Subject: Re: atomic queue limit updates for stackable devices
To: Christoph Hellwig <hch@lst.de>
Cc: Mike Snitzer <snitzer@kernel.org>, Benjamin Marzinski <bmarzins@redhat.com>, Xiao Ni <xni@redhat.com>, 
	Zdenek Kabelac <zkabelac@redhat.com>, Jens Axboe <axboe@kernel.dk>, 
	Mikulas Patocka <mpatocka@redhat.com>, Yu Kuai <yukuai3@huawei.com>, dm-devel@lists.linux.dev, 
	linux-block@vger.kernel.org, linux-raid@vger.kernel.org, 
	lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 28, 2024 at 11:56=E2=80=AFAM Christoph Hellwig <hch@lst.de> wro=
te:
>
> On Tue, Feb 27, 2024 at 01:50:19PM -0800, Song Liu wrote:
> > I think we can do something like:
> >
> > make check S=3D<list of test to skip>
> >
> > I don't have a reliable list to skip at the moment, as some of the test=
s
> > fail on some systems but not on others. However, per early report,
> > I guess we can start with the following skip list:
> >
> > shell/integrity-caching.sh
> > shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
> > shell/lvconvert-raid-reshape.sh
>
> Thanks.  I've been iterating over it this morning, eventually growing
> to:
>
> make check
> S=3Dshell/integrity-caching.sh,shell/lvconvert-raid-reshape-linear_to_rai=
d6-single-type.sh,shell/lvconvert-raid-reshape.sh,shell/lvconvert-raid-resh=
ape-linear_to_striped-single-type.sh,shell/lvconvert-raid-reshape-linear_to=
_striped.sh,shell/lvchange-raid456.sh,shell/component-raid.sh,shell/lvconve=
rt-raid-reshape-load.sh,shell/lvchange-raid-transient-failures.sh,shell/lvc=
onvert-raid-reshape-striped_to_linear-single-type.sh,shell/lvconvert-raid-r=
eshape-striped_to_linear.sh,shell/lvconvert-raid-reshape-stripes-load-fail.=
sh,shell/lvconvert-raid-reshape-stripes-load-reload.sh,shell/lvconvert-raid=
-reshape-stripes-load.sh,lvconvert-raid-reshape.sh,shell/lvconvert-raid-res=
tripe-linear.sh,shell/lvconvert-raid-status-validation.sh,shell/lvconvert-r=
aid-takeover-linear_to_raid4.sh,shell/lvconvert-raid-takeover-raid4_to_line=
ar.sh,shell/lvconvert-raid-takeover-alloc-failure.sh
>
> before giving up.  I then tried to run the md-6.9 branch that's
> supposed to have the fixes, but I still see the same md_stop_writes
> hangs.

md-6.9 branch doesn't have all the fixes, as some recent fixes
are routed via the md-6.8 branch. You can try on this branch, which
should provide a better base line. The set applies cleanly on this
branch.

https://git.kernel.org/pub/scm/linux/kernel/git/song/md.git/log/?h=3Dmd-6.9=
-for-hch

Thanks,
Song
