Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60EE41BFDEB
	for <lvm-devel@lists.linux.dev>; Thu, 12 Sep 2024 19:41:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726170065; cv=none; b=KWotx//CJeIhUOoNgJ4UpDO/iT3b05LvPreUfFDecxJjwxtuqMkhyuURitYnTbvoK4+DAlTq8qwxEwSin5HGAwZ1pOH8FxtNflPF+5KZjoXbbW1It1YSkIzbeuS5tUuN6r1gXXQmbCnHThrObzV0ZFhBUPgloeXr32y8g+xHa4U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726170065; c=relaxed/simple;
	bh=oJLvqw+WHf2B1ejDuRV93xKTAcFo6e+UtY31dBah2QY=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=hBTJismxNK4tNqdVbDzoKRwd4poXxJYfAXBDPWE6M6ZOZJP1vpgiSXi+6kB7DrTLkOtWXHZF7E1O2AfjDwNRLprKrN20KZ2flCPjHNaMVTE9aYSjeQ18wlf/N29H2UN7cYG6YhNfK1uMxX9mdAn2cd+sa7qC5ly58LuQecZOw/A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=azdtbuAk; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="azdtbuAk"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1726170061;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=1IvElP9ff5KtYTXFYP1L/1isiGcQhYpTsPEA8Pg5pzE=;
	b=azdtbuAka50Q/0IEYvDkyA0icFRN3U9dN4xkTDVzlLR+brctqHd5rsVAg0XEo5qYzscAGB
	oksLreh/U0heI/hgA5yEZHhM302ABqnxtmU+m0YcN4bh64e0GYPQjodBBOae603fEkqI6/
	dQUqXQHDrpDTbT433XN+TeXVEu9a/MU=
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com
 [209.85.167.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-615-AgoX8qYONoeo-EHAkr5Hxg-1; Thu, 12 Sep 2024 15:41:00 -0400
X-MC-Unique: AgoX8qYONoeo-EHAkr5Hxg-1
Received: by mail-oi1-f199.google.com with SMTP id 5614622812f47-3e04c60d101so1133622b6e.3
        for <lvm-devel@lists.linux.dev>; Thu, 12 Sep 2024 12:40:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726170059; x=1726774859;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=1IvElP9ff5KtYTXFYP1L/1isiGcQhYpTsPEA8Pg5pzE=;
        b=WSMt5Sf7PhyI9FSlHstmfJj7J8waTzhpP3qsmd+Jq0jNmxbyQMrRItotKZbjSvCT4Z
         bz6lHjga7INAeCniS78M5uummkKHc8NlQSYaXNX8LSNgUD74auZ46xZXVjPdhUnV0BoQ
         LYJt9lTgZnm1ZVSTppvOZX06GClkmMSYxmXKvbErkLe6OHm4zs0RFuT46zX7d4eNpYxF
         G5pDyVhDjthSih4kIdI9t6OKu1IsuUZgWsXjjmZlWeX0ZgTuwbYXsZQoWyObFLK7YnsO
         Ka3u1x+wfKWrdygE775jKguOFpHc9UtfMSPQI81yVU7wkC+nsnSC7oyYdMDWTEYUZZFI
         48KA==
X-Forwarded-Encrypted: i=1; AJvYcCURsIj7leJE1n6ptlUr7nFVGn+sPjC2FLzS0V6Pwid9QrpmBKVdhx9U2KL9B2tI5ow0WJjW2X/35pk=@lists.linux.dev
X-Gm-Message-State: AOJu0YwiZDuXWSa2HAeCkEDFSqdswCZFCBoSGF5Qs3B7Gg21dqsLekW4
	9S+MDiJMndvrqoMnpISGQzABGToQ91+lIPYpeHd/Rf4SQ934SaEJpy/wPOYEO+P+7H5bWK4ZfTd
	hdOnFkQ99x8fyWeQERepha1K2DAaEz/RUqI/quqf7aiacdDAu6/V1LyKkVh2C+fW4e14LY9OlA/
	rBV0lXijMqLuvPTFogoKIE9T9AZKu8oKA=
X-Received: by 2002:a05:6808:1586:b0:3e0:379f:b261 with SMTP id 5614622812f47-3e071b00654mr2428281b6e.46.1726170059216;
        Thu, 12 Sep 2024 12:40:59 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFm4yxuuPvog3tQMct/qizHRaVqpMtfgufYQhLPGbitRFa+S/w/d26NEjPQZ7mmwjvcP+XT++OojSW+Aor6Fgk=
X-Received: by 2002:a05:6808:1586:b0:3e0:379f:b261 with SMTP id
 5614622812f47-3e071b00654mr2428273b6e.46.1726170058860; Thu, 12 Sep 2024
 12:40:58 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
 <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com> <CAHJKXw1Xc7fabs=JOjgcuh8vTwkVMRvN2Mx9UO3Dfm8iZxxZ-w@mail.gmail.com>
 <CALjSBEu7FA7Fv87P51vkiL98jRG42R3rkf2RUuxTEjHoQHMwdA@mail.gmail.com> <CAFe+wq0NPWHwon2QWdfJ8BkzVzUnSfOzLQGxXNykUW6jzyDiuw@mail.gmail.com>
In-Reply-To: <CAFe+wq0NPWHwon2QWdfJ8BkzVzUnSfOzLQGxXNykUW6jzyDiuw@mail.gmail.com>
From: Ming Hung Tsai <mtsai@redhat.com>
Date: Fri, 13 Sep 2024 03:40:48 +0800
Message-ID: <CALjSBEtiPbHVsyJnQDFzk-zwk843-8a7D75_s3yBBnjpZDgphw@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Cc: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>, lvm-devel@lists.linux.dev
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Sep 11, 2024 at 12:05=E2=80=AFAM Lakshmi Narasimhan Sundararajan
<lsundararajan@purestorage.com> wrote:
>
> Hi Ming,
> Thanks for reaching out.
>
> It looks like at the moment, writes, reads and discards are in the
> mix, with block sizes varying from 16K-128K on a thin pool with chunk
> size 64K, pool capacity many TB.
> multiple thin lvols in the pool(200G), and all of them are busy processin=
g IOs.
> This is on a VM, and storage disks are from iscsi SAN, mpath, md array
> acting as lvm pv,  over which a thin pools gets formed.

Does the thin-pool run inside or outside the VM?  and how do the thin
lvols receive IO?
Do those thin lvols receive IOs from nested hypervisors?

> And while in this setup, and IOs in progress, power cycle tests are
> attempted and after recovering end up with data loss.

Do you perform power cycle tests on the host running thin-pool, or the
hosts generating IO workloads?
Could you please explain how you identified the data loss, given there
might be async IO operations?

> Our internal study is still evolving at the moment, I will share more
> as I find more.
> Switching to latest fedora 40 is a challenge for me, whats the next
> distro you may have in mind? Maybe list a few so I can pick whats
> easier my end.
>
> Regards
>
> On Tue, Sep 10, 2024 at 9:23=E2=80=AFPM Ming Hung Tsai <mtsai@redhat.com>=
 wrote:
> >
> > On Mon, Sep 9, 2024 at 10:53=E2=80=AFPM Lakshmi Narasimhan Sundararajan
> > <lns.myspace@gmail.com> wrote:
> > >
> > > On Mon, Sep 9, 2024 at 6:57=E2=80=AFPM Zdenek Kabelac <zdenek.kabelac=
@gmail.com> wrote:
> > > >
> > > > Dne 08. 09. 24 v 3:37 Lakshmi Narasimhan Sundararajan napsal(a):
> > > > > Hi Team,
> > > > > Greetings!
> > > > >
> > > > > In my experiments with thin pool and power cycle tests, I find th=
at
> > > > > the inflight data has not been persisted, even if there is a sync
> > > > > following write that got completed.
> > > > >
> > > > > suppose we have the following bdev stackup:
> > > > > bdevs(multi) -> mpath -> lvm pv -> lvm vg -> lvm thin pool -> mul=
tiple
> > > > > thin vols.
> > > > >
> > > > > Each of the thin vols that has inflight data, has a corresponding=
 sync
> > > > > checkpoint periodically. The expectation is all writes before the=
 sync
> > > > > are persisted to disk and can survive power reset tests.
> > > > >
> > > > > Like below seq on many thin vols on the thin pool.
> > > > > write -> write -> write -> fsync(fd) -> write -> write -> fsync(f=
d) -> ..etc
> > > > >
> > > > > Now my code only does a fsync(fd) on the thin volume (block devic=
e directly).
> > > > > There are no fs mounts on the volume.
> > > > > Is this sufficient or should the thin pool (/dev/mapper/pool) als=
o be
> > > > > synced along?
> > > > > What would be the proper sequence of sync actions to survive a po=
wer reset?
> > > > >
> > > > > I am also trying to validate if this is an issue because mpath is
> > > > > involved in any way(another dm layer in between), but would appre=
ciate
> > > > > some guidance in this
> > > > > regard.
> > > >
> > > > Hi
> > > >
> > > > Could you please retest your issue with  recent lvm2  (>=3D 2.03.24=
) and recent
> > > > linux kernel   >=3D 6.9
> > >
> > > Thank you for your quick attention.
> > >
> > > That is a big jump.
> > > Would you be willing to consider any distro (say OCP latest?), that
> > > will come with a bundle for both lvm+kernel, is there any such
> > > combination you would consider for this test?
> > > Also, is there any way I can check issues/fixes of interest?
> > >
> > > Is my logic using fsync(thin pool device) sufficient to pass power fa=
il tests?
> > > Are there any stronger versions or more logic to ensure power reset t=
est passes?
> > >
> > > Regards
> > >
> > > >
> > > > Regards
> > > >
> > > > Zdenek
> > > >
> > >
> >
> > Hi,
> >
> > Could you please provide more details on the steps you took that led
> > to the issue?
> > Additionally, if possible, it would be helpful to let us know if the
> > issue is reproducible on Fedora 40, with or without the mpath layer.
> >
> >
> > Thanks,
> > Ming-Hung Tsai
> >
> >
>

