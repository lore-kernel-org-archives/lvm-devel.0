Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECBB6156F3C
	for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 10:20:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726654862; cv=none; b=uVfDvWSc4Aw2eK7CoPP87OyWkD9Z65DeV8L6Lr/N886QEowsr2Ru6bw7bsHhaE1gbWcs83H2Hin1cij9NW0roYlObdDDEs/7ieo0NpEfDWOwzEKfKYb+h8I1qohnewBG90q3rJZUjn5/3OBYJYtenBr1CSehYqp/WfHjFwX7FTY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726654862; c=relaxed/simple;
	bh=CjE15MNlXifSkXzJySNKkJ5bfyNwoaWW9c2B/44V+uY=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=ekXcTUtFbC0qUu5C7Wr2IMotsquJBF0Y3sh5x0mpYR27egkHHfaRpn60Em7aT+7JTdC0KbpV0UuVbHkT/UEofMbc9LgbDbFBooineuRQ+CDEhWDgrxPgVe1Kbo64HAIAYqt9q0/EJVNXm6vg2ArcrqC3jTQx8VGBl9yexZJd0ZQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=JPWKr0Im; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JPWKr0Im"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1726654858;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=p0euKP5Pxg5JkpkYBgbGKNPVrVd6LsjiK3lyWgLje74=;
	b=JPWKr0ImFn96vMsOZJgPOFhRvLT/DsRw46bXidXZaMilsIoiH/UJMOUtAcmwTYvL5kb9n2
	dECFQNGt3f1KLWEGlEL5xqgVjs+nQRmhkzNOoIuVenUVXyYkPhVh7lW397WRsIq6nO2sBE
	99tP3uIAhFFiz2o/FbL4Lkx9NYZWtF8=
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com
 [209.85.167.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-369-TEycbwKePteEJnFbfqTRrA-1; Wed, 18 Sep 2024 06:20:57 -0400
X-MC-Unique: TEycbwKePteEJnFbfqTRrA-1
Received: by mail-oi1-f200.google.com with SMTP id 5614622812f47-3e0501d96d4so5328780b6e.0
        for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 03:20:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726654857; x=1727259657;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=p0euKP5Pxg5JkpkYBgbGKNPVrVd6LsjiK3lyWgLje74=;
        b=qQLb2/dpwJ7QwdePMX24z3Go1zHy7xtNT4iKAL7txIXZ4gh5gdJ7rfb54IzVwWLKFY
         VtBvA3+Jv4XOPbpFkjdGWPNEYc0tMgm2CMRjCZ69Ahld5Y/ob3oOIeM/fQ75ZPo4yo11
         2HpFIxaBdFcuIjAEZlHnTwC6G/osa5V1ZcWyT3a9UcgoGAFs0rnNiDhgJevq9CUTkv68
         oSFAhLvt3aLhg7LxuW7blapLNJ22Y2lHxUqbopd2yG2IWU1MvLMJRK8b7ZLj4yc23mRB
         oYXqOZH56JAdivsC7PWXWMUndYaVDLyOTezsz3IAH3sq3cyMeJvYLY8ScGQpSfvqhHUn
         5NUQ==
X-Forwarded-Encrypted: i=1; AJvYcCVrWaNxqDWTYh9dU12sATjblAUpWkeadeCYtIFa+ygsB19jPivp2B4C1jKPuoJhryLNDmDoY6sgBI4=@lists.linux.dev
X-Gm-Message-State: AOJu0Yz/cKKTf6i2gaZXfMgo3mX1CJdSvqJQiErsVoVerzfVV4gz72/f
	VXJKwFMgN06nFjJMmiLk795ZOFbRQOk3vdekHZBD0gXErAjYTTjpU5TxED3JGnpf11Ym2ZvXFKS
	YWBicSvNgq+NpaGx+eo8Xq45r8MwdJ5nh4WJ8L/afCYBzxo6Q+sb2Bfm9MWN5bu4JVio9wf6jpb
	p0x4KQU/altwcByTF32ZMYAc2KBrvu458=
X-Received: by 2002:a05:6808:13d2:b0:3e0:4057:6dec with SMTP id 5614622812f47-3e071a85216mr12278574b6e.2.1726654856743;
        Wed, 18 Sep 2024 03:20:56 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IGKHN71ltcT9rBAya8Mf9dKratNUzsBK3LQpi6NQLMGOvwJYdb5An4dX95QiPyuryONmm25eyr+QeOFaqTXmmM=
X-Received: by 2002:a05:6808:13d2:b0:3e0:4057:6dec with SMTP id
 5614622812f47-3e071a85216mr12278569b6e.2.1726654856461; Wed, 18 Sep 2024
 03:20:56 -0700 (PDT)
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
In-Reply-To: <CAHJKXw2jCEGFsb+EveUwJ0J-PGJP1OKuGAg6LkdYgBs4xJYsEQ@mail.gmail.com>
From: Ming Hung Tsai <mtsai@redhat.com>
Date: Wed, 18 Sep 2024 18:20:45 +0800
Message-ID: <CALjSBEvZ_5FU90D8ZaM9QjjPBvDPvgDKr+baTd3qSMyDOUyxhg@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Cc: Tony Asleson <tasleson@redhat.com>, Zdenek Kabelac <zdenek.kabelac@gmail.com>, 
	Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>, lvm-devel@lists.linux.dev
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Lakshimi,

I'm glad to hear you've resolved the issue. If you're comfortable
sharing, would you mind providing some insights into the root cause?


On Wed, Sep 18, 2024 at 1:03=E2=80=AFAM Lakshmi Narasimhan Sundararajan
<lns.myspace@gmail.com> wrote:
>
> On Fri, Sep 13, 2024 at 7:49=E2=80=AFPM Tony Asleson <tasleson@redhat.com=
> wrote:
> >
> > You may want to check out https://lwn.net/Articles/457667/
> >
> > On Fri, Sep 13, 2024 at 9:06=E2=80=AFAM Zdenek Kabelac <zdenek.kabelac@=
gmail.com> wrote:
> > >
> > > Dne 13. 09. 24 v 7:55 Lakshmi Narasimhan Sundararajan napsal(a):
> > > > Hi Ming,
> > > > I am still collecting results, so I will present findings that are
> > > > confirmed so far.
> > > > There is some good news too.
> > > >
> > > > On Fri, Sep 13, 2024 at 1:11=E2=80=AFAM Ming Hung Tsai <mtsai@redha=
t.com> wrote:
> > > >>
> > > >> Hi,
> > > >>
> > > >> On Wed, Sep 11, 2024 at 12:05=E2=80=AFAM Lakshmi Narasimhan Sundar=
arajan
> > > >> <lsundararajan@purestorage.com> wrote:
> > >
> > > > My application that is consuming the thin device pumps IO traffic
> > > > directly on the raw block device.
> > > > My application also keeps a journal record outside the thin pool an=
d
> > > > after power recycled, reading the data back
> > > > did not guarantee sync consistency.
> > > >
> > > > I wrote a sample program that is trying to recreate this outside my=
 application.
> > > > here it is: sulakshm/iotest: iotest (github.com)
> > > > I am still refining it, as I have not seen the problem with this to=
ol yet.
> > > > But the logic is similar to how my application consumes thin dev; a=
nd
> > > > my app can reproduce this very easily.
> > > >
> > > > As I said before, I am still collecting additional information from
> > > > many internal tests.
> > > > So far, I can see this problem even in 6.5 kernel.
> > > >
> > > > The latest distro/linux kernel where this problem is seen.
> > > >> 6.5.0-15-generic #15~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan 12=
 18:54:30 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
> > > >
> > > >
> > > > There is a workaround to this problem that is looking promising, te=
sts
> > > > ongoing still.
> > > >
> > > > The sync point from my application is a sync(fd) of the thin dev.
> > > > This has proven insufficient.
> > > > In addition, I had to perform "dmsetup suspend pool -> dmsetup resu=
me pool".
> > > > This guarantees sync point consistency.
> > > >
> > >
> > > Hi
> > >
> > > Not exactly sure what your app is all exactly doing - however there i=
s
> > > cut&paste from 'fsync()'  manpage:
> > >
> > > ---
> > > Calling fsync() does not necessarily ensure that the entry in the dir=
ectory
> > > containing the file has also  reached  disk.   For  that  an  explici=
t
> > > fsync() on a file descriptor for the directory is also needed.
> > > ---
> > >
> > > For this purpose our 'test suite' app basically  'opens' whole device=
 and
> > > fsync and close it - to ensure synchronization point flush.
> > >
> > > Thus 'suspend & resume' of the whole thin device could be possibly un=
necessary
> > > - just do a fsync() on blockdevice fd.
> > >
> > >
> > > You can also play fun games with 'fsfreeze' operation.
>
>
> Good day all!
>
> This issue has been rootcaused successfully to an issue with my applicati=
on.
> It had been a tough last week given the nature of the issue, and
> thanks for everyone who reached out with helpful suggestions.
> As part of this process and bug verification, I would gladly submit
> that the thin pool implementation did withstand the power cycle tests
> wonderfully.
>
> Best regards and you all have a wonderful day.
>
>
> > >
> > > Regards
> > >
> > > Zdenek
> > >
> > >
> > >
> >
>

