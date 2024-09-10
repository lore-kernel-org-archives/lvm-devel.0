Received: from mail-pj1-f41.google.com (mail-pj1-f41.google.com [209.85.216.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0A2B19994D
	for <lvm-devel@lists.linux.dev>; Tue, 10 Sep 2024 16:05:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1725984331; cv=none; b=qYYuCnKxZ2ysnvWQ3LQE5400pwsjfFssIixEO+b992PjDcAwnjSKfLViDwIUW+kfiUwoQ2Ql0Sl0uCX9Uj9wAr4DzhDjGA/nfYfYZdSkqJ9ojRONOZqRSgdmIKqpUFUNlWfEgrmuO+ud+Tsj6SUI69OWMmeMtr3+VI6e+8ItCak=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1725984331; c=relaxed/simple;
	bh=V5wg24qrzj7KwRIlznFnZ+bXKdN/u27ftA26a4V4HoE=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=FtzR/mzbidZ/ZknazA7ii5x7EDJfErkL5B/GEnONxN+03rdcbfTtID/AqdTqv69tt6YYJsysGXc+Ba2w98bZ7Yf1i3V5gAgzZ+2E36z31STwgimpcDTqeMP+4nm7r1Yo2bRU0cC/j2WARXhfFgbWJNoGwXAsJVT6+fGKDuqiWK0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com; spf=fail smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=KMK9+x5y; arc=none smtp.client-ip=209.85.216.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="KMK9+x5y"
Received: by mail-pj1-f41.google.com with SMTP id 98e67ed59e1d1-2d892997913so3753045a91.3
        for <lvm-devel@lists.linux.dev>; Tue, 10 Sep 2024 09:05:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1725984329; x=1726589129; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=dK21jjtQ46vU3HWaQx4vEXNUI/nNEdleDzpXaIgRwb0=;
        b=KMK9+x5yM1c22HGImvHKEYe92tvPu8k5xO0wMMQbZ7vtfFjfrdaxxfuwY+JG/dXl36
         fiNZUPyhbwZMvHkkwaPii+/kW8qvATQcgwQP4T4yAlw8LMMQF1DTs8Cw+8P7PohgqjvY
         kfIeUhacdbil+HMuVUTmAwq74ChQzhef/qBpDNhE/yvjxkSytoYV3bz837AkSu3vi4rr
         yC1K6NG5r5UlX2XsQUYok5+UYfBafVqUQxSRZqMFswSx+RCvir84YWNEN8kyYo8u8I3I
         iCHJYupVqHgd8IaJTWeVVh23eXfY/7Ts9M87C9BsMBcY8rdKItFwQeEP3Sp/Tafr8Url
         8IwA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1725984329; x=1726589129;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=dK21jjtQ46vU3HWaQx4vEXNUI/nNEdleDzpXaIgRwb0=;
        b=o34arI76t8/V/T8toY5+o7HTN8nkWj3Q5tWwRjNKBpZlDan8i9uiZLWiGdo4pi92fK
         zVQD2yxtf99WtFTIoAYVEhzOTpfy50Z0yJi8dBuIQT+DbVqxRbfp4Bq/E2AFDzpNprnR
         gU5F7Q1EeWJF+iRQ570ZgeMbswse9n0/A04D8Z0dKyexXV7Fih2O+F3pChzdXoFaeEDV
         +o/YaBfnzJ7IiqtKoSFb1iP2TA2cGpVqIwlClnT6oxyD8FqxsxbbrFjl74SD6gwSJ9Pu
         4nhS4eYpvg1HYX6mJ7Mnvu4E/gQuHLQA/mSIpJGQFrb3GF/KYo7LA59D1QNpaLg+pn/H
         woWw==
X-Forwarded-Encrypted: i=1; AJvYcCWWQwXP+cTD+7kE2eWz6cspwDOUFJuk0d2Jo+fDaRkxf8sNDp5eYTOn4Oj7KdfmmwQoeo2v0aL6rQU=@lists.linux.dev
X-Gm-Message-State: AOJu0Yw1jYokdLhpTqqIHpNrfig4TBsQdva73dBXgKrcEhaJxRyvqAlK
	iEYcoBKQW/Cffv+e0tlKJtHZHEaaI8V2Bji+bPpMHrVR70Oh6JCVeCnUA8zzRHsYzJnDqn9CNII
	/58TvRT5m2yv5+dAnjwIidf1wcrOH3KZPmlKykQ==
X-Google-Smtp-Source: AGHT+IEVL4WJdbG0qKUd3BW0uOUIRNQA9Uh2z1L/7vIIZcvXEskuYMdMWHZdZCmXpxaen2h6SAmiXwz2fmkRZtDQoDY=
X-Received: by 2002:a17:90b:4a0f:b0:2d8:7a1c:b7e2 with SMTP id
 98e67ed59e1d1-2dad50fa012mr16780562a91.35.1725984328526; Tue, 10 Sep 2024
 09:05:28 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
 <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com> <CAHJKXw1Xc7fabs=JOjgcuh8vTwkVMRvN2Mx9UO3Dfm8iZxxZ-w@mail.gmail.com>
 <CALjSBEu7FA7Fv87P51vkiL98jRG42R3rkf2RUuxTEjHoQHMwdA@mail.gmail.com>
In-Reply-To: <CALjSBEu7FA7Fv87P51vkiL98jRG42R3rkf2RUuxTEjHoQHMwdA@mail.gmail.com>
From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Tue, 10 Sep 2024 21:35:15 +0530
Message-ID: <CAFe+wq0NPWHwon2QWdfJ8BkzVzUnSfOzLQGxXNykUW6jzyDiuw@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Ming Hung Tsai <mtsai@redhat.com>
Cc: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>, lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Ming,
Thanks for reaching out.

It looks like at the moment, writes, reads and discards are in the
mix, with block sizes varying from 16K-128K on a thin pool with chunk
size 64K, pool capacity many TB.
multiple thin lvols in the pool(200G), and all of them are busy processing =
IOs.
This is on a VM, and storage disks are from iscsi SAN, mpath, md array
acting as lvm pv,  over which a thin pools gets formed.
And while in this setup, and IOs in progress, power cycle tests are
attempted and after recovering end up with data loss.

Our internal study is still evolving at the moment, I will share more
as I find more.
Switching to latest fedora 40 is a challenge for me, whats the next
distro you may have in mind? Maybe list a few so I can pick whats
easier my end.

Regards

On Tue, Sep 10, 2024 at 9:23=E2=80=AFPM Ming Hung Tsai <mtsai@redhat.com> w=
rote:
>
> On Mon, Sep 9, 2024 at 10:53=E2=80=AFPM Lakshmi Narasimhan Sundararajan
> <lns.myspace@gmail.com> wrote:
> >
> > On Mon, Sep 9, 2024 at 6:57=E2=80=AFPM Zdenek Kabelac <zdenek.kabelac@g=
mail.com> wrote:
> > >
> > > Dne 08. 09. 24 v 3:37 Lakshmi Narasimhan Sundararajan napsal(a):
> > > > Hi Team,
> > > > Greetings!
> > > >
> > > > In my experiments with thin pool and power cycle tests, I find that
> > > > the inflight data has not been persisted, even if there is a sync
> > > > following write that got completed.
> > > >
> > > > suppose we have the following bdev stackup:
> > > > bdevs(multi) -> mpath -> lvm pv -> lvm vg -> lvm thin pool -> multi=
ple
> > > > thin vols.
> > > >
> > > > Each of the thin vols that has inflight data, has a corresponding s=
ync
> > > > checkpoint periodically. The expectation is all writes before the s=
ync
> > > > are persisted to disk and can survive power reset tests.
> > > >
> > > > Like below seq on many thin vols on the thin pool.
> > > > write -> write -> write -> fsync(fd) -> write -> write -> fsync(fd)=
 -> ..etc
> > > >
> > > > Now my code only does a fsync(fd) on the thin volume (block device =
directly).
> > > > There are no fs mounts on the volume.
> > > > Is this sufficient or should the thin pool (/dev/mapper/pool) also =
be
> > > > synced along?
> > > > What would be the proper sequence of sync actions to survive a powe=
r reset?
> > > >
> > > > I am also trying to validate if this is an issue because mpath is
> > > > involved in any way(another dm layer in between), but would appreci=
ate
> > > > some guidance in this
> > > > regard.
> > >
> > > Hi
> > >
> > > Could you please retest your issue with  recent lvm2  (>=3D 2.03.24) =
and recent
> > > linux kernel   >=3D 6.9
> >
> > Thank you for your quick attention.
> >
> > That is a big jump.
> > Would you be willing to consider any distro (say OCP latest?), that
> > will come with a bundle for both lvm+kernel, is there any such
> > combination you would consider for this test?
> > Also, is there any way I can check issues/fixes of interest?
> >
> > Is my logic using fsync(thin pool device) sufficient to pass power fail=
 tests?
> > Are there any stronger versions or more logic to ensure power reset tes=
t passes?
> >
> > Regards
> >
> > >
> > > Regards
> > >
> > > Zdenek
> > >
> >
>
> Hi,
>
> Could you please provide more details on the steps you took that led
> to the issue?
> Additionally, if possible, it would be helpful to let us know if the
> issue is reproducible on Fedora 40, with or without the mpath layer.
>
>
> Thanks,
> Ming-Hung Tsai
>
>
