Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B4A217A597
	for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 10:44:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726656263; cv=none; b=RqD3RyqV+xj6Jt9Y6rU+G851OVFeRLGTUGiZshi6eTYaChfRWm4Fi96R2ijIYl/MKae25TdKlF+SST6QUpM/HYZHIMwndF7vxZAgvEzsjVnMkumcGpOz+ojVl5AtxJxyaB4b2M/oQpPdpNJXJFAwjZmSy7GwxeQox+cAegddjiQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726656263; c=relaxed/simple;
	bh=DEC3MmxIdK4qpHYCRRP5DAWGissqC4hr0FWrm6K0nbo=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=qBjQ+iP0cjt595HS14eomFJyT4KFxJCtQEQwGyDZaLSIuZ+6cC8H6suTZIl38wuIQZXwQtrkk6QFJ0Q5SZricifMBzn1oGeFYPezq6z/bgRl/WRuPz2fO9jnsNJ7dSCZ0zvjiDGoI3pU8ypBPP6E9dpWhCBfLBrR4H4tlpn6lKs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=f0SKOmng; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="f0SKOmng"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1726656260;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=FIe8uRIbBffd5NRv/6j65hkA+wHG81SolcmNtZH2MWw=;
	b=f0SKOmngA1CQbHpWkJ3MfCQQjAQr/lI16cYCA7ieuQIwNc0XB46owlpJrk25n6ZAbJMcqJ
	44AwuWVuUjUzDk4Rkm2YWQioM7L8HnlA6fvG+V7F9kZLhbxMcAmfJLif0unTfPIc5ojePI
	Z9gnvnMRaBTg8mj8JJApsj9liA8lREk=
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com
 [209.85.167.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-690-2NQJjBc2Nom1hA59MUwKLw-1; Wed, 18 Sep 2024 06:44:19 -0400
X-MC-Unique: 2NQJjBc2Nom1hA59MUwKLw-1
Received: by mail-oi1-f198.google.com with SMTP id 5614622812f47-3dee94f0dcdso5152582b6e.3
        for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 03:44:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726656258; x=1727261058;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=FIe8uRIbBffd5NRv/6j65hkA+wHG81SolcmNtZH2MWw=;
        b=gop/Q+1TVrdaKeIAbieeNhKpGkaI0sW/X2FNVVl8fdCcDz2ZbO/DMKOoM+wazEOCSe
         t291OLlntP+M8Rjv5rgbpcXm0jp0/GJSwlwV1UBHEtzftizZfnAH3R7Epk9DwJKdL9PN
         SRQ2+uAuKXwRAblOL3Q2GRDvsBFCbs+o1AfD98p/fGySrNpft19NuJyxRJz0isq6BWkQ
         aBM4Lr+HUPWpZz92WTcVPsMJlRzxuy0/+SMIEVaSUCJPlDCkCZK4D+xgcPbb8tAi3PZc
         XxH5AT40jIt/ZDuDf6jktfLnWkRK50ljbsAkprJyYZgPPszgrF+tlonTK7rS0jUuoWwl
         uiAg==
X-Forwarded-Encrypted: i=1; AJvYcCXmgiZkCSODtq6eOdjA8UHSlsQ9uYgpkqM4CDzp16fUkg1699ou0QKvhicdWO5m0zWfnSnJ4zlUkkQ=@lists.linux.dev
X-Gm-Message-State: AOJu0Yy8RSDFstdHX20t3qQ1Hs01ilyfspUVOao6/IQ6mKM5l5QBveha
	hI2wzE8YXC97V3cg7FcsejCWCRwZgzvZodJPhdFf8Q9BhDkX/raKW237bhO0n75xkne8rRy1mHG
	2LN8jxgq2sw1Tbg1h+N3IibTJVmA/cN8muSkITbHVCsIlQnrHBXtU16tgQJwDzHSqhzAQIo45LN
	kjfRw8zta7cdwsRJXn6BYz+aTq1z9nKq+n/wZWvwaNaw==
X-Received: by 2002:a05:6808:6491:b0:3da:a721:283 with SMTP id 5614622812f47-3e071a90a9amr11988425b6e.7.1726656257961;
        Wed, 18 Sep 2024 03:44:17 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IH92bpX5A9aaB49ZntAH0jMP80lo1g32OkWZJgUnHX1uCjF+yEAAUEXHC9+OL12sH4xoyfcF+UwOC4P683+GaY=
X-Received: by 2002:a05:6808:6491:b0:3da:a721:283 with SMTP id
 5614622812f47-3e071a90a9amr11988420b6e.7.1726656257651; Wed, 18 Sep 2024
 03:44:17 -0700 (PDT)
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
 <CAHJKXw2jCEGFsb+EveUwJ0J-PGJP1OKuGAg6LkdYgBs4xJYsEQ@mail.gmail.com>
 <CALjSBEvZ_5FU90D8ZaM9QjjPBvDPvgDKr+baTd3qSMyDOUyxhg@mail.gmail.com> <CAFe+wq3jGnnkQBuAnELraO5F529RiM6-Z6Pu19xZYBniej7Jxg@mail.gmail.com>
In-Reply-To: <CAFe+wq3jGnnkQBuAnELraO5F529RiM6-Z6Pu19xZYBniej7Jxg@mail.gmail.com>
From: Ming Hung Tsai <mtsai@redhat.com>
Date: Wed, 18 Sep 2024 18:44:06 +0800
Message-ID: <CALjSBEtB2EEs6hMCs119JjCXg0QxHR6ng2bP759CJ3vK318LQw@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Cc: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>, Tony Asleson <tasleson@redhat.com>, 
	Zdenek Kabelac <zdenek.kabelac@gmail.com>, lvm-devel@lists.linux.dev
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 18, 2024 at 6:25=E2=80=AFPM Lakshmi Narasimhan Sundararajan
<lsundararajan@purestorage.com> wrote:
>
> On Wed, Sep 18, 2024 at 3:51=E2=80=AFPM Ming Hung Tsai <mtsai@redhat.com>=
 wrote:
> >
> > Hi Lakshimi,
> >
> > I'm glad to hear you've resolved the issue. If you're comfortable
> > sharing, would you mind providing some insights into the root cause?
>
> Why not, fsync(thin dev) got incorrectly built leaving out a few
> devices while syncing a pool with multiple thin devices.
>
> LN
>

Thanks for the update. Was it due to an issue during the kernel build
process or possibly some custom patches? Also, do you still need the
"dmsetup suspend/resume pool" workaround to pass the tests?


>
> >
> >
> > On Wed, Sep 18, 2024 at 1:03=E2=80=AFAM Lakshmi Narasimhan Sundararajan
> > <lns.myspace@gmail.com> wrote:
> > >
> > > On Fri, Sep 13, 2024 at 7:49=E2=80=AFPM Tony Asleson <tasleson@redhat=
.com> wrote:
> > > >
> > > > You may want to check out https://lwn.net/Articles/457667/
> > > >
> > > > On Fri, Sep 13, 2024 at 9:06=E2=80=AFAM Zdenek Kabelac <zdenek.kabe=
lac@gmail.com> wrote:
> > > > >
> > > > > Dne 13. 09. 24 v 7:55 Lakshmi Narasimhan Sundararajan napsal(a):
> > > > > > Hi Ming,
> > > > > > I am still collecting results, so I will present findings that =
are
> > > > > > confirmed so far.
> > > > > > There is some good news too.
> > > > > >
> > > > > > On Fri, Sep 13, 2024 at 1:11=E2=80=AFAM Ming Hung Tsai <mtsai@r=
edhat.com> wrote:
> > > > > >>
> > > > > >> Hi,
> > > > > >>
> > > > > >> On Wed, Sep 11, 2024 at 12:05=E2=80=AFAM Lakshmi Narasimhan Su=
ndararajan
> > > > > >> <lsundararajan@purestorage.com> wrote:
> > > > >
> > > > > > My application that is consuming the thin device pumps IO traff=
ic
> > > > > > directly on the raw block device.
> > > > > > My application also keeps a journal record outside the thin poo=
l and
> > > > > > after power recycled, reading the data back
> > > > > > did not guarantee sync consistency.
> > > > > >
> > > > > > I wrote a sample program that is trying to recreate this outsid=
e my application.
> > > > > > here it is: sulakshm/iotest: iotest (github.com)
> > > > > > I am still refining it, as I have not seen the problem with thi=
s tool yet.
> > > > > > But the logic is similar to how my application consumes thin de=
v; and
> > > > > > my app can reproduce this very easily.
> > > > > >
> > > > > > As I said before, I am still collecting additional information =
from
> > > > > > many internal tests.
> > > > > > So far, I can see this problem even in 6.5 kernel.
> > > > > >
> > > > > > The latest distro/linux kernel where this problem is seen.
> > > > > >> 6.5.0-15-generic #15~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Ja=
n 12 18:54:30 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
> > > > > >
> > > > > >
> > > > > > There is a workaround to this problem that is looking promising=
, tests
> > > > > > ongoing still.
> > > > > >
> > > > > > The sync point from my application is a sync(fd) of the thin de=
v.
> > > > > > This has proven insufficient.
> > > > > > In addition, I had to perform "dmsetup suspend pool -> dmsetup =
resume pool".
> > > > > > This guarantees sync point consistency.
> > > > > >
> > > > >
> > > > > Hi
> > > > >
> > > > > Not exactly sure what your app is all exactly doing - however the=
re is
> > > > > cut&paste from 'fsync()'  manpage:
> > > > >
> > > > > ---
> > > > > Calling fsync() does not necessarily ensure that the entry in the=
 directory
> > > > > containing the file has also  reached  disk.   For  that  an  exp=
licit
> > > > > fsync() on a file descriptor for the directory is also needed.
> > > > > ---
> > > > >
> > > > > For this purpose our 'test suite' app basically  'opens' whole de=
vice and
> > > > > fsync and close it - to ensure synchronization point flush.
> > > > >
> > > > > Thus 'suspend & resume' of the whole thin device could be possibl=
y unnecessary
> > > > > - just do a fsync() on blockdevice fd.
> > > > >
> > > > >
> > > > > You can also play fun games with 'fsfreeze' operation.
> > >
> > >
> > > Good day all!
> > >
> > > This issue has been rootcaused successfully to an issue with my appli=
cation.
> > > It had been a tough last week given the nature of the issue, and
> > > thanks for everyone who reached out with helpful suggestions.
> > > As part of this process and bug verification, I would gladly submit
> > > that the thin pool implementation did withstand the power cycle tests
> > > wonderfully.
> > >
> > > Best regards and you all have a wonderful day.
> > >
> > >
> > > > >
> > > > > Regards
> > > > >
> > > > > Zdenek
> > > > >
> > > > >
> > > > >
> > > >
> > >
> >
>

