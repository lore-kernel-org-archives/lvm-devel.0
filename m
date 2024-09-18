Received: from mail-pj1-f41.google.com (mail-pj1-f41.google.com [209.85.216.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB21D15D5A1
	for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 10:24:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726655100; cv=none; b=W2KzM84hUOqCSqQt0iE77h69zJf3DstFuj6f9BtLE1Ueexr8tJIpZE8p5OMqjrbhtoZ9sBgyyfACAtY0FJvGcVtuTGo1pNRKmtoYc75wDOqJE8tu4xC2Qo1n4rrbbRXXoBVw6ObJ3TV7knyj19BMUfla4r1OFF458kGOiKtn9PI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726655100; c=relaxed/simple;
	bh=vYhKyRklFJtcvwpoovuYVxTJZGRcPrDuhb8If0qw44k=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=grag/XllBMP5wDDRgeU6h+ZfqV9LjJHAHnVKPQMW4F0e2Jav8Bj0OpzXz+QX0+dMOb1lssD5Ewii2sR6e9SibO09EaP40AtdVx2I45fsx5eCpXKgfj8zmY4WOuWK/MjDEAoph6N5MFXw6KnNr2yHjhlEIOh+xzM341setWU5rS0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com; spf=fail smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=XdQamvh+; arc=none smtp.client-ip=209.85.216.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="XdQamvh+"
Received: by mail-pj1-f41.google.com with SMTP id 98e67ed59e1d1-2da55ea8163so4571407a91.1
        for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 03:24:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1726655098; x=1727259898; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=rv+m8zAeMUSo/N/GMP1z1Gnalf9L02wA1B5ctriDORw=;
        b=XdQamvh+EVDaodrD5eJOqp8+kvZrs8/8Y+A33EsFXfyb+EVdKerpm3ybIJvJPvNdpE
         0Em+grjtgIDdJjvc1qKVMoWhJzDc7VgMlk1qtA8iMfGpopzwPO/MFrJ3s0WWGy6Rbr5l
         o4Y060o4CxVJT0qfMLwvSmYE8i4KRXBYeUUZcS0jNGd8gL9ayPnHfzqoXdnXDL8qhkdS
         y0KhkWdN95HH8btfWkNSqe7Pvxp/ljfJa3LVM/fImwEqlSlyynkhpXRe4iql6KKA4Lk7
         8qx8kk4BOH+DZ1GBaDGS8y+IUOCM1f7zSwcXQwYwo/y+Ulw+HQRmb4yfADxgwNg+UaHv
         EM6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726655098; x=1727259898;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=rv+m8zAeMUSo/N/GMP1z1Gnalf9L02wA1B5ctriDORw=;
        b=g9qEZ9ckwJuTSTpQH7v+7+DW0xld6dZIr47XGTt5bf5LDyTSZArecsfRBjYBh3o4JI
         W9ATGKh65meTzD1wNsK02V1xGZAKl7U85SvfN/i+AE1mLGLkpK6MPKfCHpHmUXwGvixS
         c1ewqL3O6DVYtemmy7lQc37Q4vhB3XKY72+Ndwa7gw18U//HTU7uuLZNXkwxKCac02Fk
         ie+wmXvm0fJOj/nCxwNJj3gXuCgzP1FOjovvnQ4wp2oYuHUAB20s2RUnxuUXMRYNJuHC
         LRPEt+o3RGqizAdWDuN3RVuAMrgHVhz9JaSMse0C17UYrG4MG/bIG931KKPSnyVBueTD
         6HbA==
X-Forwarded-Encrypted: i=1; AJvYcCWZWADhb1KjSivaRrm60Iqu9ChZFTlIA4ZDiK23xUY3zfza66lEpzC//ng4um+tS1Md1vNzV7UCfU0=@lists.linux.dev
X-Gm-Message-State: AOJu0YyTcnGEC9Lp/fNgp5Uq6oD5kIlQ3is7fdqa7bw0w6B1mqukQm/M
	e+SEz4mn6r2G3poro4zS6wOweiVGcDuhotkckt0mQEjpB/dRLeapvqGH1YT9tiKqIZTSYw46m/l
	dwG3YD3vOa+H2epUZNgnCQmeP0NtG19aNw+eFUA==
X-Google-Smtp-Source: AGHT+IFZBDkjaFD6ESeeKymc9ElCJIFNZBwfZniukWFWJejnqrJvBFO7ErLB/LdGkoH4mbcVNwsnfJ0NhBQzO+Etkc4=
X-Received: by 2002:a17:90a:68c5:b0:2c9:6cd2:1732 with SMTP id
 98e67ed59e1d1-2db9fec89a1mr25091186a91.0.1726655097986; Wed, 18 Sep 2024
 03:24:57 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
 <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com> <CAHJKXw1Xc7fabs=JOjgcuh8vTwkVMRvN2Mx9UO3Dfm8iZxxZ-w@mail.gmail.com>
 <CALjSBEu7FA7Fv87P51vkiL98jRG42R3rkf2RUuxTEjHoQHMwdA@mail.gmail.com>
 <CAFe+wq0NPWHwon2QWdfJ8BkzVzUnSfOzLQGxXNykUW6jzyDiuw@mail.gmail.com>
 <CALjSBEtiPbHVsyJnQDFzk-zwk843-8a7D75_s3yBBnjpZDgphw@mail.gmail.com>
 <CAHJKXw3d8-9RVhEaZ5+GuSB3LfgBMoy9mkUXEAoqwPTJdjhrjw@mail.gmail.com>
 <51fdc9a7-8639-4c1a-b8a5-c3be0a5a61f5@gmail.com> <CAPmdA5Yw+C-VTATaKJxQTsOrmYexKWiXHLK9+u7NNU1KF_D3Tg@mail.gmail.com>
 <CAHJKXw2jCEGFsb+EveUwJ0J-PGJP1OKuGAg6LkdYgBs4xJYsEQ@mail.gmail.com> <CALjSBEvZ_5FU90D8ZaM9QjjPBvDPvgDKr+baTd3qSMyDOUyxhg@mail.gmail.com>
In-Reply-To: <CALjSBEvZ_5FU90D8ZaM9QjjPBvDPvgDKr+baTd3qSMyDOUyxhg@mail.gmail.com>
From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 18 Sep 2024 15:54:46 +0530
Message-ID: <CAFe+wq3jGnnkQBuAnELraO5F529RiM6-Z6Pu19xZYBniej7Jxg@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Ming Hung Tsai <mtsai@redhat.com>
Cc: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>, Tony Asleson <tasleson@redhat.com>, 
	Zdenek Kabelac <zdenek.kabelac@gmail.com>, lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 18, 2024 at 3:51=E2=80=AFPM Ming Hung Tsai <mtsai@redhat.com> w=
rote:
>
> Hi Lakshimi,
>
> I'm glad to hear you've resolved the issue. If you're comfortable
> sharing, would you mind providing some insights into the root cause?

Why not, fsync(thin dev) got incorrectly built leaving out a few
devices while syncing a pool with multiple thin devices.

LN



>
>
> On Wed, Sep 18, 2024 at 1:03=E2=80=AFAM Lakshmi Narasimhan Sundararajan
> <lns.myspace@gmail.com> wrote:
> >
> > On Fri, Sep 13, 2024 at 7:49=E2=80=AFPM Tony Asleson <tasleson@redhat.c=
om> wrote:
> > >
> > > You may want to check out https://lwn.net/Articles/457667/
> > >
> > > On Fri, Sep 13, 2024 at 9:06=E2=80=AFAM Zdenek Kabelac <zdenek.kabela=
c@gmail.com> wrote:
> > > >
> > > > Dne 13. 09. 24 v 7:55 Lakshmi Narasimhan Sundararajan napsal(a):
> > > > > Hi Ming,
> > > > > I am still collecting results, so I will present findings that ar=
e
> > > > > confirmed so far.
> > > > > There is some good news too.
> > > > >
> > > > > On Fri, Sep 13, 2024 at 1:11=E2=80=AFAM Ming Hung Tsai <mtsai@red=
hat.com> wrote:
> > > > >>
> > > > >> Hi,
> > > > >>
> > > > >> On Wed, Sep 11, 2024 at 12:05=E2=80=AFAM Lakshmi Narasimhan Sund=
ararajan
> > > > >> <lsundararajan@purestorage.com> wrote:
> > > >
> > > > > My application that is consuming the thin device pumps IO traffic
> > > > > directly on the raw block device.
> > > > > My application also keeps a journal record outside the thin pool =
and
> > > > > after power recycled, reading the data back
> > > > > did not guarantee sync consistency.
> > > > >
> > > > > I wrote a sample program that is trying to recreate this outside =
my application.
> > > > > here it is: sulakshm/iotest: iotest (github.com)
> > > > > I am still refining it, as I have not seen the problem with this =
tool yet.
> > > > > But the logic is similar to how my application consumes thin dev;=
 and
> > > > > my app can reproduce this very easily.
> > > > >
> > > > > As I said before, I am still collecting additional information fr=
om
> > > > > many internal tests.
> > > > > So far, I can see this problem even in 6.5 kernel.
> > > > >
> > > > > The latest distro/linux kernel where this problem is seen.
> > > > >> 6.5.0-15-generic #15~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan =
12 18:54:30 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
> > > > >
> > > > >
> > > > > There is a workaround to this problem that is looking promising, =
tests
> > > > > ongoing still.
> > > > >
> > > > > The sync point from my application is a sync(fd) of the thin dev.
> > > > > This has proven insufficient.
> > > > > In addition, I had to perform "dmsetup suspend pool -> dmsetup re=
sume pool".
> > > > > This guarantees sync point consistency.
> > > > >
> > > >
> > > > Hi
> > > >
> > > > Not exactly sure what your app is all exactly doing - however there=
 is
> > > > cut&paste from 'fsync()'  manpage:
> > > >
> > > > ---
> > > > Calling fsync() does not necessarily ensure that the entry in the d=
irectory
> > > > containing the file has also  reached  disk.   For  that  an  expli=
cit
> > > > fsync() on a file descriptor for the directory is also needed.
> > > > ---
> > > >
> > > > For this purpose our 'test suite' app basically  'opens' whole devi=
ce and
> > > > fsync and close it - to ensure synchronization point flush.
> > > >
> > > > Thus 'suspend & resume' of the whole thin device could be possibly =
unnecessary
> > > > - just do a fsync() on blockdevice fd.
> > > >
> > > >
> > > > You can also play fun games with 'fsfreeze' operation.
> >
> >
> > Good day all!
> >
> > This issue has been rootcaused successfully to an issue with my applica=
tion.
> > It had been a tough last week given the nature of the issue, and
> > thanks for everyone who reached out with helpful suggestions.
> > As part of this process and bug verification, I would gladly submit
> > that the thin pool implementation did withstand the power cycle tests
> > wonderfully.
> >
> > Best regards and you all have a wonderful day.
> >
> >
> > > >
> > > > Regards
> > > >
> > > > Zdenek
> > > >
> > > >
> > > >
> > >
> >
>
