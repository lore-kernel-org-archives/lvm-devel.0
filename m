Received: from mail-pg1-f175.google.com (mail-pg1-f175.google.com [209.85.215.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A215D2A8C1
	for <lvm-devel@lists.linux.dev>; Tue, 17 Sep 2024 17:03:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726592611; cv=none; b=ub8DcREq1Eju8y2pjrp6YTVSpmDKoVdfZoPKsLIr2DJi0L+is34vj3g9LJXCbsy7zPsBiGrrOJr+CPjY5foWtLqdCwRkQGLRmZm4P5e1F2YdzFHVA6ytpRj+DGC09uvtefsE37hx/MmaWpBqQI/SFryIr9gDMwHJd7ehGeN2RL4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726592611; c=relaxed/simple;
	bh=tfiG/palGmRnSdPTDkwXj/nN7hsNxljkOJHGcXNk8kk=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=lt2i3uSqjRorqC5Ak7Cx8mhWdVQKYPQ1CMe4Xf+MabrgJ8I6qYHmXkpCGFR9oM3fLItNld+cljfak0UPJqI0MlwMiHAnN1npz/34J9Detf2JuvHtMBoJ3PukVIfjSlPQ74pUZwAIiej8wyGkQFyVTRO10i0zR96Waz4S0V3OuFo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Zd51QGBs; arc=none smtp.client-ip=209.85.215.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Zd51QGBs"
Received: by mail-pg1-f175.google.com with SMTP id 41be03b00d2f7-7d4f85766f0so4925624a12.2
        for <lvm-devel@lists.linux.dev>; Tue, 17 Sep 2024 10:03:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1726592609; x=1727197409; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=3F+ciiFbIW1xdHv3Pe0pVr50TnjAstdMjK//QaVTEj8=;
        b=Zd51QGBsWi1ENYpf89wmyfJcbge+8ARv5o7qzbXLI1B028H3eIwWsx7rwG36cMdQ1N
         PwcUvSDvFsvq3HKjjJhiHW5wvuPv7m+V9JoHXbSDaMMAVRXN4gVbkTOSzUQBzmDTcD58
         yI5Wb73QBybQpPt7MmcDEpMLu67sTigzV8F/cMolMmU6COm6xvEW30Th88SX/g4NoKGQ
         RMYKJWoSlGgG7U6f+GBvN9ql5MnEwkNBmOk0L7BPEQRaKX2/4DmvwyuoBivO9+EmmLvV
         hqJfs92FPdq+T1pbzR2UxdWC/DH8jNNP9pvEAmMK4JYRhy1w0rcNxY5w2pTSovCiT0NE
         D5Dg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726592609; x=1727197409;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=3F+ciiFbIW1xdHv3Pe0pVr50TnjAstdMjK//QaVTEj8=;
        b=C8KaNLZpLckQuGq9RGXcmlzC5B9DPoZwy076QsZz4KxCTzQ+25FiXR6/UbmRWM2Uic
         zLWPWU8OLPk3rj5D8m+IxcrV0/0KgiLzLDZ+Ro8Q9Gl03fGaiB+kgb2t8RaXfsHMgw9L
         7sGJCuTClzpxc4v6Vv/O2r3tsYysqyOWOsw/EtNjxIx02jfvI/SKDEdMarHQmkM1iSdc
         Kx8TvoGSOarmnsau79qexznMWgWY5X0ReGGWeiNsfNnWSmgLqtEYVzbeH/+2LicoTeNP
         5eeWZ5TNSFp0NWroTgq6N8nyN7eZvOvCWC7C3Stl6/BJNLHsyDqV3MFkgjLkOEk/dehN
         N8Ag==
X-Forwarded-Encrypted: i=1; AJvYcCXSeC3hNm0YXntHO7Hzy6mvvOxlKOwIeVrsv50hH1NqXauVao8/xgvTVTIBSMNq9wxjU9i8Ca9I6ec=@lists.linux.dev
X-Gm-Message-State: AOJu0YxEanlkU3N/KT0aTwCt3rrdjnniP3pqhISZt3A+/Licdr9NooNE
	oqc+GQKvzGhlA+ebd0N4Q9WC06qCaLCgLaCynMfiuAfN91HoKcn0CL26OIIsRdaUNMFiTokwEie
	e/vYf7iLSkGYzu/8dLcPkqhnFJsw=
X-Google-Smtp-Source: AGHT+IHVoKWio/WRS1ZaddKW87JN0ielBtLH2oL69plICDnFFTG4DgVLwp8MRhnnRDMXwaaPljdDSD61XA/fMsNavvw=
X-Received: by 2002:a05:6a21:1693:b0:1cf:2b8c:b5e0 with SMTP id
 adf61e73a8af0-1cf76358e74mr27650983637.37.1726592608778; Tue, 17 Sep 2024
 10:03:28 -0700 (PDT)
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
In-Reply-To: <CAPmdA5Yw+C-VTATaKJxQTsOrmYexKWiXHLK9+u7NNU1KF_D3Tg@mail.gmail.com>
From: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Date: Tue, 17 Sep 2024 22:33:16 +0530
Message-ID: <CAHJKXw2jCEGFsb+EveUwJ0J-PGJP1OKuGAg6LkdYgBs4xJYsEQ@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Tony Asleson <tasleson@redhat.com>
Cc: Zdenek Kabelac <zdenek.kabelac@gmail.com>, Ming Hung Tsai <mtsai@redhat.com>, 
	Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>, lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 13, 2024 at 7:49=E2=80=AFPM Tony Asleson <tasleson@redhat.com> =
wrote:
>
> You may want to check out https://lwn.net/Articles/457667/
>
> On Fri, Sep 13, 2024 at 9:06=E2=80=AFAM Zdenek Kabelac <zdenek.kabelac@gm=
ail.com> wrote:
> >
> > Dne 13. 09. 24 v 7:55 Lakshmi Narasimhan Sundararajan napsal(a):
> > > Hi Ming,
> > > I am still collecting results, so I will present findings that are
> > > confirmed so far.
> > > There is some good news too.
> > >
> > > On Fri, Sep 13, 2024 at 1:11=E2=80=AFAM Ming Hung Tsai <mtsai@redhat.=
com> wrote:
> > >>
> > >> Hi,
> > >>
> > >> On Wed, Sep 11, 2024 at 12:05=E2=80=AFAM Lakshmi Narasimhan Sundarar=
ajan
> > >> <lsundararajan@purestorage.com> wrote:
> >
> > > My application that is consuming the thin device pumps IO traffic
> > > directly on the raw block device.
> > > My application also keeps a journal record outside the thin pool and
> > > after power recycled, reading the data back
> > > did not guarantee sync consistency.
> > >
> > > I wrote a sample program that is trying to recreate this outside my a=
pplication.
> > > here it is: sulakshm/iotest: iotest (github.com)
> > > I am still refining it, as I have not seen the problem with this tool=
 yet.
> > > But the logic is similar to how my application consumes thin dev; and
> > > my app can reproduce this very easily.
> > >
> > > As I said before, I am still collecting additional information from
> > > many internal tests.
> > > So far, I can see this problem even in 6.5 kernel.
> > >
> > > The latest distro/linux kernel where this problem is seen.
> > >> 6.5.0-15-generic #15~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan 12 1=
8:54:30 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
> > >
> > >
> > > There is a workaround to this problem that is looking promising, test=
s
> > > ongoing still.
> > >
> > > The sync point from my application is a sync(fd) of the thin dev.
> > > This has proven insufficient.
> > > In addition, I had to perform "dmsetup suspend pool -> dmsetup resume=
 pool".
> > > This guarantees sync point consistency.
> > >
> >
> > Hi
> >
> > Not exactly sure what your app is all exactly doing - however there is
> > cut&paste from 'fsync()'  manpage:
> >
> > ---
> > Calling fsync() does not necessarily ensure that the entry in the direc=
tory
> > containing the file has also  reached  disk.   For  that  an  explicit
> > fsync() on a file descriptor for the directory is also needed.
> > ---
> >
> > For this purpose our 'test suite' app basically  'opens' whole device a=
nd
> > fsync and close it - to ensure synchronization point flush.
> >
> > Thus 'suspend & resume' of the whole thin device could be possibly unne=
cessary
> > - just do a fsync() on blockdevice fd.
> >
> >
> > You can also play fun games with 'fsfreeze' operation.


Good day all!

This issue has been rootcaused successfully to an issue with my application=
.
It had been a tough last week given the nature of the issue, and
thanks for everyone who reached out with helpful suggestions.
As part of this process and bug verification, I would gladly submit
that the thin pool implementation did withstand the power cycle tests
wonderfully.

Best regards and you all have a wonderful day.




> >
> > Regards
> >
> > Zdenek
> >
> >
> >
>
